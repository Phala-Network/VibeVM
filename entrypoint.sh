#!/bin/bash
set -e

# Create a non-root user
if ! getent group $USER >/dev/null; then
  groupadd --gid $USER_GID $USER
fi
if ! id -u $USER >/dev/null 2>&1; then
  useradd --uid $USER_UID --gid $USER --shell /bin/bash --create-home $USER
fi

# Add user to sudoers with NOPASSWD (only if we have permission)
if [ -w /etc/sudoers.d ]; then
  mkdir -p /etc/sudoers.d
  # Check if sudoers entry already exists to avoid duplicates
  if [ ! -f /etc/sudoers.d/$USER ]; then
    echo "$USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USER
    chmod 440 /etc/sudoers.d/$USER
  fi
else
  echo "Warning: Cannot modify sudoers (running in restricted environment)"
fi

# 确保必要的目录存在
mkdir -p /var/run/tinyproxy
chmod 755 /var/run/tinyproxy
chown nobody /var/run/tinyproxy
mkdir -p /home/$USER/.npm-global/lib
chmod 755 /home/$USER/.npm-global
# Only chown if /opt/jupyter exists
[ -d /opt/jupyter ] && chown -R $USER:$USER /opt/jupyter

# bashrc - only move if source exists and destination doesn't
[ -f /opt/gem/bashrc ] && [ ! -f /home/$USER/.bashrc ] && mv /opt/gem/bashrc /home/$USER/.bashrc

# Add environment variables to bashrc
if [ -f /home/$USER/.bashrc ]; then
  # Add GH_TOKEN if provided
  if [ -n "${GH_TOKEN}" ]; then
    if ! grep -q "export GH_TOKEN" /home/$USER/.bashrc; then
      echo "export GH_TOKEN=\"${GH_TOKEN}\"" >> /home/$USER/.bashrc
    fi
  fi
fi

# code-server
mkdir -p /home/$USER/.config/code-server /home/$USER/.local/share/code-server
chmod -R 755 /home/$USER/.local/share/code-server/
# Only move if source exists and destination doesn't
[ -d /opt/gem/vscode ] && [ ! -d /home/$USER/.config/code-server/vscode ] && mv /opt/gem/vscode /home/$USER/.config/code-server/vscode

# jupyter - only move if source exists and destination doesn't
[ -d /opt/gem/jupyter ] && [ ! -d /home/$USER/.jupyter ] && mv /opt/gem/jupyter /home/$USER/.jupyter

# matplotlib
mkdir -p /home/$USER/.config/matplotlib
# Only move if source exists and destination doesn't
[ -f /opt/gem/matplotlibrc ] && [ ! -f /home/$USER/.config/matplotlib/matplotlibrc ] && mv /opt/gem/matplotlibrc /home/$USER/.config/matplotlib/matplotlibrc

# Nginx - only process if template exists
if [ -f "/opt/gem/nginx/nginx.python_srv.conf" ]; then
  envsubst '${GEM_SERVER_PORT}' <"/opt/gem/nginx/nginx.python_srv.conf" >"/opt/gem/nginx/python_srv.conf"
  rm -rf /opt/gem/nginx/nginx.python_srv.conf
fi

# Set up GitHub authentication and clone repository if configured
if [ -n "${GITHUB_REPO}" ]; then
  echo "Setting up GitHub repository: $GITHUB_REPO"

  # Authenticate with GitHub CLI if token is provided
  if [ -n "${GH_TOKEN}" ]; then
    echo "Authenticating with GitHub..."
    # Set up git credentials for token-based authentication
    su - $USER -c "git config --global credential.helper store"
    su - $USER -c "echo \"https://${GH_TOKEN}@github.com\" > ~/.git-credentials"
    # Also configure gh CLI (skip validation if read:org scope is missing)
    su - $USER -c "echo \"${GH_TOKEN}\" | GH_TOKEN=\"${GH_TOKEN}\" gh auth login --with-token --skip-ssh-key 2>/dev/null || true"
    echo "GitHub authentication configured"
  fi

  # Extract repo name from owner/repo format
  REPO_NAME=$(echo "$GITHUB_REPO" | cut -d'/' -f2)

  cd /home/$USER
  if [ -d "$REPO_NAME" ]; then
    echo "Repository already exists, pulling latest..."
    su - $USER -c "cd $REPO_NAME && git pull" || echo "Pull failed, continuing..."
  else
    echo "Cloning repository..."
    su - $USER -c "git clone https://github.com/$GITHUB_REPO.git" || echo "Clone failed, continuing..."
  fi

  # Ensure ownership of cloned repo
  [ -d "$REPO_NAME" ] && chown -R $USER:$USER /home/$USER/$REPO_NAME 2>/dev/null || true
  echo "GitHub repository setup completed"
fi

# in the end ensure the home directory is owned by the user
chown -R $USER:$USER /home/$USER

# Note: Happy CLI and Claude Code installation removed to avoid permission issues
# Users can install these manually if needed via: npm install -g happy-coder @anthropic-ai/claude-code

# ================================================================
# VibeVM Desktop Configuration
# ================================================================

echo "Setting up VibeVM Desktop environment..."

# Create D-Bus directories
mkdir -p /var/run/dbus
chmod 755 /var/run/dbus

# Create desktop config directories for user
mkdir -p /home/$USER/.config/xfce4/xfconf/xfce-perchannel-xml
mkdir -p /home/$USER/.config/xfce4/panel
mkdir -p /home/$USER/.config/Thunar
mkdir -p /home/$USER/.config/autostart
mkdir -p /home/$USER/.config/dunst
mkdir -p /home/$USER/.cache/xfce4

# Ensure XDG_RUNTIME_DIR exists with proper permissions
mkdir -p $XDG_RUNTIME_DIR
chmod 700 $XDG_RUNTIME_DIR

# Copy XFCE4 panel configuration if available
if [ -d /opt/vibevm/desktop/xfce4 ]; then
  echo "Copying XFCE4 panel configuration..."
  cp -r /opt/vibevm/desktop/xfce4/* /home/$USER/.config/xfce4/xfconf/xfce-perchannel-xml/ 2>/dev/null || true
fi

# Copy Thunar configuration if available
if [ -d /opt/vibevm/desktop/thunar ]; then
  echo "Copying Thunar file manager configuration..."
  cp -r /opt/vibevm/desktop/thunar/* /home/$USER/.config/Thunar/ 2>/dev/null || true
fi

# Copy desktop autostart scripts if available
if [ -d /opt/vibevm/desktop/autostart ]; then
  echo "Copying desktop autostart scripts..."
  cp /opt/vibevm/desktop/autostart/* /home/$USER/.config/autostart/ 2>/dev/null || true
  chmod +x /home/$USER/.config/autostart/*.desktop 2>/dev/null || true
fi

# Copy logout script and desktop file
if [ -f /opt/vibevm/desktop/logout.sh ]; then
  echo "Setting up logout functionality..."
  cp /opt/vibevm/desktop/logout.sh /opt/vibevm/desktop/logout.sh.installed
  chmod +x /opt/vibevm/desktop/logout.sh
  # Copy desktop file to user's applications directory
  mkdir -p /home/$USER/.local/share/applications
  if [ -f /opt/vibevm/desktop/vibevm-logout.desktop ]; then
    cp /opt/vibevm/desktop/vibevm-logout.desktop /home/$USER/.local/share/applications/
    chmod +x /home/$USER/.local/share/applications/vibevm-logout.desktop
  fi
fi

# Copy all application desktop files
echo "Installing desktop application launchers..."
mkdir -p /home/$USER/.local/share/applications
mkdir -p /home/$USER/Desktop

for desktop_file in /opt/vibevm/desktop/*.desktop; do
  if [ -f "$desktop_file" ]; then
    filename=$(basename "$desktop_file")
    # Skip autostart files
    if [ "$filename" != "vibevm-logout.desktop" ]; then
      echo "  Installing $filename"
      cp "$desktop_file" /home/$USER/.local/share/applications/
      chmod +x /home/$USER/.local/share/applications/"$filename"
      # Also create shortcut on Desktop
      cp "$desktop_file" /home/$USER/Desktop/
      chmod +x /home/$USER/Desktop/"$filename"
    fi
  fi
done

# Set desktop environment variables
export XDG_CURRENT_DESKTOP=XFCE
export XDG_SESSION_TYPE=x11
export XDG_SESSION_DESKTOP=XFCE
export DESKTOP_SESSION=XFCE

# Ensure D-Bus can start properly
if [ ! -f /var/run/dbus/pid ]; then
  dbus-uuidgen > /etc/machine-id 2>/dev/null || true
fi

# Set ownership of all user config directories
chown -R $USER:$USER /home/$USER/.config
chown -R $USER:$USER /home/$USER/.cache
chown -R $USER:$USER /home/$USER/.local 2>/dev/null || true
chown -R $USER:$USER $XDG_RUNTIME_DIR

echo "Desktop environment configured successfully"

# ================================================================
# VibeVM Authentication Service Setup
# ================================================================

echo "Setting up VibeVM Authentication Service..."

# Create authentication log directory
mkdir -p /var/log/aio
chmod 755 /var/log/aio
touch /var/log/aio/auth-audit.log
chmod 644 /var/log/aio/auth-audit.log

# Set authentication environment variables with defaults
export VIBEVM_USERNAME=${VIBEVM_USERNAME:-admin}
export VIBEVM_PASSWORD=${VIBEVM_PASSWORD:-admin}
export VIBEVM_PASSWORD_HASH=${VIBEVM_PASSWORD_HASH:-}
export SESSION_TIMEOUT=${SESSION_TIMEOUT:-86400}
export AUTH_SERVICE_PORT=${AUTH_SERVICE_PORT:-8085}

echo "Authentication service configured (port $AUTH_SERVICE_PORT)"

# ================================================================
# Copy VibeVM Configs to AIO Sandbox Locations
# ================================================================

echo "Integrating VibeVM configurations into AIO Sandbox..."

# Copy Supervisord configs to the AIO Sandbox supervisord directory
if [ -d /opt/vibevm/supervisord ]; then
  cp /opt/vibevm/supervisord/*.conf /opt/gem/supervisord/ 2>/dev/null || true
  echo "Supervisord configurations copied"
fi

# Copy Nginx configs to the AIO Sandbox nginx directory
# Note: Authentication is now handled by nginx-server-authenticated.conf
# which will be installed by the nginx-wait-wrapper script
echo "Nginx authentication will be configured by nginx-wait-wrapper"

# Process nginx.*.conf template files in /opt/gem/nginx/ to create processed versions
# These template files need variable substitution before nginx starts
echo "Processing nginx template files..."
for template_file in /opt/gem/nginx/nginx.*.conf; do
  if [ -f "$template_file" ]; then
    # Skip our vibevm-auth config - it doesn't need processing
    if echo "$template_file" | grep -q "vibevm-auth"; then
      echo "Skipping $template_file (no variables to substitute)"
      continue
    fi

    # Get the base name without the nginx. prefix
    # E.g., nginx.code_server.conf -> code_server.conf
    base_name=$(basename "$template_file" | sed 's/^nginx\.//')
    output_file="/opt/gem/nginx/$base_name"

    # Skip if output already exists and doesn't have variables
    if [ ! -f "$output_file" ] || grep -q '\${' "$template_file"; then
      echo "Processing $template_file -> $output_file"
      # Use envsubst to replace only our port variables
      envsubst '$CODE_SERVER_PORT $JUPYTER_LAB_PORT $GEM_SERVER_PORT $MCP_SERVER_PORT $MCP_HUB_PORT $WEBSOCKET_PROXY_PORT $BROWSER_REMOTE_DEBUGGING_PORT $AUTH_SERVICE_PORT $MCP_SERVER_BROWSER_PORT $MCP_SERVER_MARKITDOWN_PORT $MCP_SERVER_CHROME_DEVTOOLS_PORT' < "$template_file" > "$output_file"
      # Rename the template file so it won't be included by nginx
      mv "$template_file" "$template_file.template"
    fi
  fi
done
echo "Nginx template processing completed"

echo "Configuration integration completed"

# ================================================================

mkdir -p $LOG_DIR
touch $LOG_DIR/entrypoint.log

# Export all necessary environment variables for supervisord and child processes
export IMAGE_VERSION=$(cat /etc/aio_version 2>/dev/null || echo "unknown")
export OTEL_SDK_DISABLED=true
export NGINX_LOG_LEVEL=${NGINX_LOG_LEVEL:-debug}
export NPM_CONFIG_PREFIX=/home/$USER/.npm-global
export PATH=$NPM_CONFIG_PREFIX/bin:$PATH
export HOMEPAGE=${HOMEPAGE:-""}
export BROWSER_NO_SANDBOX=${BROWSER_NO_SANDBOX:-"--no-sandbox"}
export BROWSER_EXTRA_ARGS="${BROWSER_NO_SANDBOX} --lang=en-US --time-zone-for-testing=${TZ} --window-position=0,0 --window-size=${DISPLAY_WIDTH},${DISPLAY_HEIGHT}  --homepage ${HOMEPAGE} ${BROWSER_EXTRA_ARGS}"

# Additional exports for gem-server
export HOME=/home/$USER
export USER=$USER
export DISPLAY=:99.0
export XDG_RUNTIME_DIR=/tmp/runtime-$USER
mkdir -p $XDG_RUNTIME_DIR
chown $USER:$USER $XDG_RUNTIME_DIR

# Ensure gem-server dependencies are available
export PYTHONPATH=/opt/gem:$PYTHONPATH
export GEM_SERVER_PORT=${GEM_SERVER_PORT:-8088}
export PUBLIC_PORT=${PUBLIC_PORT:-8080}
export WORKSPACE=/home/$USER
export SUPERVISOR_GROUP_NAME=python-server
export SUPERVISOR_SERVER_URL=unix:///var/run/supervisor.sock
export BROWSER_EXECUTABLE_PATH=/usr/local/bin/browser
export PUPPETEER_EXECUTABLE_PATH=/usr/local/bin/browser
export BROWSER_REMOTE_DEBUGGING_PORT=${BROWSER_REMOTE_DEBUGGING_PORT:-9222}
export WEBSOCKET_PROXY_PORT=${WEBSOCKET_PROXY_PORT:-6080}
export VNC_SERVER_PORT=${VNC_SERVER_PORT:-5900}
export AUTH_BACKEND_PORT=${AUTH_BACKEND_PORT:-8081}
export MCP_SERVER_PORT=${MCP_SERVER_PORT:-8089}
export MCP_SERVERS_CONFIG=${MCP_SERVERS_CONFIG:-/opt/gem/mcp-hub.json}
export MCP_FILTER_SERVERS=${MCP_FILTER_SERVERS:-sandbox}
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANGUAGE=en_US:en
export DEBIAN_FRONTEND=noninteractive
export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
export LITELLM_LOCAL_MODEL_COST_MAP=True
export SESSION_ID=${SESSION_ID:-$(cat /proc/sys/kernel/random/uuid 2>/dev/null || echo "session-$(date +%s)-$RANDOM")}
export DISPLAY_DEPTH=${DISPLAY_DEPTH:-24}
export MAX_SHELL_SESSIONS=${MAX_SHELL_SESSIONS:-50}
export WAIT_PORTS=${WAIT_PORTS:-8091}
export WAIT_INTERVAL=${WAIT_INTERVAL:-0.25}
export WAIT_TIMEOUT=${WAIT_TIMEOUT:-300}

# Add user-agent if BROWSER_USER_AGENT is set
if [ -n "${BROWSER_USER_AGENT}" ]; then
  export BROWSER_EXTRA_ARGS=" --user-agent=\"${BROWSER_USER_AGENT}\" ${BROWSER_EXTRA_ARGS}"
fi

# Only process if template exists
[ -f "/opt/gem/nginx-server-port-proxy.conf.template" ] && envsubst '${PUBLIC_PORT}' <"/opt/gem/nginx-server-port-proxy.conf.template" >"/opt/gem/nginx-server-port-proxy.conf"
# 处理代理配置
PROXY_SERVER="$(echo -n "$PROXY_SERVER" | xargs)"
if [ -n "${PROXY_SERVER}" ]; then
  PROXY_SERVER=${PROXY_SERVER#\"}
  PROXY_SERVER=${PROXY_SERVER%\"}

  TINYPROXY_CONFIG_DIR="/opt/gem/tinyproxy"
  TINYPROXY_CONFIG="/etc/tinyproxy.conf"

  if [ -d "${TINYPROXY_CONFIG_DIR}" ]; then
    # base.conf exists check
    if [ ! -f "${TINYPROXY_CONFIG_DIR}/base.conf" ]; then
      echo "ERROR: ${TINYPROXY_CONFIG_DIR}/base.conf is required but not found!" >&2
      exit 1
    fi

    # clean up old config
    > "${TINYPROXY_CONFIG}"

    # load base.conf first (mandatory)
    echo "# === base.conf ===" >> "${TINYPROXY_CONFIG}"
    cat "${TINYPROXY_CONFIG_DIR}/base.conf" >> "${TINYPROXY_CONFIG}"
    echo "" >> "${TINYPROXY_CONFIG}"

    # load gfw.conf second (if exists and PROXY_SERVER is not "true")
    if [ "${PROXY_SERVER}" != "true" ] && [ -f "${TINYPROXY_CONFIG_DIR}/gfw.conf" ]; then
      echo "# === gfw.conf ===" >> "${TINYPROXY_CONFIG}"
      envsubst '${PROXY_SERVER}' < "${TINYPROXY_CONFIG_DIR}/gfw.conf" >> "${TINYPROXY_CONFIG}"
      echo "" >> "${TINYPROXY_CONFIG}"
    fi

    # load other .conf files recursively in alphabetical order (excluding base.conf and gfw.conf)
    for conf_file in $(find "${TINYPROXY_CONFIG_DIR}" -type f -name "*.conf" 2>/dev/null | grep -vE "base.conf|gfw.conf" | sort); do
      if [ -f "${conf_file}" ]; then
        # get relative path for better comment
        rel_path="${conf_file#${TINYPROXY_CONFIG_DIR}/}"
        # add separator comment with relative path
        echo "# === ${rel_path} ===" >> "${TINYPROXY_CONFIG}"
        # Replace `${PROXY_SERVER}` and append to the configuration file.
        envsubst '${PROXY_SERVER}' < "${conf_file}" >> "${TINYPROXY_CONFIG}"
        echo "" >> "${TINYPROXY_CONFIG}"  # add empty line separator
      fi
    done

    echo "Tinyproxy configuration assembled from ${TINYPROXY_CONFIG_DIR}"
  else
    echo "ERROR: Tinyproxy config directory ${TINYPROXY_CONFIG_DIR} not found!" >&2
    exit 1
  fi

  export BROWSER_EXTRA_ARGS="${BROWSER_EXTRA_ARGS} --proxy-server=http://127.0.0.1:8118 --proxy-bypass-list=\"localhost,127.0.0.1,*.byted.org,*.bytedance.net,*.baidu.com,baidu.com\""
else
  rm -f /opt/gem/supervisord/supervisord.tinyproxy.conf
fi

# Display startup banner
print_banner() {
  echo ""
  echo -e "\033[36m██╗   ██╗██╗██████╗ ███████╗██╗   ██╗███╗   ███╗\033[0m"
  echo -e "\033[36m██║   ██║██║██╔══██╗██╔════╝██║   ██║████╗ ████║\033[0m"
  echo -e "\033[36m██║   ██║██║██████╔╝█████╗  ██║   ██║██╔████╔██║\033[0m"
  echo -e "\033[36m╚██╗ ██╔╝██║██╔══██╗██╔══╝  ╚██╗ ██╔╝██║╚██╔╝██║\033[0m"
  echo -e "\033[36m ╚████╔╝ ██║██████╔╝███████╗ ╚████╔╝ ██║ ╚═╝ ██║\033[0m"
  echo -e "\033[36m  ╚═══╝  ╚═╝╚═════╝ ╚══════╝  ╚═══╝  ╚═╝     ╚═╝\033[0m"
  echo ""
  echo -e "\033[35m🔒 Confidential Computing Desktop Environment\033[0m"
  echo -e "\033[32m🌩️  Powered by Phala Cloud CVM\033[0m"
  if [ -n "${IMAGE_VERSION}" ]; then
    echo -e "\033[34m📦 Base Version: ${IMAGE_VERSION}\033[0m"
  fi
  echo -e "\033[33m🌐 Login: http://localhost:8080/login\033[0m"
  echo -e "\033[33m📊 Dashboard: http://localhost:8080\033[0m"
  echo ""
  echo -e "\033[35m================================================================\033[0m"
}

print_banner

# Ensure gem-server can run with proper permissions
# Create supervisor runtime directory
mkdir -p /var/run
chmod 755 /var/run

# Ensure log directories exist with proper permissions
mkdir -p /var/log/supervisor
chmod 755 /var/log/supervisor

# Ensure the gem user owns their home directory completely
chown -R gem:gem /home/gem

# 启动 supervisord
exec /opt/gem/entrypoint.sh
