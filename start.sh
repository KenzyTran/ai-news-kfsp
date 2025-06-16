#!/bin/bash

# Script khởi động cho production
echo "Starting AI News Summarizer API..."

# Thiết lập biến môi trường
export OLLAMA_BASE_URL=${OLLAMA_BASE_URL:-"http://localhost:11434/v1"}
export OLLAMA_MODEL=${OLLAMA_MODEL:-"qwen3:0.6b-q4_K_M"}
export PORT=${PORT:-8000}
export HOST=${HOST:-"0.0.0.0"}

# Chạy API với uvicorn
uvicorn api:app --host $HOST --port $PORT --workers 1
