# 🚀 Deploy AI News Summarizer API lên EC2 (Không cần Sudo)

Hướng dẫn deploy API lên EC2 cho user không có quyền sudo.

## 📋 Yêu cầu

- AWS EC2 instance với user account thường (không cần sudo)
- Python3, pip, và curl đã được admin cài đặt sẵn
- Security Group mở port: 22 (SSH), 8000 (API)
- Key pair để SSH

> **Lưu ý:** Cách này không cần sudo privileges, chạy hoàn toàn trong user space.

## 🔧 Các bước deploy

### Bước 1: Chuẩn bị EC2 Instance

1. **Yêu cầu admin cài đặt:**
   ```bash
   # Admin cần cài đặt trước:
   sudo apt update
   sudo apt install python3 python3-pip python3-venv curl git -y
   ```

2. **Connect SSH:**
   ```bash
   ssh -i your-key.pem ubuntu@your-ec2-ip
   ```

### Bước 2: Upload files lên EC2

**Upload toàn bộ project:**
```bash
# Từ máy local
scp -i your-key.pem -r . ubuntu@your-ec2-ip:/home/ubuntu/ai-news-kfsp/
```

**Hoặc clone từ git:**
```bash
# Trên EC2
git clone https://github.com/your-username/your-repo.git /home/ubuntu/ai-news-kfsp
cd /home/ubuntu/ai-news-kfsp
```

### Bước 3: Setup môi trường (Không cần sudo)

```bash
# Trên EC2, vào thư mục project
cd /home/ubuntu/ai-news-kfsp
chmod +x *.sh

# Chạy script setup (không cần sudo)
bash setup_user.sh

# Reload PATH để nhận diện Ollama
source ~/.bashrc
```

### Bước 4: Deploy ứng dụng

```bash
# Deploy API (không cần sudo)
bash deploy_user.sh
```

## 🎯 Truy cập API

- **API:** `http://your-ec2-ip:8000`
- **Health check:** `http://your-ec2-ip:8000/health`
- **Documentation:** `http://your-ec2-ip:8000/docs`

## 🎛️ Quản lý ứng dụng

### Sử dụng script quản lý:
```bash
# Xem tất cả lệnh
bash manage_user.sh help

# Kiểm tra trạng thái
bash manage_user.sh status

# Khởi động services
bash manage_user.sh start

# Dừng services
bash manage_user.sh stop

# Khởi động lại
bash manage_user.sh restart

# Xem logs
bash manage_user.sh logs

# Test API
bash manage_user.sh test

# Cập nhật ứng dụng
bash manage_user.sh update
```

### Hoặc sử dụng script riêng lẻ:
```bash
# Khởi động
./start_api.sh

# Dừng
./stop_api.sh

# Kiểm tra trạng thái
./status_api.sh
```

## 📊 Test API từ bên ngoài

```bash
# Health check
curl http://your-ec2-ip:8000/health

# Test summarize
curl -X POST "http://your-ec2-ip:8000/summarize" \
     -H "Content-Type: application/json" \
     -d '{"text": "Đây là nội dung tin tức cần tóm tắt..."}'
```

## 🛠️ Troubleshooting

### Kiểm tra services:
```bash
bash manage_user.sh status
```

### Xem logs chi tiết:
```bash
bash manage_user.sh logs

# Hoặc xem trực tiếp
tail -f logs/api.log
tail -f logs/ollama.log
```

### Khởi động lại nếu có lỗi:
```bash
bash manage_user.sh restart
```

### Kiểm tra process đang chạy:
```bash
ps aux | grep python
ps aux | grep ollama
```

### Kiểm tra port:
```bash
netstat -tlnp | grep 8000
netstat -tlnp | grep 11434
```

## 📁 Cấu trúc files sau deploy

```
/home/ubuntu/ai-news-kfsp/
├── api.py                 # API chính
├── requirements.txt       # Dependencies
├── venv/                  # Python virtual environment
├── logs/                  # Logs và PID files
│   ├── api.pid           # Process ID của API
│   ├── ollama.pid        # Process ID của Ollama
│   ├── api.log           # API logs
│   └── ollama.log        # Ollama logs
├── ~/bin/ollama          # Ollama binary (trong home)
├── setup_user.sh         # Script setup không cần sudo
├── deploy_user.sh        # Script deploy không cần sudo
├── manage_user.sh        # Script quản lý tổng hợp
├── start_api.sh          # Script khởi động
├── stop_api.sh           # Script dừng
└── status_api.sh         # Script kiểm tra trạng thái
```

## 🔒 Security Group Settings

| Port | Protocol | Source | Description |
|------|----------|--------|-------------|
| 22   | TCP      | Your IP| SSH access  |
| 8000 | TCP      | 0.0.0.0/0 | API access  |

## ✨ Ưu điểm của cách này

- ✅ **Không cần sudo:** Chạy hoàn toàn trong user space
- ✅ **Dễ quản lý:** Scripts đơn giản, dễ debug
- ✅ **Portable:** Có thể chạy trên bất kỳ user account nào
- ✅ **Logs rõ ràng:** Tất cả logs được lưu trong thư mục dự án
- ✅ **Process tracking:** Theo dõi PID của từng service

## 🚨 Lưu ý quan trọng

1. **Không tự động khởi động:** Services sẽ không tự động start khi reboot
2. **Quản lý thủ công:** Cần dùng scripts để start/stop services  
3. **Port trực tiếp:** API expose trực tiếp port 8000 (không qua Nginx)
4. **User session:** Services sẽ dừng khi user logout (trừ khi dùng screen/tmux)

### Để chạy persistent sau khi logout:
```bash
# Sử dụng screen
screen -S ai-news
bash manage_user.sh start
# Ctrl+A, D để detach

# Attach lại sau
screen -r ai-news
```

**API đã sẵn sàng chạy không cần sudo!** 🎉
