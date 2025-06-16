#!/bin/bash

# Script cài đặt SSL với Let's Encrypt
echo "=== Cài đặt SSL với Let's Encrypt ==="

# Cài đặt Certbot
sudo apt install certbot python3-certbot-nginx -y

# Thay YOUR_DOMAIN bằng domain thực tế của bạn
DOMAIN="your-domain.com"

echo "Cài đặt SSL cho domain: $DOMAIN"
echo "Đảm bảo domain đã point về IP của EC2!"

# Tự động cài đặt SSL
sudo certbot --nginx -d $DOMAIN --email your-email@domain.com --agree-tos --non-interactive

# Setup auto-renewal
sudo systemctl enable certbot.timer
sudo systemctl start certbot.timer

echo "=== SSL đã cài đặt! ==="
echo "API có thể truy cập qua HTTPS: https://$DOMAIN"
