# VibeVM 🚀

<div align="center">

```
██╗   ██╗██╗██████╗ ███████╗██╗   ██╗███╗   ███╗
██║   ██║██║██╔══██╗██╔════╝██║   ██║████╗ ████║
██║   ██║██║██████╔╝█████╗  ██║   ██║██╔████╔██║
╚██╗ ██╔╝██║██╔══██╗██╔══╝  ╚██╗ ██╔╝██║╚██╔╝██║
 ╚████╔╝ ██║██████╔╝███████╗ ╚████╔╝ ██║ ╚═╝ ██║
  ╚═══╝  ╚═╝╚═════╝ ╚══════╝  ╚═══╝  ╚═╝     ╚═╝
```

**Good Vibes, Zero Trust Required**
*Powered by Phala Cloud CVM x AIO Sandbox*

</div>

## Overview

VibeVM Desktop is a secure, lightweight desktop environment built on top of the AIO Sandbox, designed specifically for deployment in Phala Cloud Confidential Virtual Machines (CVMs). It provides an authenticated, browser-accessible desktop with modern tools and a user-friendly interface.

## Why VibeVM?

Stop juggling multiple tools and environments. VibeVM gives you everything you need to build AI agents:

- **🌐 Browser Control** - Full Chrome browser with VNC, Playwright, and automation tools
- **💻 VSCode Server** - Complete IDE in your browser, no local setup needed
- **📦 Pre-installed Tools** - Python 3.13, Node.js 22, git, gh CLI, and 20+ developer tools via apt
- **🔒 TEE Security** - Cryptographic key derivation and remote attestation via Dstack
- **📁 Unified Workspace** - All tools share the same filesystem - no more file shuffling
- **📱 Mobile Access** - Code on the go with Happy CLI mobile connection

**Perfect for:** Web scraping agents, blockchain applications, confidential computing, secure API integrations, and any AI agent that needs both automation and cryptographic guarantees.

## Files in This Repository

### docker-compose.yaml
The complete deployment configuration for VibeVM. Copy this entire file and paste it into your Phala Cloud dashboard when deploying.
![alt text](image.png)

**Features:**
- ✅ Happy CLI installation for mobile remote connection (configurable)
- ✅ Claude Code AI assistant installation (configurable)
- ✅ GitHub repository auto-cloning on startup
- ✅ TEE socket mounting for cryptographic operations
- ✅ Docker socket access for container management
- ✅ Complete environment setup (Python, Node.js, git, gh CLI)
- ✅ Automatic user creation with sudo privileges
- ✅ Persistent workspace volume

[📄 View docker-compose.yaml](docker-compose.yaml)

### .env.example (for local testing)
Template for environment variables when testing locally:

```bash
# GitHub Integration
GITHUB_REPO=your-username/your-repo
GH_TOKEN=ghp_your_github_token_here

# Phala Cloud API (Optional)
PHALA_API_KEY=your_phala_api_key

# Optional: Customize display
DISPLAY_WIDTH=1920
DISPLAY_HEIGHT=1080
TZ=America/New_York
```

Copy `.env.example` to `.env` for local Docker testing, but **set these as secrets in Phala Cloud dashboard** for production deployments.

---

## Quick Reference

### Default Configuration
```bash
# User context
USER=gem
HOME=/home/gem
WORKSPACE=/workspace
```

### Key Locations
```bash
/home/gem/                    # Your home directory (persisted)
/home/gem/your-repo-name/     # Auto-cloned GitHub repo
/var/run/dstack.sock          # TEE API socket
/workspace/                   # Persistent volume
```

### Port Mapping
```bash
8080  # Main UI (VNC, VSCode, API docs, dashboard)
8089  # MCP Server
8079  # Additional services
8000  # Additional services  
8091  # Additional services
```

### Essential Commands
```bash
# GitHub authentication
gh auth login

# Access TEE info
curl --unix-socket /var/run/dstack.sock http://localhost/info

# View running services
sudo supervisorctl status

# Connect from mobile device
happy
```

---

## Getting Started

There are two ways to deploy VibeVM to Phala Cloud:

1. **Web Dashboard** (Recommended for beginners) - Simple UI-based deployment
2. **Phala Cloud API** (Recommended for automation) - Programmatic deployment with full control

---

## Option 1: Deploy via Web Dashboard (5 Minutes)

### Step 1: Sign Up for Phala Cloud

1. Go to [phala.com](https://phala.com) and create an account
2. Navigate to the dashboard and click **"Deploy New CVM"**

### Step 2: Configure Your VibeVM

1. **Copy the `docker-compose.yaml`** from this repo
2. **Paste it into the Phala Cloud dashboard** deployment configuration
3. **Select a Large TDX machine** for optimal performance

> ⚠️ **Cost Management Tip:** VibeVMs are designed for active development sessions. Turn them off when not in use to avoid unnecessary costs. They're powerful machines - don't leave them running 24/7!

### Step 3: Set Your Environment Variables

Configure these environment variables in the Phala Cloud dashboard:

#### Required Environment Variables

```bash
# Auto-clone your GitHub repository on startup
GITHUB_REPO=your-username/your-repo

# GitHub Personal Access Token (required for private repos)
GH_TOKEN=ghp_your_github_token_here
```

#### Optional Configuration

```bash
# Tool Installation
INSTALL_HAPPY=true       # Happy CLI for mobile remote access
INSTALL_CLAUDE=true      # Claude Code AI assistant

# Authentication (change default credentials!)
VIBEVM_USERNAME=admin
VIBEVM_PASSWORD=your_secure_password

# Display Settings
DISPLAY_WIDTH=1920
DISPLAY_HEIGHT=1080
TZ=America/New_York

# Session timeout (in seconds, default: 24 hours)
SESSION_TIMEOUT=86400
```

**Don't have a GitHub token?** Generate one at: https://github.com/settings/tokens/new

**Required Token Permissions (Scopes):**
- ✅ `repo` - Full control of repositories (clone, pull, push)
- ✅ `workflow` - Update GitHub Actions workflows (if using CI/CD)
- ✅ `read:org` - Read org membership (optional, for organization repos)

**For classic tokens:** Select "repo" and "workflow" scopes
**For fine-grained tokens:** Grant "Contents: Read and write" + "Workflows: Read and write" permissions

> 💡 **Pro Tip:** Always set `GITHUB_REPO` if you want your code ready when the VibeVM starts. The repo will be automatically cloned to `/home/gem/your-repo/`

### Step 4: Deploy & Access

1. Click **"Deploy"** in the Phala Cloud dashboard
2. Wait 2-3 minutes for your VibeVM to spin up
3. Go to the **"Network"** tab
4. **Click the URL** that targets **port 8080**

That's it! Your VibeVM is now running. 🎉

---

## Option 2: Deploy via Phala Cloud API (Advanced)

For automation, CI/CD pipelines, or programmatic deployments, use the Phala Cloud API.

### Prerequisites

1. **Get your API Key:**
   - Log into Phala Cloud dashboard
   - Navigate to Settings → API Keys
   - Create a new API key

2. **Verify your API Key:**
   ```bash
   curl -X GET https://cloud-api.phala.network/v1/users/me \
     -H "X-API-Key: YOUR_API_KEY"
   ```

### Step-by-Step API Deployment

#### 1. Discover Available Nodes

Find available nodes that support the VibeVM image:

```bash
curl -X GET https://cloud-api.phala.network/v1/teepods/available \
  -H "X-API-Key: YOUR_API_KEY" \
  | jq '.'
```

**Response example:**
```json
{
  "nodes": [
    {
      "node_id": "tdx-node-001",
      "region": "us-west-1",
      "available_cpu": 16,
      "available_memory_gb": 64,
      "available_disk_gb": 500,
      "supported_images": ["ghcr.io/agent-infra/sandbox:1.0.0.126"]
    }
  ]
}
```

#### 2. Prepare Your docker-compose.yaml

Read and encode your docker-compose.yaml file:

```bash
# Read the compose file
COMPOSE_CONTENT=$(cat docker-compose.yaml)

# Create a JSON payload with your compose file
cat > deployment.json <<EOF
{
  "name": "vibevm-production",
  "image": "ghcr.io/agent-infra/sandbox:1.0.0.126",
  "cpu": 8,
  "memory_gb": 32,
  "disk_gb": 100,
  "compose_file": $(echo "$COMPOSE_CONTENT" | jq -Rs .),
  "kms_type": "builtin"
}
EOF
```

#### 3. Provision Resources

Create a CVM provisioning request:

```bash
curl -X POST https://cloud-api.phala.network/v1/cvms/provision \
  -H "X-API-Key: YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d @deployment.json
```

**Response:**
```json
{
  "app_id": "app_abc123xyz",
  "compose_hash": "0x1234567890abcdef...",
  "status": "provisioned"
}
```

#### 4. Set Environment Variables (Encrypted)

Phala Cloud encrypts environment variables for security. Here's how to set them:

**Option A: Using Plain Text (Dashboard Method)**

Set environment variables in the Phala Cloud dashboard as key-value pairs. They will be automatically encrypted.

**Option B: Using Encrypted Variables (API Method)**

```python
# Python example for encrypting environment variables
import json
import base64
from cryptography.hazmat.primitives.asymmetric import x25519
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.primitives import serialization
import os

def encrypt_env_vars(env_dict, cvm_public_key_hex):
    # Generate ephemeral key pair
    private_key = x25519.X25519PrivateKey.generate()
    public_key = private_key.public_key()

    # Load CVM public key
    cvm_public_key = x25519.X25519PublicKey.from_public_bytes(
        bytes.fromhex(cvm_public_key_hex)
    )

    # Derive shared secret
    shared_secret = private_key.exchange(cvm_public_key)

    # Encrypt environment variables
    plaintext = json.dumps(env_dict).encode('utf-8')
    nonce = os.urandom(12)
    cipher = Cipher(
        algorithms.AES(shared_secret[:32]),
        modes.GCM(nonce)
    )
    encryptor = cipher.encryptor()
    ciphertext = encryptor.update(plaintext) + encryptor.finalize()

    # Return encrypted payload
    return {
        "ephemeral_public_key": public_key.public_bytes(
            encoding=serialization.Encoding.Raw,
            format=serialization.PublicFormat.Raw
        ).hex(),
        "nonce": nonce.hex(),
        "ciphertext": ciphertext.hex(),
        "tag": encryptor.tag.hex()
    }

# Your environment variables
env_vars = {
    "GITHUB_REPO": "your-username/your-repo",
    "GH_TOKEN": "ghp_your_token_here",
    "INSTALL_HAPPY": "true",
    "INSTALL_CLAUDE": "true",
    "VIBEVM_USERNAME": "admin",
    "VIBEVM_PASSWORD": "your_secure_password"
}

# Get CVM public key from provisioning response
cvm_public_key = "YOUR_CVM_PUBLIC_KEY_HEX"

# Encrypt and print
encrypted = encrypt_env_vars(env_vars, cvm_public_key)
print(json.dumps(encrypted, indent=2))
```

#### 5. Create CVM Instance

Deploy your VibeVM with the provisioned resources:

```bash
curl -X POST https://cloud-api.phala.network/v1/cvms \
  -H "X-API-Key: YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "app_id": "app_abc123xyz",
    "compose_hash": "0x1234567890abcdef...",
    "encrypted_env": {
      "ephemeral_public_key": "...",
      "nonce": "...",
      "ciphertext": "...",
      "tag": "..."
    }
  }'
```

**Response:**
```json
{
  "cvm_id": "cvm_xyz789abc",
  "status": "deploying",
  "endpoints": [
    {
      "port": 8080,
      "url": "https://cvm-xyz789abc.phala.cloud:8080"
    },
    {
      "port": 8000,
      "url": "https://cvm-xyz789abc.phala.cloud:8000"
    }
  ]
}
```

#### 6. Monitor Deployment Status

Check your deployment status:

```bash
curl -X GET https://cloud-api.phala.network/v1/cvms/cvm_xyz789abc \
  -H "X-API-Key: YOUR_API_KEY"
```

#### 7. Access Your VibeVM

Once the status shows `"running"`, access your VibeVM:

```bash
# Main UI
open https://cvm-xyz789abc.phala.cloud:8080

# Or via curl
curl https://cvm-xyz789abc.phala.cloud:8080/v1/sandbox
```

### Complete Python Deployment Script

Here's a complete example that automates the entire deployment:

```python
#!/usr/bin/env python3
import requests
import json
import time
from pathlib import Path

# Configuration
API_KEY = "YOUR_API_KEY"
BASE_URL = "https://cloud-api.phala.network/v1"
HEADERS = {
    "X-API-Key": API_KEY,
    "Content-Type": "application/json"
}

def deploy_vibevm(compose_file_path, env_vars):
    """Deploy VibeVM to Phala Cloud"""

    # 1. Check available nodes
    print("🔍 Discovering available nodes...")
    response = requests.get(f"{BASE_URL}/teepods/available", headers=HEADERS)
    nodes = response.json()["nodes"]
    print(f"✅ Found {len(nodes)} available nodes")

    # 2. Read compose file
    print("📄 Reading docker-compose.yaml...")
    compose_content = Path(compose_file_path).read_text()

    # 3. Provision resources
    print("⚙️  Provisioning resources...")
    provision_data = {
        "name": "vibevm-production",
        "image": "ghcr.io/agent-infra/sandbox:1.0.0.126",
        "cpu": 8,
        "memory_gb": 32,
        "disk_gb": 100,
        "compose_file": compose_content,
        "kms_type": "builtin"
    }

    response = requests.post(
        f"{BASE_URL}/cvms/provision",
        headers=HEADERS,
        json=provision_data
    )
    provision_result = response.json()
    app_id = provision_result["app_id"]
    compose_hash = provision_result["compose_hash"]
    print(f"✅ Provisioned: App ID {app_id}")

    # 4. Create CVM instance
    print("🚀 Creating CVM instance...")
    create_data = {
        "app_id": app_id,
        "compose_hash": compose_hash,
        "env": env_vars  # Plain text - will be encrypted by API
    }

    response = requests.post(
        f"{BASE_URL}/cvms",
        headers=HEADERS,
        json=create_data
    )
    cvm_result = response.json()
    cvm_id = cvm_result["cvm_id"]
    print(f"✅ Created CVM: {cvm_id}")

    # 5. Wait for deployment
    print("⏳ Waiting for deployment to complete...")
    while True:
        response = requests.get(
            f"{BASE_URL}/cvms/{cvm_id}",
            headers=HEADERS
        )
        status = response.json()["status"]
        print(f"   Status: {status}")

        if status == "running":
            break
        elif status == "failed":
            print("❌ Deployment failed!")
            return None

        time.sleep(10)

    # 6. Get endpoints
    endpoints = response.json()["endpoints"]
    main_url = next(ep["url"] for ep in endpoints if ep["port"] == 8080)

    print(f"\n🎉 VibeVM deployed successfully!")
    print(f"🌐 Access your VibeVM at: {main_url}")
    print(f"📝 CVM ID: {cvm_id}")

    return {
        "cvm_id": cvm_id,
        "url": main_url,
        "endpoints": endpoints
    }

# Example usage
if __name__ == "__main__":
    env_vars = {
        "GITHUB_REPO": "your-username/your-repo",
        "GH_TOKEN": "ghp_your_token_here",
        "INSTALL_HAPPY": "true",
        "INSTALL_CLAUDE": "true",
        "VIBEVM_USERNAME": "admin",
        "VIBEVM_PASSWORD": "your_secure_password"
    }

    result = deploy_vibevm("./docker-compose.yaml", env_vars)

    if result:
        print(f"\n📋 Deployment Details:")
        print(json.dumps(result, indent=2))
```

### Bash Deployment Script

For shell script automation:

```bash
#!/bin/bash
set -e

# Configuration
API_KEY="YOUR_API_KEY"
BASE_URL="https://cloud-api.phala.network/v1"
COMPOSE_FILE="docker-compose.yaml"

# Environment variables
ENV_VARS='{
  "GITHUB_REPO": "your-username/your-repo",
  "GH_TOKEN": "ghp_your_token_here",
  "INSTALL_HAPPY": "true",
  "INSTALL_CLAUDE": "true",
  "VIBEVM_USERNAME": "admin",
  "VIBEVM_PASSWORD": "your_secure_password"
}'

echo "🔍 Discovering available nodes..."
curl -s -X GET "$BASE_URL/teepods/available" \
  -H "X-API-Key: $API_KEY" | jq '.'

echo "📄 Reading compose file..."
COMPOSE_CONTENT=$(cat "$COMPOSE_FILE" | jq -Rs .)

echo "⚙️  Provisioning resources..."
PROVISION_RESPONSE=$(curl -s -X POST "$BASE_URL/cvms/provision" \
  -H "X-API-Key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d "{
    \"name\": \"vibevm-production\",
    \"image\": \"ghcr.io/agent-infra/sandbox:1.0.0.126\",
    \"cpu\": 8,
    \"memory_gb\": 32,
    \"disk_gb\": 100,
    \"compose_file\": $COMPOSE_CONTENT,
    \"kms_type\": \"builtin\"
  }")

APP_ID=$(echo "$PROVISION_RESPONSE" | jq -r '.app_id')
COMPOSE_HASH=$(echo "$PROVISION_RESPONSE" | jq -r '.compose_hash')

echo "✅ Provisioned: App ID $APP_ID"

echo "🚀 Creating CVM instance..."
CREATE_RESPONSE=$(curl -s -X POST "$BASE_URL/cvms" \
  -H "X-API-Key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d "{
    \"app_id\": \"$APP_ID\",
    \"compose_hash\": \"$COMPOSE_HASH\",
    \"env\": $ENV_VARS
  }")

CVM_ID=$(echo "$CREATE_RESPONSE" | jq -r '.cvm_id')
echo "✅ Created CVM: $CVM_ID"

echo "⏳ Waiting for deployment..."
while true; do
  STATUS_RESPONSE=$(curl -s -X GET "$BASE_URL/cvms/$CVM_ID" \
    -H "X-API-Key: $API_KEY")

  STATUS=$(echo "$STATUS_RESPONSE" | jq -r '.status')
  echo "   Status: $STATUS"

  if [ "$STATUS" == "running" ]; then
    break
  elif [ "$STATUS" == "failed" ]; then
    echo "❌ Deployment failed!"
    exit 1
  fi

  sleep 10
done

# Get main URL
MAIN_URL=$(echo "$STATUS_RESPONSE" | jq -r '.endpoints[] | select(.port == 8080) | .url')

echo ""
echo "🎉 VibeVM deployed successfully!"
echo "🌐 Access your VibeVM at: $MAIN_URL"
echo "📝 CVM ID: $CVM_ID"
```

### Environment Variable Management Best Practices

1. **Use a `.env` file for local testing:**
   ```bash
   cp .env.example .env
   # Edit .env with your values
   ```

2. **Never commit secrets to version control:**
   ```bash
   # .gitignore
   .env
   .env.local
   *.key
   *.pem
   ```

3. **Use different credentials for each environment:**
   ```bash
   # Development
   VIBEVM_USERNAME=dev_admin
   VIBEVM_PASSWORD=dev_password_123

   # Production
   VIBEVM_USERNAME=prod_admin
   VIBEVM_PASSWORD=strong_random_password_456
   ```

4. **Rotate credentials regularly:**
   - Change passwords every 90 days
   - Rotate GitHub tokens every 6 months
   - Update API keys when team members leave

5. **Use secure password generation:**
   ```bash
   # Generate a secure password
   openssl rand -base64 32

   # Generate bcrypt hash for VIBEVM_PASSWORD_HASH
   python3 -c "import bcrypt; print(bcrypt.hashpw(b'your_password', bcrypt.gensalt()).decode())"
   ```

---

## Architecture Overview

VibeVM is built on a multi-service architecture orchestrated by Supervisord:

### Service Stack

```
┌─────────────────────────────────────────────────────────────┐
│                    Nginx (Port 8080)                         │
│              Main Entry Point + Auth Gateway                 │
└─────────────────────────────────────────────────────────────┘
                              │
                ┌─────────────┴──────────────┐
                │                            │
┌───────────────▼──────┐      ┌─────────────▼─────────────┐
│  Authentication       │      │  Services & APIs          │
│  Service (8085)       │      │  • VNC/noVNC (5900/6080)  │
│  • Session mgmt       │      │  • VSCode Server (8200)   │
│  • Rate limiting      │      │  • GEM Server (8088)      │
│  • Bcrypt validation  │      │  • MCP Servers (8089+)    │
└───────────────────────┘      │  • JupyterLab (8888)      │
                               │  • Browser (9222)          │
                               └────────────────────────────┘
                                          │
                    ┌─────────────────────┴──────────────────┐
                    │                                         │
        ┌───────────▼────────┐              ┌────────────────▼──────┐
        │  Desktop Services   │              │  TEE & CVM            │
        │  • D-Bus            │              │  • dstack.sock        │
        │  • XFCE4 Panel      │              │  • Key Derivation     │
        │  • Thunar           │              │  • Remote Attestation │
        │  • Dunst            │              │  • TDX Quotes         │
        └─────────────────────┘              └───────────────────────┘
```

### Key Components

| Component | Purpose | Port |
|-----------|---------|------|
| **Nginx** | Main HTTP gateway, auth proxy, reverse proxy | 8080 |
| **Auth Service** | Session-based authentication with bcrypt | 8085 |
| **Xvnc** | Virtual X11 display server | 5900 |
| **noVNC** | Browser-based VNC client (WebSocket proxy) | 6080 |
| **VSCode Server** | Browser-based IDE | 8200 |
| **GEM Server** | PyAutoGUI automation API | 8088 |
| **MCP Servers** | Model Context Protocol servers | 8089+ |
| **Browser** | Chrome with remote debugging | 9222 |
| **JupyterLab** | Python notebook environment | 8888 |
| **Dstack Socket** | TEE operations (key derivation, attestation) | Unix socket |

### Authentication Flow

```
1. User requests http://localhost:8080/
2. Nginx sends auth_request to /auth/check
3. Auth Service validates session cookie
4. If valid:
   → Sets X-Authenticated-User header
   → Serves requested content
5. If invalid:
   → Redirects to /login
   → User submits credentials
   → Auth Service validates (bcrypt)
   → Creates session (24h default)
   → Sets secure cookie
```

### Security Features

- **Session-based authentication** with secure HTTP-only cookies
- **Bcrypt password hashing** (cost factor 12)
- **Rate limiting** (5 attempts/minute per IP)
- **Session timeout** (configurable, default 24 hours)
- **Audit logging** at `/var/log/aio/auth-audit.log`
- **TEE isolation** via Phala Cloud CVM

---

## Testing Your VibeVM

Once deployed, verify your VibeVM is working correctly with these quick tests.

### 1. Quick Health Check (30 seconds)

```bash
# Set your VibeVM URL (from Phala Cloud Network tab)
VIBEVM_URL="https://your-cvm-id.phala.cloud:8080"

# Test 1: Check if VibeVM is responding
curl -I $VIBEVM_URL

# Test 2: Get sandbox info (requires auth)
curl $VIBEVM_URL/v1/sandbox

# Test 3: Check TEE connection (inside VibeVM)
curl --unix-socket /var/run/dstack.sock http://localhost/info | jq '.'

# Test 4: List running services
docker exec vibevm supervisorctl status

# All tests passing? ✅ Your VibeVM is ready!
```

### 2. API Testing

#### Test Shell Execution

```bash
# Execute a command
curl -X POST $VIBEVM_URL/v1/shell/exec \
  -H "Content-Type: application/json" \
  -d '{
    "command": "echo \"Hello from VibeVM\" && uname -a && whoami"
  }' | jq '.'

# Expected output:
# {
#   "success": true,
#   "output": "Hello from VibeVM\nLinux...\ngem"
# }
```

#### Test File Operations

```bash
# Create a test file
curl -X POST $VIBEVM_URL/v1/file/write \
  -H "Content-Type: application/json" \
  -d '{
    "path": "/home/gem/test.txt",
    "content": "Testing VibeVM file operations"
  }' | jq '.'

# Read the file back
curl -X POST $VIBEVM_URL/v1/file/read \
  -H "Content-Type: application/json" \
  -d '{"file": "/home/gem/test.txt"}' | jq '.'

# List files
curl -X POST $VIBEVM_URL/v1/shell/exec \
  -H "Content-Type: application/json" \
  -d '{"command": "ls -la /home/gem/"}' | jq '.output'
```

#### Test Browser Automation

```bash
# Take a screenshot
curl -X POST $VIBEVM_URL/v1/browser/screenshot \
  -o screenshot.png

# Check screenshot was captured
file screenshot.png
# Expected: screenshot.png: PNG image data

# Navigate to a URL and screenshot
curl -X POST $VIBEVM_URL/v1/browser/navigate \
  -H "Content-Type: application/json" \
  -d '{"url": "https://example.com"}' | jq '.'

curl -X POST $VIBEVM_URL/v1/browser/screenshot \
  -o example_screenshot.png
```

#### Test TEE Operations

```bash
# Inside VibeVM container or via SSH
docker exec -it vibevm bash

# Get TEE info
curl --unix-socket /var/run/dstack.sock \
  http://localhost/info | jq '.'

# Expected output:
# {
#   "app_id": "...",
#   "instance_id": "...",
#   "measurement": "..."
# }

# Derive a test key
curl --unix-socket /var/run/dstack.sock \
  -X POST http://localhost/prpc/DeriveKey \
  -H "Content-Type: application/json" \
  -d '{"path": "/test/my-key"}' | jq '.'

# Generate a quote
curl --unix-socket /var/run/dstack.sock \
  -X POST http://localhost/prpc/GetQuote \
  -H "Content-Type: application/json" \
  -d '{"report_data": "dGVzdCBkYXRh"}' | jq '.'
```

### 3. Python Testing Script

Create a comprehensive test script:

```python
#!/usr/bin/env python3
"""
VibeVM Comprehensive Test Suite
Run this to verify all VibeVM functionality
"""

import requests
import json
from pathlib import Path

# Configuration
VIBEVM_URL = "https://your-cvm-id.phala.cloud:8080"
TEST_FILE = "/home/gem/vibevm-test.txt"

class VibeVMTester:
    def __init__(self, base_url):
        self.base_url = base_url.rstrip('/')
        self.session = requests.Session()
        self.passed = 0
        self.failed = 0

    def test(self, name, func):
        """Run a test and track results"""
        try:
            print(f"\n🧪 Testing: {name}")
            func()
            print(f"✅ PASSED: {name}")
            self.passed += 1
        except Exception as e:
            print(f"❌ FAILED: {name}")
            print(f"   Error: {e}")
            self.failed += 1

    def test_health(self):
        """Test basic connectivity"""
        response = self.session.get(f"{self.base_url}/v1/sandbox")
        assert response.status_code == 200, f"Expected 200, got {response.status_code}"
        data = response.json()
        print(f"   Sandbox ID: {data.get('id', 'N/A')}")

    def test_shell_exec(self):
        """Test shell command execution"""
        response = self.session.post(
            f"{self.base_url}/v1/shell/exec",
            json={"command": "echo 'Hello VibeVM' && pwd && whoami"}
        )
        assert response.status_code == 200
        data = response.json()
        assert "Hello VibeVM" in data.get("output", "")
        print(f"   Output: {data.get('output', '')[:100]}...")

    def test_file_write(self):
        """Test file writing"""
        response = self.session.post(
            f"{self.base_url}/v1/file/write",
            json={
                "path": TEST_FILE,
                "content": "VibeVM test - timestamp: 2025-10-13"
            }
        )
        assert response.status_code == 200
        print(f"   File written: {TEST_FILE}")

    def test_file_read(self):
        """Test file reading"""
        response = self.session.post(
            f"{self.base_url}/v1/file/read",
            json={"file": TEST_FILE}
        )
        assert response.status_code == 200
        data = response.json()
        content = data.get("content", "")
        assert "VibeVM test" in content
        print(f"   File read: {content[:50]}...")

    def test_browser_screenshot(self):
        """Test browser screenshot"""
        response = self.session.post(f"{self.base_url}/v1/browser/screenshot")
        assert response.status_code == 200
        assert len(response.content) > 0
        print(f"   Screenshot captured: {len(response.content)} bytes")

    def test_python_available(self):
        """Test Python is available"""
        response = self.session.post(
            f"{self.base_url}/v1/shell/exec",
            json={"command": "python3 --version"}
        )
        assert response.status_code == 200
        output = response.json().get("output", "")
        assert "Python 3" in output
        print(f"   {output.strip()}")

    def test_node_available(self):
        """Test Node.js is available"""
        response = self.session.post(
            f"{self.base_url}/v1/shell/exec",
            json={"command": "node --version"}
        )
        assert response.status_code == 200
        output = response.json().get("output", "")
        assert "v" in output
        print(f"   Node.js {output.strip()}")

    def test_git_available(self):
        """Test git is available"""
        response = self.session.post(
            f"{self.base_url}/v1/shell/exec",
            json={"command": "git --version"}
        )
        assert response.status_code == 200
        output = response.json().get("output", "")
        assert "git version" in output
        print(f"   {output.strip()}")

    def run_all(self):
        """Run all tests"""
        print("=" * 60)
        print("🚀 VibeVM Comprehensive Test Suite")
        print("=" * 60)

        # Core functionality
        self.test("Health Check", self.test_health)
        self.test("Shell Execution", self.test_shell_exec)
        self.test("File Write", self.test_file_write)
        self.test("File Read", self.test_file_read)
        self.test("Browser Screenshot", self.test_browser_screenshot)

        # Development tools
        self.test("Python Available", self.test_python_available)
        self.test("Node.js Available", self.test_node_available)
        self.test("Git Available", self.test_git_available)

        # Results
        print("\n" + "=" * 60)
        print(f"📊 Test Results: {self.passed} passed, {self.failed} failed")
        print("=" * 60)

        if self.failed == 0:
            print("🎉 All tests passed! Your VibeVM is working perfectly.")
        else:
            print(f"⚠️  {self.failed} test(s) failed. Check the errors above.")

        return self.failed == 0

if __name__ == "__main__":
    tester = VibeVMTester(VIBEVM_URL)
    success = tester.run_all()
    exit(0 if success else 1)
```

Run the test suite:

```bash
# Save the script
nano vibevm_test.py

# Make it executable
chmod +x vibevm_test.py

# Run tests
python3 vibevm_test.py
```

### 4. MCP (Model Context Protocol) Testing

Test MCP servers for AI agent integration:

```bash
# Check MCP server is running
curl $VIBEVM_URL:8089/health

# Test MCP browser server
curl -X POST $VIBEVM_URL:8100/mcp/browser \
  -H "Content-Type: application/json" \
  -d '{
    "method": "screenshot",
    "params": {}
  }' | jq '.'

# Test MCP file server
curl -X POST $VIBEVM_URL:8100/mcp/files \
  -H "Content-Type: application/json" \
  -d '{
    "method": "read",
    "params": {
      "path": "/home/gem/README.md"
    }
  }' | jq '.'

# Test MCP shell server
curl -X POST $VIBEVM_URL:8100/mcp/shell \
  -H "Content-Type: application/json" \
  -d '{
    "method": "exec",
    "params": {
      "command": "ls -la /home/gem"
    }
  }' | jq '.'
```

### 5. JavaScript/TypeScript Testing

```javascript
// test-vibevm.js
const fetch = require('node-fetch');

const VIBEVM_URL = 'https://your-cvm-id.phala.cloud:8080';

async function testVibeVM() {
  console.log('🚀 Testing VibeVM...\n');

  // Test 1: Sandbox Info
  console.log('📦 Test 1: Sandbox Info');
  const sandboxResp = await fetch(`${VIBEVM_URL}/v1/sandbox`);
  const sandbox = await sandboxResp.json();
  console.log(`   ✅ Sandbox ID: ${sandbox.id}`);

  // Test 2: Execute Command
  console.log('\n💻 Test 2: Execute Command');
  const execResp = await fetch(`${VIBEVM_URL}/v1/shell/exec`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ command: 'echo "Hello from JavaScript" && date' })
  });
  const execResult = await execResp.json();
  console.log(`   ✅ Output: ${execResult.output}`);

  // Test 3: Create File
  console.log('\n📝 Test 3: Create File');
  const writeResp = await fetch(`${VIBEVM_URL}/v1/file/write`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      path: '/home/gem/test-js.txt',
      content: 'Created from JavaScript test'
    })
  });
  console.log(`   ✅ File created`);

  // Test 4: Read File
  console.log('\n📖 Test 4: Read File');
  const readResp = await fetch(`${VIBEVM_URL}/v1/file/read`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ file: '/home/gem/test-js.txt' })
  });
  const fileContent = await readResp.json();
  console.log(`   ✅ Content: ${fileContent.content}`);

  // Test 5: Screenshot
  console.log('\n📸 Test 5: Browser Screenshot');
  const screenshotResp = await fetch(`${VIBEVM_URL}/v1/browser/screenshot`, {
    method: 'POST'
  });
  const screenshot = await screenshotResp.buffer();
  console.log(`   ✅ Screenshot captured: ${screenshot.length} bytes`);

  console.log('\n🎉 All tests passed!');
}

testVibeVM().catch(console.error);
```

Run:
```bash
npm install node-fetch
node test-vibevm.js
```

### 6. Quick Verification Checklist

After deployment, verify these key features:

```bash
# ✅ Checklist for VibeVM Verification

# 1. Basic Connectivity
curl -I https://your-cvm-id.phala.cloud:8080
# Expected: HTTP/2 200

# 2. Authentication
curl https://your-cvm-id.phala.cloud:8080/login
# Expected: Login page HTML

# 3. API Access
curl https://your-cvm-id.phala.cloud:8080/v1/sandbox
# Expected: JSON with sandbox info

# 4. VNC Access
open https://your-cvm-id.phala.cloud:8080/vnc/index.html?autoconnect=true
# Expected: Desktop environment loads

# 5. VSCode Server
open https://your-cvm-id.phala.cloud:8080/code-server/
# Expected: VSCode interface loads

# 6. GitHub Repo Cloned (if configured)
curl -X POST https://your-cvm-id.phala.cloud:8080/v1/shell/exec \
  -H "Content-Type: application/json" \
  -d '{"command": "ls -la /home/gem/"}' | jq '.output'
# Expected: Your repo directory listed

# 7. TEE Operations (from inside container)
docker exec vibevm curl --unix-socket /var/run/dstack.sock \
  http://localhost/info | jq '.'
# Expected: TEE info with app_id

# 8. Services Running
docker exec vibevm supervisorctl status
# Expected: All services RUNNING

# 9. Authentication Service
docker exec vibevm curl http://localhost:8085/auth/health
# Expected: {"status": "healthy"}

# 10. Tools Installed
docker exec vibevm bash -c "python3 --version && node --version && git --version"
# Expected: Version numbers for each
```

### Common Test Scenarios

<details>
<summary><b>Test Scenario 1: Web Scraping Agent</b></summary>

```python
from agent_sandbox import Sandbox

sandbox = Sandbox(base_url="https://your-cvm-id.phala.cloud:8080")

# Navigate to page
sandbox.browser.navigate(url="https://example.com")

# Wait for page load
import time
time.sleep(2)

# Take screenshot
screenshot = sandbox.browser.screenshot()
with open("scraped_page.png", "wb") as f:
    f.write(screenshot.data)

# Execute JavaScript to extract data
result = sandbox.browser.execute_script(
    script="return document.title"
)
print(f"Page title: {result.data}")
```
</details>

<details>
<summary><b>Test Scenario 2: Blockchain Key Generation</b></summary>

```bash
# Inside VibeVM container
docker exec -it vibevm bash

# Derive a wallet key
curl --unix-socket /var/run/dstack.sock \
  -X POST http://localhost/prpc/DeriveKey \
  -H "Content-Type: application/json" \
  -d '{"path": "/wallet/ethereum/0"}' | jq '.key'

# Get attestation quote
curl --unix-socket /var/run/dstack.sock \
  -X POST http://localhost/prpc/GetQuote \
  -H "Content-Type: application/json" \
  -d '{"report_data": "'"$(echo -n 'tx-hash-here' | base64)"'"}' \
  | jq '.'

# Verify quote at https://proof.t16z.com
```
</details>

<details>
<summary><b>Test Scenario 3: CI/CD Integration</b></summary>

```yaml
# .github/workflows/test-vibevm.yml
name: Test VibeVM Deployment

on: [push]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      - name: Test VibeVM API
        env:
          VIBEVM_URL: ${{ secrets.VIBEVM_URL }}
        run: |
          # Test sandbox is responsive
          curl -f $VIBEVM_URL/v1/sandbox

          # Test shell execution
          curl -X POST $VIBEVM_URL/v1/shell/exec \
            -H "Content-Type: application/json" \
            -d '{"command": "echo CI test && date"}'

          # Test file operations
          curl -X POST $VIBEVM_URL/v1/file/write \
            -H "Content-Type: application/json" \
            -d '{"path": "/home/gem/ci-test.txt", "content": "CI test"}'
```
</details>

---

## First Steps: GitHub Authentication
Open the terminal in VSCode Server or via the web interface and authenticate with GitHub CLI:

```bash
gh auth login
```

Follow the prompts to authorize via your browser. This gives you:
- ✅ Access to private repositories
- ✅ Ability to push commits
- ✅ Full GitHub CLI features

> 💡 **Already have GH_TOKEN set?** GitHub CLI will be automatically configured, but you may still want to run `gh auth login` for interactive features.

### 3. Connect from Mobile (Optional)

VibeVM includes **Happy CLI** for coding on the go from your mobile device:

```bash
# In your VibeVM terminal (VSCode or web terminal)
happy
```

This will:
- Start a remote connection session
- Display a QR code on screen
- Allow you to connect from the Happy Coder mobile app
- Enable real-time coding from your phone/tablet

**Mobile App:** Download "Happy Coder" from your app store to scan the QR code and start coding remotely.

**Use Cases:**
- 🚶 Code while commuting
- 🛋️ Quick fixes from your couch  
- 🌍 Access your VibeVM from anywhere
- 📱 Monitor long-running processes on mobile

> **Note:** Requires Claude CLI to be installed and authenticated. The `happy` command is pre-installed in your VibeVM.

---

## What You Get

Once logged in, access these interfaces from your browser (replace `your-vibevm-url` with your actual URL from Phala Cloud):

### 🌐 VNC Browser
Full Chrome browser for web automation and testing
```
http://your-vibevm-url-8080/vnc/index.html?autoconnect=true
```

### 💻 VSCode Server
Complete development environment in your browser
```
http://your-vibevm-url-8080/code-server/
```

### 📖 API Documentation
Interactive API docs for programmatic control
```
http://your-vibevm-url-8080/v1/docs
```

### 🤖 MCP Services
Model Context Protocol servers for AI agent integration
```
http://your-vibevm-url-8089/
```

### 📱 Mobile Connection
Code on the go with Happy CLI
```bash
# In your VibeVM terminal
happy
# Scan QR code with Happy Coder mobile app
```

---

## Quick Examples

### Python: Browser Automation + TEE

```python
from agent_sandbox import Sandbox
from dstack_sdk import DstackClient

# Initialize clients
sandbox = Sandbox(base_url="http://localhost:8080")
dstack = DstackClient()

# Get TEE instance info
info = dstack.info()
print(f"Running in TEE: App ID {info.app_id}")

# Execute shell command in sandbox
result = sandbox.shell.exec_command(command="ls -la /home/gem")
print(result.data.output)

# Derive a secure key in TEE
key_response = dstack.get_key(path="/my-app/signing-key")
print(f"Secure key derived: {key_response.key[:32]}...")

# Take browser screenshot
screenshot = sandbox.browser.screenshot()
print(f"Screenshot captured: {len(screenshot.data)} bytes")

# Read a file from your workspace
content = sandbox.file.read_file(file="/home/gem/README.md")
print(content.data.content)
```

### JavaScript: Automated Web Scraping with Attestation

```javascript
import { Sandbox } from '@agent-infra/sandbox';
import { DstackClient } from '@phala/dstack-sdk';

const sandbox = new Sandbox({ baseURL: 'http://localhost:8080' });
const dstack = new DstackClient();

// Get TEE attestation before scraping
const info = await dstack.info();
console.log('Scraping with attested TEE:', info.appId);

// Execute scraping script
const result = await sandbox.shell.exec({ 
  command: 'curl -s https://api.example.com/data' 
});
console.log('Data fetched:', result.output);

// Derive signing key to sign the scraped data
const keyResp = await dstack.getKey('/scraper/sign-key');
console.log('Signing key:', keyResp.key);

// Generate quote for data attestation
const quote = await dstack.getQuote('data-hash-here');
console.log('Attestation quote generated');

// Read and process files
const content = await sandbox.file.read({ 
  path: '/home/gem/scraped-data.json' 
});
console.log('Processed data:', content);
```

### cURL: Direct API Access

```bash
# Execute shell command
curl -X POST http://localhost:8080/v1/shell/exec \
  -H "Content-Type: application/json" \
  -d '{"command": "echo Hello from VibeVM && pwd"}'

# Get sandbox environment info
curl http://localhost:8080/v1/sandbox

# Take browser screenshot
curl -X POST http://localhost:8080/v1/browser/screenshot \
  -o screenshot.png

# Read a file
curl -X POST http://localhost:8080/v1/file/read \
  -H "Content-Type: application/json" \
  -d '{"file": "/home/gem/.bashrc"}' | jq .

# Get TEE information
curl --unix-socket /var/run/dstack.sock \
  http://localhost/info | jq .

# Derive a key in TEE
curl --unix-socket /var/run/dstack.sock \
  -X POST http://localhost/prpc/DeriveKey \
  -H "Content-Type: application/json" \
  -d '{"path": "/my-app/key"}' | jq .
```

### Rust: TEE Key Derivation for Blockchain

```rust
use dstack_rust::DstackClient;
use std::error::Error;

#[tokio::main]
async fn main() -> Result<(), Box<dyn Error>> {
    let client = DstackClient::new();
    
    // Get TEE instance information
    let info = client.info().await?;
    println!("App ID: {}", info.app_id);
    println!("Instance ID: {}", info.instance_id);
    
    // Derive a deterministic wallet key
    let wallet_key = client
        .get_key("/wallet/ethereum/0", None)
        .await?;
    println!("Ethereum wallet key: {}", wallet_key.key);
    
    // Generate TDX quote for attestation
    let quote = client
        .get_quote(b"transaction-hash-here")
        .await?;
    println!("TDX Quote generated for attestation");
    println!("Quote: {}...", &quote.quote[..64]);
    
    Ok(())
}
```

---

## docker-compose.yaml

Copy the `docker-compose.yaml` file from this repository and paste it directly into your Phala Cloud dashboard.

**Key configuration to know:**

```yaml
version: '3.8'

services:
  aio-sandbox:
    image: ghcr.io/agent-infra/sandbox:1.0.0.126
    ports:
      - "8079:8079"  # Additional services
      - "8000:8000"  # Additional services
      - "8080:8080"  # Main UI (this is what you'll access)
      - "8089:8089"  # MCP server
      - "8091:8091"  # Additional services
    environment:
      # GitHub integration (set in Phala dashboard)
      - GITHUB_REPO=${GITHUB_REPO}
      - GH_TOKEN=${GH_TOKEN}
      
      # Phala API (set in Phala dashboard)
      - PHALA_API_KEY=${PHALA_API_KEY}
      
      # ... (many more environment variables handled automatically)
    volumes:
      - sandbox_data:/workspace
      - /var/run/dstack.sock:/var/run/dstack.sock  # TEE access
      - /var/run/docker.sock:/var/run/docker.sock  # Docker access
    # ... (automatic setup script included)

volumes:
  sandbox_data:
```

The full `docker-compose.yaml` includes:
- ✅ Automatic user creation and permissions
- ✅ apt package manager installation (Python 3.13, Node.js 22, git, gh CLI, and 20+ tools)
- ✅ Happy CLI for mobile remote connection (optional via `INSTALL_HAPPY`)
- ✅ Claude Code AI assistant (optional via `INSTALL_CLAUDE`)
- ✅ GitHub repository auto-cloning
- ✅ Secure authentication setup
- ✅ Complete development environment initialization

**Just copy and paste - no modifications needed!** The secrets you set in the dashboard will be automatically injected.

**Customization:** Set `INSTALL_HAPPY`, or `INSTALL_CLAUDE` to `false` in environment variables to skip installation and reduce startup time.

---

## Pre-installed Tools via apt

Your VibeVM comes with a complete development environment managed by `apt`:

| Category | Tools |
|----------|-------|
| **Languages** | Python 3.13, Node.js 22 |
| **Version Control** | git, GitHub CLI (gh) |
| **Editors** | VSCode Server, Jupyter Notebook, vim, nano |
| **Shell Utilities** | wget, curl, tree, rsync, htop, procps |
| **Text Processing** | grep, sed, awk, jq, ripgrep |
| **Compression** | tar, gzip, unzip |
| **Networking** | netcat, nmap |
| **Media** | imagemagick, yt-dlp |
| **Remote Access** | happy-coder (mobile connection), Claude Code (AI assistant) |

**Note:** Claude Code and Happy CLI are installed via npm if `INSTALL_CLAUDE` and `INSTALL_HAPPY` are set to `true` (default).

### Installing Additional Tools

```bash
# Update package list
sudo apt update

# Install packages
sudo apt install package-name

# Search for packages
apt search package-name
```

> **Note:** The `gem` user has passwordless sudo access for system-level package installation.

---

## TEE Capabilities via Dstack

Access secure TEE operations through `/var/run/dstack.sock`:

### Key Derivation
Generate deterministic cryptographic keys from paths:
```python
key = dstack.get_key(path="/my-app/wallet-key")
```

### Remote Attestation
Prove your code runs in a genuine TEE:
```python
quote = dstack.get_quote(report_data=b"verify-this-data")
# Verify at https://proof.t16z.com/
```

### (Not Recommended for Non-Experts) TLS Certificates
Generate fresh certificates with RA-TLS support:
```python
tls_key = dstack.get_tls_key()
```

---

## Cost Optimization Tips

VibeVMs run on powerful TDX hardware. Keep costs down:

1. **Stop when not developing** - Use the Phala Cloud dashboard to stop your VibeVM when you're done for the day
2. **Use snapshots** - Save your work state and restore it later instead of leaving the VM running
3. **Right-size your machine** - Use Large TDX for development, but consider smaller instances for testing through an interface connecting to the VibeVM API.
4. **Set auto-shutdown** - Configure automatic shutdown after inactivity in the Phala Cloud dashboard

> 💰 **Rule of Thumb:** If you're not actively coding, your VibeVM still pays for compute. You can always shutdown your VibeVM and startup with a clean environment and still retain keys generated with the deterministic key generator.

---

## Common Workflows

### Starting Fresh with Your Project

1. **Set secrets in Phala Cloud:**
   ```bash
   GITHUB_REPO=your-username/your-repo
   GH_TOKEN=ghp_your_token
   ```

2. **Deploy VibeVM** - Your repo auto-clones to `/home/gem/your-repo/`

3. **Access via port 8080** and log in with your credentials

4. **Open VSCode Server** and navigate to your cloned project

5. **Start developing!** All changes are persisted in `/home/gem/`

### Blockchain Agent Development
1. Derive keys in TEE for transaction signing
2. Use browser automation to monitor on-chain events
3. Execute trades/transactions with attested keys
4. Generate quotes to prove execution integrity

```python
from dstack_sdk import DstackClient

# Derive a deterministic wallet key
client = DstackClient()
wallet_key = client.get_key(path="/wallet/main")

# Use for signing transactions
# Keys are derived from the TEE, provably secure
```

### Secure Web Scraping
1. Navigate to target sites with VNC browser
2. Extract data using Playwright automation
3. Process data in Jupyter notebooks
4. Sign results with TEE-derived keys

```python
from agent_sandbox import Sandbox
from dstack_sdk import DstackClient

sandbox = Sandbox(base_url="http://localhost:8080")
dstack = DstackClient()

# Scrape data
screenshot = sandbox.browser.screenshot()

# Derive signing key and attest the data
key = dstack.get_key(path="/scraper/sign-key")
quote = dstack.get_quote(report_data=b"scraped-data-hash")
```

### API Integration Testing
1. Clone your repo on VibeVM startup (auto-configured)
2. Use VSCode Server for development
3. Test APIs with full browser + curl access
4. Generate attestation quotes for API authentication

### Working as User `gem`

VibeVM runs as the `gem` user (not root) for security:

```bash
# Your home directory
cd /home/gem

# Your cloned repo
cd /home/gem/your-repo-name

# Install Python packages (user-level)
pip install --user package-name

# Install npm packages globally (already configured)
npm install -g package-name

# Use sudo for system-level changes (NOPASSWD configured)
sudo apt update
```

### Mobile Development with Happy CLI

Access your VibeVM from your phone or tablet:

1. **Start Happy session in VibeVM:**
   ```bash
   # SSH or open terminal in VSCode Server
   happy
   ```

2. **Scan QR code** with Happy Coder mobile app

3. **Code from mobile:**
   - Run commands remotely
   - Monitor long-running processes
   - Quick bug fixes on the go
   - Check logs and outputs

4. **Real-time sync** between your VibeVM and mobile device

**Perfect for:**
- 🚂 Coding during commute
- 🏖️ Quick fixes while traveling
- 📊 Monitoring training/scraping jobs
- 🔍 Checking deployment status remotely

---

## SDK Installation

Install SDKs in your local development environment or inside VibeVM:

```bash
# Python
pip install agent-sandbox dstack-sdk

# JavaScript/TypeScript
npm install @agent-infra/sandbox @phala/dstack-sdk

# Go
go get github.com/agent-infra/sandbox-sdk-go
go get github.com/Dstack-TEE/dstack/sdk/go/dstack
```

---

## Documentation & Resources

### AIO Sandbox
- 📚 [Official Docs](https://sandbox.agent-infra.com)
- 🔧 [API Reference](https://sandbox.agent-infra.com/api/)
- 💡 [Examples](https://sandbox.agent-infra.com/examples/)

### Dstack TEE SDK
- 🐍 [Python SDK](https://github.com/Dstack-TEE/dstack/blob/master/sdk/python/README.md)
- 📜 [JavaScript SDK](https://github.com/Dstack-TEE/dstack/blob/master/sdk/js/README.md)
- 🦀 [Rust SDK](https://github.com/Dstack-TEE/dstack/blob/master/sdk/rust/README.md)
- 🐹 [Go SDK](https://github.com/Dstack-TEE/dstack/blob/master/sdk/go/README.md)
- 📘 [cURL API](https://github.com/Dstack-TEE/dstack/blob/master/sdk/curl/api.md)

### Phala Cloud
- 🌐 [Phala Cloud Dashboard](https://phala.com)
- 📖 [Phala Docs](https://docs.phala.com)
- 🔍 [TEE Attestation Explorer](https://proof.t16z.com)

---

## Troubleshooting

### Deployment Issues

#### Can't connect to port 8080?
- Check the **Network** tab in Phala Cloud dashboard
- Ensure your deployment finished successfully (takes 2-3 min)
- Verify the correct URL is being used
- Try accessing the other exposed ports (8000, 8089) to verify connectivity
- Check CVM status using the API: `curl -X GET https://cloud-api.phala.network/v1/cvms/YOUR_CVM_ID -H "X-API-Key: YOUR_API_KEY"`

#### Deployment stuck in "provisioning" or "deploying" status?
- Wait at least 5 minutes before investigating (TEE setup takes time)
- Check the deployment logs in Phala Cloud dashboard
- Verify you selected a TDX-enabled machine (required for TEE features)
- Ensure your docker-compose.yaml is valid (test locally first)
- Try redeploying with a different node

#### API deployment returns "unauthorized" error?
- Verify your API key is valid: `curl -X GET https://cloud-api.phala.network/v1/users/me -H "X-API-Key: YOUR_API_KEY"`
- Check that your API key hasn't expired
- Regenerate API key in Phala Cloud dashboard if needed
- Ensure the header is exactly `X-API-Key` (case-sensitive)

#### Compose file validation failed?
- Ensure your docker-compose.yaml uses version `3.8` or compatible
- Verify all required fields are present (image, ports, environment)
- Check for syntax errors (use `docker-compose config` locally to validate)
- Ensure image name is exact: `ghcr.io/agent-infra/sandbox:1.0.0.126`
- Remove any local-only volumes or unsupported directives

### Environment Variable Issues

#### GitHub clone not working?
- Ensure `GITHUB_REPO` is in exact format: `username/repo` (no spaces, no `https://`)
- For private repos, set a valid `GH_TOKEN` with proper scopes
- Check the deployment logs in Phala Cloud dashboard for clone errors
- Verify token hasn't expired: `curl -H "Authorization: token YOUR_TOKEN" https://api.github.com/user`
- Repo will be cloned to `/home/gem/your-repo-name/`
- If clone fails, check container logs: `docker logs vibevm` (if running locally)

#### Environment variables not being set?
- Verify environment variables are set in Phala Cloud dashboard (not just in local .env)
- Check variable names match exactly (case-sensitive)
- For API deployments, verify JSON format is correct
- Encrypted variables must use proper encryption format
- Try plain text variables first to isolate encryption issues

#### Authentication not working?
- Default credentials are `admin/admin` if not changed
- Ensure `VIBEVM_USERNAME` and `VIBEVM_PASSWORD` are set correctly
- If using `VIBEVM_PASSWORD_HASH`, ensure it's a valid bcrypt hash
- Clear browser cookies and try again
- Check container logs for authentication errors

### TEE and Dstack Issues

#### Need to access dstack.sock?
- Verify you're on a TDX machine (required for TEE)
- Socket is mounted at `/var/run/dstack.sock`
- Use `ls -la /var/run/` to verify socket exists
- Test connection: `curl --unix-socket /var/run/dstack.sock http://localhost/info`
- Ensure container has proper permissions to access socket
- If socket is missing, redeploy on a TDX-enabled node

#### TEE operations failing?
- Verify you're running on a TDX machine (check Phala Cloud dashboard)
- Ensure dstack.sock is properly mounted (check docker-compose.yaml)
- Test basic TEE functionality: `curl --unix-socket /var/run/dstack.sock http://localhost/info`
- Check container logs for TEE-related errors
- Some operations require specific KMS configuration (builtin vs onchain)

### File System and Workspace Issues

#### Where is my workspace?
- **Home directory:** `/home/gem/` (persisted in `sandbox_data` volume)
- **Persistent volume:** `/workspace/` (mapped to Docker volume)
- **Cloned repos:** `/home/gem/your-repo-name/`
- All your files in `/home/gem/` are persisted across restarts
- Check volume status: `docker volume inspect vibevm_sandbox_data` (local) or in Phala dashboard

#### Files disappearing after restart?
- Ensure files are saved in `/home/gem/` or `/workspace/` (not `/tmp/`)
- Check that `sandbox_data` volume is properly configured in docker-compose.yaml
- Verify volume is mounted: `docker inspect vibevm | grep -A 10 Mounts`
- For Phala Cloud, check volume persistence settings in dashboard

### Port and Network Issues

#### Multiple ports - which one do I use?
- **Port 8080:** Main UI - This is what you access from the Phala Cloud Network tab (primary)
- **Port 8000:** Application port (secondary)
- **Port 8089:** MCP server (for AI agent integration)
- **Internal ports:** 5900 (VNC), 6080 (WebSocket), 8081 (Auth), etc. (not directly accessible)
- Always start with port 8080 - it's your main dashboard

#### Port forwarding not working?
- Verify ports are exposed in docker-compose.yaml
- Check Phala Cloud Network tab for correct URLs
- Try accessing via different ports (8080, 8000, 8089)
- Ensure firewall isn't blocking connections
- Check container is actually listening: `docker exec vibevm netstat -tulpn | grep 8080`

### Tool Installation Issues

#### Happy CLI not working?
- Ensure Node.js is available: `node --version` (should be v22.x)
- Check if happy is installed: `which happy`
- Reinstall if needed: `npm install -g happy-coder`
- Verify Claude CLI is installed: `claude --version`
- Make sure you're logged into Claude: `claude auth login`
- Run `happy` from your VibeVM terminal, not from local machine
- If `INSTALL_HAPPY=false`, you need to install manually

#### Claude Code not installed?
- Check that `INSTALL_CLAUDE=true` in environment variables
- Verify npm is working: `npm --version`
- Check installation logs in container startup logs
- Install manually: `npm install -g @anthropic-ai/claude-code`
- Authenticate: `claude auth login`

#### Python/Node packages not found?
- Verify you're using the correct user: `whoami` (should be `gem`)
- Install packages as user gem: `pip install --user package-name`
- For npm: `npm install -g package-name` (already configured for user install)
- Check PATH: `echo $PATH` should include `/home/gem/.local/bin`

### Performance Issues

#### VibeVM running slowly?
- Check resource allocation in Phala Cloud dashboard
- Ensure you selected a Large TDX machine (minimum recommended)
- Monitor resource usage: `htop` or `docker stats vibevm`
- Consider upgrading to a larger machine size
- Reduce concurrent browser tabs/processes
- Close unused services via supervisorctl

#### Browser automation timing out?
- Increase browser timeout settings in your code
- Check browser process is running: `pgrep chrome`
- Verify Chrome isn't crashing: `docker logs vibevm | grep chrome`
- Reduce display resolution if needed: set `DISPLAY_WIDTH=1280` and `DISPLAY_HEIGHT=720`
- Ensure sufficient memory is allocated (minimum 8GB recommended)

### Common Error Messages

#### "Error: Cannot connect to Docker daemon"
- Verify Docker socket is mounted: `-v /var/run/docker.sock:/var/run/docker.sock`
- Check socket permissions: `ls -la /var/run/docker.sock`
- Ensure user `gem` has access (should be in docker group)
- This is expected in Phala Cloud (socket may not be available)

#### "Permission denied" errors
- Ensure you're running commands as user `gem`, not root
- Check file ownership: `ls -la /home/gem/`
- Fix permissions: `sudo chown -R gem:gem /home/gem/your-directory`
- For system operations, use `sudo` (passwordless for gem user)

#### "Module not found" or "Command not found"
- Source your profile: `source ~/.bashrc` or `source ~/.profile`
- Check PATH: `echo $PATH`
- Reinstall missing tools: `sudo apt update && sudo apt install package-name`
- For Python: `pip install --user package-name`
- For Node: `npm install -g package-name`

### Getting Help

If you're still having issues:

1. **Check container logs:**
   ```bash
   # Local deployment
   docker logs vibevm

   # Or from inside the container
   sudo supervisorctl status
   sudo tail -f /var/log/supervisor/*.log
   ```

2. **Check service status:**
   ```bash
   sudo supervisorctl status
   ```

3. **Verify environment:**
   ```bash
   env | grep -E '(GITHUB|INSTALL|VIBEVM)'
   ```

4. **Test basic functionality:**
   ```bash
   # Test TEE
   curl --unix-socket /var/run/dstack.sock http://localhost/info

   # Test sandbox API
   curl http://localhost:8080/v1/sandbox

   # Test browser
   curl -X POST http://localhost:8080/v1/browser/screenshot -o test.png
   ```

5. **Report issues:**
   - [GitHub Issues](https://github.com/Phala-Network/VibeVM/issues)
   - [Phala Discord](https://discord.gg/phala-network)
   - Include logs, error messages, and steps to reproduce

---

## Support & Community

- 🐛 [Report Issues](https://github.com/Phala-Network/VibeVM/issues)
- 💬 [Community Discussions](https://github.com/Phala-Network/VibeVM/discussions)
- 📧 [Phala Support](https://discord.gg/phala-network)
- 📚 [Phala Documentation](https://docs.phala.com)

## Related Projects

- 🔧 [AIO Sandbox](https://github.com/agent-infra/sandbox) - The underlying sandbox technology
- 🔒 [Dstack TEE](https://github.com/Dstack-TEE/dstack) - Trusted Execution Environment SDK
- 📱 [Happy CLI](https://github.com/slopus/happy-cli) - Mobile remote connection for Claude Code
- 🌐 [Phala Cloud](https://github.com/Phala-Network/phala-cloud) - Private Compute Cloud Service to Host dstack CVMs

## Contributing

We welcome contributions! If you've built something cool with VibeVM or have improvements to suggest:

1. Fork this repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

Apache License 2.0 - see [LICENSE](LICENSE) for details.

---

<div align="center">

**Ready to build secure AI agents?**

[🚀 Sign up for Phala Cloud](https://phala.com) • [📖 Read the Docs](https://docs.phala.com) • [⭐ Star on GitHub](https://github.com/phala-network/VibeVM)

Built with ❤️ by the Phala Network community

**Powered by [AIO Sandbox](https://sandbox.agent-infra.com) × [Dstack TEE](https://github.com/Dstack-TEE/dstack)

</div>