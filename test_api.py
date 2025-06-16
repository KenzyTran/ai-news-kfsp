import requests
import json

# URL của API
BASE_URL = "http://localhost:8000"

def test_health():
    """Test health check endpoint"""
    response = requests.get(f"{BASE_URL}/health")
    print("=== Health Check ===")
    print(f"Status Code: {response.status_code}")
    print(f"Response: {response.json()}")
    print()

def test_summarize():
    """Test summarize endpoint"""
    sample_text = """
    Hôm nay 16/6/2025, Thủ tướng Chính phủ đã ký quyết định phê duyệt dự án đầu tư công nghệ AI mới 
    với tổng kinh phí 500 tỷ đồng. Dự án này nhằm mục đích phát triển hệ thống AI phục vụ cho việc 
    quản lý thông tin và tự động hóa các quy trình hành chính công. Theo kế hoạch, dự án sẽ được 
    triển khai trong vòng 3 năm và sẽ áp dụng tại tất cả các bộ, ngành trên toàn quốc.
    """
    
    payload = {
        "text": sample_text
    }
    
    response = requests.post(f"{BASE_URL}/summarize", json=payload)
    print("=== Summarize Test ===")
    print(f"Status Code: {response.status_code}")
    print(f"Response: {json.dumps(response.json(), ensure_ascii=False, indent=2)}")
    print()

def test_root():
    """Test root endpoint"""
    response = requests.get(f"{BASE_URL}/")
    print("=== Root Endpoint ===")
    print(f"Status Code: {response.status_code}")
    print(f"Response: {json.dumps(response.json(), ensure_ascii=False, indent=2)}")
    print()

if __name__ == "__main__":
    try:
        test_root()
        test_health() 
        test_summarize()
    except requests.exceptions.ConnectionError:
        print("Lỗi: Không thể kết nối với API. Hãy đảm bảo API đang chạy trên http://localhost:8000")
    except Exception as e:
        print(f"Lỗi: {e}")
