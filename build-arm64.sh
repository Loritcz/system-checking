#!/bin/sh
# Build XMRig untuk ARM64 di VM ARM64 Linux
# Dijalankan sebagai user biasa, tanpa root/sudo.
# Syarat: gcc, cmake, make, libuv1-dev, libssl-dev sudah terinstall.
# libhwloc-dev optional (kalau tidak ada, HWLOC otomatis dimatikan).

set -e

WORKDIR="$HOME/xmrig-edu"
SRC_DIR="$WORKDIR/xmrig-src"
BUILD_DIR="$SRC_DIR/build"

# Cek dependency compiler yang sudah harus terinstall
check_cmd() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "[-] $1 tidak ditemukan. Install dulu dengan: sudo apt install -y $2"
        exit 1
    fi
}

check_cmd gcc build-essential
check_cmd cmake cmake
check_cmd make build-essential

echo "[+] Compiler dependency sudah tersedia"

# Cek apakah libhwloc-dev tersedia dengan mencari file header
if [ -f /usr/include/hwloc.h ]; then
    HWLOC_FLAG=""
    echo "[+] HWLOC ditemukan, mengaktifkan dukungan HWLOC"
else
    HWLOC_FLAG="-DWITH_HWLOC=OFF"
    echo "[!] HWLOC tidak ditemukan, mematikan dukungan HWLOC"
    echo "    Untuk performa lebih baik, install: sudo apt install -y libhwloc-dev"
fi

mkdir -p "$WORKDIR"

# Jika source belum ada, clone dari GitHub (tidak butuh root)
if [ ! -d "$SRC_DIR" ]; then
    echo "[+] Cloning source XMRig ke $SRC_DIR..."
    git clone --depth 1 --branch v6.26.0 https://github.com/xmrig/xmrig.git "$SRC_DIR"
fi

cd "$SRC_DIR"

# Update source ke versi terbaru jika sudah pernah clone
echo "[+] Mengupdate source..."
git fetch --tags --depth 1
git checkout v6.26.0

rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

echo "[+] Mengkonfigurasi build"
cmake .. -DCMAKE_BUILD_TYPE=Release -DWITH_CUDA=OFF -DWITH_OPENCL=OFF $HWLOC_FLAG

echo "[+] Compiling XMRig ARM64 (membutuhkan waktu beberapa menit)"
make -j$(nproc)

# Copy binary hasil build ke folder kerja
cp "$BUILD_DIR/xmrig" "$WORKDIR/xmrig-aarch64"

echo "[+] Build selesai: $WORKDIR/xmrig-aarch64"
echo "[+] Sekarang kamu bisa jalankan: cd $WORKDIR && ./xmrig-aarch64 -c config.json"
