#!/bin/bash

LOG_FILE="/var/log/system_metrics.log"
CPU_THRESHOLD=80
MEMORY_THRESHOLD=75
LATENCY_THRESHOLD=100  # in milliseconds

echo "Timestamp, CPU Usage, Memory Usage, Network Latency" > $LOG_FILE

while true; do
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
    MEMORY_USAGE=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
    LATENCY=$(ping -c 1 google.com | grep 'time=' | awk -F'=' '{print $4}' | cut -d ' ' -f 1)

    echo "$(date), $CPU_USAGE%, $MEMORY_USAGE%, $LATENCY ms" >> $LOG_FILE

    if (( $(echo "$CPU_USAGE > $CPU_THRESHOLD" | bc -l) )); then
        echo "ALERT: High CPU usage detected: $CPU_USAGE%" | mail -s "High CPU Alert" user@example.com
    fi

    if (( $(echo "$MEMORY_USAGE > $MEMORY_THRESHOLD" | bc -l) )); then
        echo "ALERT: High Memory usage detected: $MEMORY_USAGE%" | mail -s "High Memory Alert" user@example.com
    fi

    if (( $(echo "$LATENCY > $LATENCY_THRESHOLD" | bc -l) )); then
        echo "ALERT: High Network Latency detected: $LATENCY ms" | mail -s "High Latency Alert" user@example.com
    fi

    sleep 60  # Check every minute
done
