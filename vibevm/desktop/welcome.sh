#!/bin/bash
# VibeVM Desktop Welcome Script
# Displays a welcome notification when the desktop starts

# Wait for notification daemon to be ready
sleep 2

# Check if notify-send is available
if command -v notify-send >/dev/null 2>&1; then
    notify-send -i dialog-information \
        "Welcome to VibeVM" \
        "Your secure confidential computing desktop is ready.\n\nPowered by Phala Cloud CVM" \
        -t 5000
fi

# You can add additional startup commands here
# Examples:
# - Set desktop wallpaper
# - Launch monitoring tools
# - Initialize custom services

exit 0
