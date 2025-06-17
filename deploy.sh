#!/bin/bash
set -e

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

# Stop existing containers
echo "🛑 Stopping existing containers..."
$DOCKER_COMPOSE down || true

# Build and start services
echo "🔨 Building and starting services..."
$DOCKER_COMPOSE up -d --build

# Wait for services to be healthy
echo "⏳ Waiting for services to be ready..."
sleep 20

# Pull the model
echo "📥 Pulling qwen3:0.6b-q4_K_M model..."
docker exec ollama ollama pull qwen3:0.6b-q4_K_M

echo "✅ Deployment completed!"
echo ""
echo "🌐 Services:"
echo "   - API: http://localhost:8000"
echo "   - API Docs: http://localhost:8000/docs"
echo "   - API Health: http://localhost:8000/health"
echo "   - Ollama: http://localhost:11434"
echo ""
echo "🧪 Test API:"
echo "   curl http://localhost:8000/health"
echo ""
echo "📊 Check status:"
echo "   ./manage.sh status"
