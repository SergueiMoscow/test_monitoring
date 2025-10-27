#!/bin/bash

# Script for monitoring the 'test' process

# Load configuration
if [ -f "/etc/test_monitor.conf" ]; then
    source /etc/test_monitor.conf
else
    # Fallback to defaults
    LOG_FILE="/var/log/test_monitor.log"
    PID_FILE="/var/run/test_monitor.pid"
    MONITORING_URL="https://notes.sushkovs.ru"
fi

echo "--- Script started at $(date '+%Y-%m-%d %H:%M:%S') ---"
echo "Running as user $(whoami). Log file: $LOG_FILE"

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

CURRENT_PID=$(pgrep -x "test" | head -n 1)

if [ -z "$CURRENT_PID" ]; then
    echo "Process 'test' not found. Exiting."
    exit 0
fi

echo "Process 'test' found with PID: $CURRENT_PID"

if [ -f "$PID_FILE" ]; then
    PREVIOUS_PID=$(cat "$PID_FILE")
    
    if [ -z "$PREVIOUS_PID" ]; then
        log_message "Process 'test' started (Initial PID: $CURRENT_PID) - PID file was empty."
        
    elif [ "$CURRENT_PID" != "$PREVIOUS_PID" ]; then
        log_message "Process 'test' RESTARTED (Old PID: $PREVIOUS_PID, New PID: $CURRENT_PID)"
    fi
else
    log_message "Process 'test' started (Initial PID: $CURRENT_PID) - PID file did not exist."
fi

echo "Updating PID file ($PID_FILE) with PID $CURRENT_PID"
echo "$CURRENT_PID" > "$PID_FILE"

if ! curl -s -f "$MONITORING_URL" > /dev/null; then
    log_message "Monitoring server unavailable ($MONITORING_URL)"
fi