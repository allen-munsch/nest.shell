#!/bin/bash
source utils/logs.sh
source utils/respond.sh

log "$0: Fetching todos"

todos=$(sqlite3 "$DB_FILE" "SELECT id, task, completed FROM todos ORDER BY id DESC" -json)

log "$0: Todos fetched: $todos"

respond json "$todos"