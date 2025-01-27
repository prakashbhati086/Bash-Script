#!/bin/bash
CPU_THRESHOLD=80            
DISK_THRESHOLD=90          
MEMORY_THRESHOLD=80        
LOG_FILE="/var/log/server_monitor.log"
ALERT_EMAIL="bhatiprakash086@gmail.com"
MAIL_COMMAND=$(command -v mailx || command -v sendmail)

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

check_cpu() {
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
    CPU_INT=${CPU_USAGE%.*} 
    if [ "$CPU_INT" -gt "$CPU_THRESHOLD" ]; then
        send_alert "High CPU Usage" "CPU usage is at ${CPU_USAGE}%"
    fi
    log_message "CPU usage: ${CPU_USAGE}%"
}

check_disk() {
    while IFS= read -r line; do
        USAGE=$(echo "$line" | awk '{print $5}' | sed 's/%//')
        MOUNT=$(echo "$line" | awk '{print $6}')
        if [ "$USAGE" -gt "$DISK_THRESHOLD" ]; then
            send_alert "High Disk Usage" "Disk usage is at ${USAGE}% on mount point $MOUNT"
        fi
        log_message "Disk usage on $MOUNT: ${USAGE}%"
    done < <(df -h --output=pcent,target | tail -n +2)
}

check_memory() {
    MEM_USAGE=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100}')
    if [ "$MEM_USAGE" -gt "$MEMORY_THRESHOLD" ]; then
        send_alert "High Memory Usage" "Memory usage is at ${MEM_USAGE}%"
    fi
    log_message "Memory usage: ${MEM_USAGE}%"
}

send_alert() {
    SUBJECT="$1"
    MESSAGE="$2"
    if [ -x "$MAIL_COMMAND" ]; then
        echo "$MESSAGE" | $MAIL_COMMAND -s "$SUBJECT" "$ALERT_EMAIL"
        log_message "Alert sent: $SUBJECT"
    else
        log_message "Mail command not found. Unable to send alert: $SUBJECT"
    fi
}

monitor() {
    log_message "Starting server monitoring..."
    check_cpu
    check_disk
    check_memory
    log_message "Monitoring completed."
}

monitor
