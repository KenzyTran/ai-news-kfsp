# 🚀 Deploy AI News Summarizer API lên AWS EC2

Hướng dẫn deploy API lên EC2 từng bước chi tiết.

> **🔔 Quan trọng:** Nếu bạn **không có quyền sudo**, vui lòng xem hướng dẫn tại [DEPLOY_NO_SUDO.md](./DEPLOY_NO_SUDO.md)

## 📋 Yêu cầu

- AWS EC2 instance (Ubuntu 22.04 LTS, tối thiểu t2.medium)
- Security Group mở port: 22 (SSH), 80 (HTTP), 8000 (API)
- Key pair để SSH
- **Quyền sudo** (cho cách deploy này)

## 🔧 Các bước deploy

### Bước 1: Chuẩn bị EC2 Instance

1. **Tạo EC2 Instance:**
   - AMI: Ubuntu 22.04 LTS
   - Instance type: t3.medium (recommended) hoặc t2.medium (minimum)
   - Security Group: Mở port 22, 80, 8000

2. **Connect SSH:**
```bash
ssh -i your-key.pem ubuntu@your-ec2-ip
```

### Bước 2: Upload files lên EC2

**Tạo thư mục và upload:**
```bash
# Từ máy local, upload toàn bộ project
scp -i your-key.pem -r . ubuntu@your-ec2-ip:/home/ubuntu/ai-news-kfsp/
```

**Hoặc sử dụng git:**
```bash
# Trên EC2
git clone https://github.com/your-username/your-repo.git /home/ubuntu/ai-news-kfsp
cd /home/ubuntu/ai-news-kfsp
```

### Bước 3: Setup môi trường

```bash
# Trên EC2, vào thư mục project
cd /home/ubuntu/ai-news-kfsp
chmod +x *.sh

# Chạy script setup
bash setup_ec2.sh
```

### Bước 4: Deploy ứng dụng

```bash
# Deploy API
bash deploy_ec2.sh
```

### Bước 5: Setup Nginx (Optional)

```bash
# Cài đặt Nginx reverse proxy
bash setup_nginx.sh
```

## 🎯 Truy cập API

### Nếu không dùng Nginx:
- API: `http://your-ec2-ip:8000`
- Health check: `http://your-ec2-ip:8000/health`
- Documentation: `http://your-ec2-ip:8000/docs`

### Nếu dùng Nginx:
- API: `http://your-ec2-ip`
- Health check: `http://your-ec2-ip/health`
- Documentation: `http://your-ec2-ip/docs`

## 🔍 Quản lý và Monitoring

### Kiểm tra trạng thái services:
```bash
bash manage.sh status
```

### Xem logs:
```bash
bash manage.sh logs
```

### Restart services:
```bash
bash manage.sh restart
```

### Test API:
```bash
bash manage.sh test
```

### Update ứng dụng:
```bash
bash manage.sh update
```

## 📊 Test API từ bên ngoài

```bash
# Health check
curl http://your-ec2-ip/health

# Test summarize
curl -X POST "http://your-ec2-ip/summarize" \
     -H "Content-Type: application/json" \
     -d '{"text": "Đây là nội dung tin tức cần tóm tắt..."}'
```

## 🛠️ Troubleshooting

### Kiểm tra services:
```bash
sudo systemctl status ollama
sudo systemctl status ai-news-api
sudo systemctl status nginx
```

### Xem logs chi tiết:
```bash
sudo journalctl -u ai-news-api -f
sudo journalctl -u ollama -f
```

### Restart từng service:
```bash
sudo systemctl restart ollama
sudo systemctl restart ai-news-api
sudo systemctl restart nginx
```

## 📁 Cấu trúc files trên EC2

```
/home/ubuntu/ai-news-kfsp/
├── api.py                 # API chính
├── requirements.txt       # Dependencies
├── venv/                  # Python virtual environment
├── setup_ec2.sh          # Script setup môi trường
├── deploy_ec2.sh         # Script deploy
├── setup_nginx.sh        # Script setup Nginx
└── manage.sh             # Script quản lý
```

## 🔒 Security Group Settings

| Port | Protocol | Source | Description |
|------|----------|--------|-------------|
| 22   | TCP      | Your IP| SSH access  |
| 80   | TCP      | 0.0.0.0/0 | HTTP (Nginx) |
| 8000 | TCP      | 0.0.0.0/0 | API direct  |

**API đã sẵn sàng cho production trên EC2!** 🎉
