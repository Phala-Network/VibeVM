#!/bin/bash
# VibeVM Logout Script
# Logs out the user by calling the auth service and redirecting browser

# Get the main browser window URL (if available)
# This assumes the VNC is accessed via noVNC web interface

# Option 1: Use zenity to show confirmation dialog
if command -v zenity &> /dev/null; then
    zenity --question \
        --title="VibeVM Logout" \
        --text="Are you sure you want to logout?\n\nThis will close your session and return you to the login page." \
        --width=300

    if [ $? -ne 0 ]; then
        # User clicked No or Cancel
        exit 0
    fi
fi

# Call the auth service logout endpoint
echo "Logging out from VibeVM..."
curl -s -X GET "http://localhost:8085/logout" \
    -b /tmp/vibevm-session-cookies.txt \
    -c /dev/null

# Option 2: If accessed via browser, try to redirect
# This creates a simple HTML file that redirects to login
cat > /tmp/vibevm-logout.html <<'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>VibeVM - Logged Out</title>
    <meta http-equiv="refresh" content="2;url=/login">
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: linear-gradient(135deg, #647D1C 0%, #B0CB72 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            height: 100vh;
            margin: 0;
            color: white;
        }
        .message {
            text-align: center;
            background: rgba(255,255,255,0.1);
            padding: 40px;
            border-radius: 10px;
        }
        h1 { margin: 0 0 20px 0; }
        p { margin: 10px 0; }
    </style>
</head>
<body>
    <div class="message">
        <h1>✓ Logged Out</h1>
        <p>You have been successfully logged out.</p>
        <p>Redirecting to login page...</p>
    </div>
</body>
</html>
EOF

# Open the logout page in browser (if available)
if command -v xdg-open &> /dev/null; then
    xdg-open "file:///tmp/vibevm-logout.html" &> /dev/null &
fi

# Show notification
if command -v notify-send &> /dev/null; then
    notify-send "VibeVM" "You have been logged out" -i system-log-out
fi

# Optional: Kill VNC session (uncomment if you want to force disconnect)
# pkill -TERM -u $USER Xvnc

echo "Logout complete. Please close your browser or refresh to login again."
exit 0
