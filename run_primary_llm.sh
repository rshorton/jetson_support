#!/bin/bash

# Run vllm and serve the primary model used for chat and reasoning.
# Access using localhost:8000

sudo docker run -it --rm --pull always --runtime=nvidia --network host \
  -e HF_TOKEN=$HF_TOKEN \
  -v $HOME/dev/torch_compile_cache:/root/.cache/vllm/torch_compile_cache \
  -v $HOME/dev/jetson-containers/data/models/huggingface:/data/models/huggingface \
  ghcr.io/nvidia-ai-iot/vllm:latest-jetson-orin vllm serve apolo13x/Qwen3.5-9B-quantized.w4a16 \
  --gpu-memory-utilization 0.5 \
  --enable-prefix-caching \
  --reasoning-parser qwen3 \
  --enable-auto-tool-choice \
  --tool-call-parser qwen3_coder \
  --port 8000