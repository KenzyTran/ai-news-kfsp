#!/bin/bash

# Helper function to detect server IP
get_server_ip() {
    # Try multiple methods to get external IP
    local ip
    
    # Method 1: External IP services
    ip=$(curl -s --connect-timeout 3 ifconfig.me 2>/dev/null)
    if [ -n "$ip" ] && [[ "$ip" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        echo "$ip"
        return 0
    fi
    
    # Method 2: Alternative external IP service
    ip=$(curl -s --connect-timeout 3 ipinfo.io/ip 2>/dev/null)
    if [ -n "$ip" ] && [[ "$ip" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        echo "$ip"
        return 0
    fi
    
    # Method 3: Local IP (fallback)
    ip=$(hostname -I | awk '{print $1}' 2>/dev/null)
    if [ -n "$ip" ] && [[ "$ip" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        echo "$ip"
        return 0
    fi
    
    # Method 4: Interface IP
    ip=$(ip route get 8.8.8.8 | awk '{print $7; exit}' 2>/dev/null)
    if [ -n "$ip" ] && [[ "$ip" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        echo "$ip"
        return 0
    fi
    
    # Fallback
    echo "localhost"
    return 1
}

# Function to show service URLs
show_service_urls() {
    local server_ip=$(get_server_ip)
    
    echo "🌐 Services available at:"
    echo "   - API: http://$server_ip:8000"
    echo "   - API Docs: http://$server_ip:8000/docs"
    echo "   - Health Check: http://$server_ip:8000/health"
    echo "   - Ollama: http://$server_ip:11434"
    echo ""
    echo "🧪 Test commands:"
    echo "   curl http://$server_ip:8000/health"
    echo "   curl http://$server_ip:8000/docs"
}

# Export functions for use in other scripts
export -f get_server_ip
export -f show_service_urls
