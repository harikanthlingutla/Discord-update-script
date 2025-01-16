#!/bin/bash

# Log file for tracking updates
LOG_FILE="/var/log/discord-updater.log"
DISCORD_DEB="/tmp/discord.deb"
DOWNLOAD_URL="https://discord.com/api/download?platform=linux&format=deb"

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root or with sudo"
    exit 1
fi

# Create log file if it doesn't exist
touch "$LOG_FILE"
chmod 644 "$LOG_FILE"

log_message "Starting Discord update check..."

# Check if Discord is currently running
if pgrep -x "discord" > /dev/null; then
    log_message "Discord is running. Closing application..."
    killall discord
    sleep 2
fi

# Get currently installed version (if any)
CURRENT_VERSION=$(dpkg-query -W -f='${Version}\n' discord 2>/dev/null || echo "none")
log_message "Current Discord version: $CURRENT_VERSION"

# Download latest Discord package
log_message "Downloading latest Discord package..."
if ! wget -q --show-progress -O "$DISCORD_DEB" "$DOWNLOAD_URL"; then
    log_message "Failed to download Discord package"
    exit 1
fi

# Get version of the downloaded package
NEW_VERSION=$(dpkg-deb -f "$DISCORD_DEB" Version)
log_message "Downloaded Discord version: $NEW_VERSION"

# Compare versions and install if different
if [ "$CURRENT_VERSION" != "$NEW_VERSION" ]; then
    log_message "New version detected. Installing..."
    
    # Install the package
    if dpkg -i "$DISCORD_DEB"; then
        log_message "Successfully installed Discord $NEW_VERSION"
        
        # Clean up
        rm "$DISCORD_DEB"
        
        # Fix any dependency issues
        apt-get install -f -y
        
        # Restart Discord if it was running before
        if [ -n "$WAS_RUNNING" ]; then
            log_message "Restarting Discord..."
            su - $SUDO_USER -c "discord &" >/dev/null 2>&1
        fi
    else
        log_message "Failed to install Discord package"
        exit 1
    fi
else
    log_message "Discord is already up to date"
    rm "$DISCORD_DEB"
fi

log_message "Update check completed"
