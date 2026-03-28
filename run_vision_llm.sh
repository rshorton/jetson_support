#!/bin/bash

# Run vllm and serve the primary model used for chat and reasoning
# Access using localhost:8001

# use the test_vlm.py script to exercise the model

sudo sysctl -w vm.drop_caches=3

sudo docker run -it --rm --runtime=nvidia --network host \
  -v $HOME/dev/torch_compile_cache:/root/.cache/vllm/torch_compile_cache \
  -v $HOME/dev/jetson-containers/data/models/huggingface:/data/models/huggingface \
  ghcr.io/nvidia-ai-iot/vllm:latest-jetson-orin  vllm serve Nvidia/Cosmos-Reason2-2B \
  --max-model-len 8192 \
  --gpu-memory-utilization 0.18 \
  --reasoning-parser qwen3 \
  --media-io-kwargs '{"video": {"num_frames": -1}}' \
  --port 8001