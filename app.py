import os
import gradio as gr
import requests
import json

# Cấu hình
API_BASE_URL = "http://18.143.77.190"  # API trên EC2

# Khởi tạo client Ollama
# client_ollama = OpenAI(
#     base_url=OPENAI_BASE_URL,
#     api_key='123'
# )

def clean_response(text):
    """Loại bỏ phần <think> và chỉ lấy câu trả lời"""
    # Không cần regex vì API đã xử lý
    return text.strip()

def summarize_text(text):
    """Tóm tắt văn bản bằng API trên EC2"""
    if not text.strip():
        return "Vui lòng nhập nội dung cần tóm tắt"
    
    try:
        # Gọi API trên EC2 với timeout lớn hơn
        payload = {"text": text}
        response = requests.post(
            f"{API_BASE_URL}/summarize", 
            json=payload, 
            timeout=120  # Tăng timeout lên 2 phút
        )
        
        if response.status_code == 200:
            result = response.json()
            if result.get("success"):
                return result.get("summary", "Không có kết quả")
            else:
                return f"Lỗi từ API: {result.get('error', 'Không xác định')}"
        else:
            return f"Lỗi HTTP {response.status_code}: {response.text}"
        
    except requests.exceptions.Timeout:
        return "Lỗi: API mất quá nhiều thời gian xử lý. Hãy thử lại với văn bản ngắn hơn."
    except requests.exceptions.RequestException as e:
        return f"Lỗi kết nối: {str(e)}"
    except Exception as e:
        return f"Lỗi: {str(e)}"

# Tạo giao diện
with gr.Blocks() as demo:
    gr.Markdown("# AI Tóm tắt tin tức")
    
    text_input = gr.Textbox(
        label="Nội dung bài viết", 
        placeholder="Dán nội dung bài viết vào đây...",
        lines=10
    )
    
    submit_btn = gr.Button("Tóm tắt", variant="primary")
    
    output = gr.Textbox(label="Kết quả", lines=5)
    
    submit_btn.click(
        fn=summarize_text,
        inputs=text_input,
        outputs=output
    )

if __name__ == "__main__":
    demo.launch()