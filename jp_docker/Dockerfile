ARG BASE_IMAGE="please_specify"
FROM ${BASE_IMAGE}
ARG USERNAME=USERNAME
ARG USER_UID=1000
ARG USER_GID=$USER_UID

SHELL ["/bin/bash", "-c"]

# Delete user if it exists in container (e.g Ubuntu Noble: ubuntu)
RUN if id -u $USER_UID ; then userdel `id -un $USER_UID` ; fi

RUN apt-get update && apt-get upgrade -y

# Create the user
RUN groupadd --gid $USER_GID $USERNAME && \
        useradd --uid $USER_UID --gid $USER_GID -m $USERNAME && \
        usermod -aG dialout $USERNAME && \
        apt-get update && \
        apt-get install -y sudo && \
        usermod -aG sudo $USERNAME && \
        echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME && \
        chmod 0440 /etc/sudoers.d/$USERNAME

RUN apt-get install -y \
        python3-pip \
        git \
        ffmpeg \
        cmake \
        pulseaudio-utils \
        alsa-utils \
        python3-pyaudio

# Build CTranslate2 (required by faster_whister) from source for compatibility with Cuda arch of the Jetson
RUN cd /tmp && \
        git clone -b v4.7.1 https://github.com/OpenNMT/CTranslate2.git --recursive && \
        cd CTranslate2 && \
        mkdir build_folder && \
        cd build_folder && \
        cmake .. -DWITH_MKL=OFF -DOPENMP_RUNTIME=NONE -DWITH_CUDA=ON -DWITH_CUDNN=ON -DCUDA_ARCH_LIST="8.7" && \
        cmake --build . && \
        sudo make install && \
        cd ../python/ && \
        pip3 install --break-system-packages -r install_requirements.txt && \
        python3 setup.py bdist_wheel && \
        pip3 install --break-system-packages dist/*.whl --break-system-packages

RUN pip install --break-system-packages \
        faster_whisper==1.2.1 \
        piper-tts==1.4.1 \
        'flask>=3,<4' \
        onnxruntime-gpu

RUN pip install --break-system-packages \
        fastapi \
        uvicorn \
        websockets \
        httpx \
        soundfile \
        numpy-ringbuffer

# Install newer openwakeword, but avoid dependency issue with tflite-runtime by
# manually installing dependencies and omitting tflite (since only onnx runtime needed).
RUN pip install --break-system-packages \
        openwakeword==0.6.0 --no-deps

RUN pip install --break-system-packages \
        onnxruntime \
        numpy \
        tqdm \
        scipy \
        scikit-learn \
        requests

# Download the default openwakeword models which include some that are always required ('melspectrogram')
RUN python3 -c "import openwakeword; openwakeword.utils.download_models()"

# Download the whisper models
COPY dl_whisper_models.py /tmp
RUN mkdir -p /opt/whisper/models/turbo && \
    python3 /tmp/dl_whisper_models.py --model_dir /opt/whisper/models/turbo --model turbo

WORKDIR /jetson_ws
USER $USERNAME

COPY image_bashrc /home/$USERNAME/.bashrc
COPY image_bash_profile /home/$USERNAME/.bash_profile

CMD ["/bin/bash"]
