#!/bin/bash
source utils/logs.sh
source utils/respond.sh

post_data=$(cat)
log $0:Received data: $post_data
id=$(echo "$post_data" | jq -r '.id')
sqlite3 "$DB_FILE" "DELETE FROM todos WHERE id = $id"
respond json '{"success": true}'
