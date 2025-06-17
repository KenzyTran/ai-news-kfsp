#!/bin/bash

# Script cài đặt môi trường không cần sudo
echo "=== Cài đặt môi trường cho AI News Summarizer (No Sudo) ==="

# Kiểm tra Python3
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 chưa được cài đặt. Vui lòng yêu cầu admin cài đặt python3, python3-pip, python3-venv"
    exit 1
fi

echo "✅ Python3 đã có sẵn"

# Tạo virtual environment
echo "📦 Tạo Python virtual environment..."
python3 -m venv venv
source venv/bin/activate

# Upgrade pip
pip install --upgrade pip

# Cài đặt dependencies
echo "📥 Cài đặt Python dependencies..."
pip install -r requirements.txt

# Kiểm tra Ollama
if ! command -v ollama &> /dev/null; then
    echo "📥 Cài đặt Ollama..."
    # Tải Ollama binary về home directory
    mkdir -p ~/bin
    curl -L https://github.com/ollama/ollama/releases/latest/download/ollama-linux-amd64 -o ~/bin/ollama
    chmod +x ~/bin/ollama
    
    # Thêm ~/bin vào PATH
    if ! grep -q 'export PATH="$HOME/bin:$PATH"' ~/.bashrc; then
        echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
    fi
    
    export PATH="$HOME/bin:$PATH"
    echo "✅ Ollama đã được cài đặt tại ~/bin/ollama"
else
    echo "✅ Ollama đã có sẵn"
fi

# Tạo thư mục cho logs
mkdir -p logs

echo ""
echo "=== Cài đặt hoàn tất! ==="
echo "🔧 Để hoàn tất setup:"
echo "1. source ~/.bashrc  # Reload PATH"
echo "2. bash deploy_user.sh  # Deploy ứng dụng"
echo ""
echo "📝 Lưu ý: Script này không cần sudo privileges"
