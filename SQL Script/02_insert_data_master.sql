-- ============================================
-- DATABASE PERPUSTAKAAN SEKOLAH
-- Solusi INSERT DATA MASTER
-- Part 2: INSERT DATA (CREATE)
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
ORDER BY id_anggota;

-- ============================================
-- 4. INSERT PETUGAS
-- ============================================
INSERT INTO petugas (
    id_petugas, nama_petugas, username,
    password, jabatan, no_telepon
) VALUES
('P0001', 'Hendra Gunawan', 'hendra.g', MD5('password123'), 'Kepala Perpustakaan', '081234567800'),
('P0002', 'Ani Kusuma', 'ani.k', MD5('password456'), 'Staff Perpustakaan', '082345678800'),
('P0003', 'Rudi Hartono', 'rudi.h', MD5('password789'), 'Staff Perpustakaan', '083456789800');

-- Verifikasi hasil insert (jangan tampilkan password!)
SELECT
    id_petugas,
    nama_petugas,
    username,
    jabatan,
    no_telepon
FROM petugas
ORDER BY id_petugas;

-- ============================================
-- SELESAI - Semua data master berhasil diinsert!
-- ============================================
