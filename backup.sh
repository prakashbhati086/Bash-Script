#!/bin/bash
SOURCE_DIR="/home/bhati/source"
DEST_DIR="/home/bhati/backup"
ARCHIVE_DIR="/home/bhati/archive"
LOG_FILE="/var/log/backup.log"

mkdir -p $(dirname "$LOG_FILE") #log

#log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE" #log messages
}

perform_backup() {
    mkdir -p "$DEST_DIR"
    rsync -avh --delete "$SOURCE_DIR" "$DEST_DIR" >> "$LOG_FILE" 2>&1 # Perform backup using rsync
    if [ $? -ne 0 ]; then
        log_message "Backup failed during rsync."
        exit 1
    fi
    log_message "Rsync completed successfully."

    mkdir -p "$ARCHIVE_DIR"
    ARCHIVE_NAME="backup_$(date '+%Y%m%d_%H%M%S').tar.gz"
    tar -czvf "$ARCHIVE_DIR/$ARCHIVE_NAME" "$DEST_DIR" >> "$LOG_FILE" 2>&1
    if [ $? -ne 0 ]; then
        log_message "Backup failed during archiving."
        exit 1
    fi
    log_message "Archive created: $ARCHIVE_NAME"
}
perform_backup
