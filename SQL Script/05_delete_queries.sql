-- ============================================
-- DATABASE PERPUSTAKAAN SEKOLAH
-- Solusi QUERY DELETE (MENGHAPUS DATA)
-- Part 2: DELETE Queries
-- ============================================

USE perpustakaan_sekolah;

-- ============================================
-- QUERY DELETE - MENGHAPUS DATA
-- ============================================

-- ⚠️ PENTING: Selalu SELECT dulu sebelum DELETE!

-- Delete 1: Hapus buku dengan ID tertentu

-- Langkah 1: Cek buku yang akan dihapus
SELECT kode_buku, judul_buku, tersedia
FROM koleksi_buku
WHERE kode_buku = 'B0009';

-- Langkah 2: Cek apakah buku pernah dipinjam (ada di detail_peminjaman)
SELECT COUNT(*) AS jumlah_transaksi
FROM detail_peminjaman
WHERE kode_buku = 'B0009';

-- Langkah 3: Jika COUNT = 0, aman untuk dihapus
DELETE FROM koleksi_buku
WHERE kode_buku = 'B0009';

-- Verifikasi hasil delete
SELECT * FROM koleksi_buku WHERE kode_buku = 'B0009';
-- Jika tidak ada hasil, berarti berhasil dihapus

-- ============================================

-- Delete 2: Hapus buku yang belum pernah dipinjam dan stoknya 0

-- Langkah 1: Cek buku yang memenuhi kriteria
SELECT b.kode_buku, b.judul_buku, b.tersedia
FROM koleksi_buku b
LEFT JOIN detail_peminjaman dp ON b.kode_buku = dp.kode_buku
WHERE b.tersedia = 0
    AND dp.kode_buku IS NULL
GROUP BY b.kode_buku, b.judul_buku, b.tersedia;

-- Langkah 2: Delete dengan subquery
DELETE FROM koleksi_buku
WHERE kode_buku IN (
    SELECT kode_buku
    FROM (
        SELECT b.kode_buku
        FROM koleksi_buku b
        LEFT JOIN detail_peminjaman dp ON b.kode_buku = dp.kode_buku
        WHERE b.tersedia = 0
            AND dp.kode_buku IS NULL
        GROUP BY b.kode_buku
    ) AS buku_hapus
);

-- ============================================

-- Delete 3: Hapus anggota yang nonaktif dan belum pernah pinjam buku

-- Cek anggota yang memenuhi kriteria
SELECT a.id_anggota, a.nama_lengkap, a.status_aktif
FROM anggota a
LEFT JOIN peminjaman p ON a.id_anggota = p.id_anggota
WHERE a.status_aktif = 'Nonaktif'
    AND p.id_anggota IS NULL;

-- Hapus anggota tersebut
DELETE FROM anggota
WHERE id_anggota IN (
    SELECT id_anggota
    FROM (
        SELECT a.id_anggota
        FROM anggota a
        LEFT JOIN peminjaman p ON a.id_anggota = p.id_anggota
        WHERE a.status_aktif = 'Nonaktif'
            AND p.id_anggota IS NULL
    ) AS anggota_hapus
);

-- ============================================

-- Delete 4: Hapus kategori yang tidak memiliki buku

-- Cek kategori kosong
SELECT k.kode_kategori, k.nama_kategori
FROM kategori_buku k
LEFT JOIN koleksi_buku b ON k.kode_kategori = b.kode_kategori
WHERE b.kode_buku IS NULL;

-- Hapus kategori kosong
DELETE FROM kategori_buku
WHERE kode_kategori NOT IN (
    SELECT DISTINCT kode_kategori
    FROM koleksi_buku
);

-- ============================================
-- CATATAN PENTING:
-- 1. Selalu SELECT dulu sebelum DELETE
-- 2. Gunakan WHERE clause untuk menghindari delete semua data
-- 3. Perhatikan FOREIGN KEY constraint (ON DELETE RESTRICT/CASCADE)
-- 4. Backup data sebelum melakukan DELETE di production
-- ============================================
