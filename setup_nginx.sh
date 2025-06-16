#!/bin/bash

# Script cài đặt Nginx reverse proxy
echo "=== Cài đặt Nginx reverse proxy ==="

# Cài đặt Nginx
sudo apt install nginx -y

# Tạo Nginx config
sudo tee /etc/nginx/sites-available/ai-news-api > /dev/null <<EOF
server {
    listen 80;
    server_name your-domain.com;  # Thay bằng domain của bạn hoặc IP

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        
        # Timeout settings
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # Health check endpoint
    location /health {
        proxy_pass http://127.0.0.1:8000/health;
        access_log off;
    }
}
EOF

# Enable site
sudo ln -s /etc/nginx/sites-available/ai-news-api /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Test và restart Nginx
sudo nginx -t
sudo systemctl enable nginx
sudo systemctl restart nginx

echo "=== Nginx đã cài đặt! ==="
echo "API có thể truy cập qua: http://YOUR_DOMAIN hoặc http://YOUR_EC2_IP"
