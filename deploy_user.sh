#!/bin/bash

# Script deploy ứng dụng không cần sudo
echo "=== Deploy AI News Summarizer API (No Sudo) ==="

# Sử dụng thư mục hiện tại
CURRENT_DIR=$(pwd)
echo "Deploying from directory: $CURRENT_DIR"

# Activate virtual environment
if [ ! -d "venv" ]; then
    echo "❌ Virtual environment chưa được tạo. Chạy: bash setup_user.sh"
    exit 1
fi

source venv/bin/activate

# Đảm bảo PATH có ~/bin
export PATH="$HOME/bin:$PATH"

# Kiểm tra Ollama
if ! command -v ollama &> /dev/null; then
    echo "❌ Ollama chưa được cài đặt. Chạy: bash setup_user.sh"
    exit 1
fi

echo "🚀 Starting Ollama server..."
# Khởi động Ollama server trong background
ollama serve &
OLLAMA_PID=$!
echo $OLLAMA_PID > logs/ollama.pid

# Đợi Ollama server khởi động
sleep 5

# Kiểm tra xem Ollama server có chạy không
if ! curl -s http://localhost:11434/api/tags > /dev/null; then
    echo "❌ Ollama server không khởi động được"
    kill $OLLAMA_PID 2>/dev/null
    exit 1
fi

echo "✅ Ollama server đang chạy"

# Pull model nếu chưa có
echo "📥 Kiểm tra và tải model..."
if ! ollama list | grep -q "qwen3:0.6b-q4_K_M"; then
    echo "Đang tải model qwen3:0.6b-q4_K_M..."
    ollama pull qwen3:0.6b-q4_K_M
fi

echo "✅ Model đã sẵn sàng"

# Tạo script start cho API
cat > start_api.sh << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"
source venv/bin/activate
export PATH="$HOME/bin:$PATH"
export OLLAMA_BASE_URL=http://localhost:11434/v1
export OLLAMA_MODEL=qwen3:0.6b-q4_K_M
export HOST=0.0.0.0
export PORT=8000

# Khởi động Ollama nếu chưa chạy
if ! curl -s http://localhost:11434/api/tags > /dev/null; then
    echo "🚀 Starting Ollama server..."
    ollama serve &
    echo $! > logs/ollama.pid
    sleep 5
fi

# Khởi động API
echo "🚀 Starting API server..."
python api.py &
echo $! > logs/api.pid
echo "✅ API server started with PID: $(cat logs/api.pid)"
EOF

chmod +x start_api.sh

# Tạo script stop
cat > stop_api.sh << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"

echo "🛑 Stopping services..."

# Stop API
if [ -f logs/api.pid ]; then
    API_PID=$(cat logs/api.pid)
    if kill -0 $API_PID 2>/dev/null; then
        kill $API_PID
        echo "✅ API server stopped"
    fi
    rm -f logs/api.pid
fi

# Stop Ollama
if [ -f logs/ollama.pid ]; then
    OLLAMA_PID=$(cat logs/ollama.pid)
    if kill -0 $OLLAMA_PID 2>/dev/null; then
        kill $OLLAMA_PID
        echo "✅ Ollama server stopped"
    fi
    rm -f logs/ollama.pid
fi

echo "🔥 All services stopped"
EOF

chmod +x stop_api.sh

# Tạo script status
cat > status_api.sh << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"

echo "📊 Service Status:"

# Check Ollama
if [ -f logs/ollama.pid ]; then
    OLLAMA_PID=$(cat logs/ollama.pid)
    if kill -0 $OLLAMA_PID 2>/dev/null; then
        echo "✅ Ollama: Running (PID: $OLLAMA_PID)"
    else
        echo "❌ Ollama: Not running"
    fi
else
    echo "❌ Ollama: PID file not found"
fi

# Check API
if [ -f logs/api.pid ]; then
    API_PID=$(cat logs/api.pid)
    if kill -0 $API_PID 2>/dev/null; then
        echo "✅ API: Running (PID: $API_PID)"
    else
        echo "❌ API: Not running"
    fi
else
    echo "❌ API: PID file not found"
fi

# Test API endpoint
echo ""
echo "🔍 Testing API endpoint..."
if curl -s http://localhost:8000/health > /dev/null; then
    echo "✅ API endpoint responding"
else
    echo "❌ API endpoint not responding"
fi
EOF

chmod +x status_api.sh

# Khởi động API
echo "🚀 Starting API server..."
export OLLAMA_BASE_URL=http://localhost:11434/v1
export OLLAMA_MODEL=qwen3:0.6b-q4_K_M
export HOST=0.0.0.0
export PORT=8000

python api.py &
API_PID=$!
echo $API_PID > logs/api.pid

sleep 3

# Kiểm tra API
if curl -s http://localhost:8000/health > /dev/null; then
    echo "✅ API server đang chạy thành công!"
    echo ""
    echo "=== Deploy hoàn tất! ==="
    echo "🌐 API: http://YOUR_EC2_IP:8000"
    echo "📋 Health check: http://YOUR_EC2_IP:8000/health"
    echo "📖 Documentation: http://YOUR_EC2_IP:8000/docs"
    echo ""
    echo "🎛️  Quản lý services:"
    echo "   ./start_api.sh    # Khởi động"
    echo "   ./stop_api.sh     # Dừng"
    echo "   ./status_api.sh   # Kiểm tra trạng thái"
else
    echo "❌ API server không khởi động được"
    kill $API_PID 2>/dev/null
    kill $OLLAMA_PID 2>/dev/null
    exit 1
fi
