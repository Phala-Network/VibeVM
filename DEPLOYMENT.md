# VibeVM Deployment Guide

## Quick Start (No Docker Build Required!)

VibeVM uses the base AIO Sandbox image and sets up everything at runtime by cloning this repo and running a setup script.

### Step 1: Configure Environment Variables

Create or update your `.env` file with your repository:

```bash
# Required: Your VibeVM repo (use the official repo or your fork)
GITHUB_REPO=Phala-Network/VibeVM

# Optional: GitHub token for private forks
GH_TOKEN=ghp_your_token_here

# Optional: Customize authentication
VIBEVM_USERNAME=admin
VIBEVM_PASSWORD=your_secure_password

# Optional: Tool installation
INSTALL_HAPPY=false
INSTALL_CLAUDE=false
```

### Step 2: Deploy to Phala Cloud

**Option A: Web Dashboard**

1. Go to https://cloud.phala.network
2. Create a new CVM
3. Upload your `docker-compose.yaml`
4. Set environment variables in the dashboard:
   ```
   GITHUB_REPO=Phala-Network/VibeVM
   ```
5. Deploy!

**Option B: API Deployment**

```bash
# Set your API key
export PHALA_API_KEY="your_api_key"

# Deploy
curl -X POST https://cloud-api.phala.network/v1/cvms \
  -H "X-API-Key: $PHALA_API_KEY" \
  -H "Content-Type: application/json" \
  -d @- <<EOF
{
  "name": "vibevm-production",
  "image": "ghcr.io/agent-infra/sandbox:1.0.0.128",
  "compose_file": $(cat docker-compose.yaml | jq -Rs .),
  "env": {
    "GITHUB_REPO": "Phala-Network/VibeVM"
  }
}
EOF
```

### Step 3: Run Setup Script

Once the CVM is running:

**Option 1: Automatic Setup (via environment variable)**

Add this to your `docker-compose.yaml` environment:

```yaml
environment:
  - GITHUB_REPO=Phala-Network/VibeVM
  - VIBEVM_AUTO_SETUP=true  # Add this to auto-run setup
```

**Option 2: Manual Setup (recommended for first time)**

```bash
# SSH or exec into your container
docker exec -it vibevm bash

# The repo should be cloned to /home/gem/VibeVM
cd /home/gem/VibeVM

# Run the setup script
./setup-vibevm.sh
```

### Step 4: Verify Installation

```bash
# Check all services are running
supervisorctl status | grep vibevm

# Should see:
# vibevm-auth                      RUNNING
# vibevm-dbus-session              RUNNING
# vibevm-dbus-system               RUNNING
# vibevm-dunst                     RUNNING
# vibevm-thunar-daemon             RUNNING
# vibevm-xfce4-panel               RUNNING
```

### Step 5: Access VibeVM

Open your CVM URL:
- **Main UI**: `https://your-cvm-id.phala.cloud:8080`
- **Desktop**: `https://your-cvm-id.phala.cloud:8080/vnc/`

Default login: `admin` / `admin`

---

## Architecture

```
AIO Sandbox Base Image
    ↓
  Clone VibeVM Repo (via GITHUB_REPO)
    ↓
  Run setup-vibevm.sh
    ↓
  ✅ VibeVM Ready!
```

**Benefits:**
- ✅ No custom Docker image needed
- ✅ No build process or platform issues
- ✅ Easy to update (just pull latest from GitHub)
- ✅ Easy to fork and customize
- ✅ Faster deployments

---

## Updating VibeVM

To update to the latest version:

```bash
# Inside your container
cd /home/gem/VibeVM
git pull origin main
./setup-vibevm.sh
```

---

## Customizing VibeVM

### Fork the Repository

1. Fork https://github.com/Phala-Network/VibeVM
2. Make your changes
3. Update `GITHUB_REPO` to point to your fork:
   ```bash
   GITHUB_REPO=your-username/VibeVM
   ```
4. Deploy!

Your custom setup will be automatically pulled and installed.

---

## Troubleshooting

### Setup Script Fails

```bash
# Check if repo was cloned
ls -la /home/gem/VibeVM

# If not cloned, check GITHUB_REPO env var
echo $GITHUB_REPO

# Manually clone if needed
cd /home/gem
git clone https://github.com/Phala-Network/VibeVM.git
cd VibeVM
./setup-vibevm.sh
```

### Services Not Starting

```bash
# Check supervisord logs
supervisorctl tail vibevm-auth
supervisorctl tail vibevm-dbus-system

# Restart services
supervisorctl restart vibevm-auth
```

### Authentication Not Working

```bash
# Check auth service status
supervisorctl status vibevm-auth

# Check auth service logs
tail -f /var/log/aio/vibevm-auth-error.log

# Verify nginx config
nginx -t
```

---

## Development Workflow

### Local Testing

```bash
# Start the base AIO Sandbox locally
docker run -it \
  -e GITHUB_REPO=your-username/VibeVM \
  -p 8080:8080 \
  ghcr.io/agent-infra/sandbox:1.0.0.128

# Inside container, run setup
cd /home/gem/VibeVM
./setup-vibevm.sh
```

### Testing Changes

1. Make changes to your fork
2. Push to GitHub
3. Pull in your CVM:
   ```bash
   cd /home/gem/VibeVM
   git pull
   ./setup-vibevm.sh
   ```

No Docker rebuild needed! 🎉

---

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `GITHUB_REPO` | `Phala-Network/VibeVM` | Repository to clone |
| `GH_TOKEN` | - | GitHub token for private repos |
| `VIBEVM_USERNAME` | `admin` | Login username |
| `VIBEVM_PASSWORD` | `admin` | Login password |
| `VIBEVM_PASSWORD_HASH` | - | Bcrypt hash (more secure) |
| `SESSION_TIMEOUT` | `86400` | Session timeout (seconds) |
| `LOGIN_REDIRECT_URL` | `/` | Post-login redirect |
| `INSTALL_HAPPY` | `false` | Install Happy CLI |
| `INSTALL_CLAUDE` | `false` | Install Claude Code |

---

## Support

- **Issues**: https://github.com/Phala-Network/VibeVM/issues
- **Phala Cloud**: https://cloud.phala.network
- **Documentation**: https://docs.phala.network
