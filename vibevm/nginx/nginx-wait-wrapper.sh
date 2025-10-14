#!/bin/bash
# VibeVM Nginx Wait Wrapper
# This processes nginx configs to add authentication and substitute variables

echo "VibeVM: Processing nginx configurations..."

# Process files that may have been created by base entrypoint with variables
for conf_file in /opt/gem/nginx/python_srv.conf /opt/gem/nginx/srv.conf /opt/gem/nginx/legacy.conf /opt/gem/nginx/vnc.conf /opt/gem/nginx/mcp.conf; do
  if [ -f "$conf_file" ] && grep -q '\${' "$conf_file"; then
    echo "  Substituting variables in $conf_file..."
    temp_file="${conf_file}.tmp"
    envsubst '$CODE_SERVER_PORT $JUPYTER_LAB_PORT $GEM_SERVER_PORT $MCP_SERVER_PORT $MCP_HUB_PORT $WEBSOCKET_PROXY_PORT $BROWSER_REMOTE_DEBUGGING_PORT $AUTH_SERVICE_PORT $SANDBOX_SRV_PORT $TINYPROXY_PORT' < "$conf_file" > "$temp_file"
    mv "$temp_file" "$conf_file"
  fi
done

# Add authentication to location blocks (except login/logout/auth paths)
echo "VibeVM: Adding authentication to location blocks..."
for conf_file in /opt/gem/nginx/*.conf; do
  if [ -f "$conf_file" ]; then
    # Skip our auth config file
    if echo "$conf_file" | grep -q "vibevm-auth"; then
      continue
    fi

    # Skip files that already have auth_request or are public endpoints
    if grep -q "auth_request" "$conf_file" 2>/dev/null; then
      continue
    fi

    echo "  Adding auth_request to $conf_file..."

    # Use sed to add auth_request after "location ... {" lines
    # This handles both "location {" and "location ... {" on the same line
    sed '/^[[:space:]]*location.*{[[:space:]]*$/{
        a\    # VibeVM: Require authentication
        a\    auth_request /auth/check;
        a\    auth_request_set $auth_user $upstream_http_x_user;
        a\    error_page 401 = @redirect_to_login;
        a\    proxy_set_header X-Authenticated-User $auth_user;
    }' "$conf_file" > "${conf_file}.auth"

    mv "${conf_file}.auth" "$conf_file"
  fi
done

# Replace nginx-server-active.conf with our authenticated version
if [ -f /opt/vibevm/nginx/nginx-server-authenticated.conf ]; then
  echo "VibeVM: Installing authenticated server configuration..."
  cp /opt/vibevm/nginx/nginx-server-authenticated.conf /opt/gem/nginx-server-active.conf
fi

echo "VibeVM: Nginx configuration processing complete"

# Now run the original nginx-wait script
exec /opt/gem/nginx-wait.sh
