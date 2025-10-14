FROM ghcr.io/agent-infra/sandbox:1.0.0.128

# Install desktop packages and authentication dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
      # Desktop Panel & Components
      xfce4-panel \
      xfce4-whiskermenu-plugin \
      xfce4-terminal \
      # File Management
      thunar \
      thunar-volman \
      thunar-archive-plugin \
      # Utilities
      dmenu \
      dunst \
      zenity \
      network-manager-gnome \
      pavucontrol \
      # Applications
      mousepad \
      # Fonts & Icons
      fonts-liberation \
      fonts-dejavu \
      adwaita-icon-theme \
      # Python dependencies for auth service
      python3-pip \
      python3-bcrypt \
      # D-Bus (required for XFCE4)
      dbus-x11 \
    && rm -rf /var/lib/apt/lists/*

# Install Python packages for authentication service
RUN pip3 install --no-cache-dir \
    fastapi==0.109.0 \
    uvicorn[standard]==0.27.0 \
    python-multipart==0.0.6 \
    bcrypt==4.1.2

# Create VibeVM directory structure
RUN mkdir -p /opt/vibevm/{auth,desktop,supervisord,nginx}

# Copy authentication service
COPY vibevm/auth/auth-service.py /opt/vibevm/auth/
COPY vibevm/auth/nginx-auth.conf /opt/vibevm/auth/

# Copy desktop configuration files
COPY vibevm/desktop/ /opt/vibevm/desktop/

# Copy supervisor configurations
COPY vibevm/supervisord/ /opt/vibevm/supervisord/

# Copy nginx configurations
COPY vibevm/nginx/ /opt/vibevm/nginx/

# Copy custom entrypoint script
COPY entrypoint.sh /usr/local/bin/vibevm-entrypoint.sh
RUN chmod +x /usr/local/bin/vibevm-entrypoint.sh

# Make desktop and nginx scripts executable
RUN chmod +x /opt/vibevm/desktop/welcome.sh && \
    chmod +x /opt/vibevm/nginx/nginx-wait-wrapper.sh 2>/dev/null || true

# Set entrypoint to our custom script (which will chain to AIO Sandbox)
ENTRYPOINT ["/usr/local/bin/vibevm-entrypoint.sh"]
