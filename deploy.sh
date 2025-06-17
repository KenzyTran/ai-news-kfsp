#!/bin/bash
set -e

# Source utility functions
source "$(dirname "$0")/utils.sh"

echo "=== Deploying AI News Summarizer ==="

# Detect docker-compose command
if command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE="docker-compose"
elif docker compose version &> /dev/null; then
    DOCKER_COMPOSE="docker compose"
else
    echo "❌ Neither docker-compose nor docker compose found"
    exit 1
fi

echo "🐳 Using: $DOCKER_COMPOSE"

# Stop only this project's containers (safe for other containers)
echo "🔍 Checking for existing AI News containers..."
if docker ps -q -f "name=ai-news-api" | grep -q .; then
    echo "🛑 Stopping ai-news-api container..."
    docker stop ai-news-api
    docker rm ai-news-api
fi

if docker ps -q -f "name=ai-news-ollama" | grep -q .; then
    echo "🛑 Stopping ai-news-ollama container..."
    docker stop ai-news-ollama
    docker rm ai-news-ollama
fi

echo "✅ Only this project's containers affected"

# Build and start services
echo "🔨 Building and starting services..."
$DOCKER_COMPOSE up -d --build

# Wait for services to be healthy
echo "⏳ Waiting for services to be ready..."
sleep 20

# Pull the model
echo "📥 Pulling qwen3:0.6b-q4_K_M model..."
docker exec ai-news-ollama ollama pull qwen3:0.6b-q4_K_M

# Auto-detect server IP
SERVER_IP=$(get_server_ip)
if [ "$SERVER_IP" = "localhost" ]; then
    echo "⚠️  Could not detect external server IP, using localhost"
else
    echo "🌐 Detected server IP: $SERVER_IP"
fi

echo "✅ Deployment completed!"
echo ""
show_service_urls
echo ""
echo "📊 Check status:"
echo "   ./manage_docker.sh status"
