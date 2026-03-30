ARG BASE_IMAGE="please_specify"
FROM ${BASE_IMAGE}
ARG USERNAME=USERNAME
ARG USER_UID=1000
ARG USER_GID=$USER_UID

SHELL ["/bin/bash", "-c"]

# Delete user if it exists in container (e.g Ubuntu Noble: ubuntu)
RUN if id -u $USER_UID ; then userdel `id -un $USER_UID` ; fi

# Create the user
RUN groupadd --gid $USER_GID $USERNAME && \
        useradd --uid $USER_UID --gid $USER_GID -m $USERNAME && \
        usermod -a -G dialout $USERNAME && \
        apt-get update && \
        apt-get install -y sudo && \
        echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME && \
        chmod 0440 /etc/sudoers.d/$USERNAME

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y \
        python3-pip \
        git \
        ffmpeg \
        cmake

# Pyaudio/sound
RUN apt-get update && apt-get install -y \
        pulseaudio-utils \
        alsa-utils \
        python3-pyaudio

# Torch and dependencies
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/arm64/cuda-keyring_1.1-1_all.deb && \
        dpkg -i cuda-keyring_1.1-1_all.deb && \
        apt-get update && \
        apt-get -y install cusparselt-cuda-12 && \
        apt-get -y install cudss && \
        apt-get install -y python3-pip libopenblas-dev libcusparselt-dev && \
        apt-get install -y cuda-cupti-12-6 && \
        python3 -m pip install torch==2.10.0 torchvision==0.25.0 --index-url=https://pypi.jetson-ai-lab.io/jp6/cu126

# Whisper        
RUN pip install openai-whisper psutil

# The following Whisper_trt support isn't building.  
# torch2trt
#ADD https://api.github.com/repos/NVIDIA-AI-IOT/torch2trt/git/refs/heads/master /tmp/torch2trt_version.json
#COPY torch2trt/install.sh torch2trt/patches/ /tmp/torch2trt/
#RUN bash /tmp/torch2trt/install.sh

#ADD https://api.github.com/repos/NVIDIA-AI-IOT/whisper_trt/git/refs/heads/main /tmp/whisper_trt_version.json

#RUN apt-get update && \
#    apt-get install -y --no-install-recommends \
#    ffmpeg \
#    && rm -rf /var/lib/apt/lists/* \
#    && apt-get clean

# whisper_trt
#RUN pip install openai-whisper && \
#    git clone https://github.com/NVIDIA-AI-IOT/whisper_trt /opt/whisper_trt && \
#    cd /opt/whisper_trt && \
#    pip install --no-build-isolation -e . && \
#    pip install onnxruntime && \
#    mkdir -p ~/.cache && \
#    ln -s /data/models/whisper ~/.cache/whisper && \
#    ln -s /data/models/whisper ~/.cache/whisper_trt

# faster whisper
RUN cd /tmp && \
    git clone -b v4.7.1 https://github.com/OpenNMT/CTranslate2.git --recursive && \
    cd CTranslate2 && \
    mkdir build_folder && \
    cd build_folder && \
    cmake .. -DWITH_MKL=OFF -DOPENMP_RUNTIME=NONE -DWITH_CUDA=ON -DWITH_CUDNN=ON && \
    cmake --build . && \
    sudo make install && \
    cd ../python/ && \
    pip3 install -r install_requirements.txt && \
    python3 setup.py bdist_wheel && \
    pip3 install dist/*.whl

RUN pip install faster_whisper==1.2.1

# Piper tts
RUN pip install piper-tts==1.4.1 && \
    pip install 'flask>=3,<4'

# OpenWakeWord
RUN pip install openwakeword
# openwakeword tflite support needs numpy 1.x
RUN pip install "numpy<2.0" 
# download the default models which include some that are always required ('melspectrogram')
RUN python3 -c "import openwakeword; openwakeword.utils.download_models()"

RUN pip install fastapi uvicorn websockets httpx soundfile

COPY dl_whisper_models.py /tmp
RUN mkdir -p /opt/whisper/models/turbo && \
    python /tmp/dl_whisper_models.py --model_dir /opt/whisper/models/turbo --model turbo

RUN pip install numpy-ringbuffer

WORKDIR /jetson_ws
USER $USERNAME

COPY image_bashrc /home/$USERNAME/.bashrc
COPY image_bash_profile /home/$USERNAME/.bash_profile

CMD ["/bin/bash"]
