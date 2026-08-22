#!/bin/sh
# Build XMRig untuk ARM64 di VM ARM64 Linux
# Dijalankan sebagai user biasa, tanpa root/sudo.
# Syarat: gcc, make, libuv1-dev, libssl-dev sudah terinstall.
# cmake akan didownload otomatis jika belum terinstall.
# libhwloc-dev optional (kalau tidak ada, HWLOC otomatis dimatikan).

set -e

WORKDIR="$HOME/xmrig-edu"
TOOLS_DIR="$WORKDIR/tools"
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
mkdir -p "$TOOLS_DIR"

# Setup CMake: pakai yang terinstall di sistem, atau download portable
if command -v cmake >/dev/null 2>&1; then
    CMAKE_BIN="$(command -v cmake)"
    echo "[+] Menggunakan CMake dari sistem: $CMAKE_BIN"
else
    CMAKE_VERSION="3.30.0"
    CMAKE_DIR="$TOOLS_DIR/cmake-${CMAKE_VERSION}-linux-aarch64"
    CMAKE_BIN="$CMAKE_DIR/bin/cmake"

    if [ ! -x "$CMAKE_BIN" ]; then
        echo "[+] CMake tidak ditemukan, mendownload portable CMake ${CMAKE_VERSION}..."
        cd "$TOOLS_DIR"
        curl -fsSL -o cmake.tar.gz "https://cmake.org/files/v3.30/cmake-${CMAKE_VERSION}-linux-aarch64.tar.gz"
        tar -xzf cmake.tar.gz
        rm -f cmake.tar.gz
    fi

    if [ ! -x "$CMAKE_BIN" ]; then
        echo "[-] Gagal setup CMake portable"
        exit 1
    fi

    echo "[+] Menggunakan CMake portable: $CMAKE_BIN"
fi

# Jika source belum ada, clone atau download tarball dari GitHub (tidak butuh root)
XMRIG_VERSION="v6.26.0"
if [ ! -d "$SRC_DIR" ]; then
    if command -v git >/dev/null 2>&1; then
        echo "[+] Cloning source XMRig ke $SRC_DIR..."
        git clone --depth 1 --branch "$XMRIG_VERSION" https://github.com/xmrig/xmrig.git "$SRC_DIR"
    else
        echo "[+] git tidak ditemukan, mendownload source tarball..."
        cd "$WORKDIR"
        curl -fsSL -o xmrig-src.tar.gz "https://github.com/xmrig/xmrig/archive/refs/tags/${XMRIG_VERSION}.tar.gz"
        tar -xzf xmrig-src.tar.gz
        mv "xmrig-6.26.0" "$SRC_DIR"
        rm -f xmrig-src.tar.gz
    fi
fi

cd "$SRC_DIR"

# Update source ke versi terbaru jika sudah pernah clone (hanya kalau pakai git)
if [ -d .git ]; then
    echo "[+] Mengupdate source..."
    git fetch --tags --depth 1
    git checkout "$XMRIG_VERSION"
fi

rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

echo "[+] Mengkonfigurasi build"
"$CMAKE_BIN" .. -DCMAKE_BUILD_TYPE=Release -DWITH_CUDA=OFF -DWITH_OPENCL=OFF $HWLOC_FLAG

echo "[+] Compiling XMRig ARM64 (membutuhkan waktu beberapa menit)"
make -j$(nproc)

# Copy binary hasil build ke folder kerja
cp "$BUILD_DIR/xmrig" "$WORKDIR/xmrig-aarch64"

echo "[+] Build selesai: $WORKDIR/xmrig-aarch64"
echo "[+] Sekarang kamu bisa jalankan: cd $WORKDIR && ./xmrig-aarch64 -c config.json"
