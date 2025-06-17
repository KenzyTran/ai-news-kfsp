#!/bin/bash

# Script quản lý ứng dụng không cần sudo
cd "$(dirname "$0")"

COMMAND=${1:-help}

case $COMMAND in
    "start")
        echo "🚀 Starting services..."
        ./start_api.sh
        ;;
    "stop")
        echo "🛑 Stopping services..."
        ./stop_api.sh
        ;;
    "restart")
        echo "🔄 Restarting services..."
        ./stop_api.sh
        sleep 2
        ./start_api.sh
        ;;
    "status")
        ./status_api.sh
        ;;
    "logs")
        echo "📋 Recent logs (last 50 lines):"
        echo "=== API Logs ==="
        if [ -f logs/api.log ]; then
            tail -50 logs/api.log
        else
            echo "No API logs found"
        fi
        echo ""
        echo "=== Ollama Logs ==="
        if [ -f logs/ollama.log ]; then
            tail -50 logs/ollama.log
        else
            echo "No Ollama logs found"
        fi
        ;;
    "test")
        echo "🧪 Testing API..."
        echo "Health check:"
        curl -s http://localhost:8000/health | python3 -m json.tool
        echo ""
        echo "Summarize test:"
        curl -X POST "http://localhost:8000/summarize" \
             -H "Content-Type: application/json" \
             -d '{"text": "Đây là một bài viết tin tức dài về công nghệ AI. Công nghệ trí tuệ nhân tạo đang phát triển rất nhanh và có nhiều ứng dụng trong đời sống."}' | python3 -m json.tool
        ;;
    "update")
        echo "🔄 Updating application..."
        ./stop_api.sh
        
        # Pull latest code if using git
        if [ -d ".git" ]; then
            git pull
        fi
        
        # Update dependencies
        source venv/bin/activate
        pip install -r requirements.txt
        
        # Restart services
        ./start_api.sh
        ;;
    "clean")
        echo "🧹 Cleaning up..."
        ./stop_api.sh
        rm -f logs/*.pid
        rm -f logs/*.log
        echo "✅ Cleanup completed"
        ;;
    *)
        echo "🎛️  AI News API Management (No Sudo Version)"
        echo ""
        echo "Usage: bash manage_user.sh [command]"
        echo ""
        echo "Commands:"
        echo "  start     - Khởi động services"
        echo "  stop      - Dừng services"
        echo "  restart   - Khởi động lại services"
        echo "  status    - Kiểm tra trạng thái"
        echo "  logs      - Xem logs"
        echo "  test      - Test API"
        echo "  update    - Cập nhật ứng dụng"
        echo "  clean     - Dọn dẹp logs và PID files"
        echo "  help      - Hiển thị hướng dẫn này"
        ;;
esac
