-- ============================================
-- DATABASE PERPUSTAKAAN SEKOLAH
-- QUERY KOMPLEKS: Daftar Anggota dengan Jumlah Buku yang Sedang Dipinjam
-- Part 3: Complex Queries - Query 1
-- ============================================

USE perpustakaan_sekolah;

-- ============================================
-- QUERY 1: Anggota & Jumlah Buku yang Sedang Dipinjam
-- ============================================

-- Versi Lengkap: Semua anggota + info peminjaman
SELECT
    a.id_anggota,
    a.nama_lengkap,
    a.jenis_anggota,
    a.email,
    a.status_aktif,
    COUNT(DISTINCT CASE
        WHEN p.status_pinjam = 'dipinjam' THEN p.kode_pinjam
    END) AS jumlah_transaksi_aktif,
    COUNT(CASE
        WHEN p.status_pinjam = 'dipinjam' THEN dp.kode_buku
    END) AS jumlah_buku_dipinjam,
    GROUP_CONCAT(
        DISTINCT CASE
            WHEN p.status_pinjam = 'dipinjam' THEN b.judul_buku
        END
        ORDER BY b.judul_buku
        SEPARATOR '; '
    ) AS daftar_buku_dipinjam
FROM anggota a
LEFT JOIN peminjaman p ON a.id_anggota = p.id_anggota
LEFT JOIN detail_peminjaman dp ON p.kode_pinjam = dp.kode_pinjam
LEFT JOIN koleksi_buku b ON dp.kode_buku = b.kode_buku
GROUP BY a.id_anggota, a.nama_lengkap, a.jenis_anggota, a.email, a.status_aktif
ORDER BY jumlah_buku_dipinjam DESC, a.nama_lengkap;

-- ============================================

-- Versi Sederhana: Hanya yang sedang meminjam
SELECT
    a.id_anggota,
    a.nama_lengkap,
    a.jenis_anggota,
    COUNT(dp.id_detail) AS jumlah_buku_dipinjam,
    p.kode_pinjam,
    p.tanggal_pinjam,
    p.batas_kembali,
    DATEDIFF(p.batas_kembali, CURRENT_DATE) AS sisa_hari
FROM anggota a
INNER JOIN peminjaman p ON a.id_anggota = p.id_anggota
INNER JOIN detail_peminjaman dp ON p.kode_pinjam = dp.kode_pinjam
WHERE p.status_pinjam = 'dipinjam'
GROUP BY a.id_anggota, a.nama_lengkap, a.jenis_anggota,
         p.kode_pinjam, p.tanggal_pinjam, p.batas_kembali
ORDER BY sisa_hari ASC;  -- Yang paling dekat batas kembali di atas

-- ============================================

-- Versi Ringkas: Total buku per anggota
SELECT
    a.id_anggota,
    a.nama_lengkap,
    COUNT(dp.kode_buku) AS total_buku_dipinjam
FROM anggota a
INNER JOIN peminjaman p ON a.id_anggota = p.id_anggota
INNER JOIN detail_peminjaman dp ON p.kode_pinjam = dp.kode_pinjam
WHERE p.status_pinjam = 'dipinjam'
GROUP BY a.id_anggota, a.nama_lengkap
ORDER BY total_buku_dipinjam DESC;

-- ============================================

-- Analisis: Anggota dengan peminjaman terbanyak (sepanjang waktu)
SELECT
    a.id_anggota,
    a.nama_lengkap,
    a.jenis_anggota,
    COUNT(DISTINCT p.kode_pinjam) AS total_transaksi_pinjam,
    COUNT(dp.id_detail) AS total_buku_pernah_dipinjam,
    SUM(CASE WHEN p.status_pinjam = 'dipinjam' THEN 1 ELSE 0 END) AS sedang_dipinjam,
    SUM(CASE WHEN p.status_pinjam = 'dikembalikan' THEN 1 ELSE 0 END) AS sudah_dikembalikan
FROM anggota a
LEFT JOIN peminjaman p ON a.id_anggota = p.id_anggota
LEFT JOIN detail_peminjaman dp ON p.kode_pinjam = dp.kode_pinjam
GROUP BY a.id_anggota, a.nama_lengkap, a.jenis_anggota
HAVING total_transaksi_pinjam > 0
ORDER BY total_buku_pernah_dipinjam DESC
LIMIT 10;  -- Top 10 peminjam
