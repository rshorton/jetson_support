#!/bin/bash

IMAGE_NAME=elsabot_l4t
SUPPORT_ARM=n

NO_CACHE_ARG=""
while getopts ":hnac:" option; do
   case $option in
      h) # display Help
         echo "Syntax: -n  New image"
         exit
         ;;
      n) # New image
         NO_CACHE_ARG="--no-cache"
         ;;
     \?) # Invalid option
         echo "Error: Invalid option"
         exit
         ;;
   esac
done

# Change to the directory where this script is and the Docker file
THIS_SCRIPT=$(readlink -e "$0")
SCRIPT_DIR=$(dirname "$THIS_SCRIPT")
cd $SCRIPT_DIR

BASE_IMAGE="nvcr.io/nvidia/l4t-jetpack:r36.4.0"

docker build $NO_CACHE_ARG \
   --build-arg USERNAME=${USER} \
   --build-arg SUPPORT_ARM=${SUPPORT_ARM} \
   --build-arg BASE_IMAGE=${BASE_IMAGE} \
   -t ${IMAGE_NAME} \
   . \
   2>&1 | tee build.log
