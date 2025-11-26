# Pembekalan Database Programmer - Part 3
## Query Kompleks & Pengujian

> 📚 **Lanjutan dari Part 2** - Pastikan data dummy sudah diinsert dan stored procedure sudah dibuat

**Part 3 ini:** ±40 menit (Query Kompleks + Testing & Debugging)

---

## 6. QUERY KOMPLEKS (JOIN & AGREGASI) 📊

### A. TUJUAN

Menguasai query lanjutan untuk:
- Menggabungkan data dari multiple tabel (JOIN)
- Agregasi dan grouping data (COUNT, SUM, AVG, GROUP BY)
- Subquery dan nested query
- Window functions untuk ranking

### B. CONTOH SOAL

**Soal:**

Buatlah query SQL untuk:

1. **Menampilkan daftar anggota beserta jumlah buku yang sedang dipinjam**
2. **Menampilkan buku yang belum pernah dipinjam**
3. **Menampilkan total denda per anggota dalam satu bulan terakhir**

### C. SOLUSI LENGKAP

#### C.1. Query 1: Daftar Anggota dengan Jumlah Buku yang Sedang Dipinjam

```sql
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
```

#### C.2. Query 2: Buku yang Belum Pernah Dipinjam

```sql
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
```

#### C.3. Query 3: Total Denda per Anggota dalam Satu Bulan Terakhir

```sql
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
    SUM(CASE
        WHEN DATEDIFF(p.tanggal_kembali, p.batas_kembali) > 0
        THEN DATEDIFF(p.tanggal_kembali, p.batas_kembali) * 1000
        ELSE 0
    END) AS denda_keterlambatan,
    SUM(COALESCE(dp.denda_kerusakan, 0)) AS denda_kerusakan,
    MAX(p.tanggal_kembali) AS pengembalian_terakhir
FROM anggota a
INNER JOIN peminjaman p ON a.id_anggota = p.id_anggota
LEFT JOIN detail_peminjaman dp ON p.kode_pinjam = dp.kode_pinjam
WHERE p.status_pinjam = 'dikembalikan'
    AND p.tanggal_kembali >= DATE_SUB(CURRENT_DATE, INTERVAL 1 MONTH)
    AND p.denda > 0  -- Hanya yang ada denda
GROUP BY a.id_anggota, a.nama_lengkap, a.jenis_anggota, a.email, a.no_telepon
ORDER BY total_denda DESC;

-- Detail: Rincian denda per transaksi bulan ini
SELECT
    p.kode_pinjam,
    a.nama_lengkap,
    a.jenis_anggota,
    p.tanggal_pinjam,
    p.batas_kembali,
    p.tanggal_kembali,
    DATEDIFF(p.tanggal_kembali, p.batas_kembali) AS hari_terlambat,
    CASE
        WHEN DATEDIFF(p.tanggal_kembali, p.batas_kembali) > 0
        THEN DATEDIFF(p.tanggal_kembali, p.batas_kembali) * 1000
        ELSE 0
    END AS denda_keterlambatan,
    COALESCE(SUM(dp.denda_kerusakan), 0) AS denda_kerusakan,
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
```

#### C.4. Query Tambahan: Laporan Perpustakaan

```sql
-- ============================================
-- QUERY BONUS: Laporan Manajemen Perpustakaan
-- ============================================

-- Laporan 1: Buku Paling Populer (Paling Sering Dipinjam)
SELECT
    b.kode_buku,
    b.judul_buku,
    b.pengarang,
    k.nama_kategori,
    COUNT(dp.id_detail) AS total_dipinjam,
    COUNT(DISTINCT p.id_anggota) AS jumlah_peminjam_berbeda,
    b.jumlah_eksemplar,
    b.tersedia,
    ROUND(
        COUNT(dp.id_detail) * 100.0 / b.jumlah_eksemplar,
        2
    ) AS tingkat_peminjaman_persen
FROM koleksi_buku b
INNER JOIN kategori_buku k ON b.kode_kategori = k.kode_kategori
INNER JOIN detail_peminjaman dp ON b.kode_buku = dp.kode_buku
INNER JOIN peminjaman p ON dp.kode_pinjam = p.kode_pinjam
GROUP BY b.kode_buku, b.judul_buku, b.pengarang, k.nama_kategori,
         b.jumlah_eksemplar, b.tersedia
ORDER BY total_dipinjam DESC
LIMIT 10;

-- Laporan 2: Kategori Buku Paling Diminati
SELECT
    k.kode_kategori,
    k.nama_kategori,
    COUNT(DISTINCT b.kode_buku) AS jumlah_buku,
    COUNT(dp.id_detail) AS total_peminjaman,
    COUNT(DISTINCT p.id_anggota) AS jumlah_peminjam,
    ROUND(AVG(b.jumlah_eksemplar), 2) AS rata_rata_eksemplar_per_buku
FROM kategori_buku k
LEFT JOIN koleksi_buku b ON k.kode_kategori = b.kode_kategori
LEFT JOIN detail_peminjaman dp ON b.kode_buku = dp.kode_buku
LEFT JOIN peminjaman p ON dp.kode_pinjam = p.kode_pinjam
GROUP BY k.kode_kategori, k.nama_kategori
ORDER BY total_peminjaman DESC;

-- Laporan 3: Transaksi Peminjaman per Bulan (Tren)
SELECT
    DATE_FORMAT(p.tanggal_pinjam, '%Y-%m') AS bulan,
    COUNT(DISTINCT p.kode_pinjam) AS jumlah_transaksi,
    COUNT(dp.id_detail) AS jumlah_buku_dipinjam,
    COUNT(DISTINCT p.id_anggota) AS jumlah_peminjam_aktif,
    SUM(CASE WHEN p.status_pinjam = 'dikembalikan' THEN 1 ELSE 0 END) AS sudah_dikembalikan,
    SUM(CASE WHEN p.status_pinjam = 'dipinjam' THEN 1 ELSE 0 END) AS masih_dipinjam,
    SUM(p.denda) AS total_denda
FROM peminjaman p
LEFT JOIN detail_peminjaman dp ON p.kode_pinjam = dp.kode_pinjam
GROUP BY DATE_FORMAT(p.tanggal_pinjam, '%Y-%m')
ORDER BY bulan DESC
LIMIT 12;  -- 12 bulan terakhir

-- Laporan 4: Petugas dengan Transaksi Terbanyak
SELECT
    pt.id_petugas,
    pt.nama_petugas,
    pt.jabatan,
    COUNT(DISTINCT p.kode_pinjam) AS jumlah_transaksi_dilayani,
    COUNT(DISTINCT p.id_anggota) AS jumlah_anggota_dilayani,
    MIN(p.tanggal_pinjam) AS transaksi_pertama,
    MAX(p.tanggal_pinjam) AS transaksi_terakhir
FROM petugas pt
LEFT JOIN peminjaman p ON pt.id_petugas = p.id_petugas
GROUP BY pt.id_petugas, pt.nama_petugas, pt.jabatan
ORDER BY jumlah_transaksi_dilayani DESC;

-- Laporan 5: Anggota Teladan (Tidak Pernah Terlambat)
SELECT
    a.id_anggota,
    a.nama_lengkap,
    a.jenis_anggota,
    COUNT(DISTINCT p.kode_pinjam) AS total_peminjaman,
    COUNT(dp.id_detail) AS total_buku_dipinjam,
    SUM(p.denda) AS total_denda,
    MAX(p.tanggal_kembali) AS peminjaman_terakhir
FROM anggota a
INNER JOIN peminjaman p ON a.id_anggota = p.id_anggota
LEFT JOIN detail_peminjaman dp ON p.kode_pinjam = dp.kode_pinjam
WHERE p.status_pinjam = 'dikembalikan'
GROUP BY a.id_anggota, a.nama_lengkap, a.jenis_anggota
HAVING SUM(p.denda) = 0  -- Tidak pernah kena denda
    AND COUNT(DISTINCT p.kode_pinjam) >= 3  -- Minimal 3x pinjam
ORDER BY total_peminjaman DESC;

-- Laporan 6: Buku dengan Kondisi Rusak (Perlu Perhatian)
SELECT
    b.kode_buku,
    b.judul_buku,
    b.pengarang,
    k.nama_kategori,
    COUNT(dp.id_detail) AS total_peminjaman,
    SUM(CASE WHEN dp.kondisi_kembali = 'Baik' THEN 1 ELSE 0 END) AS dikembalikan_baik,
    SUM(CASE WHEN dp.kondisi_kembali = 'Rusak Ringan' THEN 1 ELSE 0 END) AS dikembalikan_rusak_ringan,
    SUM(CASE WHEN dp.kondisi_kembali = 'Rusak Berat' THEN 1 ELSE 0 END) AS dikembalikan_rusak_berat,
    SUM(COALESCE(dp.denda_kerusakan, 0)) AS total_denda_kerusakan,
    ROUND(
        SUM(CASE WHEN dp.kondisi_kembali IN ('Rusak Ringan', 'Rusak Berat') THEN 1 ELSE 0 END) * 100.0 /
        COUNT(CASE WHEN dp.kondisi_kembali IS NOT NULL THEN 1 END),
        2
    ) AS persentase_rusak
FROM koleksi_buku b
INNER JOIN kategori_buku k ON b.kode_kategori = k.kode_kategori
INNER JOIN detail_peminjaman dp ON b.kode_buku = dp.kode_buku
WHERE dp.kondisi_kembali IS NOT NULL  -- Sudah dikembalikan
GROUP BY b.kode_buku, b.judul_buku, b.pengarang, k.nama_kategori
HAVING SUM(CASE WHEN dp.kondisi_kembali IN ('Rusak Ringan', 'Rusak Berat') THEN 1 ELSE 0 END) > 0
ORDER BY persentase_rusak DESC, total_denda_kerusakan DESC;

-- Laporan 7: Dashboard Summary
SELECT
    (SELECT COUNT(*) FROM koleksi_buku) AS total_koleksi_buku,
    (SELECT SUM(jumlah_eksemplar) FROM koleksi_buku) AS total_eksemplar,
    (SELECT SUM(tersedia) FROM koleksi_buku) AS total_tersedia,
    (SELECT COUNT(*) FROM anggota WHERE status_aktif = 'Aktif') AS anggota_aktif,
    (SELECT COUNT(*) FROM peminjaman WHERE status_pinjam = 'dipinjam') AS transaksi_aktif,
    (SELECT COUNT(*) FROM detail_peminjaman dp
     INNER JOIN peminjaman p ON dp.kode_pinjam = p.kode_pinjam
     WHERE p.status_pinjam = 'dipinjam') AS buku_sedang_dipinjam,
    (SELECT SUM(denda) FROM peminjaman
     WHERE status_pinjam = 'dikembalikan'
     AND MONTH(tanggal_kembali) = MONTH(CURRENT_DATE)
     AND YEAR(tanggal_kembali) = YEAR(CURRENT_DATE)) AS denda_bulan_ini,
    (SELECT COUNT(*) FROM peminjaman
     WHERE status_pinjam = 'dipinjam'
     AND batas_kembali < CURRENT_DATE) AS peminjaman_terlambat;
```

### D. KONSEP PENTING QUERY KOMPLEKS

#### 1. Jenis JOIN

| Jenis JOIN | Penjelasan | Kapan Digunakan |
|------------|-----------|-----------------|
| **INNER JOIN** | Hanya baris yang match di kedua tabel | Data yang pasti ada hubungan (buku → kategori) |
| **LEFT JOIN** | Semua dari tabel kiri + match dari kanan (NULL jika tidak match) | Mau lihat semua anggota meskipun belum pinjam |
| **RIGHT JOIN** | Kebalikan LEFT JOIN | Jarang dipakai, biasanya pakai LEFT JOIN saja |
| **CROSS JOIN** | Kombinasi semua baris (Cartesian product) | Sangat jarang, untuk kombinasi data |

#### 2. Aggregate Functions

| Function | Kegunaan | Contoh |
|----------|----------|--------|
| `COUNT()` | Hitung jumlah baris | COUNT(kode_buku) |
| `SUM()` | Jumlahkan nilai numerik | SUM(denda) |
| `AVG()` | Rata-rata nilai | AVG(jumlah_eksemplar) |
| `MAX()` | Nilai maksimum | MAX(tanggal_pinjam) |
| `MIN()` | Nilai minimum | MIN(tahun_terbit) |
| `GROUP_CONCAT()` | Gabungkan string | GROUP_CONCAT(judul_buku SEPARATOR ', ') |

#### 3. GROUP BY & HAVING

```sql
-- GROUP BY: Mengelompokkan data berdasarkan kolom tertentu
SELECT kategori, COUNT(*) AS jumlah
FROM buku
GROUP BY kategori;

-- HAVING: Filter hasil GROUP BY (WHERE untuk aggregate)
SELECT kategori, COUNT(*) AS jumlah
FROM buku
GROUP BY kategori
HAVING COUNT(*) > 10;  -- Hanya kategori dengan > 10 buku
```

#### 4. Subquery

```sql
-- Subquery di WHERE (filter berdasarkan hasil query lain)
SELECT * FROM buku
WHERE kode_buku IN (SELECT kode_buku FROM detail_peminjaman);

-- Subquery di FROM (derived table)
SELECT kategori, rata_rata
FROM (
    SELECT kode_kategori AS kategori, AVG(harga) AS rata_rata
    FROM buku
    GROUP BY kode_kategori
) AS subquery
WHERE rata_rata > 50000;

-- Subquery di SELECT (kolom hasil dari query lain)
SELECT
    nama_anggota,
    (SELECT COUNT(*) FROM peminjaman WHERE id_anggota = a.id_anggota) AS total_pinjam
FROM anggota a;
```

#### 5. CASE Expression

```sql
-- CASE untuk conditional logic
SELECT
    nama_buku,
    tersedia,
    CASE
        WHEN tersedia = 0 THEN 'Habis'
        WHEN tersedia < 3 THEN 'Stok Menipis'
        ELSE 'Tersedia'
    END AS status_ketersediaan
FROM koleksi_buku;
```

---

## 7. PENGUJIAN & DEBUGGING 🔧

### A. TUJUAN

Memastikan database dan query berfungsi dengan benar, serta mampu mengidentifikasi dan memperbaiki error.

### B. CONTOH SOAL

**Soal:**

a. Lakukan pengujian terhadap query peminjaman dan pengembalian menggunakan data dummy
b. Identifikasi dan perbaiki kesalahan logika jika hasil query tidak sesuai
c. Simulasikan skenario pengembalian buku terlambat dan validasi perhitungan denda

### C. SOLUSI LENGKAP

#### C.1. Pengujian Stored Procedure Peminjaman

```sql
-- ============================================
-- TEST CASE 1: Peminjaman Normal (Harus Sukses)
-- ============================================

-- Setup: Pastikan data sudah ada
SELECT * FROM anggota WHERE id_anggota = 'A0001';
SELECT * FROM koleksi_buku WHERE kode_buku IN ('B0001', 'B0002', 'B0003');

-- Test 1.1: Peminjaman pertama (harus sukses)
CALL proses_peminjaman('PJ20250201', 'A0001', 'P0001', 'B0001');

-- Verifikasi hasil
SELECT * FROM peminjaman WHERE kode_pinjam = 'PJ20250201';
SELECT * FROM detail_peminjaman WHERE kode_pinjam = 'PJ20250201';
SELECT kode_buku, judul_buku, tersedia FROM koleksi_buku WHERE kode_buku = 'B0001';
-- Expected: tersedia berkurang 1

-- Test 1.2: Tambah buku ke-2 dalam transaksi yang sama (harus sukses)
CALL proses_peminjaman('PJ20250201', 'A0001', 'P0001', 'B0002');

-- Test 1.3: Tambah buku ke-3 (harus sukses)
CALL proses_peminjaman('PJ20250201', 'A0001', 'P0001', 'B0003');

-- ============================================
-- TEST CASE 2: Validasi Error (Harus Gagal)
-- ============================================

-- Test 2.1: Maksimal 3 buku per transaksi
CALL proses_peminjaman('PJ20250201', 'A0001', 'P0001', 'B0004');
-- Expected: ERROR - Maksimal 3 buku per transaksi

-- Test 2.2: Buku yang sama tidak bisa dipinjam 2x dalam transaksi sama
CALL proses_peminjaman('PJ20250201', 'A0001', 'P0001', 'B0001');
-- Expected: ERROR - Buku sudah ada dalam transaksi

-- Test 2.3: Anggota tidak aktif
UPDATE anggota SET status_aktif = 'Nonaktif' WHERE id_anggota = 'A0006';
CALL proses_peminjaman('PJ20250202', 'A0006', 'P0001', 'B0005');
-- Expected: ERROR - Anggota tidak aktif
UPDATE anggota SET status_aktif = 'Aktif' WHERE id_anggota = 'A0006';  -- Restore

-- Test 2.4: Buku tidak tersedia (stok habis)
UPDATE koleksi_buku SET tersedia = 0 WHERE kode_buku = 'B0006';
CALL proses_peminjaman('PJ20250203', 'A0002', 'P0001', 'B0006');
-- Expected: ERROR - Buku tidak tersedia

-- Test 2.5: Anggota tidak ditemukan
CALL proses_peminjaman('PJ20250204', 'A9999', 'P0001', 'B0005');
-- Expected: ERROR - Anggota tidak ditemukan

-- ============================================
-- TEST CASE 3: Maksimal 3 Transaksi Aktif per Anggota
-- ============================================

-- Anggota A0002 buat 3 transaksi
CALL proses_peminjaman('PJ20250205', 'A0002', 'P0001', 'B0004');
CALL proses_peminjaman('PJ20250206', 'A0002', 'P0001', 'B0005');
-- B0006 restore dulu
UPDATE koleksi_buku SET tersedia = 1 WHERE kode_buku = 'B0006';
CALL proses_peminjaman('PJ20250207', 'A0002', 'P0001', 'B0006');

-- Coba transaksi ke-4 (harus error)
CALL proses_peminjaman('PJ20250208', 'A0002', 'P0001', 'B0007');
-- Expected: ERROR - Sudah memiliki 3 peminjaman aktif

-- Cek peminjaman aktif
SELECT * FROM peminjaman WHERE id_anggota = 'A0002' AND status_pinjam = 'dipinjam';
```

#### C.2. Pengujian Stored Procedure Pengembalian

```sql
-- ============================================
-- TEST CASE 4: Pengembalian Tepat Waktu (Tidak Ada Denda)
-- ============================================

-- Test 4.1: Kembalikan buku dalam kondisi baik, tepat waktu
CALL proses_pengembalian('PJ20250201', 'B0001', 'Baik');
-- Expected: Denda = 0 (tepat waktu, kondisi baik)

-- Verifikasi
SELECT * FROM peminjaman WHERE kode_pinjam = 'PJ20250201';
SELECT * FROM detail_peminjaman WHERE kode_pinjam = 'PJ20250201' AND kode_buku = 'B0001';
SELECT kode_buku, judul_buku, tersedia FROM koleksi_buku WHERE kode_buku = 'B0001';
-- Expected: tersedia bertambah 1, kondisi_kembali = 'Baik', denda_kerusakan = 0

-- ============================================
-- TEST CASE 5: Pengembalian Terlambat (Ada Denda Keterlambatan)
-- ============================================

-- Test 5.1: Simulasi keterlambatan 5 hari
-- Ubah tanggal pinjam jadi 12 hari yang lalu (7 hari + 5 hari terlambat)
UPDATE peminjaman
SET tanggal_pinjam = DATE_SUB(CURRENT_DATE, INTERVAL 12 DAY),
    batas_kembali = DATE_SUB(CURRENT_DATE, INTERVAL 5 DAY)
WHERE kode_pinjam = 'PJ20250201';

-- Kembalikan buku B0002
CALL proses_pengembalian('PJ20250201', 'B0002', 'Baik');
-- Expected: Denda keterlambatan = 5 hari x Rp 1.000 = Rp 5.000

-- Verifikasi perhitungan denda
SELECT
    kode_pinjam,
    tanggal_pinjam,
    batas_kembali,
    tanggal_kembali,
    DATEDIFF(tanggal_kembali, batas_kembali) AS hari_terlambat,
    denda
FROM peminjaman
WHERE kode_pinjam = 'PJ20250201';

-- ============================================
-- TEST CASE 6: Pengembalian dengan Kerusakan
-- ============================================

-- Test 6.1: Kembalikan dengan kerusakan ringan (10 hari terlambat + rusak ringan)
UPDATE peminjaman
SET tanggal_pinjam = DATE_SUB(CURRENT_DATE, INTERVAL 17 DAY),
    batas_kembali = DATE_SUB(CURRENT_DATE, INTERVAL 10 DAY)
WHERE kode_pinjam = 'PJ20250201';

CALL proses_pengembalian('PJ20250201', 'B0003', 'Rusak Ringan');
-- Expected:
-- Denda keterlambatan = 10 hari x Rp 1.000 = Rp 10.000
-- Denda kerusakan = Rp 10.000
-- Total = Rp 20.000

-- Verifikasi
SELECT * FROM peminjaman WHERE kode_pinjam = 'PJ20250201';
SELECT * FROM detail_peminjaman WHERE kode_pinjam = 'PJ20250201';
-- Expected: status_pinjam = 'dikembalikan' (semua buku sudah kembali)

-- Test 6.2: Kembalikan dengan kerusakan berat
CALL proses_peminjaman('PJ20250209', 'A0003', 'P0002', 'B0007');

-- Simulasi terlambat 3 hari
UPDATE peminjaman
SET tanggal_pinjam = DATE_SUB(CURRENT_DATE, INTERVAL 10 DAY),
    batas_kembali = DATE_SUB(CURRENT_DATE, INTERVAL 3 DAY)
WHERE kode_pinjam = 'PJ20250209';

CALL proses_pengembalian('PJ20250209', 'B0007', 'Rusak Berat');
-- Expected:
-- Denda keterlambatan = 3 hari x Rp 1.000 = Rp 3.000
-- Denda kerusakan = Rp 50.000
-- Total = Rp 53.000

-- ============================================
-- TEST CASE 7: Pengembalian Bertahap (Multiple Buku)
-- ============================================

-- Pinjam 3 buku
CALL proses_peminjaman('PJ20250210', 'A0004', 'P0001', 'B0001');
CALL proses_peminjaman('PJ20250210', 'A0004', 'P0001', 'B0002');
CALL proses_peminjaman('PJ20250210', 'A0004', 'P0001', 'B0003');

-- Cek status awal
SELECT * FROM peminjaman WHERE kode_pinjam = 'PJ20250210';
-- Expected: status_pinjam = 'dipinjam'

-- Kembalikan buku pertama
CALL proses_pengembalian('PJ20250210', 'B0001', 'Baik');
SELECT status_pinjam FROM peminjaman WHERE kode_pinjam = 'PJ20250210';
-- Expected: Masih 'dipinjam' (karena masih ada 2 buku belum kembali)

-- Kembalikan buku kedua
CALL proses_pengembalian('PJ20250210', 'B0002', 'Baik');
SELECT status_pinjam FROM peminjaman WHERE kode_pinjam = 'PJ20250210';
-- Expected: Masih 'dipinjam'

-- Kembalikan buku ketiga (terakhir)
CALL proses_pengembalian('PJ20250210', 'B0003', 'Baik');
SELECT status_pinjam FROM peminjaman WHERE kode_pinjam = 'PJ20250210';
-- Expected: Berubah menjadi 'dikembalikan' (semua buku sudah kembali)

-- ============================================
-- TEST CASE 8: Validasi Error Pengembalian
-- ============================================

-- Test 8.1: Pengembalian data yang tidak ada
CALL proses_pengembalian('PJ99999999', 'B0001', 'Baik');
-- Expected: ERROR - Data peminjaman tidak ditemukan

-- Test 8.2: Pengembalian buku yang sudah dikembalikan
CALL proses_pengembalian('PJ20250210', 'B0001', 'Baik');
-- Expected: ERROR - Data sudah dikembalikan
```

#### C.3. Validasi Integritas Data

```sql
-- ============================================
-- VALIDASI KONSISTENSI DATA
-- ============================================

-- Validasi 1: Cek konsistensi stok buku
SELECT
    b.kode_buku,
    b.judul_buku,
    b.jumlah_eksemplar,
    b.tersedia,
    COUNT(CASE WHEN p.status_pinjam = 'dipinjam' THEN dp.id_detail END) AS sedang_dipinjam,
    (b.jumlah_eksemplar - b.tersedia) AS seharusnya_dipinjam,
    -- Bandingkan
    CASE
        WHEN COUNT(CASE WHEN p.status_pinjam = 'dipinjam' THEN dp.id_detail END) =
             (b.jumlah_eksemplar - b.tersedia)
        THEN '✓ OK'
        ELSE '✗ TIDAK KONSISTEN!'
    END AS status_validasi
FROM koleksi_buku b
LEFT JOIN detail_peminjaman dp ON b.kode_buku = dp.kode_buku
LEFT JOIN peminjaman p ON dp.kode_pinjam = p.kode_pinjam
GROUP BY b.kode_buku, b.judul_buku, b.jumlah_eksemplar, b.tersedia
HAVING status_validasi = '✗ TIDAK KONSISTEN!';
-- Jika ada hasil, berarti ada inkonsistensi!

-- Validasi 2: Cek peminjaman tanpa detail
SELECT
    p.kode_pinjam,
    p.id_anggota,
    p.tanggal_pinjam,
    p.status_pinjam,
    COUNT(dp.id_detail) AS jumlah_buku
FROM peminjaman p
LEFT JOIN detail_peminjaman dp ON p.kode_pinjam = dp.kode_pinjam
GROUP BY p.kode_pinjam, p.id_anggota, p.tanggal_pinjam, p.status_pinjam
HAVING COUNT(dp.id_detail) = 0;
-- Seharusnya tidak ada hasil (setiap peminjaman harus ada detailnya)

-- Validasi 3: Cek detail peminjaman orphan (tanpa header)
SELECT dp.*, 'ORPHAN - tidak ada header peminjaman!' AS masalah
FROM detail_peminjaman dp
LEFT JOIN peminjaman p ON dp.kode_pinjam = p.kode_pinjam
WHERE p.kode_pinjam IS NULL;
-- Seharusnya tidak ada hasil

-- Validasi 4: Cek transaksi dengan status 'dikembalikan' tapi masih ada buku belum kembali
SELECT
    p.kode_pinjam,
    p.status_pinjam,
    COUNT(dp.id_detail) AS total_buku,
    SUM(CASE WHEN dp.kondisi_kembali IS NULL THEN 1 ELSE 0 END) AS belum_kembali
FROM peminjaman p
INNER JOIN detail_peminjaman dp ON p.kode_pinjam = dp.kode_pinjam
WHERE p.status_pinjam = 'dikembalikan'
GROUP BY p.kode_pinjam, p.status_pinjam
HAVING SUM(CASE WHEN dp.kondisi_kembali IS NULL THEN 1 ELSE 0 END) > 0;
-- Seharusnya tidak ada hasil (inconsistent state)

-- Validasi 5: Cek buku dengan tersedia > jumlah_eksemplar
SELECT
    kode_buku,
    judul_buku,
    jumlah_eksemplar,
    tersedia,
    'ERROR: tersedia > jumlah_eksemplar' AS masalah
FROM koleksi_buku
WHERE tersedia > jumlah_eksemplar;
-- Seharusnya tidak ada hasil

-- Validasi 6: Cek peminjaman melewati batas kembali yang masih aktif
SELECT
    p.kode_pinjam,
    a.nama_lengkap,
    p.tanggal_pinjam,
    p.batas_kembali,
    DATEDIFF(CURRENT_DATE, p.batas_kembali) AS hari_terlambat,
    COUNT(dp.id_detail) AS jumlah_buku
FROM peminjaman p
INNER JOIN anggota a ON p.id_anggota = a.id_anggota
INNER JOIN detail_peminjaman dp ON p.kode_pinjam = dp.kode_pinjam
WHERE p.status_pinjam = 'dipinjam'
    AND p.batas_kembali < CURRENT_DATE
GROUP BY p.kode_pinjam, a.nama_lengkap, p.tanggal_pinjam, p.batas_kembali
ORDER BY hari_terlambat DESC;
-- Ini daftar peminjaman yang terlambat dan perlu ditindaklanjuti
```

### D. DEBUGGING TIPS & COMMON ERRORS

#### 1. Error Umum dan Solusinya

| Error Code | Pesan | Penyebab | Solusi |
|------------|-------|----------|--------|
| **1062** | Duplicate entry for key 'PRIMARY' | Insert PK yang sudah ada | Gunakan kode unik atau cek data existing |
| **1452** | Cannot add or update a child row | Foreign key tidak valid | Pastikan data parent exists dulu |
| **1451** | Cannot delete or update a parent row | Masih ada child records | Hapus child dulu atau gunakan CASCADE |
| **1054** | Unknown column | Typo nama kolom atau kolom tidak ada | Cek DESCRIBE tabel untuk nama kolom |
| **1064** | Syntax error | SQL syntax salah | Cek tanda kutip, koma, keyword |
| **1146** | Table doesn't exist | Tabel belum dibuat | Pastikan USE database yang benar |
| **1242** | Subquery returns more than 1 row | Subquery di SELECT mengembalikan > 1 row | Tambahkan LIMIT 1 atau gunakan aggregate |
| **3819** | Check constraint violated | Nilai tidak sesuai CHECK constraint | Pastikan nilai sesuai kondisi CHECK |
| **1364** | Field doesn't have a default value | NOT NULL field tanpa nilai | Berikan nilai atau set DEFAULT |

#### 2. Query Optimization Tools

```sql
-- EXPLAIN: Lihat execution plan query
EXPLAIN SELECT
    b.judul_buku, a.nama_lengkap
FROM koleksi_buku b
INNER JOIN detail_peminjaman dp ON b.kode_buku = dp.kode_buku
INNER JOIN peminjaman p ON dp.kode_pinjam = p.kode_pinjam
INNER JOIN anggota a ON p.id_anggota = a.id_anggota
WHERE p.status_pinjam = 'dipinjam';

-- Cek index yang digunakan
SHOW INDEX FROM koleksi_buku;
SHOW INDEX FROM peminjaman;

-- Analisa slow query (cek execution time)
SET profiling = 1;
SELECT ... (your query) ...;
SHOW PROFILES;
```

#### 3. Transaction Testing

```sql
-- Manual transaction untuk testing aman
START TRANSACTION;

-- Jalankan query yang ingin ditest
UPDATE koleksi_buku SET tersedia = tersedia - 1 WHERE kode_buku = 'B0001';

-- Cek hasil sementara
SELECT * FROM koleksi_buku WHERE kode_buku = 'B0001';

-- Jika salah, rollback
ROLLBACK;

-- Jika benar, commit
-- COMMIT;
```

### E. CHECKLIST PENGUJIAN LENGKAP

#### ✅ Sebelum Submit/Deploy

- [ ] **Struktur Database**
  - [ ] Semua tabel sudah dibuat dengan nama yang benar
  - [ ] Primary key ada di semua tabel
  - [ ] Foreign key relationship sudah benar
  - [ ] Constraint NOT NULL, UNIQUE sudah tepat
  - [ ] CHECK constraint berfungsi dengan benar
  - [ ] Index sudah dibuat untuk kolom yang sering di-query

- [ ] **Data Dummy**
  - [ ] Minimal 3 record per tabel master
  - [ ] Data realistis dan konsisten
  - [ ] Foreign key reference valid

- [ ] **CRUD Operations**
  - [ ] INSERT berhasil untuk semua tabel
  - [ ] SELECT menampilkan data yang benar
  - [ ] UPDATE mengubah data dengan tepat
  - [ ] DELETE bekerja dengan validasi FK

- [ ] **Stored Procedures**
  - [ ] Procedure peminjaman bisa dijalankan tanpa error
  - [ ] Validasi maksimal 3 buku berfungsi
  - [ ] Validasi status anggota berfungsi
  - [ ] Validasi stok buku berfungsi
  - [ ] Procedure pengembalian bisa dijalankan
  - [ ] Perhitungan denda keterlambatan benar (Rp 1.000/hari)
  - [ ] Perhitungan denda kerusakan benar (Rp 10.000 / 50.000)
  - [ ] Stok buku ter-update otomatis

- [ ] **Query Kompleks**
  - [ ] Query anggota dengan jumlah pinjaman berjalan
  - [ ] Query buku belum pernah dipinjam menampilkan hasil benar
  - [ ] Query total denda per anggota akurat
  - [ ] JOIN tidak menghasilkan cartesian product
  - [ ] Aggregate function (COUNT, SUM) menghasilkan nilai benar

- [ ] **Validasi & Testing**
  - [ ] Test case happy path (sukses) berjalan
  - [ ] Test case error handling berjalan
  - [ ] Validasi konsistensi data tidak ada masalah
  - [ ] Simulasi keterlambatan menghitung denda dengan benar
  - [ ] Tidak ada orphan records
  - [ ] Tidak ada data inconsistent

- [ ] **Dokumentasi**
  - [ ] Query diberi komentar yang jelas
  - [ ] Asumsi bisnis didokumentasikan
  - [ ] Error handling dijelaskan
  - [ ] File SQL sudah di-backup

---

**🎯 CHECKPOINT PART 3:**

Anda telah menyelesaikan:
- ✅ Query kompleks dengan JOIN multi-tabel
- ✅ Agregasi data dengan GROUP BY, HAVING
- ✅ Subquery untuk filter dan derived table
- ✅ Laporan manajemen perpustakaan lengkap
- ✅ Pengujian stored procedure dengan berbagai test case
- ✅ Validasi integritas data dan konsistensi
- ✅ Debugging tips dan common errors
- ✅ Checklist pengujian lengkap

---

## 🎓 PENUTUP & TIPS UJIAN

### Strategi Mengerjakan Ujian (120 Menit)

| Waktu | Aktivitas | Tips |
|-------|-----------|------|
| **0-10 menit** | Baca soal lengkap 2x | Pahami requirement, tandai keyword penting |
| **10-20 menit** | Rancang ERD di kertas | Identifikasi entitas, atribut, relasi |
| **20-50 menit** | Implementasi CREATE TABLE | Copy-paste template, sesuaikan nama/tipe data |
| **50-70 menit** | Insert data & CRUD | Minimal 3 record per tabel, test SELECT/UPDATE |
| **70-95 menit** | Stored procedure transaksi | Fokus validasi utama dulu, test dengan CALL |
| **95-110 menit** | Query kompleks JOIN | Mulai dari query sederhana, tambah kompleksitas |
| **110-115 menit** | Testing & validasi | Jalankan semua test case, cek error |
| **115-120 menit** | Review & backup | Export SQL, cek checklist, dokumentasi |

### Do's ✅

- ✅ Baca soal 2x sebelum mulai
- ✅ Buat ERD sketch di kertas terlebih dahulu
- ✅ Copy-paste template SQL untuk mempercepat
- ✅ Test setiap query sebelum lanjut ke tahap berikutnya
- ✅ Gunakan nama variabel/kolom yang jelas dan konsisten
- ✅ Tambahkan komentar di SQL kompleks
- ✅ Backup/export database sebelum submit
- ✅ Verifikasi hasil dengan SELECT setelah INSERT/UPDATE/DELETE

### Don'ts ❌

- ❌ Langsung coding tanpa rancangan ERD
- ❌ Skip validasi constraint (CHECK, FK, UNIQUE)
- ❌ Lupa WHERE clause di UPDATE/DELETE
- ❌ Abaikan error message (baca baik-baik!)
- ❌ Buat nama tabel/kolom dengan spasi atau karakter aneh
- ❌ Lupa test stored procedure sebelum submit
- ❌ Submit tanpa backup file SQL
- ❌ Panik jika ada error (debug step by step)

### Tools & Resources

- **phpMyAdmin**: Export/Import, visual query builder
- **Notepad++/VS Code**: Edit SQL dengan syntax highlighting
- **MySQL Docs**: https://dev.mysql.com/doc/
- **W3Schools SQL**: https://www.w3schools.com/sql/
- **Stack Overflow**: Cari solusi error dengan error code

---

**🎉 SELAMAT! Anda sudah menyelesaikan semua materi pembekalan Database Programmer.**

**Good luck untuk ujian! 💪🚀**

---

**Catatan Akhir:**
- Simpan semua file Part 1, 2, dan 3 sebagai referensi
- Latih ulang stored procedure dan query kompleks
- Pahami konsep, jangan hafalan query
- Fokus pada pemahaman, bukan menghafal
