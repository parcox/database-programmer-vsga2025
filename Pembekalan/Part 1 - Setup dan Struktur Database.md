# Pembekalan Database Programmer - Part 1
## Setup Environment & Struktur Database

> ⚠️ **Penting:** Pembekalan ini menggunakan **kasus perpustakaan sekolah**. Pelajari konsep, bukan hafalan!

**Durasi Total:** 120 menit
**Part 1 ini:** ±40 menit (Setup + Perancangan + Implementasi)

---

## 1. PERSIAPAN ENVIRONMENT 🧰

### A. TUJUAN

Menyiapkan environment MySQL/MariaDB dengan phpMyAdmin di Windows agar siap untuk praktik membuat database perpustakaan.

### B. INSTALASI XAMPP (Windows)

**Langkah-langkah:**

1. **Download XAMPP**
   - Buka browser: https://www.apachefriends.org/download.html
   - Pilih versi Windows terbaru (PHP 8.x recommended)
   - Download installer (sekitar 150MB)

2. **Install XAMPP**
   - Jalankan installer sebagai Administrator
   - Komponen yang harus dicentang:
     - ✅ Apache (web server)
     - ✅ MySQL (database server)
     - ✅ phpMyAdmin (GUI database)
     - ✅ PHP (scripting language)
   - Install di lokasi default: `C:\xampp`
   - Klik Next hingga selesai

3. **Jalankan Services**
   - Buka **XAMPP Control Panel** dari Start Menu
   - Klik tombol `Start` pada **Apache**
   - Klik tombol `Start` pada **MySQL**
   - Pastikan status berubah menjadi hijau dengan label "Running"
   - Port default: Apache (80), MySQL (3306)

4. **Verifikasi Instalasi**
   - Buka browser Chrome/Firefox
   - Akses: `http://localhost` → Harus muncul halaman XAMPP Dashboard
   - Akses: `http://localhost/phpmyadmin` → Harus masuk ke phpMyAdmin
   - Login default:
     - Username: `root`
     - Password: (kosong/blank)

### C. TROUBLESHOOTING UMUM

| Masalah | Penyebab | Solusi |
|---------|----------|--------|
| **Port 80 already in use** | IIS atau Skype menggunakan port 80 | 1. Matikan IIS: `iisreset /stop`<br>2. Atau ubah port Apache di `httpd.conf` menjadi 8080 |
| **Port 3306 already in use** | MySQL service lain berjalan | 1. Stop MySQL service: `services.msc`<br>2. Atau ubah port di `my.ini` |
| **MySQL tidak bisa start** | Error konfigurasi atau port conflict | Cek log: `C:\xampp\mysql\data\mysql_error.log` |
| **Access denied di phpMyAdmin** | Password salah atau user tidak ada | Reset password root atau cek `config.inc.php` |
| **Apache tidak bisa start** | Port 443 (SSL) bentrok | Matikan aplikasi yang pakai port 443 |

### D. TIPS PENTING

✅ **Best Practices:**
- Jalankan XAMPP Control Panel sebagai Administrator
- Jangan install di folder `Program Files` (gunakan `C:\xampp`)
- Aktifkan firewall exception untuk Apache dan MySQL
- Bookmark `http://localhost/phpmyadmin` untuk akses cepat
- Matikan MySQL dari XAMPP jika tidak dipakai (hemat resource)

---

## 2. PERANCANGAN DATABASE 📐

### A. STUDI KASUS: Sistem Informasi Perpustakaan Sekolah

**Deskripsi:**
Sebuah perpustakaan sekolah membutuhkan sistem untuk mengelola koleksi buku, anggota perpustakaan (siswa, guru, staff), dan transaksi peminjaman/pengembalian. Sistem harus dapat:

1. **Mengelola Koleksi Buku**
   - Mencatat data buku (judul, pengarang, penerbit, tahun terbit)
   - Mengelompokkan buku berdasarkan kategori
   - Melacak jumlah eksemplar dan ketersediaan

2. **Mengelola Anggota**
   - Mencatat data anggota (siswa, guru, staff)
   - Menyimpan informasi kontak dan identitas
   - Melacak status keanggotaan

3. **Mengelola Petugas**
   - Mencatat data petugas perpustakaan
   - Menyimpan kredensial login untuk sistem

4. **Proses Peminjaman**
   - Mencatat transaksi peminjaman oleh anggota
   - Maksimal 3 buku per anggota
   - Lama peminjaman maksimal 7 hari
   - Mencatat kondisi buku saat dipinjam

5. **Proses Pengembalian**
   - Mencatat tanggal pengembalian
   - Menghitung denda keterlambatan (Rp 1.000/hari)
   - Mencatat kondisi buku saat dikembalikan
   - Menghitung denda kerusakan jika ada

### B. IDENTIFIKASI ENTITAS DAN ATRIBUT

> 💡 **Catatan:** Contoh data di bawah menunjukkan relasi antar tabel melalui Foreign Key (FK)

#### **Entitas 1: KATEGORI_BUKU**

Menyimpan jenis/kategori buku untuk pengelompokan.

**Atribut:**
- `kode_kategori` (PK) - Kode unik kategori, CHAR(5), contoh: "KT001"
- `nama_kategori` - Nama kategori, VARCHAR(100), contoh: "Fiksi Remaja"
- `keterangan` - Deskripsi kategori, TEXT, optional
- `created_at` - Waktu pembuatan record, TIMESTAMP

**Contoh Data:**
| kode_kategori | nama_kategori | keterangan | created_at |
|---------------|---------------|------------|------------|
| KT001 | Fiksi | Novel dan cerita fiksi | 2025-11-26 10:00:00 |
| KT002 | Non-Fiksi | Buku pengetahuan umum | 2025-11-26 10:00:00 |
| KT003 | Referensi | Kamus, ensiklopedia | 2025-11-26 10:00:00 |

---

#### **Entitas 2: KOLEKSI_BUKU**

Menyimpan data buku yang dimiliki perpustakaan.

**Atribut:**
- `kode_buku` (PK) - Kode unik buku, CHAR(5), contoh: "B0001"
- `judul_buku` - Judul buku lengkap, VARCHAR(200)
- `pengarang` - Nama pengarang/penulis, VARCHAR(100)
- `penerbit` - Nama penerbit, VARCHAR(100)
- `tahun_terbit` - Tahun publikasi, YEAR (1901-2155)
- `kode_kategori` (FK) - Referensi ke kategori_buku.kode_kategori
- `jumlah_eksemplar` - Total buku yang dimiliki, INT
- `tersedia` - Jumlah buku yang tersedia (belum dipinjam), INT
- `isbn` - Nomor ISBN (unik), VARCHAR(20)
- `created_at` - Waktu pembuatan record, TIMESTAMP

**Contoh Data:**
| kode_buku | judul_buku | pengarang | penerbit | tahun_terbit | kode_kategori | jumlah_eksemplar | tersedia | isbn | created_at |
|-----------|------------|-----------|----------|--------------|---------------|------------------|----------|------|------------|
| B0001 | Laskar Pelangi | Andrea Hirata | Bentang Pustaka | 2005 | KT001 | 5 | 3 | 978-979-3062-79-2 | 2025-11-26 10:15:00 |
| B0002 | Bumi Manusia | Pramoedya Ananta Toer | Hasta Mitra | 1980 | KT001 | 3 | 3 | 978-979-461-001-5 | 2025-11-26 10:15:00 |
| B0003 | Sapiens | Yuval Noah Harari | Kepustakaan Populer Gramedia | 2015 | KT002 | 4 | 2 | 978-602-424-109-3 | 2025-11-26 10:15:00 |

**Penjelasan FK:**
- `kode_kategori` berisi nilai yang ada di tabel `kategori_buku.kode_kategori`
- Contoh: B0001 dan B0002 masuk kategori "KT001" (Fiksi), B0003 masuk kategori "KT002" (Non-Fiksi)

---

#### **Entitas 3: ANGGOTA**

Menyimpan data anggota perpustakaan (siswa, guru, staff).

**Atribut:**
- `id_anggota` (PK) - ID unik anggota, CHAR(5), contoh: "A0001"
- `nama_lengkap` - Nama lengkap anggota, VARCHAR(100)
- `jenis_anggota` - Tipe anggota, ENUM('Siswa','Guru','Staff')
- `nomor_identitas` - NIS/NIP/NIK (unik), VARCHAR(20)
- `email` - Email anggota, VARCHAR(100), optional
- `no_telepon` - Nomor telepon, VARCHAR(15)
- `alamat` - Alamat lengkap, TEXT
- `tanggal_daftar` - Tanggal mendaftar, DATE
- `status_aktif` - Status keanggotaan, ENUM('Aktif','Nonaktif')
- `created_at` - Waktu pembuatan record, TIMESTAMP

**Contoh Data:**
| id_anggota | nama_lengkap | jenis_anggota | nomor_identitas | email | no_telepon | alamat | tanggal_daftar | status_aktif | created_at |
|------------|--------------|---------------|-----------------|-------|------------|--------|----------------|--------------|------------|
| A0001 | Ahmad Fauzi | Siswa | 2024001 | ahmad@sekolah.com | 081234567890 | Jl. Merdeka No. 10, Jakarta | 2024-01-15 | Aktif | 2024-01-15 08:00:00 |
| A0002 | Siti Nurhaliza | Guru | 198501001 | siti@sekolah.com | 082345678901 | Jl. Sudirman No. 25, Jakarta | 2020-07-01 | Aktif | 2020-07-01 09:00:00 |
| A0003 | Budi Santoso | Siswa | 2024002 | budi@sekolah.com | 083456789012 | Jl. Thamrin No. 15, Jakarta | 2024-01-15 | Aktif | 2024-01-15 08:00:00 |

---

#### **Entitas 4: PETUGAS**

Menyimpan data petugas/pustakawan yang mengelola sistem.

**Atribut:**
- `id_petugas` (PK) - ID unik petugas, CHAR(5), contoh: "P0001"
- `nama_petugas` - Nama lengkap petugas, VARCHAR(100)
- `username` - Username login (unik), VARCHAR(50)
- `password` - Password terenkripsi, VARCHAR(255)
- `jabatan` - Jabatan petugas, VARCHAR(50)
- `no_telepon` - Nomor telepon, VARCHAR(15)
- `created_at` - Waktu pembuatan record, TIMESTAMP

**Contoh Data:**
| id_petugas | nama_petugas | username | password | jabatan | no_telepon | created_at |
|------------|--------------|----------|----------|---------|------------|------------|
| P0001 | Hendra Gunawan | hendra_admin | 0192023a7bbd73250516f069df18b500 | Kepala Perpustakaan | 081234560001 | 2020-01-10 08:00:00 |
| P0002 | Dewi Lestari | dewi_staff | 9e7d1c70e93c66e3e1e5c0f8e5c8e9f3 | Staff Perpustakaan | 082345670002 | 2020-01-10 08:00:00 |

**Catatan:** Password adalah hasil MD5 hash dari password asli (contoh: MD5('admin123'))

---

#### **Entitas 5: PEMINJAMAN**

Menyimpan header transaksi peminjaman (master).

**Atribut:**
- `kode_pinjam` (PK) - Kode unik transaksi, CHAR(10), contoh: "PJ20250001"
- `id_anggota` (FK) - Referensi ke anggota.id_anggota
- `id_petugas` (FK) - Referensi ke petugas.id_petugas
- `tanggal_pinjam` - Tanggal peminjaman, DATE
- `tanggal_kembali` - Tanggal pengembalian aktual, DATE (NULL jika belum kembali)
- `batas_kembali` - Batas waktu pengembalian, DATE (tanggal_pinjam + 7 hari)
- `status_pinjam` - Status, ENUM('dipinjam','dikembalikan')
- `denda` - Total denda keterlambatan + kerusakan, DECIMAL(10,2)
- `catatan` - Catatan tambahan, TEXT
- `created_at` - Waktu pembuatan record, TIMESTAMP

**Contoh Data:**
| kode_pinjam | id_anggota | id_petugas | tanggal_pinjam | tanggal_kembali | batas_kembali | status_pinjam | denda | catatan | created_at |
|-------------|------------|------------|----------------|-----------------|---------------|---------------|-------|---------|------------|
| PJ20250001 | A0001 | P0001 | 2025-11-20 | NULL | 2025-11-27 | dipinjam | 0.00 | NULL | 2025-11-20 09:30:00 |
| PJ20250002 | A0002 | P0002 | 2025-11-15 | 2025-11-22 | 2025-11-22 | dikembalikan | 0.00 | NULL | 2025-11-15 10:00:00 |
| PJ20250003 | A0003 | P0001 | 2025-11-10 | 2025-11-20 | 2025-11-17 | dikembalikan | 3000.00 | Terlambat 3 hari | 2025-11-10 14:00:00 |

**Penjelasan FK:**
- `id_anggota` berisi nilai yang ada di tabel `anggota.id_anggota`
- `id_petugas` berisi nilai yang ada di tabel `petugas.id_petugas`
- Contoh: PJ20250001 adalah peminjaman oleh Ahmad Fauzi (A0001), dilayani petugas Hendra (P0001)

---

#### **Entitas 6: DETAIL_PEMINJAMAN**

Menyimpan detail buku yang dipinjam dalam setiap transaksi.

**Atribut:**
- `id_detail` (PK) - ID auto increment, INT
- `kode_pinjam` (FK) - Referensi ke peminjaman.kode_pinjam
- `kode_buku` (FK) - Referensi ke koleksi_buku.kode_buku
- `kondisi_pinjam` - Kondisi saat dipinjam, ENUM('Baik','Rusak Ringan','Rusak Berat')
- `kondisi_kembali` - Kondisi saat dikembalikan, ENUM('Baik','Rusak Ringan','Rusak Berat'), NULL jika belum dikembalikan
- `denda_kerusakan` - Denda jika ada kerusakan, DECIMAL(10,2)

**Contoh Data:**
| id_detail | kode_pinjam | kode_buku | kondisi_pinjam | kondisi_kembali | denda_kerusakan |
|-----------|-------------|-----------|----------------|-----------------|-----------------|
| 1 | PJ20250001 | B0001 | Baik | NULL | 0.00 |
| 2 | PJ20250001 | B0002 | Baik | NULL | 0.00 |
| 3 | PJ20250002 | B0003 | Baik | Baik | 0.00 |
| 4 | PJ20250003 | B0001 | Baik | Rusak Ringan | 10000.00 |
| 5 | PJ20250003 | B0002 | Baik | Baik | 0.00 |

**Penjelasan FK:**
- `kode_pinjam` berisi nilai yang ada di tabel `peminjaman.kode_pinjam`
- `kode_buku` berisi nilai yang ada di tabel `koleksi_buku.kode_buku`
- Contoh:
  - Detail id 1 dan 2 → peminjaman PJ20250001 (Ahmad meminjam 2 buku: B0001 dan B0002)
  - Detail id 3 → peminjaman PJ20250002 (Siti meminjam 1 buku: B0003)
  - Detail id 4 dan 5 → peminjaman PJ20250003 (Budi meminjam 2 buku: B0001 dikembalikan rusak ringan, B0002 baik)

**Visualisasi Relasi Data:**
```
PJ20250001 (Ahmad pinjam 2 buku, masih dipinjam)
  ├── B0001 (Laskar Pelangi) - Kategori: KT001 (Fiksi)
  └── B0002 (Bumi Manusia) - Kategori: KT001 (Fiksi)

PJ20250002 (Siti pinjam 1 buku, sudah kembali tepat waktu)
  └── B0003 (Sapiens) - Kategori: KT002 (Non-Fiksi)

PJ20250003 (Budi pinjam 2 buku, sudah kembali terlambat 3 hari + 1 rusak)
  ├── B0001 (Laskar Pelangi) - Rusak Ringan (denda Rp 10.000)
  └── B0002 (Bumi Manusia) - Baik
  Total denda: Rp 3.000 (keterlambatan) + Rp 10.000 (kerusakan) = Rp 13.000
```

---

### C. ENTITY RELATIONSHIP DIAGRAM (ERD)

```
┌────────────────┐         ┌──────────────────┐
│ KATEGORI_BUKU  │1      N │ KOLEKSI_BUKU     │
│────────────────│◄────────│──────────────────│
│*kode_kategori  │         │*kode_buku        │
│ nama_kategori  │         │ judul_buku       │
│ keterangan     │         │ pengarang        │
│ created_at     │         │ penerbit         │
└────────────────┘         │ tahun_terbit     │
                           │ kode_kategori    │
                           │ jumlah_eksemplar │
                           │ tersedia         │
                           │ isbn             │
                           │ created_at       │
                           └────────┬─────────┘
                                    │ N
                                    │
                                    │ 1
                           ┌────────▼───────┐
                           │     DETAIL     │
                           │  PEMINJAMAN    │
                           │────────────────│
┌─────────────┐        1   │*id_detail      │
│  PETUGAS    │◄───────────│ kode_pinjam    │
│─────────────│            │ kode_buku      │
│*id_petugas  │            │ kondisi_pinjam │
│ nama_petugas│            │ kondisi_kembali│
│ username    │            │ denda_kerusakan│
│ password    │            └───────┬────────┘
│ jabatan     │                    │
│ no_telepon  │                    │N
│ created_at  │◄──┐ 1              │
└─────────────┘   │                │
                  │                │
                  │                │1
                  │        ┌───────▼────────┐
                  │        │  PEMINJAMAN    │
                  │        │────────────────│
                  │        │*kode_pinjam    │
                  │        │ id_anggota     │
                  │     N  │ id_petugas     │
                  └────────┤ tanggal_pinjam │
                           │ tanggal_kembali│
                        ┌──┤ batas_kembali  │
                        │N │ status_pinjam  │
                        │  │ denda          │
                        │  │ catatan        │
┌─────────────────┐     │  │ created_at     │
│  ANGGOTA        │◄────┘  └────────────────┘
│─────────────────│1
│*id_anggota      │
│ nama_lengkap    │
│ jenis_anggota   │
│ nomor_identitas │
│ email           │
│ no_telepon      │
│ alamat          │
│ tanggal_daftar  │
│ status_aktif    │
│ created_at      │
└─────────────────┘
```

### D. RELASI ANTAR ENTITAS

| Relasi | Kardinalitas | Keterangan |
|--------|--------------|------------|
| KATEGORI_BUKU → KOLEKSI_BUKU | 1:N | Satu kategori memiliki banyak buku |
| ANGGOTA → PEMINJAMAN | 1:N | Satu anggota dapat melakukan banyak peminjaman |
| PETUGAS → PEMINJAMAN | 1:N | Satu petugas dapat menangani banyak peminjaman |
| PEMINJAMAN → DETAIL_PEMINJAMAN | 1:N | Satu peminjaman dapat berisi banyak buku (max 3) |
| KOLEKSI_BUKU → DETAIL_PEMINJAMAN | 1:N | Satu buku dapat dipinjam berkali-kali (di waktu berbeda) |

### E. BUSINESS RULES

1. **Peminjaman:**
   - Maksimal 3 buku per anggota per transaksi
   - Lama peminjaman maksimal 7 hari
   - Anggota harus berstatus "Aktif"
   - Buku harus tersedia (tersedia > 0)

2. **Pengembalian:**
   - Denda keterlambatan: Rp 1.000 per hari per buku
   - Denda kerusakan:
     - Rusak Ringan: Rp 10.000
     - Rusak Berat: Rp 50.000
   - Saat pengembalian, jumlah buku tersedia bertambah

3. **Validasi:**
   - ISBN buku harus unik
   - Nomor identitas anggota harus unik
   - Username petugas harus unik
   - Jumlah tersedia tidak boleh negatif
   - Jumlah tersedia ≤ jumlah_eksemplar

---

## 3. IMPLEMENTASI STRUKTUR DATABASE 🛠️

### A. TUJUAN

Membuat tabel-tabel database dengan constraint lengkap menggunakan SQL DDL (Data Definition Language).

### B. CONTOH SOAL

**Soal:**
Buatlah perintah SQL untuk membuat semua tabel berdasarkan ERD yang telah dirancang, dengan ketentuan:

1. Gunakan tipe data yang sesuai untuk setiap kolom
2. Tambahkan constraint PRIMARY KEY pada setiap tabel
3. Tambahkan constraint FOREIGN KEY untuk menjaga referential integrity
4. Tambahkan constraint NOT NULL untuk field yang wajib diisi
5. Tambahkan constraint UNIQUE untuk field yang tidak boleh duplikat (ISBN, nomor_identitas, username)
6. Tambahkan constraint CHECK untuk validasi nilai (jumlah >= 0, denda >= 0)
7. Tambahkan DEFAULT value untuk field yang memiliki nilai default
8. Atur ON UPDATE CASCADE dan ON DELETE RESTRICT/CASCADE dengan tepat

### C. SOLUSI LENGKAP

```sql
-- ============================================
-- DATABASE PERPUSTAKAAN SEKOLAH
-- Solusi Implementasi Struktur Database
-- ============================================

-- Step 1: Hapus database jika sudah ada (hati-hati di production!)
DROP DATABASE IF EXISTS perpustakaan_sekolah;

-- Step 2: Buat database baru dengan character set UTF-8
CREATE DATABASE perpustakaan_sekolah
CHARACTER SET utf8mb4
COLLATE utf8mb4_general_ci;

-- Step 3: Pilih database yang akan digunakan
USE perpustakaan_sekolah;

-- ============================================
-- TABEL 1: KATEGORI_BUKU
-- Parent table (tidak ada FK ke tabel lain)
-- ============================================
CREATE TABLE kategori_buku (
    kode_kategori CHAR(5) PRIMARY KEY
        COMMENT 'Kode unik kategori, contoh: KT001',
    nama_kategori VARCHAR(100) NOT NULL
        COMMENT 'Nama kategori buku',
    keterangan TEXT
        COMMENT 'Deskripsi kategori (optional)',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        COMMENT 'Waktu pembuatan record'
) ENGINE=InnoDB COMMENT='Master kategori buku';

-- ============================================
-- TABEL 2: KOLEKSI_BUKU
-- Memiliki FK ke kategori_buku
-- ============================================
CREATE TABLE koleksi_buku (
    kode_buku CHAR(5) PRIMARY KEY
        COMMENT 'Kode unik buku, contoh: B0001',
    judul_buku VARCHAR(200) NOT NULL
        COMMENT 'Judul buku lengkap',
    pengarang VARCHAR(100) NOT NULL
        COMMENT 'Nama pengarang/penulis',
    penerbit VARCHAR(100) NOT NULL
        COMMENT 'Nama penerbit',
    tahun_terbit YEAR NOT NULL
        COMMENT 'Tahun publikasi (1901-2155)',
    kode_kategori CHAR(5) NOT NULL
        COMMENT 'Foreign key ke kategori_buku',
    jumlah_eksemplar INT NOT NULL DEFAULT 1
        COMMENT 'Total buku yang dimiliki',
    tersedia INT NOT NULL DEFAULT 1
        COMMENT 'Jumlah buku yang tersedia (belum dipinjam)',
    isbn VARCHAR(20) UNIQUE
        COMMENT 'Nomor ISBN (International Standard Book Number)',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        COMMENT 'Waktu pembuatan record',

    -- Foreign Key Constraint
    FOREIGN KEY (kode_kategori) REFERENCES kategori_buku(kode_kategori)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    -- Check constraints
    CONSTRAINT chk_jumlah_eksemplar CHECK (jumlah_eksemplar >= 0),
    CONSTRAINT chk_tersedia_positif CHECK (tersedia >= 0),
    CONSTRAINT chk_tersedia_max CHECK (tersedia <= jumlah_eksemplar)
) ENGINE=InnoDB COMMENT='Master koleksi buku perpustakaan';

-- ============================================
-- TABEL 3: ANGGOTA
-- Parent table untuk peminjaman
-- ============================================
CREATE TABLE anggota (
    id_anggota CHAR(5) PRIMARY KEY
        COMMENT 'ID unik anggota, contoh: A0001',
    nama_lengkap VARCHAR(100) NOT NULL
        COMMENT 'Nama lengkap anggota',
    jenis_anggota ENUM('Siswa','Guru','Staff') NOT NULL DEFAULT 'Siswa'
        COMMENT 'Tipe anggota perpustakaan',
    nomor_identitas VARCHAR(20) NOT NULL UNIQUE
        COMMENT 'NIS/NIP/NIK (harus unik)',
    email VARCHAR(100)
        COMMENT 'Email anggota (optional)',
    no_telepon VARCHAR(15)
        COMMENT 'Nomor telepon/HP',
    alamat TEXT
        COMMENT 'Alamat lengkap',
    tanggal_daftar DATE NOT NULL DEFAULT (CURRENT_DATE)
        COMMENT 'Tanggal mendaftar sebagai anggota',
    status_aktif ENUM('Aktif','Nonaktif') DEFAULT 'Aktif'
        COMMENT 'Status keanggotaan',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        COMMENT 'Waktu pembuatan record'
) ENGINE=InnoDB COMMENT='Master anggota perpustakaan';

-- ============================================
-- TABEL 4: PETUGAS
-- Parent table untuk peminjaman
-- ============================================
CREATE TABLE petugas (
    id_petugas CHAR(5) PRIMARY KEY
        COMMENT 'ID unik petugas, contoh: P0001',
    nama_petugas VARCHAR(100) NOT NULL
        COMMENT 'Nama lengkap petugas',
    username VARCHAR(50) NOT NULL UNIQUE
        COMMENT 'Username login (harus unik)',
    password VARCHAR(255) NOT NULL
        COMMENT 'Password terenkripsi (gunakan MD5/SHA256)',
    jabatan VARCHAR(50) NOT NULL
        COMMENT 'Jabatan petugas (Kepala/Staff)',
    no_telepon VARCHAR(15)
        COMMENT 'Nomor telepon/HP',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        COMMENT 'Waktu pembuatan record'
) ENGINE=InnoDB COMMENT='Master petugas perpustakaan';

-- ============================================
-- TABEL 5: PEMINJAMAN
-- Master transaksi peminjaman
-- Memiliki FK ke anggota dan petugas
-- ============================================
CREATE TABLE peminjaman (
    kode_pinjam CHAR(10) PRIMARY KEY
        COMMENT 'Kode unik transaksi, contoh: PJ20250001',
    id_anggota CHAR(5) NOT NULL
        COMMENT 'Foreign key ke anggota',
    id_petugas CHAR(5) NOT NULL
        COMMENT 'Foreign key ke petugas yang melayani',
    tanggal_pinjam DATE NOT NULL DEFAULT (CURRENT_DATE)
        COMMENT 'Tanggal peminjaman',
    tanggal_kembali DATE
        COMMENT 'Tanggal pengembalian aktual (NULL jika belum kembali)',
    batas_kembali DATE NOT NULL
        COMMENT 'Batas waktu pengembalian (tanggal_pinjam + 7 hari)',
    status_pinjam ENUM('dipinjam','dikembalikan') NOT NULL DEFAULT 'dipinjam'
        COMMENT 'Status peminjaman',
    denda DECIMAL(10,2) NOT NULL DEFAULT 0
        COMMENT 'Total denda keterlambatan + kerusakan',
    catatan TEXT
        COMMENT 'Catatan tambahan (optional)',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        COMMENT 'Waktu pembuatan record',

    -- Foreign Key Constraints
    FOREIGN KEY (id_anggota) REFERENCES anggota(id_anggota)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    FOREIGN KEY (id_petugas) REFERENCES petugas(id_petugas)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    -- Check constraint
    CONSTRAINT chk_denda CHECK (denda >= 0)
) ENGINE=InnoDB COMMENT='Master transaksi peminjaman';

-- ============================================
-- TABEL 6: DETAIL_PEMINJAMAN
-- Detail buku yang dipinjam dalam setiap transaksi
-- Memiliki FK ke peminjaman dan koleksi_buku
-- ============================================
CREATE TABLE detail_peminjaman (
    id_detail INT AUTO_INCREMENT PRIMARY KEY
        COMMENT 'ID auto increment',
    kode_pinjam CHAR(10) NOT NULL
        COMMENT 'Foreign key ke peminjaman',
    kode_buku CHAR(5) NOT NULL
        COMMENT 'Foreign key ke koleksi_buku',
    kondisi_pinjam ENUM('Baik','Rusak Ringan','Rusak Berat') NOT NULL DEFAULT 'Baik'
        COMMENT 'Kondisi buku saat dipinjam',
    kondisi_kembali ENUM('Baik','Rusak Ringan','Rusak Berat')
        COMMENT 'Kondisi buku saat dikembalikan (NULL jika belum kembali)',
    denda_kerusakan DECIMAL(10,2) DEFAULT 0
        COMMENT 'Denda jika ada kerusakan',

    -- Foreign Key Constraints
    FOREIGN KEY (kode_pinjam) REFERENCES peminjaman(kode_pinjam)
        ON UPDATE CASCADE
        ON DELETE CASCADE,  -- Jika peminjaman dihapus, detail ikut terhapus
    FOREIGN KEY (kode_buku) REFERENCES koleksi_buku(kode_buku)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,  -- Buku tidak boleh dihapus jika masih ada di detail

    -- Check constraint
    CONSTRAINT chk_denda_kerusakan CHECK (denda_kerusakan >= 0)
) ENGINE=InnoDB COMMENT='Detail buku yang dipinjam';

-- ============================================
-- INDEKS UNTUK PERFORMA QUERY (OPSIONAL)
-- ============================================

-- Indeks untuk pencarian buku
-- CREATE INDEX idx_buku_kategori ON koleksi_buku(kode_kategori);
-- CREATE INDEX idx_buku_judul ON koleksi_buku(judul_buku);
-- CREATE INDEX idx_buku_pengarang ON koleksi_buku(pengarang);

-- Indeks untuk anggota
-- CREATE INDEX idx_anggota_jenis ON anggota(jenis_anggota);
-- CREATE INDEX idx_anggota_status ON anggota(status_aktif);
-- CREATE INDEX idx_anggota_nama ON anggota(nama_lengkap);

-- Indeks untuk peminjaman
-- CREATE INDEX idx_peminjaman_anggota ON peminjaman(id_anggota);
-- CREATE INDEX idx_peminjaman_petugas ON peminjaman(id_petugas);
-- CREATE INDEX idx_peminjaman_status ON peminjaman(status_pinjam);
-- CREATE INDEX idx_peminjaman_tanggal ON peminjaman(tanggal_pinjam);
-- CREATE INDEX idx_peminjaman_batas ON peminjaman(batas_kembali);

-- Indeks untuk detail_peminjaman
-- CREATE INDEX idx_detail_pinjam ON detail_peminjaman(kode_pinjam);
-- CREATE INDEX idx_detail_buku ON detail_peminjaman(kode_buku);

-- ============================================
-- VERIFIKASI HASIL
-- ============================================

-- Tampilkan semua tabel yang telah dibuat
SHOW TABLES;

-- Tampilkan struktur setiap tabel
DESC kategori_buku;
DESC koleksi_buku;
DESC anggota;
DESC petugas;
DESC peminjaman;
DESC detail_peminjaman;

-- Cek foreign key relationships
SELECT
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'perpustakaan_sekolah'
    AND REFERENCED_TABLE_NAME IS NOT NULL;
```

### D. PENJELASAN DETAIL

#### 1. Tipe Data yang Digunakan

| Tipe Data | Penggunaan | Contoh |
|-----------|------------|--------|
| `CHAR(n)` | Kode/ID dengan panjang tetap | kode_buku: "B0001" |
| `VARCHAR(n)` | Teks dengan panjang variabel | nama_lengkap, email |
| `TEXT` | Teks panjang tanpa batas jelas | alamat, keterangan, catatan |
| `YEAR` | Tahun (1901-2155) | tahun_terbit: 2005 |
| `DATE` | Tanggal (YYYY-MM-DD) | tanggal_pinjam: 2025-11-20 |
| `TIMESTAMP` | Tanggal + waktu lengkap | created_at: 2025-11-20 14:30:00 |
| `DECIMAL(p,s)` | Angka desimal presisi tinggi | denda: 15000.00 |
| `INT` | Bilangan bulat | jumlah_eksemplar: 5 |
| `ENUM` | Pilihan nilai terbatas | status_pinjam: 'dipinjam' |

#### 2. Constraint yang Digunakan

| Constraint | Fungsi | Contoh |
|------------|--------|--------|
| `PRIMARY KEY` | Identifikasi unik per record | kode_buku CHAR(5) PRIMARY KEY |
| `FOREIGN KEY` | Hubungan antar tabel | FOREIGN KEY (kode_kategori) REFERENCES kategori_buku |
| `NOT NULL` | Field wajib diisi | nama_lengkap VARCHAR(100) NOT NULL |
| `UNIQUE` | Nilai tidak boleh duplikat | isbn VARCHAR(20) UNIQUE |
| `CHECK` | Validasi nilai | CHECK (denda >= 0) |
| `DEFAULT` | Nilai default | status_aktif ENUM DEFAULT 'Aktif' |

#### 3. ON UPDATE/DELETE Actions

| Action | Penjelasan | Kapan Digunakan |
|--------|-----------|-----------------|
| `CASCADE` | Perubahan/hapus parent → otomatis ubah/hapus child | Detail ikut terhapus jika peminjaman dihapus |
| `RESTRICT` | Cegah hapus parent jika masih ada child | Anggota tidak bisa dihapus jika masih punya pinjaman |
| `SET NULL` | Set NULL di child jika parent dihapus | Jarang dipakai (jika FK optional) |
| `NO ACTION` | Sama dengan RESTRICT | Default behavior |

#### 4. Kenapa Pakai ENGINE=InnoDB?

✅ **Keuntungan InnoDB:**
- Support FOREIGN KEY constraint
- Support transaksi (ACID compliance)
- Crash recovery yang baik
- Row-level locking (performa lebih baik untuk concurrent access)

### E. TIPS IMPLEMENTASI

1. **Urutan Pembuatan Tabel:**
   - Buat parent table dulu (kategori_buku, anggota, petugas)
   - Baru buat child table (koleksi_buku, peminjaman, detail_peminjaman)
   - Jika salah urutan, akan error karena FK reference tidak ada

2. **Testing Constraint:**
   ```sql
   -- Test PRIMARY KEY duplicate (harus error)
   INSERT INTO kategori_buku VALUES ('KT001', 'Test', NULL, NOW());
   INSERT INTO kategori_buku VALUES ('KT001', 'Test2', NULL, NOW()); -- ERROR!

   -- Test FOREIGN KEY invalid (harus error)
   INSERT INTO koleksi_buku VALUES ('B0001', 'Test', 'Author', 'Publisher', 2020, 'KT999', 1, 1, NULL, NOW()); -- ERROR!

   -- Test CHECK constraint (harus error)
   INSERT INTO peminjaman VALUES ('PJ0001', 'A0001', 'P0001', CURRENT_DATE, NULL, CURRENT_DATE + INTERVAL 7 DAY, 'dipinjam', -1000, NULL, NOW()); -- ERROR!
   ```

3. **Backup Sebelum Production:**
   ```sql
   -- Export database
   mysqldump -u root -p perpustakaan_sekolah > backup.sql

   -- Import database
   mysql -u root -p perpustakaan_sekolah < backup.sql
   ```

---

**🎯 CHECKPOINT PART 1:**

Anda telah menyelesaikan:
- ✅ Setup environment XAMPP + phpMyAdmin
- ✅ Perancangan database (identifikasi entitas, atribut, ERD, relasi)
- ✅ Implementasi struktur database (CREATE TABLE dengan constraint lengkap)

**Lanjut ke Part 2:** Manipulasi Data CRUD & Transaksi Peminjaman/Pengembalian

---

**Catatan:** Simpan semua script SQL di file `.sql` untuk dokumentasi dan troubleshooting!
