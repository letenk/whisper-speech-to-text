# Makefile for Whisper.cpp Container

.PHONY: help download-model up down logs status test

# Default model
MODEL ?= small.en

help:
	@echo "Available commands:"
	@echo "  make download-model  - Download Whisper model (MODEL=small.en)"
	@echo "  make up              - Start whisper container"
	@echo "  make down            - Stop whisper container"
	@echo "  make logs            - View container logs"
	@echo "  make status          - Check container status"
	@echo "  make test            - Test whisper server with sample"

download-model:
	@echo "Downloading model: $(MODEL)..."
	@docker run -it --rm \
		-v ./models:/models \
		ghcr.io/ggml-org/whisper.cpp:main \
		"./models/download-ggml-model.sh $(MODEL) /models"
	@echo "✅ Model downloaded to ./models/"

up:
	@echo "Starting whisper container..."
	@docker compose up -d
	@echo "✅ Whisper server started on port $$(grep WHISPER_PORT .env | cut -d= -f2 | tr -d ' ')"

down:
	@echo "Stopping whisper container..."
	@docker compose down
	@echo "✅ Whisper container stopped"

logs:
	@docker compose logs -f whisper

status:
	@docker compose ps

test:
	@echo "Testing whisper server..."
	@curl -s http://localhost:$$(grep WHISPER_PORT .env | cut -d= -f2 | tr -d ' ')/health || echo "❌ Server not responding"
