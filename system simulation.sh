#!/bin/bash

DURATION=60  # Duration of each test in seconds

echo "Starting CPU stress test..."
stress --cpu 4 --timeout $DURATION

echo "Starting memory stress test..."
stress --vm 2 --vm-bytes 1G --timeout $DURATION

echo "Simulating high network load..."
iperf3 -s &  # Start iperf server
dd if=/dev/zero bs=1M count=1024 | nc -w $DURATION localhost 5201

echo "Load simulation completed."
