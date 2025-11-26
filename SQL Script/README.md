# SQL Script - Database Perpustakaan Sekolah

Folder ini berisi solusi SQL script untuk pembekalan Database Programmer, tersusun sistematis per topik.

## 📋 Daftar File SQL

### Setup & Structure
- **00_master_script.sql** - Master script untuk menjalankan semua file secara berurutan
- **01_create_database_and_tables.sql** - Membuat database dan 6 tabel dengan constraint lengkap

### CRUD Operations
- **02_insert_data_master.sql** - Insert data ke semua tabel master (kategori, buku, anggota, petugas)
- **03_select_queries.sql** - Contoh query SELECT (filter, JOIN, GROUP BY, agregasi)
- **04_update_queries.sql** - Contoh query UPDATE (update email, stok, status)
- **05_delete_queries.sql** - Contoh query DELETE (dengan validasi foreign key)

### Transactions
- **06_stored_procedure_peminjaman.sql** - Stored procedure untuk proses peminjaman buku
- **07_stored_procedure_pengembalian.sql** - Stored procedure untuk proses pengembalian buku

### Complex Queries
- **08_query_kompleks_1_anggota_peminjaman.sql** - Query anggota beserta jumlah buku dipinjam
- **09_query_kompleks_2_buku_belum_dipinjam.sql** - Query buku yang belum pernah dipinjam
- **10_query_kompleks_3_denda_anggota.sql** - Query total denda per anggota (1 bulan terakhir)

### Testing
- **11_testing_validation.sql** - Query validasi integritas data dan statistik perpustakaan

## 🚀 Cara Menggunakan

### Opsi 1: Jalankan Semua Script Sekaligus
```sql
-- Di MySQL Command Line atau phpMyAdmin SQL tab
SOURCE /path/to/00_master_script.sql;
```

### Opsi 2: Jalankan File Per File (Recommended untuk Pemula)
```sql
-- Step 1: Buat database dan tabel
SOURCE /path/to/01_create_database_and_tables.sql;

-- Step 2: Insert data master
SOURCE /path/to/02_insert_data_master.sql;

-- Step 3: Buat stored procedures
SOURCE /path/to/06_stored_procedure_peminjaman.sql;
SOURCE /path/to/07_stored_procedure_pengembalian.sql;

-- Step 4: Test dengan query lainnya
SOURCE /path/to/03_select_queries.sql;
...
```

### Opsi 3: Copy-Paste Manual
1. Buka file SQL dengan text editor (Notepad++, VS Code)
2. Copy semua isi file
3. Paste ke phpMyAdmin SQL tab atau MySQL Workbench
4. Klik Execute/Go

## 📝 Catatan Penting

1. **Urutan Eksekusi**: Jalankan file sesuai nomor urut (01 → 02 → ... → 11)
2. **Database Name**: Semua script menggunakan database `perpustakaan_sekolah`
3. **Business Rules**:
   - Maksimal peminjaman: 2 buku per transaksi
   - Lama peminjaman: 10 hari
   - Denda keterlambatan: Rp 2.000/hari
4. **Backup**: Selalu backup database sebelum menjalankan DELETE queries
5. **Testing**: File 11_testing_validation.sql berguna untuk debug dan validasi

## 🎯 Peta Konsep

```
00_master_script.sql (All-in-One)
    │
    ├── SETUP
    │   └── 01_create_database_and_tables.sql
    │
    ├── DATA
    │   └── 02_insert_data_master.sql
    │
    ├── CRUD
    │   ├── 03_select_queries.sql
    │   ├── 04_update_queries.sql
    │   └── 05_delete_queries.sql
    │
    ├── TRANSACTIONS
    │   ├── 06_stored_procedure_peminjaman.sql
    │   └── 07_stored_procedure_pengembalian.sql
    │
    ├── COMPLEX QUERIES
    │   ├── 08_query_kompleks_1_anggota_peminjaman.sql
    │   ├── 09_query_kompleks_2_buku_belum_dipinjam.sql
    │   └── 10_query_kompleks_3_denda_anggota.sql
    │
    └── TESTING
        └── 11_testing_validation.sql
```

## ⚠️ Troubleshooting

### Error: "Database already exists"
```sql
-- Hapus database terlebih dahulu
DROP DATABASE IF EXISTS perpustakaan_sekolah;
-- Lalu jalankan kembali script pembuatan database
```

### Error: "Foreign key constraint fails"
- Pastikan menjalankan file sesuai urutan
- Parent table harus dibuat sebelum child table
- Data master harus diinsert sebelum data transaksi

### Error: "Procedure already exists"
```sql
-- Hapus procedure terlebih dahulu
DROP PROCEDURE IF EXISTS proses_peminjaman;
DROP PROCEDURE IF EXISTS proses_pengembalian;
-- Lalu buat ulang
```

## 📚 Referensi Pembekalan

File SQL ini adalah ekstrak dari dokumen pembekalan:
- **Part 1**: Setup dan Struktur Database → File 01
- **Part 2**: CRUD dan Transaksi → File 02-07
- **Part 3**: Query Kompleks dan Debugging → File 08-11

Untuk penjelasan lengkap konsep, lihat file `.md` di folder `Pembekalan/`.

---

**Good luck untuk ujian! 💪🚀**
