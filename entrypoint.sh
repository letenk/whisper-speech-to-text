#!/bin/bash
set -e

MODEL_NAME="${WHISPER_MODEL:-small}"
MODEL_PATH="./models/ggml-${MODEL_NAME}.bin"
HOST="${WHISPER_HOST:-0.0.0.0}"
PORT="${WHISPER_PORT:-8178}"
LANGUAGE="${WHISPER_LANGUAGE:-en}"
THREADS="${WHISPER_THREADS:-4}"

# Download the model if it does not exist yet
if [ ! -f "$MODEL_PATH" ]; then
    echo "Model $MODEL_NAME not found, downloading..."
    mkdir -p ./models
    BASE_URL="https://huggingface.co/ggerganov/whisper.cpp/resolve/main"
    curl -L --progress-bar \
        "$BASE_URL/ggml-${MODEL_NAME}.bin" \
        -o "$MODEL_PATH"
    echo "Download complete: $MODEL_PATH"   
else
    echo "Model $MODEL_NAME already exists, skipping download."
fi

echo "Starting whisper-server..."
echo "  Model    : $MODEL_PATH"
echo "  Host     : $HOST"
echo "  Port     : $PORT"
echo "  Language : $LANGUAGE"
echo "  Threads  : $THREADS"

exec ./whisper-server \
    --model "$MODEL_PATH" \
    --host "$HOST" \
    --port "$PORT" \
    --language "$LANGUAGE" \
    --threads "$THREADS" \
    --convert