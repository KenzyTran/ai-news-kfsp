#!/bin/bash
set -e

echo "=== AI News Summarizer Setup (Docker) ==="

# Check Docker installation
if ! command -v docker &> /dev/null; then
    echo "❌ Docker not installed. Please install Docker first:"
    echo "   sudo apt update && sudo apt install docker.io docker-compose -y"
    echo "   sudo usermod -aG docker $USER"
    echo "   newgrp docker"
    exit 1
fi

# Check Docker access
if ! docker ps &> /dev/null; then
    echo "❌ Cannot access Docker daemon. Please ensure:"
    echo "   1. Docker service is running: sudo systemctl start docker"
    echo "   2. User is in docker group: sudo usermod -aG docker $USER"
    echo "   3. Logout and login again, or run: newgrp docker"
    exit 1
fi

# Check docker-compose
if ! command -v docker-compose &> /dev/null; then
    echo "⚠️  docker-compose not found. Using docker compose plugin..."
    DOCKER_COMPOSE="docker compose"
else
    DOCKER_COMPOSE="docker-compose"
fi

echo "✅ Docker setup verified"
echo "🐳 Docker Compose: $DOCKER_COMPOSE"

# Create .env file if not exists
if [ ! -f .env ]; then
    cat > .env << 'EOF'
# Ollama Configuration (Internal Docker network only)
OLLAMA_BASE_URL=http://ollama:11434/v1
OLLAMA_MODEL=qwen3:0.6b-q4_K_M

# API Configuration (Only exposed port)
API_HOST=0.0.0.0
API_PORT=8000
EOF
    echo "📝 Created .env file"
fi

echo "🎉 Setup completed! Run './deploy.sh' to start the application."
echo "📡 API will be available at: http://localhost:8000"
echo "🔒 Ollama runs internally (not exposed to host)"
