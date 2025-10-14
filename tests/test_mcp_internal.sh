#!/bin/bash
# Test MCP servers from inside the VibeVM container (bypasses auth)

echo "🚀 Testing VibeVM MCP Servers (Internal)"
echo "=========================================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PASSED=0
FAILED=0

# Test function
test_endpoint() {
    local name="$1"
    local url="$2"
    local method="${3:-GET}"
    local data="$4"

    echo -n "🧪 Testing: $name ... "

    if [ "$method" = "POST" ]; then
        response=$(curl -s -w "\n%{http_code}" -X POST -H "Content-Type: application/json" -d "$data" "$url" 2>&1)
    else
        response=$(curl -s -w "\n%{http_code}" "$url" 2>&1)
    fi

    http_code=$(echo "$response" | tail -n 1)
    body=$(echo "$response" | head -n -1)

    if [ "$http_code" = "200" ]; then
        echo -e "${GREEN}✅ PASSED${NC}"
        echo -e "   ${GREEN}↳ Status: $http_code${NC}"
        PASSED=$((PASSED + 1))
        return 0
    else
        echo -e "${RED}❌ FAILED${NC}"
        echo -e "   ${RED}↳ Status: $http_code${NC}"
        FAILED=$((FAILED + 1))
        return 1
    fi
}

echo -e "${BLUE}📦 Basic API Tests${NC}"
echo "-----------------------------------"

# Test sandbox info
test_endpoint "Sandbox Info" "http://localhost:8080/v1/sandbox"

# Test shell execution
test_endpoint "Shell Execution" "http://localhost:8080/v1/shell/exec" "POST" '{"command": "echo Hello && whoami"}'

# Test file write
test_endpoint "File Write" "http://localhost:8080/v1/file/write" "POST" '{"path": "/home/gem/test.txt", "content": "Test content"}'

# Test file read
test_endpoint "File Read" "http://localhost:8080/v1/file/read" "POST" '{"file": "/home/gem/test.txt"}'

# Test browser screenshot
test_endpoint "Browser Screenshot" "http://localhost:8080/v1/browser/screenshot" "POST"

echo ""
echo -e "${BLUE}🔌 MCP Server Tests${NC}"
echo "-----------------------------------"

# Test MCP hub
test_endpoint "MCP Hub" "http://localhost:8079"

# Test MCP browser server
test_endpoint "MCP Browser Server" "http://localhost:8100"

# Test MCP markitdown server
test_endpoint "MCP Markitdown Server" "http://localhost:8101"

# Test MCP chrome devtools server
test_endpoint "MCP Chrome DevTools Server" "http://localhost:8102"

echo ""
echo -e "${BLUE}🐍 Environment Tests${NC}"
echo "-----------------------------------"

# Test Python via shell
echo -n "🧪 Testing: Python Environment ... "
python_output=$(curl -s -X POST -H "Content-Type: application/json" \
    -d '{"command": "python3 --version"}' \
    http://localhost:8080/v1/shell/exec | jq -r '.output' 2>/dev/null)
if [[ $python_output == *"Python"* ]]; then
    echo -e "${GREEN}✅ PASSED${NC}"
    echo -e "   ${GREEN}↳ $python_output${NC}"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}❌ FAILED${NC}"
    FAILED=$((FAILED + 1))
fi

# Test Node.js via shell
echo -n "🧪 Testing: Node.js Environment ... "
node_output=$(curl -s -X POST -H "Content-Type: application/json" \
    -d '{"command": "node --version"}' \
    http://localhost:8080/v1/shell/exec | jq -r '.output' 2>/dev/null)
if [[ $node_output == *"v"* ]]; then
    echo -e "${GREEN}✅ PASSED${NC}"
    echo -e "   ${GREEN}↳ $node_output${NC}"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}❌ FAILED${NC}"
    FAILED=$((FAILED + 1))
fi

# Test git via shell
echo -n "🧪 Testing: Git Environment ... "
git_output=$(curl -s -X POST -H "Content-Type: application/json" \
    -d '{"command": "git --version"}' \
    http://localhost:8080/v1/shell/exec | jq -r '.output' 2>/dev/null)
if [[ $git_output == *"git version"* ]]; then
    echo -e "${GREEN}✅ PASSED${NC}"
    echo -e "   ${GREEN}↳ $git_output${NC}"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}❌ FAILED${NC}"
    FAILED=$((FAILED + 1))
fi

echo ""
echo -e "${BLUE}🔗 TEE Tests${NC}"
echo "-----------------------------------"

# Test dstack socket
echo -n "🧪 Testing: Dstack TEE Socket ... "
if [ -S /var/run/dstack.sock ]; then
    tee_output=$(curl -s --unix-socket /var/run/dstack.sock http://localhost/info 2>/dev/null)
    if [[ $tee_output == *"app_id"* ]]; then
        echo -e "${GREEN}✅ PASSED${NC}"
        echo -e "   ${GREEN}↳ TEE socket accessible${NC}"
        PASSED=$((PASSED + 1))
    else
        echo -e "${YELLOW}⚠️  SKIPPED${NC}"
        echo -e "   ${YELLOW}↳ Socket exists but no response (TEE may not be initialized)${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  SKIPPED${NC}"
    echo -e "   ${YELLOW}↳ Not running in TEE environment${NC}"
fi

echo ""
echo -e "${BLUE}⚡ Service Status${NC}"
echo "-----------------------------------"

# Check supervisord status
echo "📊 Supervisor Services:"
supervisorctl status | while read line; do
    if [[ $line == *"RUNNING"* ]]; then
        echo -e "   ${GREEN}✓${NC} $line"
    else
        echo -e "   ${RED}✗${NC} $line"
    fi
done

echo ""
echo "=========================================="
echo -e "${BLUE}📊 Test Results${NC}"
echo "=========================================="
echo "Total Tests: $((PASSED + FAILED))"
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"

if [ $FAILED -eq 0 ]; then
    echo ""
    echo -e "${GREEN}🎉 All MCP tests passed!${NC}"
    echo -e "${GREEN}✅ Your VibeVM MCP servers are ready for production!${NC}"
    exit 0
else
    echo ""
    echo -e "${YELLOW}⚠️  $FAILED test(s) failed${NC}"
    echo -e "${YELLOW}Review the errors above before deploying to production${NC}"
    exit 1
fi
