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
    ./models/download-ggml-model.sh "$MODEL_NAME"
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