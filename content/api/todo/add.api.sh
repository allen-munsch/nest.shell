#!/bin/bash
set -e

source utils/logs.sh
source utils/respond.sh

# Read and log the POST data
post_data=$(cat)
log "add.api.sh: Received POST data: $post_data"

# Extract the task using jq
task=$(echo "$post_data" | jq -r '.task')
log "add.api.sh: Extracted task: $task"

# Insert the task into the database
sqlite3 "$DB_FILE" "INSERT INTO todos (task) VALUES ('$task')"
log "add.api.sh: Task inserted into database"

# Prepare the response
response='{"success": true}'
log "add.api.sh: Preparing response: $response"

# Send the response
respond json "$response"
log "add.api.sh: Response sent"