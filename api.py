from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from openai import OpenAI
import re
import os
from typing import Optional
import uvicorn

# Cấu hình
OPENAI_BASE_URL = os.getenv("OLLAMA_BASE_URL", "http://localhost:11434/v1")
OLLAMA_MODEL = os.getenv("OLLAMA_MODEL", "qwen3:0.6b-q4_K_M")
API_KEY = os.getenv("OLLAMA_API_KEY", "123")
PORT = int(os.getenv("PORT", 8000))
HOST = os.getenv("HOST", "0.0.0.0")

# Khởi tạo FastAPI
app = FastAPI(
    title="AI News Summarizer API",
    description="API để tóm tắt tin tức bằng AI",
    version="1.0.0"
)

# Cấu hình CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Trong production nên chỉ định domain cụ thể
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Khởi tạo client Ollama
client_ollama = OpenAI(
    base_url=OPENAI_BASE_URL,
    api_key=API_KEY
)

# Models cho request/response
class SummarizeRequest(BaseModel):
    text: str

class SummarizeResponse(BaseModel):
    summary: str
    success: bool
    error: str = None

class HealthResponse(BaseModel):
    status: str
    message: str

def clean_response(text: str) -> str:
    """Loại bỏ phần <think> và chỉ lấy câu trả lời"""
    # Loại bỏ phần <think>...</think>
    text = re.sub(r'<think>.*?</think>', '', text, flags=re.DOTALL)
    
    # Loại bỏ các thẻ XML khác nếu có
    text = re.sub(r'<[^>]+>', '', text)
    
    # Loại bỏ khoảng trắng thừa
    text = text.strip()
    
    return text

@app.get("/", response_model=dict)
async def root():
    """Endpoint gốc"""
    return {
        "message": "AI News Summarizer API",
        "version": "1.0.0",
        "endpoints": {
            "health": "/health",
            "summarize": "/summarize",
            "docs": "/docs"
        }
    }

@app.get("/health", response_model=HealthResponse)
async def health_check():
    """Kiểm tra trạng thái API và kết nối với Ollama"""
    try:
        # Test kết nối với Ollama
        response = client_ollama.chat.completions.create(
            model=OLLAMA_MODEL,
            messages=[{"role": "user", "content": "Hello"}],
            max_tokens=10
        )
        
        return HealthResponse(
            status="healthy",
            message="API và Ollama đang hoạt động bình thường"
        )
    except Exception as e:
        raise HTTPException(
            status_code=503,
            detail=f"Lỗi kết nối với Ollama: {str(e)}"
        )

@app.post("/summarize", response_model=SummarizeResponse)
async def summarize_news(request: SummarizeRequest):
    """Tóm tắt tin tức"""
    
    try:
        prompt = f"Tóm tắt nội dung tin tức sau:\n\n{request.text}"

        messages = [
            {"role": "system", "content": "You are an AI assistant specialized in summarizing full news articles into concise Vietnamese news briefs. For each article, provide a summary of no more than 50 words, focusing only on the most essential information: who, what, where, and why (if applicable). The output must always be a single paragraph news update in Vietnamese, with no line breaks, no bullet points, and no list formatting—just one coherent paragraph."},
            {"role": "user", "content": prompt}
        ]
        
        response = client_ollama.chat.completions.create(
            model=OLLAMA_MODEL,
            messages=messages,
            temperature=0.3
        )
        
        # Làm sạch response
        summary = clean_response(response.choices[0].message.content)
        
        return SummarizeResponse(
            summary=summary,
            success=True
        )
        
    except Exception as e:
        return SummarizeResponse(
            summary="",
            success=False,
            error=str(e)
        )

@app.get("/models")
async def get_available_models():
    """Lấy danh sách models có sẵn"""
    try:
        # Trong thực tế, bạn có thể gọi API Ollama để lấy danh sách models
        return {
            "current_model": OLLAMA_MODEL,
            "base_url": OPENAI_BASE_URL,
            "status": "active"
        }
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Lỗi khi lấy thông tin models: {str(e)}"
        )

if __name__ == "__main__":
    uvicorn.run(
        "api:app",
        host=HOST,
        port=PORT,
        reload=False,  # Tắt reload trong production
        access_log=True
    )
