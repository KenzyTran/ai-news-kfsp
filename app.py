import os
import gradio as gr
from openai import OpenAI
import re

# Cấu hình
OPENAI_BASE_URL = "http://localhost:11434/v1"
OLLAMA_MODEL = 'qwen3:0.6b-q4_K_M'  # Thay đổi model nếu cần

# Khởi tạo client Ollama
client_ollama = OpenAI(
    base_url=OPENAI_BASE_URL,
    api_key='123'
)

def clean_response(text):
    """Loại bỏ phần <think> và chỉ lấy câu trả lời"""
    # Loại bỏ phần <think>...</think>
    text = re.sub(r'<think>.*?</think>', '', text, flags=re.DOTALL)
    
    # Loại bỏ các thẻ XML khác nếu có
    text = re.sub(r'<[^>]+>', '', text)
    
    # Loại bỏ khoảng trắng thừa
    text = text.strip()
    
    return text

def summarize_text(text):
    """Tóm tắt văn bản bằng Ollama"""
    if not text.strip():
        return "Vui lòng nhập nội dung cần tóm tắt"
    
    try:
        prompt = f"Tóm tắt nội dung tin tức sau:\n\n{text}"

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
        result = clean_response(response.choices[0].message.content)
        
        return result
        
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