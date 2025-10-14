#!/bin/bash
# Test VibeVM APIs with Authentication
# This script handles login and uses session cookies for API access

set -e

# Configuration
VIBEVM_URL="${VIBEVM_URL:-http://localhost:8080}"
USERNAME="${VIBEVM_USERNAME:-admin}"
PASSWORD="${VIBEVM_PASSWORD:-admin}"
COOKIE_FILE="/tmp/vibevm-session-cookies.txt"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

echo -e "${BOLD}${BLUE}🔐 VibeVM Authenticated API Test Suite${NC}"
echo "=========================================="
echo "Target: $VIBEVM_URL"
echo ""

# Step 1: Login and get session cookie
echo -e "${BOLD}Step 1: Authenticating...${NC}"
login_response=$(curl -s -c $COOKIE_FILE -X POST \
    "$VIBEVM_URL/auth/login" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "username=$USERNAME&password=$PASSWORD" \
    -w "\n%{http_code}")

http_code=$(echo "$login_response" | tail -n 1)

if [ "$http_code" = "200" ] || [ "$http_code" = "302" ]; then
    echo -e "${GREEN}✅ Authentication successful!${NC}"
else
    echo -e "${RED}❌ Authentication failed (HTTP $http_code)${NC}"
    echo "Response: $(echo \"$login_response\" | head -n -1)"
    exit 1
fi

# Test function with cookies
test_api() {
    local name="$1"
    local endpoint="$2"
    local method="${3:-GET}"
    local data="$4"

    echo -n -e "🧪 Testing: $name ... "

    if [ "$method" = "POST" ]; then
        response=$(curl -s -b $COOKIE_FILE -w "\n%{http_code}" -X POST \
            -H "Content-Type: application/json" \
            -d "$data" \
            "$VIBEVM_URL$endpoint" 2>&1)
    else
        response=$(curl -s -b $COOKIE_FILE -w "\n%{http_code}" "$VIBEVM_URL$endpoint" 2>&1)
    fi

    http_code=$(echo "$response" | tail -1)
    body=$(echo "$response" | sed '$d')

    if [ "$http_code" = "200" ]; then
        echo -e "${GREEN}✅ PASSED${NC}"
        # Show first line of response
        first_line=$(echo "$body" | head -n 1 | cut -c 1-60)
        if [ ! -z "$first_line" ]; then
            echo -e "   ${GREEN}↳ ${first_line}...${NC}"
        fi
        return 0
    else
        echo -e "${RED}❌ FAILED (HTTP $http_code)${NC}"
        return 1
    fi
}

echo ""
echo -e "${BOLD}${BLUE}📦 Testing APIs with Authentication${NC}"
echo "=========================================="

# Test sandbox info
test_api "Sandbox Info" "/v1/sandbox"

# Test shell execution
test_api "Shell Execution" "/v1/shell/exec" "POST" '{"command": "echo Hello VibeVM && whoami"}'

# Test file write
test_api "File Write" "/v1/file/write" "POST" '{"path": "/home/gem/auth-test.txt", "content": "Authenticated test"}'

# Test file read
test_api "File Read" "/v1/file/read" "POST" '{"file": "/home/gem/auth-test.txt"}'

# Test browser screenshot
test_api "Browser Screenshot" "/v1/browser/screenshot" "POST"

# Test Python
echo -e "\n${BOLD}${BLUE}🐍 Testing Python Environment${NC}"
echo "=========================================="
test_api "Python Version" "/v1/shell/exec" "POST" '{"command": "python3 --version"}'
test_api "Node Version" "/v1/shell/exec" "POST" '{"command": "node --version"}'
test_api "Git Version" "/v1/shell/exec" "POST" '{"command": "git --version"}'

echo ""
echo -e "${GREEN}${BOLD}✅ All tests completed!${NC}"
echo -e "${YELLOW}Session cookie saved to: $COOKIE_FILE${NC}"
echo ""
echo -e "${BOLD}💡 You can now use this cookie for API requests:${NC}"
echo -e "   curl -b $COOKIE_FILE $VIBEVM_URL/v1/sandbox"

# Cleanup
# rm -f $COOKIE_FILE
