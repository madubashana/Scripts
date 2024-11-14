#!/bin/bash

# Define file paths and variables
INCIDENT_FILE="incidents.csv"
LOG_FILE="incident_management.log"
ESCALATION_THRESHOLD=60 # Time in minutes for escalation
CURRENT_TIME=$(date +%s)

# Function to auto-assign incidents based on type
auto_assign() {
    while IFS=, read -r incident_id incident_type assigned_to logged_time status
    do
        # Skip the header line
        [[ "$incident_id" == "incident_id" ]] && continue

        if [[ "$assigned_to" == "Unassigned" ]]; then
            case "$incident_type" in
                "Network Issue")
                    assigned_to="Network Team"
                    ;;
                "Database Issue")
                    assigned_to="Database Team"
                    ;;
                "Application Issue")
                    assigned_to="Application Support Team"
                    ;;
                *)
                    assigned_to="General Support Team"
                    ;;
            esac
            echo "Auto-assigning Incident $incident_id to $assigned_to"
            echo "$incident_id,$incident_type,$assigned_to,$logged_time,$status" >> "$LOG_FILE"
        fi
    done < "$INCIDENT_FILE"
}

# Function to auto-escalate incidents based on time elapsed
auto_escalate() {
    while IFS=, read -r incident_id incident_type assigned_to logged_time status
    do
        # Skip the header line
        [[ "$incident_id" == "incident_id" ]] && continue

        # Calculate time elapsed since the incident was logged
        logged_timestamp=$(date -d "$logged_time" +%s)
        time_elapsed=$(( (CURRENT_TIME - logged_timestamp) / 60 ))

        # Check if the incident needs escalation
        if [[ "$status" == "Open" && $time_elapsed -ge $ESCALATION_THRESHOLD ]]; then
            echo "Escalating Incident $incident_id assigned to $assigned_to"
            echo "Incident $incident_id has been escalated due to delay." | mail -s "Incident Escalation Alert" support_manager@example.com
            echo "$incident_id,$incident_type,$assigned_to,$logged_time,Escalated" >> "$LOG_FILE"
        fi
    done < "$INCIDENT_FILE"
}

# Main execution
echo "Starting Incident Management Automation Script..."
auto_assign
auto_escalate
echo "Incident Management Automation Script completed."
