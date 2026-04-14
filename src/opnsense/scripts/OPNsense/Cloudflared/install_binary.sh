#!/bin/sh

# Download the latest cloudflared binary for FreeBSD from kjake's fork
VERSION="2025.8.0"
BINARY_URL="https://github.com/kjake/cloudflared/releases/download/${VERSION}/cloudflared-freebsd14-amd64"
DEST="/usr/local/bin/cloudflared"

# Log to syslog
log_msg() {
    logger -t cloudflared-install "$1"
    echo "$1"
}

log_msg "Starting cloudflared ${VERSION} installation to ${DEST}..."

if fetch -o ${DEST} ${BINARY_URL}; then
    chmod +x ${DEST}
    log_msg "Installation successful."
else
    log_msg "Installation failed. Please check your internet connection or URL."
    exit 1
fi
