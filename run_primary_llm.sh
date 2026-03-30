#!/bin/bash

# Run vllm and serve the primary model used for chat and reasoning.
# Access using localhost:8000

QWEN35_35B=1
QWEN35_9B=2
NEMO3_NANO_30B=3
QWEN3_30B=4
MINISTRAL_3_REASONING_14B=5

MODEL=5

sudo sysctl -w vm.drop_caches=3

if [ $MODEL == $QWEN35_35B ]; then
  # Max context size: 262144
  CONTEXT_SIZE=65536
  # disable vlm via --language-model-only option

  sudo docker run -it --rm --runtime=nvidia --network host \
    -e HF_TOKEN=$HF_TOKEN \
    -v $HOME/dev/torch_compile_cache:/root/.cache/vllm/torch_compile_cache \
    -v $HOME/dev/jetson-containers/data/models/huggingface:/data/models/huggingface \
    ghcr.io/nvidia-ai-iot/vllm:latest-jetson-orin \
    vllm serve Kbenkhaled/Qwen3.5-35B-A3B-quantized.w4a16 \
    --port 8000 \
    --gpu-memory-utilization 0.6 \
    --enable-prefix-caching \
    --reasoning-parser qwen3 \
    --enable-auto-tool-choice \
    --tool-call-parser qwen3_coder \
    --max-model-len ${CONTEXT_SIZE} \
    --language-model-only

elif [ $MODEL == $QWEN35_9B ]; then
  # Max context size: 262144
  CONTEXT_SIZE=65536
  # disable vlm via --language-model-only option

  sudo docker run -it --rm --runtime=nvidia --network host \
    -e HF_TOKEN=$HF_TOKEN \
    -v $HOME/dev/torch_compile_cache:/root/.cache/vllm/torch_compile_cache \
    -v $HOME/dev/jetson-containers/data/models/huggingface:/data/models/huggingface \
    ghcr.io/nvidia-ai-iot/vllm:latest-jetson-orin \
    vllm serve apolo13x/Qwen3.5-9B-quantized.w4a16 \
    --port 8000 \
    --gpu-memory-utilization 0.5 \
    --enable-prefix-caching \
    --reasoning-parser qwen3 \
    --enable-auto-tool-choice \
    --tool-call-parser qwen3_coder \
    --max-model-len ${CONTEXT_SIZE} \
    --language-model-only

elif [ $MODEL == $NEMO3_NANO_30B ]; then
  # Max context size: 262144
  CONTEXT_SIZE=65536

  sudo docker run -it --rm --runtime=nvidia --network host \
    -e HF_TOKEN=$HF_TOKEN \
    -v $HOME/dev/torch_compile_cache:/root/.cache/vllm/torch_compile_cache \
    -v $HOME/dev/jetson-containers/data/models/huggingface:/data/models/huggingface \
    -e VLLM_USE_FLASHINFER_MOE_FP4=1 \
    -e VLLM_FLASHINFER_MOE_BACKEND=throughput \
    ghcr.io/nvidia-ai-iot/vllm:latest-jetson-orin \
    bash -c "wget -q -O /tmp/nano_v3_reasoning_parser.py \
    --header=\"Authorization: Bearer \$HF_TOKEN\" \
    https://huggingface.co/nvidia/NVIDIA-Nemotron-3-Nano-30B-A3B-NVFP4/resolve/main/nano_v3_reasoning_parser.py && \
    vllm serve stelterlab/NVIDIA-Nemotron-3-Nano-30B-A3B-AWQ \
    --port 8000 \
    --gpu-memory-utilization 0.4 \
    --trust-remote-code \
    --enable-auto-tool-choice \
    --tool-call-parser qwen3_coder \
    --reasoning-parser-plugin /tmp/nano_v3_reasoning_parser.py \
    --reasoning-parser nano_v3 \
    --max-model-len ${CONTEXT_SIZE} \
    --kv-cache-dtype fp8"

elif [ $MODEL == $QWEN3_30B ]; then
  # Max context size: 40960

  sudo docker run -it --rm --runtime=nvidia --network host \
    -e HF_TOKEN=$HF_TOKEN \
    -v $HOME/dev/torch_compile_cache:/root/.cache/vllm/torch_compile_cache \
    -v $HOME/dev/jetson-containers/data/models/huggingface:/data/models/huggingface \
    ghcr.io/nvidia-ai-iot/vllm:latest-jetson-orin \
    vllm serve RedHatAI/Qwen3-30B-A3B-quantized.w4a16 \
    --port 8000 \
    --gpu-memory-utilization 0.5 \
    --enable-prefix-caching \
    --reasoning-parser qwen3 \
    --enable-auto-tool-choice \
    --tool-call-parser qwen3_coder

elif [ $MODEL == $MINISTRAL_3_REASONING_14B ]; then
  sudo docker run -it --rm --runtime=nvidia --network host \
    -e HF_TOKEN=$HF_TOKEN \
    -v $HOME/dev/torch_compile_cache:/root/.cache/vllm/torch_compile_cache \
    -v $HOME/dev/jetson-containers/data/models/huggingface:/data/models/huggingface \
    ghcr.io/nvidia-ai-iot/vllm:latest-jetson-orin \
    vllm serve mistralai/Ministral-3-14B-Reasoning-2512 \
    --port 8000 \
    --gpu-memory-utilization 0.5 \
    --tokenizer_mode mistral \
    --config_format mistral \
    --load_format mistral \
    --enable-auto-tool-choice \
    --tool-call-parser mistral \
    --reasoning-parser mistral

else
  echo "Invalid model selection: $MODEL"
fi