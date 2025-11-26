-- ============================================
-- DATABASE PERPUSTAKAAN SEKOLAH
-- QUERY KOMPLEKS: Total Denda per Anggota dalam Satu Bulan Terakhir
-- Part 3: Complex Queries - Query 3
-- ============================================

USE perpustakaan_sekolah;

-- ============================================
-- QUERY 3: Total Denda per Anggota (1 Bulan Terakhir)
-- ============================================

-- Query Utama: Total denda per anggota bulan ini
SELECT
    a.id_anggota,
    a.nama_lengkap,
    a.jenis_anggota,
    a.email,
    a.no_telepon,
    COUNT(DISTINCT p.kode_pinjam) AS jumlah_transaksi,
    SUM(p.denda) AS total_denda,
    MAX(p.tanggal_kembali) AS pengembalian_terakhir
FROM anggota a
INNER JOIN peminjaman p ON a.id_anggota = p.id_anggota
WHERE p.status_pinjam = 'dikembalikan'
    AND p.tanggal_kembali >= DATE_SUB(CURRENT_DATE, INTERVAL 1 MONTH)
    AND p.denda > 0  -- Hanya yang ada denda
GROUP BY a.id_anggota, a.nama_lengkap, a.jenis_anggota, a.email, a.no_telepon
ORDER BY total_denda DESC;

-- ============================================

-- Detail: Rincian denda per transaksi bulan ini
SELECT
    p.kode_pinjam,
    a.nama_lengkap,
    a.jenis_anggota,
    p.tanggal_pinjam,
    p.batas_kembali,
    p.tanggal_kembali,
    DATEDIFF(p.tanggal_kembali, p.batas_kembali) AS hari_terlambat,
    p.denda AS total_denda,
    COUNT(dp.id_detail) AS jumlah_buku
FROM peminjaman p
INNER JOIN anggota a ON p.id_anggota = a.id_anggota
LEFT JOIN detail_peminjaman dp ON p.kode_pinjam = dp.kode_pinjam
WHERE p.status_pinjam = 'dikembalikan'
    AND p.tanggal_kembali >= DATE_SUB(CURRENT_DATE, INTERVAL 1 MONTH)
    AND p.denda > 0
GROUP BY p.kode_pinjam, a.nama_lengkap, a.jenis_anggota,
         p.tanggal_pinjam, p.batas_kembali, p.tanggal_kembali, p.denda
ORDER BY p.tanggal_kembali DESC;

-- ============================================

-- Statistik: Denda per jenis anggota
SELECT
    a.jenis_anggota,
    COUNT(DISTINCT a.id_anggota) AS jumlah_anggota_berdenda,
    COUNT(DISTINCT p.kode_pinjam) AS jumlah_transaksi_berdenda,
    SUM(p.denda) AS total_denda,
    AVG(p.denda) AS rata_rata_denda_per_transaksi,
    MIN(p.denda) AS denda_minimum,
    MAX(p.denda) AS denda_maksimum
FROM anggota a
INNER JOIN peminjaman p ON a.id_anggota = p.id_anggota
WHERE p.status_pinjam = 'dikembalikan'
    AND p.tanggal_kembali >= DATE_SUB(CURRENT_DATE, INTERVAL 1 MONTH)
    AND p.denda > 0
GROUP BY a.jenis_anggota
ORDER BY total_denda DESC;
