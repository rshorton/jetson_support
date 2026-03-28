#!/bin/bash

WS_DIR="$PWD"
echo "WS_DIR = $WS_DIR"

xhost +local:docker

WS_DIR_INSIDE="/jetson_ws"

# FIX, is privileged still needed?
docker run -it --privileged --net=host  --pid=host --ipc=host --runtime nvidia \
  -e HOST_WS_DIR=${WS_DIR} \
  -e WS_DIR=${WS_DIR_INSIDE} \
  -e DISPLAY=unix:0 \
  -v ${WS_DIR}:${WS_DIR_INSIDE} \
  -v /dev/elsabot_dev_links:/dev/elsabot_dev_links \
  -v /dev/input:/dev/input \
  -v /dev/i2c-0:/dev/i2c-0 \
  -v /dev/i2c-1:/dev/i2c-1 \
  -v /dev/i2c-2:/dev/i2c-2 \
  -v /dev/i2c-3:/dev/i2c-3 \
  -v /dev/i2c-4:/dev/i2c-4 \
  -v /dev/i2c-5:/dev/i2c-5 \
  -v /dev/i2c-6:/dev/i2c-6 \
  -v /dev/i2c-7:/dev/i2c-7 \
  -v /dev/i2c-8:/dev/i2c-8 \
  -v /dev/i2c-9:/dev/i2c-9 \
  -v /dev/i2c-10:/dev/i2c-10 \
  -v /dev/i2c-20:/dev/i2c-20 \
  -v /dev/bus/usb:/dev/bus/usb \
  --device-cgroup-rule='c 189:* rmw' \
  -v /dev/snd:/dev/snd \
  --device /dev/snd \
  -e PULSE_SERVER=unix:/run/user/1000/pulse/native -v /run/user/1000/pulse:/run/user/1000/pulse \
  -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -v $HOME/.Xauthority:$HOME/.Xauthority -e XAUTHORITY=$HOME/.Xauthority \
  elsabot_l4t \
  "$@"
  
