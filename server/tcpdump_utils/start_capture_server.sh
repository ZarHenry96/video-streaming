#!/bin/bash

# Start tcpdump in background in order to capture the video streaming traffic outgoing from the server
tcpdump -U -s0 -i server-eth0 src port 1935 -w shared/server_out.pcap &
