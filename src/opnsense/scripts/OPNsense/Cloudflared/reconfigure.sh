#!/bin/sh

# Logging helper
log_msg() {
    logger -t cloudflared-reconfigure "$1"
    echo "$1"
}

log_msg "Starting cloudflared reconfiguration..."

# Ensure config directory exists
mkdir -p /usr/local/etc/cloudflared
chmod 750 /usr/local/etc/cloudflared

# Reload OPNsense templates
log_msg "Reloading configuration templates..."
/usr/local/sbin/configctl template reload OPNsense/Cloudflared

# Apply sysctl tunables if they exist
if [ -f /usr/local/etc/sysctl.conf.d/cloudflared.conf ]; then
    log_msg "Applying sysctl tunables..."
    while read line; do
        if [ ! -z "$line" ] && [ "${line#\#}" = "$line" ]; then
            sysctl $line > /dev/null 2>&1
        fi
    done < /usr/local/etc/sysctl.conf.d/cloudflared.conf
fi

# Restart the service
log_msg "Restarting cloudflared service..."
/usr/local/sbin/configctl service cloudflared restart

log_msg "Cloudflared reconfiguration complete."
