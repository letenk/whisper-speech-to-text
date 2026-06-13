# ─────────────────────────────────────────
# Stage 1: Builder — compile whisper-server
# ─────────────────────────────────────────
FROM debian:bookworm-slim AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    cmake \
    build-essential \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Clone whisper.cpp
RUN git clone --depth=1 https://github.com/ggml-org/whisper.cpp .

# Build whisper server (Release, use all available cores)
RUN cmake -B build -DWHISPER_BUILD_SERVER=ON \
    && cmake --build build --config Release -j$(nproc) --target whisper-server

# ─────────────────────────────────────────
# Stage 2: Runtime — lightweight final image
# ─────────────────────────────────────────
FROM debian:bookworm-slim AS runtime

# Install FFmpeg (for --convert flag) + ca-certificates
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy binary from stage builder
COPY --from=builder /app/build/bin/whisper-server ./whisper-server

# Copy script download model
COPY --from=builder /app/models/download-ggml-model.sh ./models/download-ggml-model.sh
RUN chmod +x ./models/download-ggml-model.sh

# Copy entrypoint script
COPY entrypoint.sh ./entrypoint.sh
RUN chmod +x ./entrypoint.sh

# Port whisper-server
EXPOSE 8178

ENTRYPOINT ["./entrypoint.sh"]