-- ============================================
-- DATABASE PERPUSTAKAAN SEKOLAH
-- COMPLETE WORKFLOW: From Database Creation to Testing
-- Master Script - Run All Steps in Order
-- ============================================

-- ============================================
-- STEP 1: CREATE DATABASE & TABLES
-- ============================================
SOURCE /path/to/01_create_database_and_tables.sql;

-- ============================================
-- STEP 2: INSERT MASTER DATA
-- ============================================
SOURCE /path/to/02_insert_data_master.sql;

-- ============================================
-- STEP 3: CREATE STORED PROCEDURES
-- ============================================
SOURCE /path/to/06_stored_procedure_peminjaman.sql;
SOURCE /path/to/07_stored_procedure_pengembalian.sql;

-- ============================================
-- STEP 4: TEST CRUD OPERATIONS
-- ============================================

-- Test SELECT queries
SOURCE /path/to/03_select_queries.sql;

-- Test UPDATE queries
SOURCE /path/to/04_update_queries.sql;

-- Test DELETE queries (optional - be careful!)
-- SOURCE /path/to/05_delete_queries.sql;

-- ============================================
-- STEP 5: TEST TRANSACTIONS (PEMINJAMAN & PENGEMBALIAN)
-- ============================================

USE perpustakaan_sekolah;

-- Test 1: Peminjaman normal (2 buku)
CALL proses_peminjaman('PJ20250101', 'A0001', 'P0001', 'B0001');
CALL proses_peminjaman('PJ20250101', 'A0001', 'P0001', 'B0002');

-- Verify
SELECT * FROM peminjaman WHERE kode_pinjam = 'PJ20250101';
SELECT * FROM detail_peminjaman WHERE kode_pinjam = 'PJ20250101';

-- Test 2: Pengembalian tepat waktu
CALL proses_pengembalian('PJ20250101', 'B0001');

-- Verify
SELECT * FROM peminjaman WHERE kode_pinjam = 'PJ20250101';

-- Test 3: Pengembalian terlambat (simulasi)
-- Update tanggal pinjam untuk simulasi keterlambatan
UPDATE peminjaman
SET tanggal_pinjam = DATE_SUB(CURRENT_DATE, INTERVAL 15 DAY),
    batas_kembali = DATE_SUB(CURRENT_DATE, INTERVAL 5 DAY)
WHERE kode_pinjam = 'PJ20250101';

-- Kembalikan buku kedua dengan keterlambatan 5 hari
CALL proses_pengembalian('PJ20250101', 'B0002');
-- Expected denda: 5 hari x Rp 2.000 = Rp 10.000

-- Verify denda
SELECT kode_pinjam, id_anggota, tanggal_pinjam, batas_kembali,
       tanggal_kembali, denda, status_pinjam
FROM peminjaman
WHERE kode_pinjam = 'PJ20250101';

-- ============================================
-- STEP 6: TEST COMPLEX QUERIES
-- ============================================

-- Query 1: Anggota dengan buku yang dipinjam
SOURCE /path/to/08_query_kompleks_1_anggota_peminjaman.sql;

-- Query 2: Buku yang belum pernah dipinjam
SOURCE /path/to/09_query_kompleks_2_buku_belum_dipinjam.sql;

-- Query 3: Total denda per anggota
SOURCE /path/to/10_query_kompleks_3_denda_anggota.sql;

-- ============================================
-- STEP 7: VALIDATION & TESTING
-- ============================================

SOURCE /path/to/11_testing_validation.sql;

-- ============================================
-- STEP 8: FINAL REPORT
-- ============================================

SELECT '========================================' AS '';
SELECT 'FINAL DATABASE STATISTICS' AS '';
SELECT '========================================' AS '';

-- Summary Statistics
SELECT
    'Total Kategori' AS metrik,
    COUNT(*) AS nilai
FROM kategori_buku
UNION ALL
SELECT 'Total Buku', COUNT(*) FROM koleksi_buku
UNION ALL
SELECT 'Total Anggota Aktif', COUNT(*) FROM anggota WHERE status_aktif = 'Aktif'
UNION ALL
SELECT 'Total Petugas', COUNT(*) FROM petugas
UNION ALL
SELECT 'Total Transaksi', COUNT(*) FROM peminjaman
UNION ALL
SELECT 'Peminjaman Aktif', COUNT(*) FROM peminjaman WHERE status_pinjam = 'dipinjam'
UNION ALL
SELECT 'Total Denda Terkumpul', CONCAT('Rp ', FORMAT(SUM(denda), 0)) FROM peminjaman;

SELECT '========================================' AS '';
SELECT 'DATABASE SETUP COMPLETE!' AS '';
SELECT '========================================' AS '';

-- ============================================
-- NOTES:
-- 1. Ganti /path/to/ dengan path sebenarnya ke folder SQL Script
-- 2. Atau copy-paste isi setiap file secara manual
-- 3. Untuk production, backup database sebelum menjalankan DELETE queries
-- 4. Sesuaikan business rules (max books, loan period, late fee) sesuai kebutuhan
-- ============================================
