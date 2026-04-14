#!/bin/sh

# Ensure config directory exists
mkdir -p /usr/local/etc/cloudflared

# This script is called by configd to re-apply configuration and restart the service
/usr/local/sbin/configctl template reload OPNsense/Cloudflared

# Apply sysctl tunables if they exist
if [ -f /usr/local/etc/sysctl.conf.d/cloudflared.conf ]; then
    while read line; do
        if [ ! -z "$line" ] && [ "${line#\#}" = "$line" ]; then
            sysctl $line
        fi
    done < /usr/local/etc/sysctl.conf.d/cloudflared.conf
fi

# Restart the service (this will also start it if it was enabled)
/usr/local/sbin/configctl service cloudflared restart
