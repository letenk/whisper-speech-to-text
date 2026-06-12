# Whisper.cpp Server for Speech to Text

Self-hosted Speech-to-Text (STT) server using [ggml-org/whisper.cpp](https://github.com/ggml-org/whisper.cpp) official Docker image.

## Architecture

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Client     │────→│  whisper    │────→│  whisper.cpp│
│  Backend    │     │  -network   │     │  Server     │
└─────────────┘     └─────────────┘     └─────────────┘
       │                                           │
       └───────────────────────────────────────────┘
                    (HTTP API: /inference)
```

- **Network**: `whisper-network` (isolated Docker bridge network)
- **Container**: `whisper-speech-to-text`
- **Port**: 8080 (configurable via `.env`)
- **Model**: `small.en` (English-optimized, ~466MB)

## Why Separate Network?

- **Isolation**: Whisper server is independent from backend lifecycle
- **Reusability**: Other services can connect to `whisper-network`
- **Scalability**: Can run whisper on a different machine and join the network overlay
- **Portability**: Whisper container can be moved/restarted without affecting backend

## Quick Start

### 1. Download Model

```bash
make download-model
```

This downloads `ggml-small.en.bin` (~466MB) to `./models/`.

### 2. Start Server

```bash
make up
```

Server will be available at `http://localhost:8080`.

### 3. Test

```bash
make test
```

Or manually:
```bash
curl -X POST http://localhost:8080/inference \
  -F "file=@test-audio.wav" \
  -F "response_format=json"
```

## Commands

| Command | Description |
|---------|-------------|
| `make download-model` | Download whisper model |
| `make up` | Start container |
| `make down` | Stop container |
| `make logs` | View logs |
| `make status` | Check container status |
| `make test` | Test server health |

## Configuration

Edit `.env`:
```bash
WHISPER_PORT=8080
```

## Backend Connection

Backend connects via Docker network (no exposed port needed):
```bash
# From backend container
curl http://whisper-speech-to-text:8080/inference
```

Backend `.env`:
```bash
WHISPER_ENDPOINT=http://whisper-speech-to-text:8080
WHISPER_MODEL=small.en
```

## Hardware Requirements

| Spec | Minimum | Recommended |
|------|---------|-------------|
| CPU | 2 cores | 4+ cores |
| RAM | 2GB | 4GB+ |
| Disk | 1GB | 5GB |
| GPU | Optional | Not required for small.en |

## Model Options

| Model | Size | Accuracy | Speed | RAM |
|-------|------|----------|-------|-----|
| `tiny.en` | 75MB | ⭐⭐ | ⚡ Fast | ~273MB |
| `base.en` | 142MB | ⭐⭐⭐ | ⚡ Fast | ~388MB |
| `small.en` | 466MB | ⭐⭐⭐⭐ | 🐢 Medium | ~852MB |
| `medium.en` | 1.5GB | ⭐⭐⭐⭐⭐ | 🐌 Slow | ~2.1GB |

Change model in `docker-compose.yml`:
```yaml
command: >
  whisper-speech-to-text
  -m /models/ggml-base.en.bin  # <-- change here
```

## Troubleshooting

### Container won't start
```bash
make logs
# Check if model file exists
ls -la models/
```

### Out of memory
- Use smaller model: `ggml-base.en.bin` or `ggml-tiny.en.bin`
- Reduce container memory limit

## Resources

- [whisper.cpp GitHub](https://github.com/ggml-org/whisper.cpp)
- [whisper.cpp Docker](https://github.com/ggml-org/whisper.cpp/pkgs/container/whisper.cpp)
- [OpenAI Whisper](https://github.com/openai/whisper)

## License

MIT - whisper.cpp is open source under MIT license.
