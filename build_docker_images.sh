#!/bin/bash

echo "Build docker image for the video streaming server"
cp common/stop_capture.sh server/tcpdump_utils
docker build -t video_streaming_server --file ./server/Dockerfile.server ./server
rm server/tcpdump_utils/stop_capture.sh

echo "Build docker image for the video streaming client"
cp common/stop_capture.sh client/tcpdump_utils
docker build -t video_streaming_client --file ./client/Dockerfile.client ./client
rm client/tcpdump_utils/stop_capture.sh
