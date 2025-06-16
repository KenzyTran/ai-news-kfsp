#!/bin/bash

# Script monitoring và quản lý services
echo "=== AI News API Management ==="

case "$1" in
    status)
        echo "=== Service Status ==="
        sudo systemctl status ollama --no-pager
        echo ""
        sudo systemctl status ai-news-api --no-pager
        echo ""
        sudo systemctl status nginx --no-pager
        ;;
    logs)
        echo "=== API Logs ==="
        sudo journalctl -u ai-news-api -f --no-pager
        ;;
    restart)
        echo "=== Restarting Services ==="
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
