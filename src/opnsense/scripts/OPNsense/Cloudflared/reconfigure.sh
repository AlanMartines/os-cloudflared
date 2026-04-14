#!/bin/sh

# Ensure config directory exists
mkdir -p /usr/local/etc/cloudflared

# This script is called by configd to re-apply configuration and restart the service
/usr/local/sbin/configctl template reload OPNsense/Cloudflared

if [ -f /usr/local/etc/sysctl.conf.d/cloudflared.conf ]; then
    # Apply tunables immediately
    while read line; do
        if [ ! -z "$line" ] && [ "${line#\#}" = "$line" ]; then
            sysctl $line
        fi
    done < /usr/local/etc/sysctl.conf.d/cloudflared.conf
fi

if [ -f /usr/local/etc/rc.d/cloudflared ]; then
    # Reload sysctl tunables if they have changed (not strictly necessary but good to mention)
    # Most tunables need a reboot, but let's check what we can do.
    
    # Restart the service
    /usr/local/sbin/configctl service cloudflared restart
fi
