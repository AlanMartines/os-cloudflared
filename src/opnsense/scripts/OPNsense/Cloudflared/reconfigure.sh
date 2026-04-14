#!/bin/sh

# Logging helper
log_msg() {
    logger -t cloudflared-reconfigure "$1"
    echo "$1"
}

log_msg "Starting cloudflared reconfiguration..."

# Ensure required directories exist before template generation
mkdir -p /usr/local/etc/cloudflared
chmod 750 /usr/local/etc/cloudflared
mkdir -p /usr/local/etc/sysctl.conf.d

# Reload OPNsense templates
log_msg "Reloading configuration templates..."
/usr/local/sbin/configctl template reload OPNsense/Cloudflared

# Restrict token file permissions (must not be world-readable)
if [ -f /usr/local/etc/cloudflared/token ]; then
    chmod 600 /usr/local/etc/cloudflared/token
    log_msg "Token file permissions set to 600."
fi

# Apply sysctl tunables if they exist
if [ -f /usr/local/etc/sysctl.conf.d/cloudflared.conf ]; then
    log_msg "Applying sysctl tunables..."
    while read line; do
        if [ -n "$line" ] && [ "${line#\#}" = "$line" ]; then
            sysctl $line > /dev/null 2>&1
        fi
    done < /usr/local/etc/sysctl.conf.d/cloudflared.conf
fi

# Check if the binary exists before attempting to start the service
if [ ! -x /usr/local/bin/cloudflared ]; then
    log_msg "WARNING: Binary /usr/local/bin/cloudflared not found. Use 'Install/Update Binary' to install it first."
    exit 0
fi

# Restart the service
log_msg "Restarting cloudflared service..."
/usr/local/sbin/configctl service cloudflared restart

log_msg "Cloudflared reconfiguration complete."
