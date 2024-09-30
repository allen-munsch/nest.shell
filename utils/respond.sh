#!/bin/bash

# File: utils/respond.sh

# Function to send an HTTP response
respond() {
    local content_type="$1"
    local content="$2"
    local status_code="${3:-200}"
    local status_text

    case $status_code in
        200) status_text="OK" ;;
        201) status_text="Created" ;;
        204) status_text="No Content" ;;
        400) status_text="Bad Request" ;;
        401) status_text="Unauthorized" ;;
        403) status_text="Forbidden" ;;
        404) status_text="Not Found" ;;
        500) status_text="Internal Server Error" ;;
        *) status_text="Unknown" ;;
    esac

    case $content_type in
        json)
            mime_type="application/json"
            ;;
        html)
            mime_type="text/html"
            ;;
        text)
            mime_type="text/plain"
            ;;
        *)
            mime_type="application/octet-stream"
            ;;
    esac

    echo -ne "HTTP/1.1 $status_code $status_text\r\nContent-Type: $mime_type\r\nContent-Length: ${#content}\r\n\r\n$content"
}

# Example usage:
# respond json '{"success": true}' 200
# respond html '<h1>Hello, World!</h1>' 200
# respond text 'Error occurred' 500