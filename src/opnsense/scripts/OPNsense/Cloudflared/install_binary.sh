#!/bin/sh

log_msg() {
    logger -t cloudflared-install "$1"
    echo "$1"
}

DEST="/usr/local/bin/cloudflared"
GITHUB_API="https://api.github.com/repos/kjake/cloudflared/releases/latest"

OS_VERSION=$(uname -r | cut -d'.' -f1)
ARCH=$(uname -m)

log_msg "Detected FreeBSD ${OS_VERSION} / ${ARCH}"

# Fetch latest release tag — try curl first, fall back to fetch
log_msg "Fetching latest release version from GitHub..."
if command -v curl > /dev/null 2>&1; then
    API_RESPONSE=$(curl -fsSL -A "opnsense-cloudflared/1.0" "${GITHUB_API}" 2>/dev/null)
else
    API_RESPONSE=$(fetch -qo - "${GITHUB_API}" 2>/dev/null)
fi

LATEST_TAG=$(echo "${API_RESPONSE}" \
    | grep '"tag_name"' \
    | sed -E 's/.*"tag_name": *"([^"]+)".*/\1/' \
    | head -1)

if [ -z "${LATEST_TAG}" ]; then
    log_msg "ERROR: Could not determine latest version from GitHub API."
    log_msg "API response: $(echo "${API_RESPONSE}" | head -3)"
    log_msg "Check internet connectivity and that github.com is reachable."
    exit 1
fi

log_msg "Latest version: ${LATEST_TAG}"

BINARY_NAME="cloudflared-freebsd${OS_VERSION}-${ARCH}"
BINARY_URL="https://github.com/kjake/cloudflared/releases/download/${LATEST_TAG}/${BINARY_NAME}"

log_msg "Downloading ${BINARY_NAME}..."

if command -v curl > /dev/null 2>&1; then
    curl -fsSL -o "${DEST}" "${BINARY_URL}" 2>/dev/null
    DOWNLOAD_OK=$?
else
    fetch -o "${DEST}" "${BINARY_URL}" > /dev/null 2>&1
    DOWNLOAD_OK=$?
fi

if [ "${DOWNLOAD_OK}" -eq 0 ] && [ -s "${DEST}" ]; then
    chmod +x "${DEST}"
    log_msg "Installation of cloudflared ${LATEST_TAG} successful."
else
    log_msg "ERROR: Download failed for ${BINARY_URL}"
    log_msg "Binary may not exist for FreeBSD ${OS_VERSION} / ${ARCH}."
    exit 1
fi
