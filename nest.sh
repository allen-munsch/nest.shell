#!/bin/bash

# Configuration
PORT=${PORT:-8080}
CONTENT_DIR="./content"
CACHE_DIR="./cache"
DB_FILE="./app.db"
source utils/logs.sh

# Ensure necessary directories exist
mkdir -p "$CONTENT_DIR" "$CACHE_DIR"

# Initialize SQLite database
init_db() {
    if [ ! -f "$DB_FILE" ]; then
        sqlite3 "$DB_FILE" <<EOF
CREATE TABLE IF NOT EXISTS todos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    task TEXT NOT NULL,
    completed BOOLEAN NOT NULL DEFAULT 0
);
EOF
        chmod 666 "$DB_FILE"  # Ensure the database is writable
    fi
}

# Function to include Tailwind CSS
include_tailwind() {
    echo '<script src="https://cdn.tailwindcss.com"></script>'
}

# Function to render content
render_content() {
    local route="$1"
    local content="$2"
    local dir="$CONTENT_DIR$route"
    local js=""
    log render_content:$route
    
    # If there's an index.html, use it as a template
    if [ -f "$dir/index.html" ]; then
        local template=$(cat "$dir/index.html")
        if [ -z "$content" ] || [ "$content" == "{{content}}" ]; then
            # If content is empty or just the placeholder, generate content from script.sh
            if [ -f "$dir/script.sh" ]; then
                content=$("$dir/script.sh")
            else
                content=""
            fi
        fi
        content="${template//\{\{content\}\}/$content}"
    elif [ -f "$dir/script.sh" ]; then
        # If there's no index.html but there's a script.sh, use its output as content
        content=$("$dir/script.sh")
    fi
    
    # If there's a script.js, include it
    if [ -f "$dir/script.js" ]; then
        js+="<script>$(cat "$dir/script.js")</script>"
    fi
    
    echo "<div class='widget' data-route='$route'>$content$js</div>"
}

# Recursive function to render nested content
render_nested_content() {
    local route="$1"
    local content="$2"
    log render_nested_content:$route:content:$(echo "$content" | wc -l)

    # Render current level
    content=$(render_content "$route" "$content")

    # Base case: if we're at the root, return the content
    if [ "$route" = "/" ] || [ -z "$route" ]; then
        echo "$content"
        return
    fi

    # Get the parent route and recurse
    local parent_route=$(dirname "$route")
    render_nested_content "$parent_route" "$content"
}

# Routing and view rendering
handle_route() {
    local method="$1"
    local route="$2"
    local headers="$3"
    local body="$4"
    
    # Sanitize the route to prevent path traversal
    local sanitized_route=$(echo "$route" | sed 's/\.\.//g' | sed 's/^\/*//' | sed 's/\/$//')
    local full_path="$CONTENT_DIR/$sanitized_route"
    
    log handle_route:$method:$sanitized_route
    # Check if it's an API request
    if [[ "$route" == /api/* ]]; then
        handle_api_request "$method" "$route" "$headers" "$body"
        return
    fi
    
    # If it's a directory, look for index.html
    if [ -d "$full_path" ]; then
        if [ -f "$full_path/index.html" ]; then
            render_nested_content "$route" ""
        else
            echo "404 Not Found"
        fi
    else
        echo "404 Not Found"
    fi
}

handle_api_request() {
    local method="$1"
    local route="$2"
    local headers="$3"
    local body="$4"
    local api_file="$CONTENT_DIR$route.api.sh"
    log "handle_api_request:$method:$api_file"

    if [ ! -f "$api_file" ]; then
        log "handle_api_request: MISSING $api_file"
        echo -ne "HTTP/1.1 404 Not Found\r\nContent-Type: text/plain\r\nContent-Length: 13\r\n\r\n404 Not Found"
        return
    fi

    if [ ! -x "$api_file" ]; then
        log "handle_api_request: NOT EXECUTABLE $api_file"
        chmod +x "$api_file"
    fi

    log "handle_api_request: Executing: $api_file"
    local api_response
    api_response=$(echo "$body" | DB_FILE="$DB_FILE" CONTENT_LENGTH="$CONTENT_LENGTH" LOG_FILE="$LOG_FILE" HTTP_METHOD="$method" bash "$api_file" 2>&1) || {
        local exit_code=$?
        log "handle_api_request: Error executing API file: $api_file. Exit code: $exit_code. Output: $api_response"
        echo -ne "HTTP/1.1 500 Internal Server Error\r\nContent-Type: text/plain\r\nContent-Length: 21\r\n\r\nInternal Server Error"
        return
    }

    log "API response: $api_response"
    echo -ne "$api_response"
}

# Request handler
handle_request() {
    while true; do
        read -r request_line
        [ -z "$request_line" ] && break
        local method=$(echo "$request_line" | cut -d' ' -f1)
        local route=$(echo "$request_line" | cut -d' ' -f2)
        log "handle_request:$method:$route"
        
        # Read headers
        local content_length=0
        local headers=""
        while IFS= read -r header; do
            header=$(echo "$header" | tr -d '\r\n')
            [ -z "$header" ] && break
            headers+="$header\n"
            if [[ "$header" == Content-Length:* ]]; then
                content_length=$(echo "$header" | cut -d' ' -f2)
            fi
        done
        
        # Read body if present
        local body=""
        if [ "$content_length" -gt 0 ]; then
            body=$(dd bs=1 count=$content_length 2>/dev/null)
        fi
        
        # Set CONTENT_LENGTH for API requests
        export CONTENT_LENGTH=$content_length
        
        # Handle the route
        if [[ "$route" == /api/* ]]; then
            handle_api_request "$method" "$route" "$headers" "$body"
        else
            local response_body=$(handle_route "$method" "$route" "$headers" "$body")
            
            # Include Tailwind CSS and the root index.js
            local head_content=$(include_tailwind)
            if [ -f "$CONTENT_DIR/index.js" ]; then
                head_content+="<script>$(cat "$CONTENT_DIR/index.js")</script>"
            fi
            
            response_body="<!DOCTYPE html><html><head><title>nest.shell App</title>$head_content</head><body class='bg-gray-100'>$response_body</body></html>"
            local content_length=${#response_body}
            
            echo -ne "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\nContent-Length: $content_length\r\n\r\n$response_body"
        fi
    done
}


# Main server loop using socat
start_server() {
    echo '' >| $LOG_FILE
    init_db
 
    # Use process substitution to combine tail and socat output
    exec 2>&1
    log "Server starting on http://localhost:$PORT"
    log "nest.shell server running on http://localhost:$PORT"
    log "Press Ctrl+C to stop the server"

    # Start tailing the log file and run socat in parallel
    (
        tail -f "$LOG_FILE" &
        TAIL_PID=$!
        trap "kill $TAIL_PID" EXIT
        socat TCP-LISTEN:$PORT,reuseaddr,fork EXEC:"$0 handle_connection"
    )
}

# Function to handle each connection (called by socat)
handle_connection() {
    handle_request
}

# Check if we're being called to handle a connection
if [ "$1" = "handle_connection" ]; then
    handle_connection
else
    # Start the server
    start_server
fi