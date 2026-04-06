#!/bin/bash

# Run vllm/llama_cpp and serve the primary model used for chat and reasoning.
# Access using localhost:8000

QWEN35_35B=1
QWEN35_9B=2
QWEN35_4B=3
QWEN35_08B=4
NEMO3_NANO_30B=5
QWEN3_30B=6
MINISTRAL_3_REASONING_8B=7
GLM_47_FLASH=8
GEMMA_4_26B=9
GEMMA_4_E4B=10
GEMMA_4_E2B=11
GLM47_FLASH_GGUF=12
LLAMA2_7B_GGUF=13

MODEL=$LLAMA2_7B_GGUF

sudo sysctl -w vm.drop_caches=3

COMMON_ARGS="-e HF_TOKEN=$HF_TOKEN \
    -v $HOME/dev/torch_compile_cache:/root/.cache/vllm/torch_compile_cache \
    -v $HOME/dev/jetson-containers/data/models/huggingface:/data/models/huggingface"


if [ $MODEL == $QWEN35_35B ]; then
  # Max context size: 262144
  CONTEXT_SIZE=65536
  # disable vlm via --language-model-only option

  sudo docker run -it --rm --runtime=nvidia --network host \
    $COMMON_ARGS \
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

elif [ $MODEL == $QWEN35_4B ]; then
  # Max context size: 262144
  #CONTEXT_SIZE=65536
  # disable vlm via --language-model-only option

  sudo docker run -it --rm --runtime=nvidia --network host \
    -e HF_TOKEN=$HF_TOKEN \
    -v $HOME/dev/torch_compile_cache:/root/.cache/vllm/torch_compile_cache \
    -v $HOME/dev/jetson-containers/data/models/huggingface:/data/models/huggingface \
    ghcr.io/nvidia-ai-iot/vllm:latest-jetson-orin \
    vllm serve cyankiwi/Qwen3.5-4B-AWQ-4bit \
    --port 8000 \
    --gpu-memory-utilization 0.3 \
    --enable-prefix-caching \
    --reasoning-parser qwen3 \
    --enable-auto-tool-choice \
    --tool-call-parser qwen3_coder \
    --language-model-only

elif [ $MODEL == $QWEN35_08B ]; then
  # Max context size: 262144
  #CONTEXT_SIZE=65536
  # disable vlm via --language-model-only option

  sudo docker run -it --rm --runtime=nvidia --network host \
    -e HF_TOKEN=$HF_TOKEN \
    -v $HOME/dev/torch_compile_cache:/root/.cache/vllm/torch_compile_cache \
    -v $HOME/dev/jetson-containers/data/models/huggingface:/data/models/huggingface \
    ghcr.io/nvidia-ai-iot/vllm:latest-jetson-orin \
    vllm serve Qwen/Qwen3.5-0.8B \
    --port 8000 \
    --gpu-memory-utilization 0.3 \
    --enable-prefix-caching \
    --reasoning-parser qwen3 \
    --enable-auto-tool-choice \
    --tool-call-parser qwen3_coder \
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

elif [ $MODEL == $MINISTRAL_3_REASONING_8B ]; then
  CONTEXT_SIZE=65536

# This model does not currently work with Openclaw (nor hermes) (as of 3/28/26) since the ministral model
# needs tool call IDs to adhere to strict9 format.  The result is the toolcall being included in the
# text response back to openclaw.

# It does work with Pydantic AI.
# Does not perform very well with robot movement test scenario.

  sudo docker run -it --rm --runtime=nvidia --network host \
    -e HF_TOKEN=$HF_TOKEN \
    -v $HOME/dev/torch_compile_cache:/root/.cache/vllm/torch_compile_cache \
    -v $HOME/dev/jetson-containers/data/models/huggingface:/data/models/huggingface \
    -v $(pwd)/jetson_support:/jetson_support \
    ghcr.io/nvidia-ai-iot/vllm:latest-jetson-orin \
    vllm serve mistralai/Ministral-3-8B-Reasoning-2512 \
    --port 8000 \
    --gpu-memory-utilization 0.5 \
    --enable-auto-tool-choice \
    --tool-call-parser mistral \
    --reasoning-parser mistral \
    --max-model-len ${CONTEXT_SIZE} \
    --tokenizer_mode mistral \
    --config_format mistral \
    --load_format mistral 

elif [ $MODEL == $GLM_47_FLASH ]; then

# Doesn't run on latest jetson vllm (as of 4/1/26)

  sudo docker run -it --rm --runtime=nvidia --network host \
    -e HF_TOKEN=$HF_TOKEN \
    -v $HOME/dev/torch_compile_cache:/root/.cache/vllm/torch_compile_cache \
    -v $HOME/dev/jetson-containers/data/models/huggingface:/data/models/huggingface \
    ghcr.io/nvidia-ai-iot/vllm:latest-jetson-orin \
    vllm serve cyankiwi/GLM-4.7-Flash-AWQ-4bit \
    --port 8000 \
    --gpu-memory-utilization 0.6 \
    --tool-call-parser glm47 \
    --max-model-len 100001 \
    --tensor-parallel-size 4 \
    --speculative-config.method mtp \
    --speculative-config.num_speculative_tokens 1 \
    --tool-call-parser glm47 \
    --reasoning-parser glm45 \
    --enable-auto-tool-choice \
    --served-model-name glm-4.7-flash

elif [ $MODEL == $GEMMA_4_26B ]; then
  #GPU MEM 24.3G

  sudo docker run -it --rm --pull always --runtime=nvidia --network host \
    -e HF_TOKEN=$HF_TOKEN \
    -v $HOME/dev/torch_compile_cache:/root/.cache/vllm/torch_compile_cache \
    -v $HOME/dev/jetson-containers/data/models/huggingface:/data/models/huggingface \
    ghcr.io/nvidia-ai-iot/llama_cpp:gemma4-jetson-orin \
    llama-server -hf ggml-org/gemma-4-26B-A4B-it-GGUF:Q4_K_M \
    --port 8000


elif [ $MODEL == $GEMMA_4_E4B ]; then

  sudo docker run -it --rm --pull always --runtime=nvidia --network host \
    -e HF_TOKEN=$HF_TOKEN \
    -v $HOME/dev/torch_compile_cache:/root/.cache/vllm/torch_compile_cache \
    -v $HOME/dev/jetson-containers/data/models/huggingface:/data/models/huggingface \
    ghcr.io/nvidia-ai-iot/llama_cpp:gemma4-jetson-orin \
    llama-server -hf ggml-org/gemma-4-E4B-it-GGUF:Q4_K_M \
    --port 8000


elif [ $MODEL == $GEMMA_4_E2B ]; then
  
  sudo docker run -it --rm --pull always --runtime=nvidia --network host \
    -e HF_TOKEN=$HF_TOKEN \
    $COMMON_ARGS \
    ghcr.io/nvidia-ai-iot/llama_cpp:gemma4-jetson-orin \
    llama-server -hf ggml-org/gemma-4-E2B-it-GGUF:Q8_0 \
    --port 8000

elif [ $MODEL == $GLM47_FLASH_GGUF ]; then
  #GPU MEM 28.4G

  sudo docker run -it --rm --pull always --runtime=nvidia --network host \
    -e HF_TOKEN=$HF_TOKEN \
    $COMMON_ARGS \
    ghcr.io/nvidia-ai-iot/llama_cpp:gemma4-jetson-orin \
    llama-server -hf unsloth/GLM-4.7-Flash-GGUF \
    --port 8000

elif [ $MODEL == $LLAMA2_7B_GGUF ]; then

  sudo docker run -it --rm --pull always --runtime=nvidia --network host \
    -e HF_TOKEN=$HF_TOKEN \
    $COMMON_ARGS \
    ghcr.io/nvidia-ai-iot/llama_cpp:gemma4-jetson-orin \
    llama-server -hf TheBloke/Llama-2-7b-Chat-GGUF \
    --port 8000

else
  echo "Invalid model selection: $MODEL"
fi