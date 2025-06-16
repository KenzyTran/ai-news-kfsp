#!/bin/bash

# Script cài đặt môi trường trên EC2
echo "=== Cài đặt môi trường cho AI News Summarizer ==="

# Update system
sudo apt update && sudo apt upgrade -y

# Cài đặt Python và pip
sudo apt install python3 python3-pip python3-venv git curl -y

# Cài đặt Docker (optional)
sudo apt install docker.io docker-compose -y
sudo usermod -aG docker $USER

# Cài đặt Ollama
curl -fsSL https://ollama.ai/install.sh | sh

# Tạo systemd service cho Ollama
sudo tee /etc/systemd/system/ollama.service > /dev/null <<EOF
[Unit]
Description=Ollama
After=network.target

[Service]
Type=simple
User=ubuntu
ExecStart=/usr/local/bin/ollama serve
Restart=always
RestartSec=3
Environment=OLLAMA_HOST=0.0.0.0:11434

[Install]
WantedBy=multi-user.target
EOF

# Enable và start Ollama service
sudo systemctl enable ollama
sudo systemctl start ollama

echo "=== Cài đặt hoàn tất! ==="
echo "Chạy script này với: bash setup_ec2.sh"
