# Jetson Support for Elsabot

This package contains scripts for building and running containers for hosting processes that require Jetson-specific hardware acceleration such as LLMs, TTS, STT, etc.


Run model for thinking/instruction:

```
jetson_support/run_primary_llm.sh -p 8000 -t reasoning
```

Run model for chat:

```
jetson_support/run_primary_llm.sh -p 8003 -t chat
```

Run model for vision:

```
jetson_support/run_vision_llm.sh
```

* Uses port 8001

Run stt/tts packages:

```
jetson_support/jp_docker/run_docker.sh
jetson_support/run_stt_tts.sh
```

* TTS (Piper) uses port 5000
* STT uses port 8800