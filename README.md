# Whisper Server — Docker Setup

Self-hosted speech-to-text server powered by whisper.cpp with FFmpeg support for automatic audio format conversion.

## File Structure

```
whisper/
├── Dockerfile
├── docker-compose.yml
├── entrypoint.sh
├── models/          ← auto-created, stores .bin model files
└── README.md
```

## Prerequisites

Create the shared Docker network before running for the first time:

```bash
docker network create whisper-server-network
```

This only needs to be done once. Any container that joins `whisper-server-network` can communicate with the whisper server using its container name as the hostname.

## Usage

### 1. Build & Start

```bash
docker compose up -d --build
```

On first run, the entrypoint script will automatically download the configured model. The model is saved to `./models/` on the host so it is not re-downloaded on subsequent restarts.

### 2. Check Status

```bash
# Check container is running
docker compose ps

# Follow logs (including model download progress)
docker compose logs -f

# Health check
curl http://localhost:8178/health
# {"status":"ok"}
```

### 3. Test Transcription

```bash
curl http://localhost:8178/inference \
  -F file=@audio.m4a \
  -F response_format=json
```

Supported audio formats: `.wav`, `.mp3`, `.m4a`, `.webm`, `.ogg`, `.flac`
All formats are automatically converted via FFmpeg before inference.

## Configuration

Edit the `environment` section in `docker-compose.yml`:

| Variable | Default | Options |
|----------|---------|---------|
| `WHISPER_MODEL` | `small` | `tiny`, `base`, `small`, `medium`, `large` |
| `WHISPER_LANGUAGE` | `en` | `en`, `id`, `auto` |
| `WHISPER_THREADS` | `4` | Adjust to match your CPU core count |
| `WHISPER_PORT` | `8178` | Any available port |

## Connecting from Another Container

Add the same network to your other service's `docker-compose.yml`:

```yaml
networks:
  whisper-network:
    external: true
    name: whisper-server-network
```

Then use the container name as the hostname in your service configuration:

```env
WHISPER_SERVER_URL=http://whisper-server:8178
```

## Changing the Model

Update `WHISPER_MODEL` in `docker-compose.yml`, then restart:

```bash
docker compose up -d
```

The new model will be downloaded automatically on startup.

## Model Size Reference

| Model | Disk | RAM | Speed |
|-------|------|-----|-------|
| tiny | 75 MB | ~273 MB | Fastest |
| base | 142 MB | ~388 MB | Fast |
| small | 466 MB | ~852 MB | Balanced |
| medium | 1.5 GB | ~2.1 GB | Accurate |
| large | 2.9 GB | ~3.9 GB | Most accurate |