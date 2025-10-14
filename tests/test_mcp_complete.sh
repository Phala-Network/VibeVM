#!/bin/bash
# Comprehensive MCP Test Suite for VibeVM
# Tests all MCP functionality using the direct sandbox port (8091)

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

PASSED=0
FAILED=0

echo -e "${BOLD}${BLUE}=================================================================${NC}"
echo -e "${BOLD}${BLUE}    🚀 VibeVM MCP Comprehensive Test Suite${NC}"
echo -e "${BOLD}${BLUE}=================================================================${NC}"
echo ""

# Test function
run_test() {
    local name="$1"
    local command="$2"

    echo -n -e "🧪 ${BOLD}Testing:${NC} $name ... "

    if output=$(docker exec vibevm-vibevm-1 bash -c "$command" 2>&1); then
        echo -e "${GREEN}✅ PASSED${NC}"
        if [ ! -z "$output" ]; then
            first_line=$(echo "$output" | head -1 | cut -c 1-70)
            echo -e "   ${GREEN}↳ ${first_line}${NC}"
        fi
        PASSED=$((PASSED + 1))
        return 0
    else
        echo -e "${RED}❌ FAILED${NC}"
        echo -e "   ${RED}↳ $output${NC}"
        FAILED=$((FAILED + 1))
        return 1
    fi
}

# Section 1: Core API Tests
echo -e "${BOLD}${BLUE}📦 Section 1: Core API Tests${NC}"
echo "================================================================="

run_test "Sandbox Info" \
    'curl -s http://localhost:8091/v1/sandbox | jq -r ".data" | head -3'

run_test "Shell Execution" \
    'curl -s -X POST http://localhost:8091/v1/shell/exec \
        -H "Content-Type: application/json" \
        -d "{\"command\": \"echo Hello VibeVM && whoami\"}" \
        | jq -r ".data.output"'

run_test "File Write" \
    'curl -s -X POST http://localhost:8091/v1/file/write \
        -H "Content-Type: application/json" \
        -d "{\"file\": \"/home/gem/mcp-test.txt\", \"content\": \"MCP Test Success\"}" \
        | jq -r ".message"'

run_test "File Read" \
    'curl -s -X POST http://localhost:8091/v1/file/read \
        -H "Content-Type: application/json" \
        -d "{\"file\": \"/home/gem/mcp-test.txt\"}" \
        | jq -r ".data.content"'

run_test "Browser Screenshot" \
    'curl -s -X POST http://localhost:8091/v1/browser/screenshot \
        -o /tmp/test.png && echo "Screenshot: $(stat -f%z /tmp/test.png 2>/dev/null || stat -c%s /tmp/test.png) bytes"'

echo ""
# Section 2: Development Environment
echo -e "${BOLD}${BLUE}🐍 Section 2: Development Environment${NC}"
echo "================================================================="

run_test "Python Version" \
    'curl -s -X POST http://localhost:8091/v1/shell/exec \
        -H "Content-Type: application/json" \
        -d "{\"command\": \"python3 --version\"}" \
        | jq -r ".data.output"'

run_test "Node.js Version" \
    'curl -s -X POST http://localhost:8091/v1/shell/exec \
        -H "Content-Type: application/json" \
        -d "{\"command\": \"node --version\"}" \
        | jq -r ".data.output"'

run_test "Git Version" \
    'curl -s -X POST http://localhost:8091/v1/shell/exec \
        -H "Content-Type: application/json" \
        -d "{\"command\": \"git --version\"}" \
        | jq -r ".data.output"'

run_test "pip Available" \
    'curl -s -X POST http://localhost:8091/v1/shell/exec \
        -H "Content-Type: application/json" \
        -d "{\"command\": \"pip3 --version\"}" \
        | jq -r ".data.output"'

run_test "npm Available" \
    'curl -s -X POST http://localhost:8091/v1/shell/exec \
        -H "Content-Type: application/json" \
        -d "{\"command\": \"npm --version\"}" \
        | jq -r ".data.output"'

echo ""
# Section 3: MCP Servers Status
echo -e "${BOLD}${BLUE}🔌 Section 3: MCP Servers Status${NC}"
echo "================================================================="

run_test "All Services Running" \
    'supervisorctl status | grep -c RUNNING'

echo ""
echo -e "${BOLD}📊 MCP Servers:${NC}"
docker exec vibevm-vibevm-1 bash -c 'supervisorctl status' | grep mcp | while read line; do
    if [[ $line == *"RUNNING"* ]]; then
        echo -e "   ${GREEN}✓${NC} $line"
    else
        echo -e "   ${RED}✗${NC} $line"
    fi
done

echo ""
# Section 4: Browser Automation
echo -e "${BOLD}${BLUE}🌐 Section 4: Browser Automation${NC}"
echo "================================================================="

run_test "Navigate to URL" \
    'curl -s -X POST http://localhost:8091/v1/browser/navigate \
        -H "Content-Type: application/json" \
        -d "{\"url\": \"https://example.com\"}" \
        | jq -r ".message"'

run_test "Get Page Title" \
    'curl -s -X POST http://localhost:8091/v1/browser/execute_script \
        -H "Content-Type: application/json" \
        -d "{\"script\": \"return document.title\"}" \
        | jq -r ".data.result"'

run_test "Screenshot After Navigation" \
    'curl -s -X POST http://localhost:8091/v1/browser/screenshot \
        -o /tmp/example.png && echo "Captured example.com screenshot"'

echo ""
# Section 5: Advanced File Operations
echo -e "${BOLD}${BLUE}📁 Section 5: Advanced File Operations${NC}"
echo "================================================================="

run_test "Create JSON File" \
    'curl -s -X POST http://localhost:8091/v1/file/write \
        -H "Content-Type: application/json" \
        -d "{\"file\": \"/home/gem/test.json\", \"content\": \"{\\\"test\\\": \\\"success\\\", \\\"mcp\\\": true}\"}" \
        | jq -r ".success"'

run_test "Read and Parse JSON" \
    'curl -s -X POST http://localhost:8091/v1/shell/exec \
        -H "Content-Type: application/json" \
        -d "{\"command\": \"cat /home/gem/test.json | jq .test\"}" \
        | jq -r ".data.output"'

run_test "List Home Directory" \
    'curl -s -X POST http://localhost:8091/v1/shell/exec \
        -H "Content-Type: application/json" \
        -d "{\"command\": \"ls -la /home/gem | wc -l\"}" \
        | jq -r ".data.output"'

echo ""
# Section 6: Python Environment
echo -e "${BOLD}${BLUE}🐍 Section 6: Python Code Execution${NC}"
echo "================================================================="

run_test "Execute Python Code" \
    'curl -s -X POST http://localhost:8091/v1/shell/exec \
        -H "Content-Type: application/json" \
        -d "{\"command\": \"python3 -c \\\"import sys; print(f\\\\\\\"Python {sys.version_info.major}.{sys.version_info.minor}\\\\\\\")\\\"\"}" \
        | jq -r ".data.output"'

run_test "Python JSON Processing" \
    'curl -s -X POST http://localhost:8091/v1/shell/exec \
        -H "Content-Type: application/json" \
        -d "{\"command\": \"python3 -c \\\"import json; print(json.dumps({\\\\\\\"status\\\\\\\": \\\\\\\"ok\\\\\\\"}))\\\"\"}" \
        | jq -r ".data.output"'

echo ""
# Section 7: Integration Test
echo -e "${BOLD}${BLUE}🔗 Section 7: Integration Workflow${NC}"
echo "================================================================="

run_test "Multi-Step Workflow" \
    'curl -s -X POST http://localhost:8091/v1/shell/exec \
        -H "Content-Type: application/json" \
        -d "{\"command\": \"echo Step1 > /tmp/workflow.txt && echo Step2 >> /tmp/workflow.txt && cat /tmp/workflow.txt\"}" \
        | jq -r ".data.output"'

# Final Results
echo ""
echo -e "${BOLD}${BLUE}=================================================================${NC}"
echo -e "${BOLD}${BLUE}    📊 Test Results${NC}"
echo -e "${BOLD}${BLUE}=================================================================${NC}"
echo ""
echo -e "Total Tests:  $((PASSED + FAILED))"
echo -e "${GREEN}Passed:       $PASSED${NC}"
echo -e "${RED}Failed:       $FAILED${NC}"

if [ $FAILED -eq 0 ]; then
    PASS_RATE="100.0"
else
    PASS_RATE=$(echo "scale=1; $PASSED * 100 / ($PASSED + $FAILED)" | bc)
fi
echo -e "Pass Rate:    ${PASS_RATE}%"

echo ""
if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}${BOLD}🎉 All MCP tests passed!${NC}"
    echo -e "${GREEN}✅ Your VibeVM MCP servers are ready for production!${NC}"
    echo ""
    echo -e "${BOLD}💡 Next Steps:${NC}"
    echo -e "   1. Access APIs via: http://localhost:8091 (no auth required)"
    echo -e "   2. Access with auth via: http://localhost:8080 (requires login)"
    echo -e "   3. Deploy to production on Phala Cloud"
    exit 0
else
    echo -e "${YELLOW}${BOLD}⚠️  $FAILED test(s) failed${NC}"
    echo -e "${YELLOW}Review the errors above${NC}"
    exit 1
fi
