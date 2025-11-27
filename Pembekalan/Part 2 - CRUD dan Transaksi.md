# Pembekalan Database Programmer - Part 2
## Manipulasi Data CRUD & Transaksi

> 📚 **Lanjutan dari Part 1** - Pastikan database perpustakaan_sekolah sudah dibuat

**Part 2 ini:** ±40 menit (CRUD + Stored Procedure Transaksi)

---

## 4. MANIPULASI DATA (CRUD) ✏️

### A. TUJUAN

Menguasai operasi dasar database:
- **CREATE** - INSERT data baru
- **READ** - SELECT/menampilkan data
- **UPDATE** - Mengubah data yang ada
- **DELETE** - Menghapus data

### B. CONTOH SOAL

**Soal 4a: Insert Data**

Masukkan data contoh (minimal 3 data) ke dalam tabel:
- **Kategori Buku**: Fiksi, Non-Fiksi, Referensi
- **Koleksi Buku**: judul, pengarang, penerbit, tahun_terbit (minimal 3 buku)
- **Anggota**: nama, email, jenis_anggota (minimal 1 Siswa dan 1 Guru)
- **Petugas**: data petugas perpustakaan

**Soal 4b: Query SELECT**

Buatlah query untuk:
1. Menampilkan daftar buku yang tersedia (tersedia > 0)
2. Mengupdate email anggota dengan ID tertentu
3. Menghapus data buku dengan ID tertentu

### C. SOLUSI LENGKAP

#### C.1. INSERT DATA (CREATE)

```sql
-- ============================================
-- INSERT DATA MASTER
-- ============================================

USE perpustakaan_sekolah;

-- ============================================
-- 1. INSERT KATEGORI_BUKU
-- ============================================
INSERT INTO kategori_buku (kode_kategori, nama_kategori, keterangan) VALUES
('KT001', 'Fiksi', 'Novel, cerita pendek, dan karya fiksi lainnya'),
('KT002', 'Non-Fiksi', 'Buku pengetahuan, biografi, sejarah'),
('KT003', 'Referensi', 'Kamus, ensiklopedia, buku panduan'),
('KT004', 'Komik', 'Komik dan novel grafis'),
('KT005', 'Sains', 'Buku sains dan teknologi');

-- Verifikasi hasil insert
SELECT * FROM kategori_buku;

-- ============================================
-- 2. INSERT KOLEKSI_BUKU
-- ============================================
INSERT INTO koleksi_buku (
    kode_buku, judul_buku, pengarang, penerbit,
    tahun_terbit, kode_kategori, jumlah_eksemplar,
    tersedia, isbn
) VALUES
-- Fiksi
('B0001', 'Laskar Pelangi', 'Andrea Hirata', 'Bentang Pustaka', 2005, 'KT001', 5, 5, '978-979-3062-79-2'),
('B0002', 'Bumi Manusia', 'Pramoedya Ananta Toer', 'Hasta Mitra', 1980, 'KT001', 3, 3, '978-979-461-001-5'),
('B0003', 'Perahu Kertas', 'Dee Lestari', 'Bentang Pustaka', 2009, 'KT001', 4, 4, '978-979-3062-98-3'),

-- Non-Fiksi
('B0004', 'Sapiens: Riwayat Singkat Manusia', 'Yuval Noah Harari', 'Kepustakaan Populer Gramedia', 2015, 'KT002', 3, 3, '978-602-424-109-3'),
('B0005', 'Filosofi Teras', 'Henry Manampiring', 'Kompas', 2018, 'KT002', 6, 6, '978-602-412-518-9'),

-- Referensi
('B0006', 'Kamus Besar Bahasa Indonesia', 'Tim Redaksi', 'Balai Pustaka', 2020, 'KT003', 2, 2, '978-979-407-182-4'),
('B0007', 'Ensiklopedia Indonesia', 'Tim Penulis', 'Erlangga', 2019, 'KT003', 2, 2, '978-602-298-765-3'),

-- Sains
('B0008', 'Fisika untuk SMA Kelas X', 'Marthen Kanginan', 'Erlangga', 2021, 'KT005', 10, 10, '978-602-298-890-2'),
('B0009', 'Biologi untuk SMA Kelas XI', 'Campbell', 'Erlangga', 2020, 'KT005', 8, 8, '978-602-298-891-9');

-- Verifikasi hasil insert dengan JOIN
SELECT
    b.kode_buku,
    b.judul_buku,
    b.pengarang,
    k.nama_kategori,
    b.tahun_terbit,
    b.jumlah_eksemplar,
    b.tersedia
FROM koleksi_buku b
INNER JOIN kategori_buku k ON b.kode_kategori = k.kode_kategori
ORDER BY b.kode_buku;

-- ============================================
-- 3. INSERT ANGGOTA
-- ============================================
INSERT INTO anggota (
    id_anggota, nama_lengkap, jenis_anggota,
    nomor_identitas, email, no_telepon,
    alamat, tanggal_daftar, status_aktif
) VALUES
-- Siswa
('A0001', 'Ahmad Fauzi', 'Siswa', '2024001', 'ahmad.fauzi@sekolah.com', '081234567890', 'Jl. Merdeka No. 10, Jakarta', '2024-01-15', 'Aktif'),
('A0002', 'Siti Nurhaliza', 'Siswa', '2024002', 'siti.nur@sekolah.com', '082345678901', 'Jl. Sudirman No. 25, Jakarta', '2024-01-15', 'Aktif'),
('A0003', 'Budi Santoso', 'Siswa', '2024003', 'budi.santoso@sekolah.com', '083456789012', 'Jl. Thamrin No. 15, Jakarta', '2024-02-01', 'Aktif'),

-- Guru
('A0004', 'Dewi Lestari, S.Pd', 'Guru', '198501001', 'dewi.lestari@sekolah.com', '081234567899', 'Jl. Gatot Subroto No. 5, Jakarta', '2020-07-01', 'Aktif'),
('A0005', 'Bambang Wijaya, S.Pd', 'Guru', '198502002', 'bambang.wijaya@sekolah.com', '082345678900', 'Jl. Kuningan No. 20, Jakarta', '2020-07-01', 'Aktif'),

-- Staff
('A0006', 'Rina Kartika', 'Staff', '199001001', 'rina.kartika@sekolah.com', '083456789013', 'Jl. Blora No. 8, Jakarta', '2021-01-15', 'Aktif');

-- Verifikasi hasil insert
SELECT
    id_anggota,
    nama_lengkap,
    jenis_anggota,
    nomor_identitas,
    email,
    status_aktif
FROM anggota
ORDER BY jenis_anggota, id_anggota;

-- ============================================
-- 4. INSERT PETUGAS
-- ============================================
INSERT INTO petugas (
    id_petugas, nama_petugas, username,
    password, jabatan, no_telepon
) VALUES
('P0001', 'Hendra Gunawan', 'hendra_admin', MD5('admin123'), 'Kepala Perpustakaan', '081234560001'),
('P0002', 'Sari Indah', 'sari_staff', MD5('staff123'), 'Staff Perpustakaan', '082345670002'),
('P0003', 'Agus Prasetyo', 'agus_staff', MD5('staff123'), 'Staff Perpustakaan', '083456780003');

-- Verifikasi hasil insert (tanpa password untuk keamanan)
SELECT
    id_petugas,
    nama_petugas,
    username,
    jabatan,
    no_telepon
FROM petugas;

-- ============================================
-- VERIFIKASI TOTAL DATA
-- ============================================
SELECT 'Kategori Buku' AS tabel, COUNT(*) AS jumlah FROM kategori_buku
UNION ALL
SELECT 'Koleksi Buku', COUNT(*) FROM koleksi_buku
UNION ALL
SELECT 'Anggota', COUNT(*) FROM anggota
UNION ALL
SELECT 'Petugas', COUNT(*) FROM petugas;
```

#### C.2. SELECT DATA (READ)

```sql
-- ============================================
-- QUERY SELECT - READ DATA
-- ============================================

-- Query 1: Menampilkan daftar buku yang tersedia
SELECT
    b.kode_buku,
    b.judul_buku,
    b.pengarang,
    b.penerbit,
    k.nama_kategori,
    b.tahun_terbit,
    b.jumlah_eksemplar,
    b.tersedia,
    CONCAT(b.tersedia, ' dari ', b.jumlah_eksemplar, ' eksemplar') AS info_ketersediaan
FROM koleksi_buku b
INNER JOIN kategori_buku k ON b.kode_kategori = k.kode_kategori
WHERE b.tersedia > 0  -- Hanya yang tersedia
ORDER BY k.nama_kategori, b.judul_buku;

-- Query 2: Menampilkan buku dengan filter kategori tertentu
SELECT
    kode_buku,
    judul_buku,
    pengarang,
    tersedia
FROM koleksi_buku
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

-- Query 4: Menampilkan anggota beserta jumlah aktif per jenis
SELECT
    jenis_anggota,
    COUNT(*) AS jumlah_anggota,
    SUM(CASE WHEN status_aktif = 'Aktif' THEN 1 ELSE 0 END) AS aktif,
    SUM(CASE WHEN status_aktif = 'Nonaktif' THEN 1 ELSE 0 END) AS nonaktif
FROM anggota
GROUP BY jenis_anggota;

-- Query 5: Cari buku berdasarkan kata kunci judul atau pengarang
SELECT
    b.kode_buku,
    b.judul_buku,
    b.pengarang,
    k.nama_kategori,
    b.tersedia
FROM koleksi_buku b
INNER JOIN kategori_buku k ON b.kode_kategori = k.kode_kategori
WHERE b.judul_buku LIKE '%manusia%'  -- Cari kata "manusia" di judul
    OR b.pengarang LIKE '%hirata%'   -- Atau cari "hirata" di pengarang
ORDER BY b.judul_buku;
```

#### C.3. UPDATE DATA (UPDATE)

```sql
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
SET email = 'ahmad.fauzi.baru@sekolah.com',
    no_telepon = '081999888777'  -- Sekalian update telepon
WHERE id_anggota = 'A0001';

-- Langkah 3: Verifikasi hasil update
SELECT id_anggota, nama_lengkap, email, no_telepon
FROM anggota
WHERE id_anggota = 'A0001';

-- Update 2: Update jumlah buku tersedia (simulasi peminjaman manual)
-- Sebelum update
SELECT kode_buku, judul_buku, jumlah_eksemplar, tersedia
FROM koleksi_buku
WHERE kode_buku = 'B0001';

-- Update (kurangi 1 buku karena dipinjam)
UPDATE koleksi_buku
SET tersedia = tersedia - 1
WHERE kode_buku = 'B0001'
    AND tersedia > 0;  -- Pastikan tidak negatif

-- Setelah update
SELECT kode_buku, judul_buku, jumlah_eksemplar, tersedia
FROM koleksi_buku
WHERE kode_buku = 'B0001';

-- Update 3: Nonaktifkan anggota yang sudah lulus/resign
UPDATE anggota
SET status_aktif = 'Nonaktif'
WHERE id_anggota = 'A0003';

-- Verifikasi
SELECT id_anggota, nama_lengkap, jenis_anggota, status_aktif
FROM anggota
WHERE id_anggota = 'A0003';

-- Update 4: Update password petugas (dengan enkripsi)
UPDATE petugas
SET password = MD5('newpassword123')
WHERE username = 'sari_staff';

-- Update 5: Koreksi data buku (typo pengarang atau penerbit)
UPDATE koleksi_buku
SET pengarang = 'Andrea Hirata',  -- Koreksi jika typo
    tahun_terbit = 2005
WHERE kode_buku = 'B0001';
```

#### C.4. DELETE DATA (DELETE)

```sql
-- ============================================
-- QUERY DELETE - MENGHAPUS DATA
-- ============================================

-- ⚠️ PENTING: Selalu SELECT dulu sebelum DELETE!

-- Delete 1: Hapus buku dengan ID tertentu

-- Langkah 1: Cek buku yang akan dihapus
SELECT kode_buku, judul_buku, tersedia
FROM koleksi_buku
WHERE kode_buku = 'B0009';

-- Langkah 2: Cek apakah buku sedang dipinjam
SELECT dp.kode_buku, b.judul_buku, COUNT(*) AS sedang_dipinjam
FROM detail_peminjaman dp
INNER JOIN koleksi_buku b ON dp.kode_buku = b.kode_buku
INNER JOIN peminjaman p ON dp.kode_pinjam = p.kode_pinjam
WHERE dp.kode_buku = 'B0009'
    AND p.status_pinjam = 'dipinjam'
GROUP BY dp.kode_buku, b.judul_buku;

-- Langkah 3: Hapus jika aman (tidak sedang dipinjam)
DELETE FROM koleksi_buku
WHERE kode_buku = 'B0009';

-- Verifikasi hasil delete
SELECT * FROM koleksi_buku WHERE kode_buku = 'B0009';
-- Jika tidak ada hasil, berarti berhasil dihapus

-- Delete 2: Hapus buku yang belum pernah dipinjam dan stoknya 0

-- Langkah 1: Cek buku yang memenuhi kriteria
SELECT b.kode_buku, b.judul_buku, b.tersedia
FROM koleksi_buku b
LEFT JOIN detail_peminjaman dp ON b.kode_buku = dp.kode_buku
WHERE b.tersedia = 0  -- Stok habis
    AND dp.kode_buku IS NULL  -- Belum pernah dipinjam
GROUP BY b.kode_buku, b.judul_buku, b.tersedia;

-- Langkah 2: Hapus jika ada
DELETE FROM koleksi_buku
WHERE kode_buku IN (
    SELECT kode_buku FROM (
        SELECT b.kode_buku
        FROM koleksi_buku b
        LEFT JOIN detail_peminjaman dp ON b.kode_buku = dp.kode_buku
        WHERE b.tersedia = 0 AND dp.kode_buku IS NULL
    ) AS temp
);

-- Delete 3: Hapus kategori yang tidak memiliki buku
-- Cek dulu
SELECT k.kode_kategori, k.nama_kategori, COUNT(b.kode_buku) AS jumlah_buku
FROM kategori_buku k
LEFT JOIN koleksi_buku b ON k.kode_kategori = b.kode_kategori
GROUP BY k.kode_kategori, k.nama_kategori
HAVING COUNT(b.kode_buku) = 0;

-- Hapus jika ada
DELETE FROM kategori_buku
WHERE kode_kategori NOT IN (
    SELECT DISTINCT kode_kategori FROM koleksi_buku
);

-- Delete 4: Hapus anggota yang sudah nonaktif dan tidak punya riwayat peminjaman
SELECT a.id_anggota, a.nama_lengkap, a.status_aktif
FROM anggota a
LEFT JOIN peminjaman p ON a.id_anggota = p.id_anggota
WHERE a.status_aktif = 'Nonaktif'
    AND p.kode_pinjam IS NULL;

-- Hapus jika aman
DELETE FROM anggota
WHERE id_anggota IN (
    SELECT id_anggota FROM (
        SELECT a.id_anggota
        FROM anggota a
        LEFT JOIN peminjaman p ON a.id_anggota = p.id_anggota
        WHERE a.status_aktif = 'Nonaktif' AND p.kode_pinjam IS NULL
    ) AS temp
);
```

### D. TIPS CRUD OPERATIONS

#### ✅ Best Practices

1. **INSERT:**
   - Gunakan INSERT dengan kolom eksplisit (jangan `INSERT INTO tabel VALUES (...)`)
   - Insert data parent dulu sebelum child (kategori → buku)
   - Cek constraint sebelum insert (unique, foreign key)

2. **SELECT:**
   - Gunakan alias untuk tabel (FROM koleksi_buku b)
   - Filter dengan WHERE yang spesifik
   - JOIN hanya kolom yang diperlukan
   - Gunakan LIMIT untuk data besar

3. **UPDATE:**
   - **SELALU pakai WHERE!** Tanpa WHERE = semua record berubah
   - SELECT dulu untuk preview data yang akan diubah
   - Gunakan transaksi untuk update penting:
     ```sql
     START TRANSACTION;
     UPDATE ...;
     SELECT * FROM ...; -- Cek hasil
     COMMIT; -- atau ROLLBACK jika salah
     ```

4. **DELETE:**
   - **SANGAT HATI-HATI!** Data terhapus permanen
   - SELECT dulu untuk preview data yang akan dihapus
   - Cek foreign key dependency (data child dulu)
   - Backup database sebelum DELETE massal
   - Pertimbangkan "soft delete" (update status_aktif)

#### ⚠️ Common Mistakes

| Error | Penyebab | Solusi |
|-------|----------|--------|
| Duplicate entry for key 'PRIMARY' | Insert PK yang sudah ada | Gunakan kode unik atau AUTO_INCREMENT |
| Cannot add or update a child row | FK tidak valid | Pastikan data parent exists |
| Cannot delete or update a parent row | Masih ada child records | Hapus child dulu atau gunakan CASCADE |
| Data too long for column | VARCHAR terlalu pendek | Perbesar ukuran atau potong data |
| UPDATE/DELETE tanpa WHERE | Lupa filter | Semua data berubah/hilang! |

---

## 5. TRANSAKSI PEMINJAMAN & PENGEMBALIAN 🔄

### A. TUJUAN

Membuat **stored procedure** untuk menangani logika bisnis kompleks transaksi peminjaman dan pengembalian buku dengan validasi otomatis.

### B. CONTOH SOAL

**Soal:**

Buatlah *stored procedure* atau SQL script untuk mencatat transaksi peminjaman dan pengembalian, dengan aturan:

1. **Peminjaman:**
   - Maksimal 2 buku per anggota per transaksi
   - Lama peminjaman maksimal 10 hari

2. **Pengembalian:**
   - Jika buku dikembalikan lebih dari 10 hari, sistem harus menghitung denda Rp 2.000/hari

### C. SOLUSI LENGKAP

#### C.1. Stored Procedure: Proses Peminjaman

```sql
-- ============================================
-- STORED PROCEDURE: PROSES PEMINJAMAN BUKU
-- ============================================

DELIMITER $$

DROP PROCEDURE IF EXISTS proses_peminjaman$$

CREATE PROCEDURE proses_peminjaman(
    IN p_kode_pinjam CHAR(10),
    IN p_id_anggota CHAR(5),
    IN p_id_petugas CHAR(5),
    IN p_kode_buku CHAR(5)
)
BEGIN
    -- Deklarasi variabel
    DECLARE v_jumlah_buku_transaksi INT;
    DECLARE v_batas_kembali DATE;
    DECLARE v_peminjaman_exists INT;

    -- Handler untuk error
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'ERROR: Transaksi gagal! Silakan cek data dan coba lagi.' AS status;
    END;

    -- Mulai transaksi
    START TRANSACTION;

    -- ============================================
    -- VALIDASI: Cek jumlah buku dalam transaksi ini
    -- (Maksimal 2 buku per transaksi)
    -- ============================================
    SELECT COUNT(*) INTO v_peminjaman_exists
    FROM peminjaman
    WHERE kode_pinjam = p_kode_pinjam;

    IF v_peminjaman_exists > 0 THEN
        -- Transaksi sudah ada, cek jumlah buku
        SELECT COUNT(*) INTO v_jumlah_buku_transaksi
        FROM detail_peminjaman
        WHERE kode_pinjam = p_kode_pinjam;

        IF v_jumlah_buku_transaksi >= 2 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Error: Maksimal 2 buku per transaksi!';
        END IF;

        -- Cek apakah buku sudah dipinjam di transaksi ini
        IF EXISTS (
            SELECT 1 FROM detail_peminjaman
            WHERE kode_pinjam = p_kode_pinjam AND kode_buku = p_kode_buku
        ) THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Error: Buku ini sudah ada dalam transaksi!';
        END IF;
    END IF;

    -- ============================================
    -- PROSES: Hitung batas kembali (10 hari)
    -- ============================================
    SET v_batas_kembali = DATE_ADD(CURRENT_DATE, INTERVAL 10 DAY);

    -- ============================================
    -- PROSES: Insert/Update peminjaman
    -- ============================================
    IF v_peminjaman_exists = 0 THEN
        -- Transaksi baru
        INSERT INTO peminjaman (
            kode_pinjam, id_anggota, id_petugas,
            tanggal_pinjam, batas_kembali, status_pinjam
        ) VALUES (
            p_kode_pinjam, p_id_anggota, p_id_petugas,
            CURRENT_DATE, v_batas_kembali, 'dipinjam'
        );
    END IF;

    -- ============================================
    -- PROSES: Insert detail peminjaman
    -- ============================================
    INSERT INTO detail_peminjaman (
        kode_pinjam, kode_buku, kondisi_pinjam
    ) VALUES (
        p_kode_pinjam, p_kode_buku, 'Baik'
    );

    -- Commit transaksi
    COMMIT;

    -- ============================================
    -- OUTPUT: Informasi transaksi berhasil
    -- ============================================
    SELECT
        'SUKSES' AS status,
        p_kode_pinjam AS kode_pinjam,
        p_id_anggota AS id_anggota,
        (SELECT nama_lengkap FROM anggota WHERE id_anggota = p_id_anggota) AS nama_anggota,
        p_kode_buku AS kode_buku,
        (SELECT judul_buku FROM koleksi_buku WHERE kode_buku = p_kode_buku) AS judul_buku,
        CURRENT_DATE AS tanggal_pinjam,
        v_batas_kembali AS batas_kembali,
        'Peminjaman berhasil! Harap kembalikan sebelum batas waktu.' AS keterangan;

END$$

DELIMITER ;
```

#### C.2. Stored Procedure: Proses Pengembalian

```sql
-- ============================================
-- STORED PROCEDURE: PROSES PENGEMBALIAN BUKU
-- ============================================

DELIMITER $$

DROP PROCEDURE IF EXISTS proses_pengembalian$$

CREATE PROCEDURE proses_pengembalian(
    IN p_kode_pinjam CHAR(10),
    IN p_kode_buku CHAR(5)
)
BEGIN
    -- Deklarasi variabel
    DECLARE v_tanggal_pinjam DATE;
    DECLARE v_batas_kembali DATE;
    DECLARE v_hari_terlambat INT;
    DECLARE v_denda_terlambat DECIMAL(10,2);
    DECLARE v_jumlah_buku_belum_kembali INT;
    DECLARE v_detail_exists INT;

    -- Handler untuk error
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'ERROR: Pengembalian gagal! Silakan cek data peminjaman.' AS status;
    END;

    -- Mulai transaksi
    START TRANSACTION;

    -- ============================================
    -- VALIDASI: Cek peminjaman exists
    -- ============================================
    SELECT COUNT(*) INTO v_detail_exists
    FROM detail_peminjaman dp
    INNER JOIN peminjaman p ON dp.kode_pinjam = p.kode_pinjam
    WHERE dp.kode_pinjam = p_kode_pinjam
        AND dp.kode_buku = p_kode_buku
        AND p.status_pinjam = 'dipinjam';

    IF v_detail_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error: Data peminjaman tidak ditemukan atau sudah dikembalikan!';
    END IF;

    -- ============================================
    -- HITUNG DENDA KETERLAMBATAN
    -- ============================================
    SELECT tanggal_pinjam, batas_kembali
    INTO v_tanggal_pinjam, v_batas_kembali
    FROM peminjaman
    WHERE kode_pinjam = p_kode_pinjam;

    -- Hitung hari terlambat (jika > 0 berarti terlambat)
    SET v_hari_terlambat = GREATEST(DATEDIFF(CURRENT_DATE, v_batas_kembali), 0);

    -- Denda Rp 2.000 per hari
    SET v_denda_terlambat = v_hari_terlambat * 2000;

    -- ============================================
    -- UPDATE: Detail peminjaman (tandai sudah dikembalikan)
    -- ============================================
    UPDATE detail_peminjaman
    SET kondisi_kembali = 'Baik'
    WHERE kode_pinjam = p_kode_pinjam
        AND kode_buku = p_kode_buku;

    -- ============================================
    -- CEK: Apakah semua buku sudah dikembalikan?
    -- ============================================
    SELECT COUNT(*) INTO v_jumlah_buku_belum_kembali
    FROM detail_peminjaman
    WHERE kode_pinjam = p_kode_pinjam
        AND kondisi_kembali IS NULL;

    -- Jika semua buku sudah dikembalikan, update status peminjaman
    IF v_jumlah_buku_belum_kembali = 0 THEN
        UPDATE peminjaman
        SET tanggal_kembali = CURRENT_DATE,
            status_pinjam = 'dikembalikan',
            denda = v_denda_terlambat
        WHERE kode_pinjam = p_kode_pinjam;
    ELSE
        -- Jika masih ada buku lain yang belum dikembalikan, update denda saja
        UPDATE peminjaman
        SET denda = v_denda_terlambat
        WHERE kode_pinjam = p_kode_pinjam;
    END IF;

    -- Commit transaksi
    COMMIT;

    -- ============================================
    -- OUTPUT: Informasi pengembalian
    -- ============================================
    SELECT
        'SUKSES' AS status,
        p_kode_pinjam AS kode_pinjam,
        p_kode_buku AS kode_buku,
        (SELECT judul_buku FROM koleksi_buku WHERE kode_buku = p_kode_buku) AS judul_buku,
        v_tanggal_pinjam AS tanggal_pinjam,
        v_batas_kembali AS batas_kembali,
        CURRENT_DATE AS tanggal_kembali,
        v_hari_terlambat AS hari_terlambat,
        v_denda_terlambat AS denda,
        v_jumlah_buku_belum_kembali AS buku_belum_kembali,
        IF(v_jumlah_buku_belum_kembali = 0, 'Semua buku sudah dikembalikan', 'Masih ada buku yang belum dikembalikan') AS keterangan;

END$$

DELIMITER ;
```

### D. CARA MENGGUNAKAN STORED PROCEDURE

```sql
-- ============================================
-- TEST STORED PROCEDURE
-- ============================================

-- TEST 1: Proses Peminjaman
-- Anggota A0001 meminjam buku B0001
CALL proses_peminjaman('PJ20250101', 'A0001', 'P0001', 'B0001');

-- Anggota yang sama meminjam buku lain dalam transaksi yang sama
CALL proses_peminjaman('PJ20250101', 'A0001', 'P0001', 'B0002');

-- Coba pinjam buku ke-3 (harus error - maksimal 2 buku)
CALL proses_peminjaman('PJ20250101', 'A0001', 'P0001', 'B0003');

-- TEST 2: Cek hasil peminjaman
SELECT * FROM peminjaman WHERE kode_pinjam = 'PJ20250101';
SELECT * FROM detail_peminjaman WHERE kode_pinjam = 'PJ20250101';
SELECT kode_buku, judul_buku, tersedia FROM koleksi_buku WHERE kode_buku IN ('B0001', 'B0002');

-- TEST 3: Proses Pengembalian (tepat waktu)
CALL proses_pengembalian('PJ20250101', 'B0001');

-- TEST 4: Simulasi keterlambatan
-- Update tanggal pinjam jadi 15 hari yang lalu
UPDATE peminjaman SET tanggal_pinjam = DATE_SUB(CURRENT_DATE, INTERVAL 15 DAY),
                      batas_kembali = DATE_SUB(CURRENT_DATE, INTERVAL 5 DAY)
WHERE kode_pinjam = 'PJ20250101';

-- Kembalikan buku kedua dengan keterlambatan
CALL proses_pengembalian('PJ20250101', 'B0002');
-- Harusnya denda = 5 hari x Rp 2.000 = Rp 10.000

-- TEST 5: Cek denda total
SELECT
    kode_pinjam,
    id_anggota,
    tanggal_pinjam,
    batas_kembali,
    tanggal_kembali,
    status_pinjam,
    denda
FROM peminjaman
WHERE kode_pinjam = 'PJ20250101';
```

### E. PENJELASAN TEKNIS

#### 1. Kenapa Pakai Stored Procedure?

✅ **Keuntungan:**
- **Logika bisnis terpusat** di database (tidak tersebar di aplikasi)
- **Validasi otomatis** (cek batas pinjam, duplikasi)
- **Transaksi atomik** (all or nothing - jika error, semua rollback)
- **Performa lebih baik** (eksekusi di server, kurang network overhead)
- **Reusable** (bisa dipanggil dari berbagai aplikasi)

#### 2. Komponen Stored Procedure

| Komponen | Fungsi |
|----------|--------|
| `DELIMITER $$` | Ubah delimiter sementara agar `;` tidak mengakhiri procedure |
| `IN parameter` | Input parameter dari pemanggil |
| `OUT parameter` | Output parameter yang bisa dibaca pemanggil |
| `DECLARE` | Deklarasi variabel lokal |
| `START TRANSACTION` | Mulai transaksi |
| `COMMIT` | Simpan perubahan |
| `ROLLBACK` | Batalkan perubahan jika error |
| `SIGNAL SQLSTATE` | Bangkitkan error custom |
| `EXIT HANDLER` | Tangani error otomatis |

#### 3. Testing & Debugging

```sql
-- Lihat daftar stored procedure
SHOW PROCEDURE STATUS WHERE Db = 'perpustakaan_sekolah';

-- Lihat definisi procedure
SHOW CREATE PROCEDURE proses_peminjaman;

-- Hapus procedure (jika mau recreate)
DROP PROCEDURE IF EXISTS proses_peminjaman;

-- Debug: Tambahkan SELECT di tengah procedure untuk cek nilai variabel
-- Contoh:
-- SELECT v_buku_tersedia AS debug_tersedia;
```

---

**🎯 CHECKPOINT PART 2:**

Anda telah menyelesaikan:
- ✅ Manipulasi data CRUD (INSERT, SELECT, UPDATE, DELETE) dengan contoh lengkap
- ✅ Stored procedure peminjaman dengan validasi (max 3 buku, status aktif, stok tersedia)
- ✅ Stored procedure pengembalian dengan perhitungan denda (keterlambatan + kerusakan)
- ✅ Testing dan debugging tips

**Lanjut ke Part 3:** Query Kompleks (JOIN & Agregasi) dan Pengujian & Debugging

---

**Catatan:** Copy semua script ke file `.sql` terpisah untuk backup!
