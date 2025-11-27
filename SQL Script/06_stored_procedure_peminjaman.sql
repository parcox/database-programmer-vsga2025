-- ============================================
-- DATABASE PERPUSTAKAAN SEKOLAH
-- STORED PROCEDURE: PROSES PEMINJAMAN BUKU
-- Part 2: Transaction - Peminjaman
-- ============================================

USE perpustakaan_sekolah;

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

-- ============================================
-- VERIFIKASI STORED PROCEDURE
-- ============================================

-- Lihat daftar stored procedures
SHOW PROCEDURE STATUS WHERE db = 'perpustakaan_sekolah';

-- Lihat detail definisi procedure
SHOW CREATE PROCEDURE proses_peminjaman;

-- ============================================
-- CARA MENGGUNAKAN STORED PROCEDURE
-- ============================================

-- Contoh 1: Anggota A0001 meminjam buku B0001
CALL proses_peminjaman('PJ20250101', 'A0001', 'P0001', 'B0001');

-- Contoh 2: Anggota yang sama meminjam buku kedua
CALL proses_peminjaman('PJ20250101', 'A0001', 'P0001', 'B0002');

-- Contoh 3: Coba pinjam buku ke-3 (harus error - maksimal 2 buku)
CALL proses_peminjaman('PJ20250101', 'A0001', 'P0001', 'B0003');

-- Cek hasil peminjaman
SELECT * FROM peminjaman WHERE kode_pinjam = 'PJ20250101';
SELECT * FROM detail_peminjaman WHERE kode_pinjam = 'PJ20250101';
