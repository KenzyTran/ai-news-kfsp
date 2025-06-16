# AI News Summarizer API

API tóm tắt tin tức sử dụng AI (Ollama) với FastAPI.

## 🚀 Tính năng

- API REST để tóm tắt tin tức
- Hỗ trợ tiếng Việt và tiếng Anh
- Kiểm tra sức khỏe hệ thống
- Tùy chỉnh độ dài tóm tắt
- Ready for production deployment

## 📋 API Endpoints

### GET /
Thông tin cơ bản về API

### GET /health
Kiểm tra trạng thái API và kết nối Ollama

### POST /summarize
Tóm tắt tin tức

**Request Body:**
```json
{
  "text": "Nội dung tin tức cần tóm tắt...",
  "max_words": 50,
  "language": "vietnamese"
}
```

**Response:**
```json
{
  "summary": "Tóm tắt tin tức...",
  "original_length": 500,
  "summary_length": 45,
  "status": "success"
}
```

### GET /models
Thông tin về model đang sử dụng

## 🛠️ Cài đặt và chạy

### 1. Development
```bash
# Cài đặt dependencies
pip install -r requirements.txt

# Chạy API
python api.py
```

### 2. Production với Docker
```bash
# Build và chạy
docker-compose up -d

# Hoặc chỉ build API (nếu đã có Ollama)
docker build -t ai-news-api .
docker run -p 8000:8000 -e OLLAMA_BASE_URL=http://your-ollama-server:11434/v1 ai-news-api
```

### 3. Production với Gunicorn
```bash
# Cài thêm gunicorn
pip install gunicorn

# Chạy với gunicorn
bash start_production.sh
```

## 🔧 Cấu hình

### Biến môi trường:
- `OLLAMA_BASE_URL`: URL của Ollama server (mặc định: http://localhost:11434/v1)
- `OLLAMA_MODEL`: Tên model sử dụng (mặc định: qwen2.5:0.5b)
- `OLLAMA_API_KEY`: API key cho Ollama (mặc định: 123)
- `HOST`: Host bind (mặc định: 0.0.0.0)
- `PORT`: Port (mặc định: 8000)

### File .env:
```bash
cp .env.example .env
# Chỉnh sửa .env với thông tin của bạn
```

## 📚 Sử dụng API

### cURL example:
```bash
curl -X POST "http://localhost:8000/summarize" \
     -H "Content-Type: application/json" \
     -d '{
       "text": "Đây là nội dung tin tức cần tóm tắt...",
       "max_words": 30,
       "language": "vietnamese"
     }'
```

### Python example:
```python
import requests

response = requests.post(
    "http://localhost:8000/summarize",
    json={
        "text": "Nội dung tin tức...",
        "max_words": 50,
        "language": "vietnamese"
    }
)

result = response.json()
print(result["summary"])
```

### JavaScript example:
```javascript
const response = await fetch('http://localhost:8000/summarize', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    text: 'Nội dung tin tức...',
    max_words: 50,
    language: 'vietnamese'
  })
});

const result = await response.json();
console.log(result.summary);
```

## 🚀 Deployment

### 1. VPS/Server truyền thống:
```bash
# Clone repository
git clone <your-repo>
cd ai-news-kfsp

# Cài đặt Python dependencies
pip install -r requirements.txt

# Cài đặt và chạy Ollama
curl -fsSL https://ollama.ai/install.sh | sh
ollama serve &
ollama pull qwen2.5:0.5b

# Chạy API
python api.py
```

### 2. Cloud platforms:
- **Heroku**: Sử dụng Procfile
- **Railway**: Deploy trực tiếp từ GitHub
- **DigitalOcean App Platform**: Sử dụng Docker
- **AWS ECS/EKS**: Deploy với Docker

### 3. Nginx reverse proxy:
```nginx
server {
    listen 80;
    server_name yourdomain.com;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

## 📊 Monitoring

- Health check endpoint: `/health`
- Logs: Sử dụng uvicorn/gunicorn logs
- Metrics: Có thể tích hợp Prometheus/Grafana

## 🔒 Security

- CORS đã được cấu hình
- Input validation với Pydantic
- Error handling
- Rate limiting (cần thêm middleware)

## 🤝 Contributing

1. Fork repository
2. Tạo feature branch
3. Commit changes
4. Push và tạo Pull Request
