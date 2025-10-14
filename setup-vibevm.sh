#!/bin/bash
# VibeVM Setup Script
# This script should be run AFTER the AIO Sandbox has started
# Clone your VibeVM repo with GITHUB_REPO=Phala-Network/VibeVM and run this script

set -e

echo "=========================================="
echo "🚀 VibeVM Setup Starting..."
echo "=========================================="

VIBEVM_DIR="/home/gem/VibeVM"

# Check if we're in the VibeVM directory
if [ ! -d "$VIBEVM_DIR" ]; then
    echo "❌ ERROR: VibeVM directory not found at $VIBEVM_DIR"
    echo "Make sure GITHUB_REPO=Phala-Network/VibeVM (or your fork) is set"
    exit 1
fi

cd "$VIBEVM_DIR"

echo "📦 Installing system dependencies..."
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
    xfce4-panel \
    xfce4-whiskermenu-plugin \
    xfce4-terminal \
    thunar \
    thunar-volman \
    thunar-archive-plugin \
    dmenu \
    dunst \
    zenity \
    network-manager-gnome \
    pavucontrol \
    mousepad \
    fonts-liberation \
    fonts-dejavu \
    adwaita-icon-theme \
    python3-pip \
    python3-bcrypt \
    dbus-x11

echo "📦 Installing Python packages..."
sudo pip3 install --no-cache-dir \
    fastapi==0.109.0 \
    uvicorn[standard]==0.27.0 \
    python-multipart==0.0.6 \
    bcrypt==4.1.2

echo "📁 Setting up VibeVM directories..."
sudo mkdir -p /opt/vibevm/{auth,desktop,supervisord,nginx}
sudo mkdir -p /var/log/aio
sudo chmod 755 /var/log/aio

echo "📋 Copying VibeVM configurations..."
sudo cp -r "$VIBEVM_DIR/vibevm/auth/"* /opt/vibevm/auth/
sudo cp -r "$VIBEVM_DIR/vibevm/desktop/"* /opt/vibevm/desktop/
sudo cp -r "$VIBEVM_DIR/vibevm/supervisord/"* /opt/vibevm/supervisord/
sudo cp -r "$VIBEVM_DIR/vibevm/nginx/"* /opt/vibevm/nginx/

echo "🔧 Making scripts executable..."
sudo chmod +x /opt/vibevm/desktop/welcome.sh
sudo chmod +x /opt/vibevm/desktop/logout.sh
sudo chmod +x /opt/vibevm/nginx/nginx-wait-wrapper.sh 2>/dev/null || true

echo "👤 Configuring user environment..."
USER=${USER:-gem}
XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-/tmp/runtime-gem}

# Create desktop config directories
mkdir -p ~/.config/xfce4/xfconf/xfce-perchannel-xml
mkdir -p ~/.config/xfce4/panel
mkdir -p ~/.config/Thunar
mkdir -p ~/.config/autostart
mkdir -p ~/.config/dunst
mkdir -p ~/.cache/xfce4
mkdir -p ~/.local/share/applications
mkdir -p ~/Desktop

# Copy XFCE4 panel configuration
if [ -d /opt/vibevm/desktop/xfce4 ]; then
    echo "Copying XFCE4 panel configuration..."
    cp -r /opt/vibevm/desktop/xfce4/* ~/.config/xfce4/xfconf/xfce-perchannel-xml/
fi

# Copy Thunar configuration
if [ -d /opt/vibevm/desktop/thunar ]; then
    echo "Copying Thunar file manager configuration..."
    cp -r /opt/vibevm/desktop/thunar/* ~/.config/Thunar/
fi

# Copy desktop autostart scripts
if [ -d /opt/vibevm/desktop/autostart ]; then
    echo "Copying desktop autostart scripts..."
    cp /opt/vibevm/desktop/autostart/* ~/.config/autostart/ 2>/dev/null || true
    chmod +x ~/.config/autostart/*.desktop 2>/dev/null || true
fi

# Install desktop application launchers
echo "Installing desktop application launchers..."
for desktop_file in /opt/vibevm/desktop/*.desktop; do
    if [ -f "$desktop_file" ]; then
        filename=$(basename "$desktop_file")
        if [ "$filename" != "vibevm-logout.desktop" ]; then
            echo "  Installing $filename"
            cp "$desktop_file" ~/.local/share/applications/
            chmod +x ~/.local/share/applications/"$filename"
            cp "$desktop_file" ~/Desktop/
            chmod +x ~/Desktop/"$filename"
        fi
    fi
done

# Install logout desktop file
if [ -f /opt/vibevm/desktop/vibevm-logout.desktop ]; then
    cp /opt/vibevm/desktop/vibevm-logout.desktop ~/.local/share/applications/
    chmod +x ~/.local/share/applications/vibevm-logout.desktop
fi

echo "🗄️ Setting up D-Bus..."
sudo mkdir -p /var/run/dbus
sudo chmod 755 /var/run/dbus
sudo mkdir -p "$XDG_RUNTIME_DIR"
sudo chmod 700 "$XDG_RUNTIME_DIR"
sudo chown $USER:$USER "$XDG_RUNTIME_DIR"

# Generate D-Bus machine ID if needed
if [ ! -f /etc/machine-id ]; then
    sudo dbus-uuidgen | sudo tee /etc/machine-id > /dev/null
fi

echo "🔐 Setting up authentication service..."
sudo touch /var/log/aio/auth-audit.log
sudo chmod 644 /var/log/aio/auth-audit.log

echo "⚙️ Configuring supervisord services..."
# Copy VibeVM supervisord configs
sudo cp /opt/vibevm/supervisord/*.conf /etc/supervisor/conf.d/

# Copy VibeVM nginx configs
sudo mkdir -p /opt/gem/nginx
sudo cp /opt/vibevm/nginx/nginx-server-authenticated.conf /etc/nginx/sites-available/vibevm.conf

echo "🔄 Reloading supervisord..."
sudo supervisorctl reread
sudo supervisorctl update

echo "🚀 Starting VibeVM services..."
# Start D-Bus services first
sudo supervisorctl start vibevm-dbus-system || echo "System D-Bus already running"
sudo supervisorctl start vibevm-dbus-session || echo "Session D-Bus already running"

# Start authentication service
sudo supervisorctl start vibevm-auth || echo "Auth service already running"

# Restart nginx with new config
sudo supervisorctl restart nginx || echo "Nginx restart failed"

# Start desktop services
sudo supervisorctl start vibevm-xfce4-panel || echo "Panel already running"
sudo supervisorctl start vibevm-thunar-daemon || echo "Thunar already running"
sudo supervisorctl start vibevm-dunst || echo "Dunst already running"

echo ""
echo "=========================================="
echo "✅ VibeVM Setup Complete!"
echo "=========================================="
echo ""
echo "📊 Service Status:"
sudo supervisorctl status | grep vibevm || true
echo ""
echo "🌐 Access VibeVM:"
echo "   - Main UI:  http://localhost:8080"
echo "   - Desktop:  http://localhost:8080/vnc/"
echo ""
echo "🔑 Default Login: admin / admin"
echo "   (Change with VIBEVM_USERNAME and VIBEVM_PASSWORD env vars)"
echo ""
echo "=========================================="
