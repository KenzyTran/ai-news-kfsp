#!/bin/bash

# Source utility functions
source "$(dirname "$0")/utils.sh"

# Detect docker-compose command
if command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE="docker-compose"
elif docker compose version &> /dev/null; then
    DOCKER_COMPOSE="docker compose"
else
    echo "❌ Neither docker-compose nor docker compose found"
    exit 1
fi

case $1 in
    start)
        echo "🚀 Starting services..."
        $DOCKER_COMPOSE start
        ;;
    stop)
        echo "🛑 Stopping services..."
        $DOCKER_COMPOSE stop
        ;;
    restart)
        echo "🔄 Restarting services..."
        $DOCKER_COMPOSE restart
        ;;
    status)
        echo "📊 Service status:"
        $DOCKER_COMPOSE ps
        echo ""
        echo "🏥 Health checks:"
        docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
        ;;
    logs)
        if [ -n "$2" ]; then
            echo "📋 Logs for $2:"
            $DOCKER_COMPOSE logs -f $2
        else
            echo "📋 All service logs:"
            $DOCKER_COMPOSE logs -f
        fi
        ;;
    build)
        echo "🔨 Rebuilding services..."
        $DOCKER_COMPOSE build --no-cache
        ;;
    clean)
        echo "🧹 Cleaning up..."
        $DOCKER_COMPOSE down -v
        docker system prune -f
        echo "✅ Cleanup completed"
        ;;
    test)
        echo "🧪 Testing services..."
        echo "Testing API health:"
        curl -f http://localhost:8000/health || echo "❌ API health check failed"
        echo ""
        echo "Testing API summarize:"
        curl -X POST "http://localhost:8000/summarize" \
             -H "Content-Type: application/json" \
             -d '{"text": "Đây là một bài viết tin tức dài về công nghệ AI. Công nghệ trí tuệ nhân tạo đang phát triển rất nhanh."}' || echo "❌ API summarize failed"
        echo ""
        echo "Testing Ollama:"
        curl -f http://localhost:11434/api/tags || echo "❌ Ollama check failed"
        echo ""
        echo "🌐 External access URLs:"
        show_service_urls
        ;;
    test-ip)
        if [ -z "$2" ]; then
            echo "❌ Please provide IP address"
            echo "Usage: $0 test-ip <IP_ADDRESS>"
            exit 1
        fi
        TEST_IP="$2"
        echo "🧪 Testing API on IP: $TEST_IP"
        echo ""
        echo "Testing health endpoint:"
        curl -f http://$TEST_IP:8000/health || echo "❌ Health check failed"
        echo ""
        echo "Testing summarize endpoint:"
        curl -X POST "http://$TEST_IP:8000/summarize" \
             -H "Content-Type: application/json" \
             -d '{"text": "Đây là một bài viết tin tức về công nghệ AI cần được tóm tắt."}' || echo "❌ Summarize test failed"
        echo ""
        echo "🌐 Full API URLs:"
        echo "   - API: http://$TEST_IP:8000"
        echo "   - Docs: http://$TEST_IP:8000/docs"
        ;;
    external-test)
        echo "🧪 Testing external access..."
        SERVER_IP=$(get_server_ip)
        echo "Testing API health from external IP ($SERVER_IP):"
        curl -f http://$SERVER_IP:8000/health || echo "❌ External API health check failed"
        echo ""
        echo "Testing API summarize from external:"
        curl -X POST "http://$SERVER_IP:8000/summarize" \
             -H "Content-Type: application/json" \
             -d '{"text": "Đây là một bài viết tin tức dài về công nghệ AI."}' || echo "❌ External API summarize failed"
        ;;
    urls)
        show_service_urls
        ;;
    ip)
        SERVER_IP=$(get_server_ip)
        echo "🌐 Current server IP: $SERVER_IP"
        ;;
    pull-model)
        model=${2:-qwen3:0.6b-q4_K_M}
        echo "📥 Pulling model: $model"
        docker exec ai-news-ollama ollama pull $model
        ;;
    shell)
        service=${2:-ai-news-api}
        echo "🐚 Opening shell in $service container..."
        docker exec -it $service /bin/bash
        ;;
    *)
        echo "🔧 AI News Summarizer Management"
        echo ""
        echo "Usage: $0 {command} [options]"
        echo ""
        echo "Commands:"
        echo "  start              Start all services"
        echo "  stop               Stop all services"  
        echo "  restart            Restart all services"
        echo "  status             Show service status"
        echo "  logs [service]     Show logs (all or specific service)"
        echo "  build              Rebuild Docker images"
        echo "  clean              Stop and remove all containers/volumes"
        echo "  test               Test API and Ollama endpoints (internal)"
        echo "  external-test      Test API from external IP"
        echo "  test-ip <IP>       Test API on specific IP address"
        echo "  urls               Show service URLs with current IP"
        echo "  ip                 Show current server IP"
        echo "  pull-model [model] Pull Ollama model (default: qwen3:0.6b-q4_K_M)"
        echo "  shell [service]    Open shell in container (default: ai-news-api)"
        echo ""
        echo "Examples:"
        echo "  $0 logs ai-news-api        # Show API logs"
        echo "  $0 shell ai-news-ollama    # Open shell in Ollama container"
        echo "  $0 external-test           # Test from outside server"
        echo "  $0 test-ip 192.168.1.100   # Test on specific IP"
        ;;
esac
