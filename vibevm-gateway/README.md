# VibeVM Gateway (Combined nginx + auth)

This directory contains the combined gateway and authentication service.

## What's Inside

- **nginx** - Reverse proxy on port 80 (externally accessible)
- **FastAPI auth** - Authentication service on 127.0.0.1:8765 (localhost only)
- **supervisor** - Process manager running both services

## Files

- `Dockerfile` - Multi-service image (Python + nginx + supervisor)
- `nginx.conf` - Reverse proxy configuration with auth_request
- `app.py` - FastAPI authentication service
- `supervisord.conf` - Process configuration
- `requirements.txt` - Python dependencies

## Building

```bash
docker build -t hashwarlock/vibevm-gateway:v0.0.4 .
```

## Security

✅ **Only port 80 exposed** - Auth service binds to localhost only
✅ **TEE integration** - JWT keys derived from dstack
✅ **Auto password hashing** - Plain passwords hashed with bcrypt on startup

## Environment Variables

- `VIBEVM_PASSWORD` - Required, auto-hashed with bcrypt
- `VIBEVM_USERNAME` - Default: admin
- `JWT_KEY_PATH` - Dstack path for JWT signing (default: `$vibevm/auth/signing`)
- `JWT_EXPIRY_HOURS` - Session duration (default: 24)

## Architecture

```
Port 80 (nginx) → 127.0.0.1:8765 (auth) → /var/run/dstack.sock (TEE)
                ↓
           127.0.0.1:8080 (aio-sandbox)
```

All services communicate via localhost for security.
