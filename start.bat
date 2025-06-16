@echo off
rem Script khởi động cho production trên Windows

echo Starting AI News Summarizer API...

rem Thiết lập biến môi trường
if "%OLLAMA_BASE_URL%"=="" set OLLAMA_BASE_URL=http://localhost:11434/v1
if "%OLLAMA_MODEL%"=="" set OLLAMA_MODEL=qwen3:0.6b-q4_K_M
if "%PORT%"=="" set PORT=8000
if "%HOST%"=="" set HOST=0.0.0.0

rem Chạy API với uvicorn
uvicorn api:app --host %HOST% --port %PORT% --workers 1
