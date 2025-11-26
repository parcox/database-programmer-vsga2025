-- ============================================
-- DATABASE PERPUSTAKAAN SEKOLAH
-- Solusi QUERY SELECT (READ DATA)
-- Part 2: SELECT Queries
-- ============================================

USE perpustakaan_sekolah;

-- ============================================
-- QUERY SELECT - READ DATA
-- ============================================

-- Query 1: Menampilkan daftar buku yang tersedia
SELECT
    b.kode_buku,
    b.judul_buku,
    b.pengarang,
    b.penerbit,
    b.tahun_terbit,
    k.nama_kategori,
    b.jumlah_eksemplar,
    b.tersedia,
    CONCAT(b.tersedia, ' dari ', b.jumlah_eksemplar, ' buku') AS ketersediaan
FROM koleksi_buku b
INNER JOIN kategori_buku k ON b.kode_kategori = k.kode_kategori
WHERE b.tersedia > 0  -- Hanya buku yang tersedia
ORDER BY b.judul_buku;

-- Query 2: Menampilkan buku berdasarkan kategori tertentu
SELECT
    b.kode_buku,
    b.judul_buku,
    b.pengarang,
    b.penerbit,
    b.tahun_terbit,
    b.tersedia
FROM koleksi_buku b
WHERE kode_kategori = 'KT001'  -- Kategori Fiksi
    AND tersedia > 0
ORDER BY judul_buku;

-- Query 3: Menampilkan semua anggota dengan jenis "Siswa"
SELECT
    id_anggota,
    nama_lengkap,
    nomor_identitas,
    email,
    no_telepon,
    tanggal_daftar,
    status_aktif
FROM anggota
WHERE jenis_anggota = 'Siswa'
    AND status_aktif = 'Aktif'
ORDER BY nama_lengkap;

-- Query 4: Mencari buku berdasarkan judul atau pengarang (LIKE)
SELECT
    kode_buku,
    judul_buku,
    pengarang,
    penerbit,
    tahun_terbit,
    tersedia
FROM koleksi_buku
WHERE judul_buku LIKE '%Manusia%'
    OR pengarang LIKE '%Andrea%'
ORDER BY judul_buku;

-- Query 5: Menampilkan jumlah buku per kategori (GROUP BY + COUNT)
SELECT
    k.nama_kategori,
    COUNT(b.kode_buku) AS jumlah_buku,
    SUM(b.jumlah_eksemplar) AS total_eksemplar,
    SUM(b.tersedia) AS total_tersedia
FROM kategori_buku k
LEFT JOIN koleksi_buku b ON k.kode_kategori = b.kode_kategori
GROUP BY k.kode_kategori, k.nama_kategori
ORDER BY jumlah_buku DESC;

-- Query 6: Menampilkan statistik perpustakaan
SELECT
    'Total Kategori' AS keterangan,
    COUNT(*) AS jumlah
FROM kategori_buku
UNION ALL
SELECT
    'Total Buku',
    COUNT(*)
FROM koleksi_buku
UNION ALL
SELECT
    'Total Anggota Aktif',
    COUNT(*)
FROM anggota
WHERE status_aktif = 'Aktif'
UNION ALL
SELECT
    'Total Petugas',
    COUNT(*)
FROM petugas;
