-- ============================================
-- DATABASE PERPUSTAKAAN SEKOLAH
-- Solusi Implementasi Struktur Database
-- Part 1: CREATE DATABASE & TABLES
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
        COMMENT 'Batas waktu pengembalian (tanggal_pinjam + 10 hari)',
    status_pinjam ENUM('dipinjam','dikembalikan') NOT NULL DEFAULT 'dipinjam'
        COMMENT 'Status peminjaman',
    denda DECIMAL(10,2) NOT NULL DEFAULT 0
        COMMENT 'Total denda keterlambatan',
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
-- SELESAI - Semua tabel berhasil dibuat!
-- ============================================

-- Verifikasi tabel yang sudah dibuat
SHOW TABLES;

-- Lihat struktur setiap tabel
SHOW CREATE TABLE kategori_buku;
SHOW CREATE TABLE koleksi_buku;
SHOW CREATE TABLE anggota;
SHOW CREATE TABLE petugas;
SHOW CREATE TABLE peminjaman;
SHOW CREATE TABLE detail_peminjaman;
