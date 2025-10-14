#!/usr/bin/env python3
"""
Generate JWT tokens for VibeVM API access
"""

import jwt
import datetime
import os
import sys
import json

# Default secret key (should be overridden via environment)
SECRET_KEY = os.getenv("JWT_SECRET_KEY", "your-secret-key-change-this-in-production")
ALGORITHM = "HS256"

def generate_token(username: str, expires_in_days: int = 30) -> dict:
    """
    Generate a JWT token for API access

    Args:
        username: Username for the token
        expires_in_days: Token expiration in days (default: 30)

    Returns:
        dict with token and metadata
    """
    now = datetime.datetime.utcnow()
    expiration = now + datetime.timedelta(days=expires_in_days)

    payload = {
        "sub": username,
        "iat": now,
        "exp": expiration,
        "type": "api_access"
    }

    token = jwt.encode(payload, SECRET_KEY, algorithm=ALGORITHM)

    return {
        "token": token,
        "username": username,
        "issued_at": now.isoformat(),
        "expires_at": expiration.isoformat(),
        "expires_in_days": expires_in_days
    }

def verify_token(token: str) -> dict:
    """
    Verify a JWT token

    Args:
        token: JWT token string

    Returns:
        Decoded payload if valid

    Raises:
        jwt.InvalidTokenError if token is invalid or expired
    """
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return payload
    except jwt.ExpiredSignatureError:
        raise ValueError("Token has expired")
    except jwt.InvalidTokenError as e:
        raise ValueError(f"Invalid token: {e}")

def main():
    """CLI interface for token generation"""
    if len(sys.argv) < 2:
        print("Usage: python generate_token.py <username> [expiry_days]")
        print("Example: python generate_token.py admin 30")
        sys.exit(1)

    username = sys.argv[1]
    expires_in_days = int(sys.argv[2]) if len(sys.argv) > 2 else 30

    token_data = generate_token(username, expires_in_days)

    print(json.dumps(token_data, indent=2))
    print("\n" + "="*70)
    print("✅ JWT Token generated successfully!")
    print("="*70)
    print(f"\nUsername: {token_data['username']}")
    print(f"Expires: {token_data['expires_at']} ({token_data['expires_in_days']} days)")
    print(f"\n📋 Your API Token:")
    print(f"   {token_data['token']}")
    print(f"\n💡 Use this token in API requests:")
    print(f'   curl -H "Authorization: Bearer {token_data["token"]}" \\')
    print(f'        http://localhost:8080/v1/sandbox')
    print()

if __name__ == "__main__":
    main()
