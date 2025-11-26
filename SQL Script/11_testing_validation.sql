-- ============================================
-- DATABASE PERPUSTAKAAN SEKOLAH
-- TESTING & VALIDATION QUERIES
-- Part 3: Testing and Debugging
-- ============================================

USE perpustakaan_sekolah;

-- ============================================
-- VALIDASI INTEGRITAS DATABASE
-- ============================================

-- 1. Cek Foreign Key Integrity: Anggota di peminjaman harus ada di master anggota
SELECT
    p.kode_pinjam,
    p.id_anggota,
    'Anggota tidak ditemukan!' AS error
FROM peminjaman p
LEFT JOIN anggota a ON p.id_anggota = a.id_anggota
WHERE a.id_anggota IS NULL;

-- 2. Cek Foreign Key Integrity: Petugas di peminjaman harus ada di master petugas
SELECT
    p.kode_pinjam,
    p.id_petugas,
    'Petugas tidak ditemukan!' AS error
FROM peminjaman p
LEFT JOIN petugas pt ON p.id_petugas = pt.id_petugas
WHERE pt.id_petugas IS NULL;

-- 3. Cek Foreign Key Integrity: Buku di detail_peminjaman harus ada di master buku
SELECT
    dp.id_detail,
    dp.kode_buku,
    'Buku tidak ditemukan!' AS error
FROM detail_peminjaman dp
LEFT JOIN koleksi_buku b ON dp.kode_buku = b.kode_buku
WHERE b.kode_buku IS NULL;

-- 4. Cek Konsistensi Stok: Tersedia tidak boleh lebih dari jumlah_eksemplar
SELECT
    kode_buku,
    judul_buku,
    jumlah_eksemplar,
    tersedia,
    'Stok tersedia melebihi total eksemplar!' AS error
FROM koleksi_buku
WHERE tersedia > jumlah_eksemplar;

-- 5. Cek Konsistensi Denda: Denda harus >= 0
SELECT
    kode_pinjam,
    id_anggota,
    denda,
    'Denda negatif!' AS error
FROM peminjaman
WHERE denda < 0;

-- 6. Cek Konsistensi Tanggal: Tanggal kembali harus >= tanggal pinjam
SELECT
    kode_pinjam,
    id_anggota,
    tanggal_pinjam,
    tanggal_kembali,
    'Tanggal kembali lebih awal dari tanggal pinjam!' AS error
FROM peminjaman
WHERE tanggal_kembali < tanggal_pinjam;

-- ============================================
-- STATISTIK PERPUSTAKAAN
-- ============================================

-- Statistik Umum
SELECT
    'Total Kategori' AS metrik,
    COUNT(*) AS nilai
FROM kategori_buku
UNION ALL
SELECT
    'Total Buku',
    COUNT(*)
FROM koleksi_buku
UNION ALL
SELECT
    'Total Eksemplar',
    SUM(jumlah_eksemplar)
FROM koleksi_buku
UNION ALL
SELECT
    'Total Buku Tersedia',
    SUM(tersedia)
FROM koleksi_buku
UNION ALL
SELECT
    'Total Anggota',
    COUNT(*)
FROM anggota
UNION ALL
SELECT
    'Anggota Aktif',
    COUNT(*)
FROM anggota
WHERE status_aktif = 'Aktif'
UNION ALL
SELECT
    'Total Petugas',
    COUNT(*)
FROM petugas
UNION ALL
SELECT
    'Total Transaksi Peminjaman',
    COUNT(*)
FROM peminjaman
UNION ALL
SELECT
    'Peminjaman Aktif',
    COUNT(*)
FROM peminjaman
WHERE status_pinjam = 'dipinjam'
UNION ALL
SELECT
    'Total Denda Terkumpul',
    SUM(denda)
FROM peminjaman;

-- ============================================
-- DEBUGGING QUERIES
-- ============================================

-- Lihat semua tabel
SHOW TABLES;

-- Lihat struktur tabel
DESCRIBE kategori_buku;
DESCRIBE koleksi_buku;
DESCRIBE anggota;
DESCRIBE petugas;
DESCRIBE peminjaman;
DESCRIBE detail_peminjaman;

-- Lihat constraint dan foreign keys
SELECT
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'perpustakaan_sekolah'
    AND REFERENCED_TABLE_NAME IS NOT NULL;

-- Lihat index yang ada
SHOW INDEX FROM koleksi_buku;
SHOW INDEX FROM peminjaman;
SHOW INDEX FROM detail_peminjaman;

-- Cek stored procedures
SHOW PROCEDURE STATUS WHERE Db = 'perpustakaan_sekolah';

-- Lihat definisi stored procedure
SHOW CREATE PROCEDURE proses_peminjaman;
SHOW CREATE PROCEDURE proses_pengembalian;
