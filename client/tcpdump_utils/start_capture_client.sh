#!/bin/bash

# Start tcpdump in background in order to capture the video streaming traffic coming from the server
tcpdump -U -s0 -i client-eth0 src port 1935 -w shared/client_out.pcap &
