#!/bin/bash

# Function to print usage on terminal
function usage {
    echo "Usage: ./get_streaming.sh [-o stream_output_filename] [-d]"
    echo "    -o stream_output_filename = name of the (.flv) output file without extension (the default value
                                          is 'stream_output')"
    echo "    -d = disable the capture of the video stream incoming packets through tcpdump (the capture is
                   enabled by default, with output file 'shared/client_out.pcap')"
}

# Parse the script arguments
out_file="stream_output.flv"
capture_traffic="true"
while getopts 'o:dh' OPTION; do
    case "$OPTION" in
        o)
            out_file="${OPTARG}.flv"
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
    ./tcpdump_utils/start_capture_client.sh
    sleep 2
fi

# Get the video stream and save it to the specified file
start_time=$(date +%s)
ffmpeg -i rtmp://10.0.0.1:1935/live/video.flv -probesize 80000 -analyzeduration 15 -c:a copy -c:v copy "${out_file}"
run_time=$(($(date +%s) - start_time))

# Stop tcpdump capture, if required
if [ ${capture_traffic} == "true" ]; then
    ./tcpdump_utils/stop_capture.sh
    sleep 3
fi

# Print the stream acquisition run time
printf "\n"
echo The stream acquisition run time is ${run_time}s
