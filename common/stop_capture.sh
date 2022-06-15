#!/bin/bash

# Get the PID of the tcpdump process
pid=$(ps -e | grep tcpdump | awk '{print $1}')

# Stop it
kill -2 "${pid}"
