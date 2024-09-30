#!/bin/bash
source utils/logs.sh
source utils/respond.sh
post_data=$(cat)
id=$(echo "$post_data" | jq -r '.id')
log toggle.api.sh:$post_data
sqlite3 "$DB_FILE" "UPDATE todos SET completed = NOT completed WHERE id = $id"
respond json '{"success": true}'