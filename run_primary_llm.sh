#!/bin/bash

# Run vllm/llama_cpp and serve the specified model
# Access using localhost and by port 8000 unless specified otherwise

# FIX - Only the command for gemma 4 26B (VLLM) has been updated for Jetpack 7.2.1 update. 
# Update other models as needed.

PORT=8000

QWEN35_35B=1
QWEN35_9B=2
QWEN35_4B=3
QWEN35_08B=4
NEMO3_NANO_30B=5
QWEN3_30B=6
MINISTRAL_3_REASONING_8B=7
GLM_47_FLASH=8
GEMMA_4_26B=9
GEMMA_4_26B_VLLM_JP62=10
GEMMA_4_31B_VLLM=11
GEMMA_4_E4B=12
GEMMA_4_E2B=13
GEMMA_4_E2B_VLLM=14
GEMMA_4_E4B_VLLM=15
GLM47_FLASH_GGUF=16
LLAMA2_7B_GGUF=17

#Running on JP 7.2
GEMMA_4_26B_VLLM_JP72=18
NEMOTRON_35_LIGHTNING=19
COSMOS3_EDGE=20
QWEN38_27B=21
MUSE_GLIMMER_30B=22
NEMOTRON_3_NANO_OMNI=23

DEF_REASONING_MODEL=$GEMMA_4_26B_VLLM
DEF_CHAT_MODEL=$GEMMA_4_26B_VLLM

#MODEL=$GEMMA_4_26B_VLLM
MODEL=$GEMMA_4_26B_VLLM_JP72

while getopts ":ht:p:" option; do
  case $option in
    h)
      echo "Syntax: -p <port number> -t <type>"
      echo "where <type> is either 'chat' or 'reasoning'"
      exit
      ;;
    p)
      PORT=$OPTARG 
      ;;
    t)
      if [ $OPTARG=='chat' ]; then
        MODEL=$LLAMA2_7B_GGUF
      elif [ $OPTARG=='reasoning' ]; then
        MODEL=$DEF_REASONING_MODEL
      else
        echo "Error: Invalid model type: $OPTARG"
        exit
      fi
      ;;    
    \?) # Invalid option
      echo "Error: Invalid option"
      exit
      ;;
   esac
done

# This avoids OOM during model loading
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
    --port $PORT \
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
    --port $PORT \
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
    --port $PORT \
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
    --port $PORT \
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
    --port $PORT \
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
    --port $PORT \
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
    --port $PORT \
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
    --port $PORT \
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
    --port $PORT

elif [ $MODEL == $GEMMA_4_26B_VLLM_JP62 ]; then
  # This revision is no longer available.  Used cached version for now.
  #  vllm serve cyankiwi/gemma-4-26B-A4B-it-AWQ-4bit --revision 519bdca117c8f10a9a578d1b70b5c0d54c59b7ba 

  sudo docker run -it --rm --pull always --runtime=nvidia --network host \
    -e HF_TOKEN=$HF_TOKEN \
    -v $HOME/dev/torch_compile_cache:/root/.cache/vllm/torch_compile_cache \
    -v $HOME/dev/jetson-containers/data/models/huggingface:/data/models/huggingface \
    -v $HOME/robot_ws/jetson_support:/jetson_support \
    ghcr.io/nvidia-ai-iot/vllm:gemma4-jetson-orin \
    vllm serve --model /data/models/huggingface/models--cyankiwi--gemma-4-26B-A4B-it-AWQ-4bit/snapshots/519bdca117c8f10a9a578d1b70b5c0d54c59b7ba \
    --gpu-memory-utilization 0.5 \
    --enable-auto-tool-choice \
    --reasoning-parser gemma4 \
    --tool-call-parser my_fixed_gemma_parser \
    --tool-parser-plugin /jetson_support/fixed_gemma4_tool_parser_665f9c4.py \
    --max_model_len 64000 \
    --port $PORT \
    --chat-template /jetson_support/fixed_tool_chat_template_gemma4.jinja 

elif [ $MODEL == $GEMMA_4_31B_VLLM ]; then
  
  sudo docker run -it --rm --pull always --runtime=nvidia --network host \
    -e HF_TOKEN=$HF_TOKEN \
    -v $HOME/dev/torch_compile_cache:/root/.cache/vllm/torch_compile_cache \
    -v $HOME/dev/jetson-containers/data/models/huggingface:/data/models/huggingface \
    -v $HOME/robot_ws/jetson_support:/jetson_support \
    ghcr.io/nvidia-ai-iot/vllm:gemma4-jetson-orin \
    vllm serve cyankiwi/gemma-4-31B-it-AWQ-4bit  \
    --gpu-memory-utilization 0.6 \
    --enable-auto-tool-choice \
    --reasoning-parser gemma4 \
    --tool-call-parser gemma4 \
    --max-model-len 64000 \
    --port $PORT \
    --chat-template /jetson_support/fixed_tool_chat_template_gemma4.jinja

elif [ $MODEL == $GEMMA_4_E4B ]; then

  sudo docker run -it --rm --pull always --runtime=nvidia --network host \
    -e HF_TOKEN=$HF_TOKEN \
    -v $HOME/dev/torch_compile_cache:/root/.cache/vllm/torch_compile_cache \
    -v $HOME/dev/jetson-containers/data/models/huggingface:/data/models/huggingface \
    ghcr.io/nvidia-ai-iot/llama_cpp:gemma4-jetson-orin \
    llama-server -hf ggml-org/gemma-4-E4B-it-GGUF:Q4_K_M \
    --port $PORT

elif [ $MODEL == $GEMMA_4_E2B ]; then
  
  sudo docker run -it --rm --pull always --runtime=nvidia --network host \
    -e HF_TOKEN=$HF_TOKEN \
    $COMMON_ARGS \
    ghcr.io/nvidia-ai-iot/llama_cpp:gemma4-jetson-orin \
    llama-server -hf ggml-org/gemma-4-E2B-it-GGUF:Q8_0 \
    --port $PORT

elif [ $MODEL == $GEMMA_4_E2B_VLLM ]; then
  
  sudo docker run -it --rm --pull always --runtime=nvidia --network host \
    -e HF_TOKEN=$HF_TOKEN \
    -v $HOME/dev/torch_compile_cache:/root/.cache/vllm/torch_compile_cache \
    -v $HOME/dev/jetson-containers/data/models/huggingface:/data/models/huggingface \
    -v $HOME/robot_ws/jetson_support:/jetson_support \
    ghcr.io/nvidia-ai-iot/vllm:gemma4-jetson-orin \
    vllm serve google/gemma-4-E2B-it \
    --gpu-memory-utilization 0.4 \
    --enable-auto-tool-choice \
    --reasoning-parser gemma4 \
    --tool-call-parser gemma4 \
    --max-model-len 64000 \
    --port $PORT \
    --chat-template /jetson_support/fixed_tool_chat_template_gemma4.jinja 

elif [ $MODEL == $GEMMA_4_E4B_VLLM ]; then
  
  sudo docker run -it --rm --pull always --runtime=nvidia --network host \
    -e HF_TOKEN=$HF_TOKEN \
    -v $HOME/dev/torch_compile_cache:/root/.cache/vllm/torch_compile_cache \
    -v $HOME/dev/jetson-containers/data/models/huggingface:/data/models/huggingface \
    -v $HOME/robot_ws/jetson_support:/jetson_support \
    ghcr.io/nvidia-ai-iot/vllm:gemma4-jetson-orin \
    vllm serve google/gemma-4-E4B-it \
    --gpu-memory-utilization 0.4 \
    --enable-auto-tool-choice \
    --reasoning-parser gemma4 \
    --tool-call-parser gemma4 \
    --max-model-len 64000 \
    --port $PORT \
    --chat-template /jetson_support/fixed_tool_chat_template_gemma4.jinja 


elif [ $MODEL == $GLM47_FLASH_GGUF ]; then
  #GPU MEM 28.4G

  sudo docker run -it --rm --pull always --runtime=nvidia --network host \
    -e HF_TOKEN=$HF_TOKEN \
    $COMMON_ARGS \
    ghcr.io/nvidia-ai-iot/llama_cpp:gemma4-jetson-orin \
    llama-server -hf unsloth/GLM-4.7-Flash-GGUF \
    --port $PORT

elif [ $MODEL == $LLAMA2_7B_GGUF ]; then

  sudo docker run -it --rm --pull always --runtime=nvidia --network host \
    -e HF_TOKEN=$HF_TOKEN \
    $COMMON_ARGS \
    ghcr.io/nvidia-ai-iot/llama_cpp:gemma4-jetson-orin \
    llama-server -hf TheBloke/Llama-2-7b-Chat-GGUF \
    --port $PORT \
    --chat-template chatml

elif [ $MODEL == $GEMMA_4_26B_VLLM_JP72 ]; then
  # NeoChen1024/gemma-4-26B-A4B-it-qat-W4A16
  # cyankiwi/gemma-4-26B-A4B-it-AWQ-4bit 

  # Enforce eager seems to increase latency
  #     --enforce-eager 

  sudo docker run -it --rm --pull always --runtime=nvidia --network host \
    -e HF_TOKEN=$HF_TOKEN \
    -v $HOME/dev/torch_compile_cache:/root/.cache/vllm/torch_compile_cache \
    -v ~/.cache/huggingface:/root/.cache/huggingface \
    -v ~/.cache/vllm:/root/.cache/vllm \
    vllm/vllm-openai:latest NeoChen1024/gemma-4-26B-A4B-it-qat-W4A16 \
    --gpu-memory-utilization 0.5 \
    --max-model-len 64000 \
    --trust-remote-code \
    --reasoning-parser gemma4 \
    --enable-auto-tool-choice \
    --tool-call-parser gemma4 \
    --speculative-config '{"method":"mtp","model":"google/gemma-4-26B-A4B-it-assistant","num_speculative_tokens":3}' \
    --default-chat-template-kwargs '{"enable_thinking":false}' \
    --port $PORT

elif [ $MODEL == $NEMOTRON_35_LIGHTNING ]; then
  # No vlm

  docker run --pull always --rm -it \
    --name nemotron35-vllm \
    --runtime=nvidia \
    --network host \
    -e HF_TOKEN=$HF_TOKEN \
    -v $HOME/dev/torch_compile_cache:/root/.cache/vllm/torch_compile_cache \
    -v ~/.cache/huggingface:/root/.cache/huggingface \
    -v ~/.cache/vllm:/root/.cache/vllm \
    vllm/vllm-openai:v0.27.1 \
    --model nvidia/NVIDIA-Nemotron-3.5-Lightning-30B-A3B-NVFP4 \
    --served-model-name nemotron35 \
    --reasoning-parser nemotron_v3 \
    --enable-auto-tool-choice \
    --tool-call-parser qwen3_coder \
    --max-model-len 128000 \
    --trust-remote-code \
    --kv-cache-dtype bfloat16 \
    --gpu-memory-utilization 0.7 \
    --max-num-batched-tokens 16384 \
    --enable-prefix-caching \
    --speculative_config.method dspark \
    --speculative_config.model nvidia/NVIDIA-Nemotron-3.5-Lightning-30B-A3B-NVFP4-DSpark \
    --speculative_config.num_speculative_tokens 5 \
    --speculative_config.kv_cache_dtype bfloat16 \
    --mamba-backend flashinfer \
    --mamba-ssm-cache-dtype float16 \
    --enable-mamba-cache-stochastic-rounding \
    --mamba-cache-philox-rounds 5 \
    --mamba-cache-mode align \
    --port $PORT

elif [ $MODEL == $COSMOS3_EDGE ]; then
  # Doesn't appear to support toolcalling

  sudo docker run -it --rm --pull always \
    --runtime=nvidia --network host \
    -e HF_TOKEN=$HF_TOKEN \
    -v $HOME/dev/torch_compile_cache:/root/.cache/vllm/torch_compile_cache \
    -v ~/.cache/huggingface:/root/.cache/huggingface \
    -v ~/.cache/vllm:/root/.cache/vllm \
    --entrypoint "" \
    vllm/vllm-openai:cosmos3 \
    vllm serve nvidia/Cosmos3-Edge \
    --enable-auto-tool-choice \
    --tool-call-parser pythonic \
    --host 0.0.0.0 \
    --trust-remote-code \
    --max-model-len 16384 \
    --gpu-memory-utilization 0.6 \
    --port $PORT

elif [ $MODEL == $QWEN38_27B ]; then
  mkdir -p ~/.model_logs/llama_server
  docker run --gpus all --rm -it \
    --runtime nvidia \
    --network host \
    -e HF_TOKEN=$HF_TOKEN \
    -v ~/.model_logs/llama_server:/logs \
    -v ~/.cache/huggingface:/data/models/huggingface \
    ghcr.io/nvidia-ai-iot/llama_cpp:latest-jetson-orin \
    llama-server \
      -hf unsloth/Qwen3.8-27B-GGUF:Q4_K_M \
      -ngl all \
      --spec-type draft-mtp \
      --temp 1.0 \
      --top-k 20 \
      --min-p 0.0 \
      --host 0.0.0.0 \
      --jinja \
      --reasoning-preserve \
      --chat-template-kwargs '{"preserve_thinking": true, "reasoning_effort": "medium"}' \
      --log-prompts-dir ./logs \
      --port $PORT && echo "done"

elif [ $MODEL == $MUSE_GLIMMER_30B ]; then
  sudo docker run --gpus all --rm -it --pull always \
    --runtime=nvidia \
    --network host \
    -e HF_TOKEN=$HF_TOKEN \
    -v ~/.model_logs/llama_server:/logs \
    -v ~/.cache/huggingface:/data/models/huggingface \
    ghcr.io/nvidia-ai-iot/llama_cpp:latest-jetson-orin \
    llama-server \
      -hf meta-models/Muse-Glimmer-30B-GGUF \
      -hff Muse-Glimmer-30B-KQuant-17GB-Q4_K_M.gguf \
      --spec-type draft-dflash \
      --n-gpu-layers 999 \
      --spec-draft-ngl 999 \
      --ctx-size 131072 \
      --flash-attn on \
      --parallel 1 \
      --jinja \
      --temp 1.0 \
      --top-p 0.95 \
      --top-k 64 \
      --port $PORT && echo "done"

elif [ $MODEL == $NEMOTRON_3_NANO_OMNI ]; then

  sudo docker run --gpus all --rm -it --pull always \
    --runtime=nvidia \
    --network host \
    -e HF_TOKEN=$HF_TOKEN \
    -v ~/.model_logs/llama_server:/logs \
    -v ~/.cache/huggingface:/data/models/huggingface \
    ghcr.io/nvidia-ai-iot/llama_cpp:latest-jetson-orin \
    llama-server \
      --hf-repo ggml-org/NVIDIA-Nemotron-3-Nano-Omni-30B-A3B-GGUF \
      --hf-file NVIDIA-Nemotron-3-Nano-Omni-30B-A3B-Q4_K_M.gguf \
      --ctx-size 8192 \
      --alias my_model \
      --n-gpu-layers 999 \
      --port $PORT && echo "done"

else
  echo "Invalid model selection: $MODEL"
fi