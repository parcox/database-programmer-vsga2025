-- ============================================
-- DATABASE PERPUSTAKAAN SEKOLAH
-- QUERY KOMPLEKS: Buku yang Belum Pernah Dipinjam
-- Part 3: Complex Queries - Query 2
-- ============================================

USE perpustakaan_sekolah;

-- ============================================
-- QUERY 2: Buku yang Belum Pernah Dipinjam
-- ============================================

-- Metode 1: LEFT JOIN dengan IS NULL (Paling mudah dipahami)
SELECT
    b.kode_buku,
    b.judul_buku,
    b.pengarang,
    b.penerbit,
    k.nama_kategori,
    b.tahun_terbit,
    b.jumlah_eksemplar,
    b.tersedia,
    'Belum pernah dipinjam' AS status
FROM koleksi_buku b
INNER JOIN kategori_buku k ON b.kode_kategori = k.kode_kategori
LEFT JOIN detail_peminjaman dp ON b.kode_buku = dp.kode_buku
WHERE dp.kode_buku IS NULL  -- Tidak ada di detail_peminjaman
ORDER BY k.nama_kategori, b.judul_buku;

-- ============================================

-- Metode 2: NOT IN dengan Subquery
SELECT
    b.kode_buku,
    b.judul_buku,
    b.pengarang,
    k.nama_kategori,
    b.jumlah_eksemplar
FROM koleksi_buku b
INNER JOIN kategori_buku k ON b.kode_kategori = k.kode_kategori
WHERE b.kode_buku NOT IN (
    SELECT DISTINCT kode_buku
    FROM detail_peminjaman
)
ORDER BY k.nama_kategori, b.judul_buku;

-- ============================================

-- Metode 3: NOT EXISTS dengan Subquery (Paling efisien untuk data besar)
SELECT
    b.kode_buku,
    b.judul_buku,
    b.pengarang,
    b.penerbit,
    k.nama_kategori,
    b.tahun_terbit
FROM koleksi_buku b
INNER JOIN kategori_buku k ON b.kode_kategori = k.kode_kategori
WHERE NOT EXISTS (
    SELECT 1
    FROM detail_peminjaman dp
    WHERE dp.kode_buku = b.kode_buku
)
ORDER BY k.nama_kategori, b.judul_buku;

-- ============================================

-- Analisis: Buku per kategori (belum pernah vs pernah dipinjam)
SELECT
    k.nama_kategori,
    COUNT(b.kode_buku) AS total_buku,
    SUM(CASE WHEN dp.kode_buku IS NULL THEN 1 ELSE 0 END) AS belum_pernah_dipinjam,
    SUM(CASE WHEN dp.kode_buku IS NOT NULL THEN 1 ELSE 0 END) AS pernah_dipinjam,
    ROUND(
        SUM(CASE WHEN dp.kode_buku IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(b.kode_buku),
        2
    ) AS persentase_belum_dipinjam
FROM kategori_buku k
LEFT JOIN koleksi_buku b ON k.kode_kategori = b.kode_kategori
LEFT JOIN (
    SELECT DISTINCT kode_buku FROM detail_peminjaman
) dp ON b.kode_buku = dp.kode_buku
GROUP BY k.nama_kategori
ORDER BY persentase_belum_dipinjam DESC;
