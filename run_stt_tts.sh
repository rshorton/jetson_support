#!/bin/bash

trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT

echo "Starting STT/TTS processes"

echo "STT..."
cd ${WS_DIR}/src/elsabot_speech_input/elsabot_speech_input
python -m server.main 2>&1 | tee ${WS_DIR}/jetson_support/sst.log &

echo "TTS..."

cd ${WS_DIR}/jetson_support
python3 -m piper.http_server -m en_US-amy-medium --cuda 2>&1 | tee ${WS_DIR}/jetson_support/tts.log &

echo "Cntrl-c to exit"
wait

