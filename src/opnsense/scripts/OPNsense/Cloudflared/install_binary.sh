#!/bin/sh

# Download the latest cloudflared binary for FreeBSD from kjake's fork
VERSION="2025.8.0"
BINARY_URL="https://github.com/kjake/cloudflared/releases/download/${VERSION}/cloudflared-freebsd14-amd64"
DEST="/usr/local/bin/cloudflared"

echo "Downloading cloudflared ${VERSION} to ${DEST}..."
fetch -o ${DEST} ${BINARY_URL}
chmod +x ${DEST}

if [ $? -eq 0 ]; then
    echo "Installation successful."
else
    echo "Installation failed."
    exit 1
fi
