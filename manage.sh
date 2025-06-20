#!/bin/bash

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
    test)
        echo "🧪 Testing services..."
        echo ""
        echo "Testing API health:"
        if curl -f http://localhost:8000/health 2>/dev/null; then
            echo "✅ API health check passed"
        else
            echo "❌ API health check failed"
        fi
        echo ""
        echo "Testing API summarize:"
        curl -X POST "http://localhost:8000/summarize" \
             -H "Content-Type: application/json" \
             -d '{"text": "Đây là một bài viết tin tức dài về công nghệ AI."}' \
             2>/dev/null | python3 -m json.tool || echo "❌ Summarize test failed"
        ;;
    *)
        echo "🔧 AI News Summarizer Management"
        echo ""
        echo "Usage: $0 {command} [options]"
        echo ""
        echo "Commands:"
        echo "  start          Start all services"
        echo "  stop           Stop all services"  
        echo "  restart        Restart all services"
        echo "  status         Show service status"
        echo "  logs [service] Show logs"
        echo "  test           Test API endpoints"
        echo ""
        echo "Examples:"
        echo "  $0 logs ai-news-api"
        echo "  $0 test"
        ;;
esac
        sudo systemctl restart ollama
        sudo systemctl restart ai-news-api
        sudo systemctl restart nginx
        echo "All services restarted!"
        ;;
    update)
        echo "=== Updating Application ==="
        CURRENT_DIR=$(pwd)
        echo "Updating from directory: $CURRENT_DIR"
        
        # Pull updates nếu dùng git
        if [ -d ".git" ]; then
            git pull
        fi
        
        source venv/bin/activate
        pip install -r requirements.txt
        sudo systemctl restart ai-news-api
        echo "Application updated!"
        ;;
    test)
        echo "=== Testing API ==="
        curl -X GET http://localhost:8000/health
        echo ""
        ;;
    *)
        echo "Usage: $0 {status|logs|restart|update|test}"
        echo ""
        echo "  status  - Hiển thị trạng thái services"
        echo "  logs    - Xem logs của API"
        echo "  restart - Restart tất cả services"
        echo "  update  - Update application"
        echo "  test    - Test API local"
        ;;
esac
