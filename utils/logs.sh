LOG_FILE="server.logs"
echo 'imported log.sh' >> $LOG_FILE
log() {
    printf '%s\n' "$*" >> $LOG_FILE
}
