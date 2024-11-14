#!/bin/bash

LOG_FILE="/var/log/system_metrics.log"
ARCHIVE_DIR="/var/log/metrics_archive"
RETENTION_DAYS=7

mkdir -p $ARCHIVE_DIR

# Rotate log file if it exists
if [[ -f $LOG_FILE ]]; then
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    mv $LOG_FILE $ARCHIVE_DIR/system_metrics_$TIMESTAMP.log
    echo "Timestamp, CPU Usage, Memory Usage, Network Latency" > $LOG_FILE
fi

# Delete logs older than retention period
find $ARCHIVE_DIR -type f -mtime +$RETENTION_DAYS -exec rm -f {} \;
