#!/bin/bash
# VisionClaw Connectivity Test Script
# 测试 LAN 和 Tailscale 连接到 OpenClaw

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
LAN_HOST="http://10.0.0.192"
TAILSCALE_HOST="http://karls-mac-mini.tail765ae2.ts.net"
PORT="18789"
TOKEN="5c0e3d45324d766a14f6a98cabe2d79b04cde61e4fcf64f3"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  VisionClaw Connectivity Test Suite${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Test function
test_connection() {
    local name=$1
    local host=$2
    local timeout=${3:-5}
    
    echo -n -e "Testing ${YELLOW}$name${NC}... "
    
    # Health check
    if curl -s -m $timeout "$host:$PORT/health" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Health OK${NC}"
        
        # API test
        echo -n "  └─ API test... "
        response=$(curl -s -m 10 -X POST "$host:$PORT/v1/chat/completions" \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $TOKEN" \
            -d '{"model": "openclaw", "messages": [{"role": "user", "content": "ping"}], "stream": false}' 2>&1)
        
        if echo "$response" | grep -q "pong\|收到\|Hi\|OK"; then
            echo -e "${GREEN}✓ API Working${NC}"
            return 0
        else
            echo -e "${RED}✗ API Error${NC}"
            echo "  └─ Response: ${response:0:100}..."
            return 1
        fi
    else
        echo -e "${RED}✗ Unreachable${NC}"
        return 1
    fi
}

# Run tests
echo -e "${BLUE}1. LAN Connection${NC}"
LAN_OK=false
if test_connection "LAN" "$LAN_HOST"; then
    LAN_OK=true
fi
echo ""

echo -e "${BLUE}2. Tailscale Connection${NC}"
TAILSCALE_OK=false
if test_connection "Tailscale" "$TAILSCALE_HOST" 10; then
    TAILSCALE_OK=true
fi
echo ""

echo -e "${BLUE}3. OpenClaw Gateway Status${NC}"
echo -n "  Checking gateway bind... "
bind_mode=$(cat ~/.openclaw/openclaw.json 2>/dev/null | grep -o '"bind": "[^"]*"' | cut -d'"' -f4)
if [ "$bind_mode" = "auto" ]; then
    echo -e "${GREEN}✓ bind: auto (LAN + Tailscale)${NC}"
else
    echo -e "${YELLOW}⚠ bind: $bind_mode${NC}"
fi
echo ""

# Summary
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Summary${NC}"
echo -e "${BLUE}========================================${NC}"

if $LAN_OK && $TAILSCALE_OK; then
    echo -e "${GREEN}✓ All connections working!${NC}"
    echo -e "  VisionClaw can use LAN (low latency) or Tailscale (anywhere)"
    exit 0
elif $LAN_OK; then
    echo -e "${YELLOW}⚠ Only LAN working${NC}"
    echo -e "  Tailscale needs attention for outdoor use"
    exit 1
elif $TAILSCALE_OK; then
    echo -e "${YELLOW}⚠ Only Tailscale working${NC}"
    echo -e "  LAN should work when on same WiFi"
    exit 1
else
    echo -e "${RED}✗ No connections working!${NC}"
    echo -e "  Check OpenClaw gateway status: openclaw status"
    exit 2
fi
