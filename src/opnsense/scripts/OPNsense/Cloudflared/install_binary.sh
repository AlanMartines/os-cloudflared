#!/bin/sh

# Log to syslog
log_msg() {
    logger -t cloudflared-install "$1"
    echo "$1"
}

DEST="/usr/local/bin/cloudflared"
GITHUB_API="https://api.github.com/repos/kjake/cloudflared/releases/latest"

# Detect FreeBSD major version and CPU architecture
OS_VERSION=$(uname -r | cut -d'.' -f1)
ARCH=$(uname -m)

log_msg "Detected FreeBSD ${OS_VERSION} / ${ARCH}"

# Fetch latest release tag from GitHub API
log_msg "Fetching latest release version from GitHub..."
LATEST_TAG=$(fetch -qo - "${GITHUB_API}" 2>/dev/null \
    | grep '"tag_name"' \
    | sed -E 's/.*"tag_name": *"([^"]+)".*/\1/')

if [ -z "${LATEST_TAG}" ]; then
    log_msg "ERROR: Could not determine latest version. Check internet connectivity."
    exit 1
fi

log_msg "Latest version: ${LATEST_TAG}"

BINARY_NAME="cloudflared-freebsd${OS_VERSION}-${ARCH}"
BINARY_URL="https://github.com/kjake/cloudflared/releases/download/${LATEST_TAG}/${BINARY_NAME}"

log_msg "Downloading ${BINARY_NAME} from: ${BINARY_URL}"

if fetch -o "${DEST}" "${BINARY_URL}"; then
    chmod +x "${DEST}"
    log_msg "Installation of cloudflared ${LATEST_TAG} successful."
else
    log_msg "ERROR: Download failed. Binary may not exist for FreeBSD ${OS_VERSION} / ${ARCH}."
    log_msg "URL attempted: ${BINARY_URL}"
    exit 1
fi
