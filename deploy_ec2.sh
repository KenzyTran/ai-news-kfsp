#!/bin/bash

# Script deploy ứng dụng lên EC2
echo "=== Deploy AI News Summarizer API ==="

# Sử dụng thư mục hiện tại
CURRENT_DIR=$(pwd)
echo "Deploying from directory: $CURRENT_DIR"

# Cài đặt Python dependencies
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Pull Ollama model
ollama pull qwen3:0.6b-q4_K_M

# Tạo systemd service cho API với đường dẫn đúng
sudo tee /etc/systemd/system/ai-news-api.service > /dev/null <<EOF
[Unit]
Description=AI News Summarizer API
After=network.target ollama.service
Requires=ollama.service

[Service]
Type=simple
User=ubuntu
WorkingDirectory=$CURRENT_DIR
Environment=PATH=$CURRENT_DIR/venv/bin
Environment=OLLAMA_BASE_URL=http://localhost:11434/v1
Environment=OLLAMA_MODEL=qwen3:0.6b-q4_K_M
Environment=HOST=0.0.0.0
Environment=PORT=8000
ExecStart=$CURRENT_DIR/venv/bin/python api.py
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

# Enable và start service
sudo systemctl enable ai-news-api
sudo systemctl start ai-news-api

echo "=== Deploy hoàn tất! ==="
echo "API đang chạy tại: http://YOUR_EC2_IP:8000"
echo "Kiểm tra status: sudo systemctl status ai-news-api"
echo "Xem logs: sudo journalctl -u ai-news-api -f"
