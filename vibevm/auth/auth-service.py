#!/usr/bin/env python3
"""
VibeVM Authentication Service
Provides login/logout functionality with session management
"""

import os
import secrets
import time
import logging
from collections import defaultdict
from typing import Optional

import bcrypt
from fastapi import FastAPI, Form, Cookie, Response, Request
from fastapi.responses import HTMLResponse, RedirectResponse
from fastapi.middleware.cors import CORSMiddleware

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger("vibevm-auth")
audit_logger = logging.getLogger("vibevm-auth-audit")

# File handler for audit logs
audit_handler = logging.FileHandler("/var/log/aio/auth-audit.log")
audit_handler.setFormatter(logging.Formatter("%(asctime)s - %(message)s"))
audit_logger.addHandler(audit_handler)
audit_logger.setLevel(logging.INFO)

# FastAPI app
app = FastAPI(
    title="VibeVM Authentication Service",
    description="Secure authentication for VibeVM Desktop",
    version="1.0.0"
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# In-memory session store (use Redis for production)
sessions = {}

# Rate limiting store
login_attempts = defaultdict(list)

# Configuration from environment variables
VIBEVM_USERNAME = os.getenv("VIBEVM_USERNAME", "admin")
VIBEVM_PASSWORD = os.getenv("VIBEVM_PASSWORD", "admin")
VIBEVM_PASSWORD_HASH = os.getenv("VIBEVM_PASSWORD_HASH", "")
SESSION_TIMEOUT = int(os.getenv("SESSION_TIMEOUT", "86400"))  # 24 hours default
SESSION_SECRET = os.getenv("SESSION_SECRET", secrets.token_urlsafe(32))
LOGIN_REDIRECT_URL = os.getenv("LOGIN_REDIRECT_URL", "/")  # AIO Sandbox by default

# Warn if using default credentials
if VIBEVM_USERNAME == "admin" and VIBEVM_PASSWORD == "admin":
    logger.warning("⚠️  Using default credentials (admin/admin). CHANGE THIS IN PRODUCTION!")


def hash_password(password: str) -> str:
    """Hash a password using bcrypt"""
    return bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()


def verify_password(password: str, hashed: str) -> bool:
    """Verify a password against a bcrypt hash"""
    try:
        return bcrypt.checkpw(password.encode(), hashed.encode())
    except Exception as e:
        logger.error(f"Error verifying password: {e}")
        return False


def validate_credentials(username: str, password: str) -> bool:
    """Validate username and password"""
    # Check username
    if username != VIBEVM_USERNAME:
        return False

    # Check password (hashed or plain text)
    if VIBEVM_PASSWORD_HASH:
        return verify_password(password, VIBEVM_PASSWORD_HASH)
    else:
        logger.warning("Using plain text password comparison. Set VIBEVM_PASSWORD_HASH for security!")
        return password == VIBEVM_PASSWORD


def check_rate_limit(ip: str) -> bool:
    """Check if IP is rate limited (max 5 attempts per minute)"""
    now = time.time()
    # Clean old attempts (older than 1 minute)
    login_attempts[ip] = [t for t in login_attempts[ip] if now - t < 60]

    # Check if too many attempts
    if len(login_attempts[ip]) >= 5:
        return False

    # Record this attempt
    login_attempts[ip].append(now)
    return True


def log_login_attempt(username: str, ip: str, success: bool):
    """Log login attempt to audit log"""
    status = "SUCCESS" if success else "FAILURE"
    audit_logger.info(f"Login {status} - User: {username}, IP: {ip}")


def log_logout(username: str, ip: str):
    """Log logout to audit log"""
    audit_logger.info(f"Logout - User: {username}, IP: {ip}")


@app.get("/login", response_class=HTMLResponse)
async def login_page(error: Optional[str] = None):
    """Display login page"""
    error_html = f'<div class="error">{error}</div>' if error else ''

    return f"""
    <!DOCTYPE html>
    <html>
    <head>
        <title>VibeVM - Login</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
            * {{
                margin: 0;
                padding: 0;
                box-sizing: border-box;
            }}
            body {{
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
                background: linear-gradient(135deg, #647D1C 0%, #B0CB72 50%, #cdfa50 100%);
                min-height: 100vh;
                display: flex;
                align-items: center;
                justify-content: center;
                padding: 20px;
            }}
            .login-container {{
                background: rgba(255, 255, 255, 0.98);
                border-radius: 16px;
                box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
                max-width: 420px;
                width: 100%;
                overflow: hidden;
                border: 1px solid #e4e4e7;
            }}
            .login-header {{
                background: linear-gradient(135deg, #647D1C 0%, #B0CB72 50%, #cdfa50 100%);
                color: #ffffff;
                padding: 40px 30px;
                text-align: center;
            }}
            .login-header h1 {{
                font-size: 28px;
                font-weight: 600;
                margin-bottom: 8px;
            }}
            .login-header p {{
                font-size: 14px;
                opacity: 0.9;
            }}
            .login-body {{
                padding: 40px 30px;
            }}
            .form-group {{
                margin-bottom: 24px;
            }}
            label {{
                display: block;
                font-size: 14px;
                font-weight: 500;
                color: #18181b;
                margin-bottom: 8px;
            }}
            input {{
                width: 100%;
                padding: 14px 16px;
                border: 2px solid #e4e4e7;
                border-radius: 8px;
                font-size: 15px;
                transition: border-color 0.3s, background 0.3s;
                background: #ffffff;
                color: #18181b;
            }}
            input:focus {{
                outline: none;
                border-color: #B0CB72;
                background: #fafafa;
            }}
            input::placeholder {{
                color: #71717a;
            }}
            button {{
                width: 100%;
                padding: 14px;
                background: linear-gradient(135deg, #647D1C 0%, #B0CB72 50%, #cdfa50 100%);
                color: #ffffff;
                border: none;
                border-radius: 8px;
                font-size: 16px;
                font-weight: 600;
                cursor: pointer;
                transition: transform 0.2s, box-shadow 0.2s;
            }}
            button:hover {{
                transform: translateY(-2px);
                box-shadow: 0 10px 20px rgba(176, 203, 114, 0.4);
            }}
            button:active {{
                transform: translateY(0);
            }}
            .error {{
                background: #fef2f2;
                color: #ef4444;
                padding: 12px 16px;
                border-radius: 8px;
                margin-bottom: 20px;
                font-size: 14px;
                border-left: 4px solid #ef4444;
            }}
            .footer {{
                text-align: center;
                padding: 20px;
                font-size: 12px;
                color: #71717a;
                background: #fafafa;
                border-top: 1px solid #e4e4e7;
            }}
            .footer a {{
                color: #647D1C;
                text-decoration: none;
                font-weight: 500;
                transition: color 0.2s;
            }}
            .footer a:hover {{
                color: #526618;
                text-decoration: underline;
            }}
            @media (max-width: 480px) {{
                .login-container {{
                    border-radius: 0;
                }}
                .login-header {{
                    padding: 30px 20px;
                }}
                .login-body {{
                    padding: 30px 20px;
                }}
            }}
        </style>
    </head>
    <body>
        <div class="login-container">
            <div class="login-header">
                <h1>VibeVM</h1>
                <p>Good Vibes, Zero Trust Required</p>
            </div>
            <div class="login-body">
                {error_html}
                <form method="post" action="/login">
                    <div class="form-group">
                        <label for="username">Username</label>
                        <input
                            type="text"
                            id="username"
                            name="username"
                            placeholder="Enter your username"
                            required
                            autofocus
                        >
                    </div>
                    <div class="form-group">
                        <label for="password">Password</label>
                        <input
                            type="password"
                            id="password"
                            name="password"
                            placeholder="Enter your password"
                            required
                        >
                    </div>
                    <button type="submit">Sign In</button>
                </form>
            </div>
            <div class="footer">
                Powered by <a href="https://phala.com" target="_blank">Phala Cloud</a> x <a href="https://sandbox.agent-infra.com" target="_blank">AIO Sandbox</a> x <a href="https://github.com/Dstack-TEE/dstack" target="_blank">dstack</a>
            </div>
        </div>
    </body>
    </html>
    """


@app.post("/login")
async def login(
    request: Request,
    response: Response,
    username: str = Form(...),
    password: str = Form(...)
):
    """Handle login POST request"""
    client_ip = request.client.host

    # Check rate limiting
    if not check_rate_limit(client_ip):
        logger.warning(f"Rate limit exceeded for IP: {client_ip}")
        log_login_attempt(username, client_ip, False)
        return RedirectResponse(
            url="/login?error=Too+many+attempts.+Try+again+in+1+minute.",
            status_code=302
        )

    # Validate credentials
    if validate_credentials(username, password):
        # Create session
        session_id = secrets.token_urlsafe(32)
        sessions[session_id] = {
            "username": username,
            "created_at": time.time(),
            "ip": client_ip
        }

        # Log successful login
        log_login_attempt(username, client_ip, True)
        logger.info(f"User {username} logged in from {client_ip}")

        # Set session cookie and redirect to desktop
        response = RedirectResponse(url=LOGIN_REDIRECT_URL, status_code=302)
        response.set_cookie(
            key="vibevm_session",
            value=session_id,
            httponly=True,
            secure=False,  # Set to True if using HTTPS
            samesite="lax",
            max_age=SESSION_TIMEOUT
        )
        return response
    else:
        # Log failed login
        log_login_attempt(username, client_ip, False)
        logger.warning(f"Failed login attempt for user {username} from {client_ip}")

        return RedirectResponse(
            url="/login?error=Invalid+username+or+password",
            status_code=302
        )


@app.get("/check")
async def check_auth(vibevm_session: Optional[str] = Cookie(None)):
    """Check if session is valid (used by Nginx auth_request)"""
    if not vibevm_session:
        return Response(status_code=401)

    session = sessions.get(vibevm_session)
    if not session:
        return Response(status_code=401)

    # Check session timeout
    age = time.time() - session["created_at"]
    if age > SESSION_TIMEOUT:
        # Session expired
        del sessions[vibevm_session]
        return Response(status_code=401)

    # Valid session
    return Response(
        status_code=200,
        headers={"X-User": session["username"]}
    )


@app.get("/logout")
async def logout(
    request: Request,
    response: Response,
    vibevm_session: Optional[str] = Cookie(None)
):
    """Handle logout"""
    client_ip = request.client.host

    if vibevm_session and vibevm_session in sessions:
        username = sessions[vibevm_session]["username"]
        del sessions[vibevm_session]
        log_logout(username, client_ip)
        logger.info(f"User {username} logged out from {client_ip}")

    response = RedirectResponse(url="/login", status_code=302)
    response.delete_cookie("vibevm_session")
    return response


@app.get("/health")
async def health():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "service": "vibevm-auth",
        "active_sessions": len(sessions)
    }


if __name__ == "__main__":
    import uvicorn

    # Get port from environment or default to 8085
    port = int(os.getenv("AUTH_SERVICE_PORT", "8085"))

    logger.info(f"Starting VibeVM Authentication Service on port {port}")
    logger.info(f"Configured username: {VIBEVM_USERNAME}")
    logger.info(f"Session timeout: {SESSION_TIMEOUT} seconds")
    logger.info(f"Login redirect URL: {LOGIN_REDIRECT_URL}")

    uvicorn.run(
        app,
        host="0.0.0.0",
        port=port,
        log_level="info"
    )
