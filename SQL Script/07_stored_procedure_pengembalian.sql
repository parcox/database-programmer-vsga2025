-- ============================================
-- DATABASE PERPUSTAKAAN SEKOLAH
-- STORED PROCEDURE: PROSES PENGEMBALIAN BUKU
-- Part 2: Transaction - Pengembalian
-- ============================================

USE perpustakaan_sekolah;

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
        SIGNAL SQLSTATE '45000';
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

-- ============================================
-- CARA MENGGUNAKAN STORED PROCEDURE
-- ============================================

-- TEST 1: Proses Pengembalian (tepat waktu)
CALL proses_pengembalian('PJ20250101', 'B0001');

-- TEST 2: Simulasi keterlambatan
-- Update tanggal pinjam jadi 15 hari yang lalu
UPDATE peminjaman SET tanggal_pinjam = DATE_SUB(CURRENT_DATE, INTERVAL 15 DAY),
                      batas_kembali = DATE_SUB(CURRENT_DATE, INTERVAL 5 DAY)
WHERE kode_pinjam = 'PJ20250101';

-- Kembalikan buku kedua dengan keterlambatan
CALL proses_pengembalian('PJ20250101', 'B0002');
-- Harusnya denda = 5 hari x Rp 2.000 = Rp 10.000

-- TEST 3: Cek hasil pengembalian
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
