#!/bin/bash

LOG_FILE="/var/log/system_metrics.log"
REPORT_FILE="/var/log/system_weekly_report.log"  # New report file for weekly summary
CPU_THRESHOLD=80
MEMORY_THRESHOLD=75
LATENCY_THRESHOLD=100  # in milliseconds

# Initialize the log and report files
echo "Timestamp, CPU Usage, Memory Usage, Network Latency" > $LOG_FILE
echo "Weekly Report - Performance Summary" > $REPORT_FILE
echo "---------------------------------------------------" >> $REPORT_FILE
echo "Week Starting: $(date)" >> $REPORT_FILE

# Function to generate weekly summary report
generate_weekly_report() {
    echo "Generating weekly report..." >> $REPORT_FILE
    echo "---------------------------------------------------" >> $REPORT_FILE
    echo "Summary of CPU, Memory, and Latency Issues for the Week:" >> $REPORT_FILE

    # Process the system log file for weekly summary
    echo "High CPU Usage Events (Above $CPU_THRESHOLD%):" >> $REPORT_FILE
    grep "CPU usage" $LOG_FILE | awk -F, '{if ($2 > '"$CPU_THRESHOLD"') print $0}' >> $REPORT_FILE

    echo "High Memory Usage Events (Above $MEMORY_THRESHOLD%):" >> $REPORT_FILE
    grep "Memory usage" $LOG_FILE | awk -F, '{if ($3 > '"$MEMORY_THRESHOLD"') print $0}' >> $REPORT_FILE

    echo "High Network Latency Events (Above $LATENCY_THRESHOLD ms):" >> $REPORT_FILE
    grep "Latency" $LOG_FILE | awk -F, '{if ($4 > '"$LATENCY_THRESHOLD"') print $0}' >> $REPORT_FILE

    echo "---------------------------------------------------" >> $REPORT_FILE
    echo "End of Week Report: $(date)" >> $REPORT_FILE
}

# Track the start time of the week
START_OF_WEEK=$(date +%s)
SECONDS_IN_WEEK=604800  # 60 * 60 * 24 * 7 = 604800 seconds (1 week)

while true; do
    # Capture the real-time metrics
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
    MEMORY_USAGE=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
    LATENCY=$(ping -c 1 google.com | grep 'time=' | awk -F'=' '{print $4}' | cut -d ' ' -f 1)

    # Log the metrics with timestamp
    echo "$(date), $CPU_USAGE%, $MEMORY_USAGE%, $LATENCY ms" >> $LOG_FILE

    # Send real-time alerts for high usage
    if (( $(echo "$CPU_USAGE > $CPU_THRESHOLD" | bc -l) )); then
        echo "ALERT: High CPU usage detected: $CPU_USAGE%" | mail -s "High CPU Alert" user@example.com
    fi

    if (( $(echo "$MEMORY_USAGE > $MEMORY_THRESHOLD" | bc -l) )); then
        echo "ALERT: High Memory usage detected: $MEMORY_USAGE%" | mail -s "High Memory Alert" user@example.com
    fi

    if (( $(echo "$LATENCY > $LATENCY_THRESHOLD" | bc -l) )); then
        echo "ALERT: High Network Latency detected: $LATENCY ms" | mail -s "High Latency Alert" user@example.com
    fi

    # Check if a week has passed, then generate the weekly report
    CURRENT_TIME=$(date +%s)
    if (( CURRENT_TIME - START_OF_WEEK >= SECONDS_IN_WEEK )); then
        generate_weekly_report  # Call function to generate report
        START_OF_WEEK=$CURRENT_TIME  # Reset start of the week
    fi

    sleep 60  # Check every minute
done
