#!/bin/bash

# Function to print usage on terminal
function usage {
    echo "Usage: ./stream_video.sh [-i video] [-o] [-d]"
    echo "    -i video = input video filepath, with default value 'videos/big_buck_bunny_720p_5mb.mp4'"
    echo "    -o = stream the video once, without looping on it (the default behaviour is an infinite loop)"
    echo "    -d = disable the capture of the video stream outgoing packets through tcpdump (the capture is
                   enabled by default, with output file 'shared/server_out.pcap')"
}

# Parse the script arguments
video="videos/big_buck_bunny_720p_5mb.mp4"
loops_number=-1
capture_traffic="true"
while getopts 'i:odh' OPTION; do
    case "$OPTION" in
        i)
            video="${OPTARG}"
            ;;
        o)
            loops_number=0
            ;;
        d)
            capture_traffic="false"
            ;;
        h)
            usage
            exit 0
            ;;
        *)
            usage
            exit 0
            ;;
    esac
done
shift "$((OPTIND -1))"

# Start tcpdump capture, if required
if [ ${capture_traffic} == "true" ]; then
    ./tcpdump_utils/start_capture_server.sh
    sleep 2
fi

# Stream the specified video
ffmpeg -re -stream_loop "${loops_number}" -i "${video}" -c:v copy -c:a aac -ar 44100 -ac 1 \
       -f flv rtmp://localhost:1935/live/video.flv

# Stop tcpdump capture, if required
if [ ${capture_traffic} == "true" ]; then
    ./tcpdump_utils/stop_capture.sh
    sleep 3
fi
