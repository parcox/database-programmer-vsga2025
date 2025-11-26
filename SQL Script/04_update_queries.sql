-- ============================================
-- DATABASE PERPUSTAKAAN SEKOLAH
-- Solusi QUERY UPDATE (MENGUBAH DATA)
-- Part 2: UPDATE Queries
-- ============================================

USE perpustakaan_sekolah;

-- ============================================
-- QUERY UPDATE - MENGUBAH DATA
-- ============================================

-- Update 1: Mengupdate email anggota dengan ID tertentu

-- Langkah 1: Cek data sebelum update
SELECT id_anggota, nama_lengkap, email
FROM anggota
WHERE id_anggota = 'A0001';

-- Langkah 2: Lakukan update
UPDATE anggota
SET email = 'ahmad.fauzi.baru@sekolah.com'
WHERE id_anggota = 'A0001';

-- Langkah 3: Verifikasi hasil update
SELECT id_anggota, nama_lengkap, email
FROM anggota
WHERE id_anggota = 'A0001';

-- ============================================

-- Update 2: Mengupdate stok buku tersedia
-- Misalnya: Tambah stok buku karena ada pembelian buku baru

-- Sebelum update
SELECT kode_buku, judul_buku, jumlah_eksemplar, tersedia
FROM koleksi_buku
WHERE kode_buku = 'B0001';

-- Update: Tambah 2 eksemplar buku B0001
UPDATE koleksi_buku
SET jumlah_eksemplar = jumlah_eksemplar + 2,
    tersedia = tersedia + 2
WHERE kode_buku = 'B0001';

-- Setelah update
SELECT kode_buku, judul_buku, jumlah_eksemplar, tersedia
FROM koleksi_buku
WHERE kode_buku = 'B0001';

-- ============================================

-- Update 3: Menonaktifkan anggota
UPDATE anggota
SET status_aktif = 'Nonaktif'
WHERE id_anggota = 'A0006';

-- Verifikasi
SELECT id_anggota, nama_lengkap, status_aktif
FROM anggota
WHERE id_anggota = 'A0006';

-- ============================================

-- Update 4: Update password petugas
UPDATE petugas
SET password = MD5('newpassword2025')
WHERE id_petugas = 'P0001';

-- Verifikasi (jangan tampilkan password!)
SELECT id_petugas, nama_petugas, username, 'Password sudah diupdate' AS status
FROM petugas
WHERE id_petugas = 'P0001';

-- ============================================

-- Update 5: Update dengan kondisi multiple
-- Misalnya: Update status anggota yang daftar sebelum 2024
UPDATE anggota
SET status_aktif = 'Nonaktif'
WHERE tanggal_daftar < '2024-01-01'
    AND jenis_anggota = 'Staff';

-- Verifikasi
SELECT id_anggota, nama_lengkap, jenis_anggota, tanggal_daftar, status_aktif
FROM anggota
WHERE jenis_anggota = 'Staff';
