# 📚 Database Programmer - Pembekalan VSGA 2025

Material pembekalan lengkap untuk sertifikasi **Database Programmer** VSGA 2025. Repository ini berisi materi pembelajaran terstruktur dan script SQL siap pakai untuk membantu peserta memahami konsep database relasional dengan MySQL/MariaDB.

## 📁 Struktur Repository

```
Database Programmer/
├── Pembekalan/              # 📖 Materi pembelajaran lengkap
│   ├── Part 1 - Setup dan Struktur Database.md
│   ├── Part 2 - CRUD dan Transaksi.md
│   └── Part 3 - Query Kompleks dan Debugging.md
│
├── SQL Script/              # 💻 Script SQL siap pakai
│   ├── 00_master_script.sql
│   ├── 01_create_database_and_tables.sql
│   ├── 02_insert_data_master.sql
│   ├── 03_select_queries.sql
│   ├── 04_update_queries.sql
│   ├── 05_delete_queries.sql
│   ├── 06_stored_procedure_peminjaman.sql
│   ├── 07_stored_procedure_pengembalian.sql
│   ├── 08_query_kompleks_1_anggota_peminjaman.sql
│   ├── 09_query_kompleks_2_buku_belum_dipinjam.sql
│   ├── 10_query_kompleks_3_denda_anggota.sql
│   └── 11_testing_validation.sql
│
└── MUK/                     # 🎯 Dokumen ujian (untuk instruktur)
```

## 🎯 Studi Kasus

**Sistem Informasi Perpustakaan Sekolah**

Database untuk mengelola:
- 📚 Koleksi buku dan kategori
- 👥 Data anggota perpustakaan (siswa, guru, staff)
- 👨‍💼 Data petugas perpustakaan
- 📝 Transaksi peminjaman dan pengembalian
- 💰 Perhitungan denda keterlambatan

### Aturan Bisnis
- Maksimal **2 buku** per transaksi
- Lama peminjaman: **10 hari**
- Denda keterlambatan: **Rp 2.000/hari**

## 🚀 Quick Start

### Prerequisites
- MySQL 8.0+ atau MariaDB 10.5+
- XAMPP/MAMP (untuk local development)
- phpMyAdmin atau MySQL Workbench

### Instalasi

1. **Clone repository**
   ```bash
   git clone https://github.com/username/database-programmer-vsga2025.git
   cd database-programmer-vsga2025
   ```

2. **Import database**
   ```sql
   -- Opsi 1: Import semua sekaligus
   SOURCE SQL\ Script/00_master_script.sql;

   -- Opsi 2: Import step-by-step
   SOURCE SQL\ Script/01_create_database_and_tables.sql;
   SOURCE SQL\ Script/02_insert_data_master.sql;
   ```

3. **Test stored procedures**
   ```sql
   -- Proses peminjaman
   CALL proses_peminjaman('PJ20250101', 'A0001', 'P0001', 'B0001');

   -- Proses pengembalian
   CALL proses_pengembalian('PJ20250101', 'B0001');
   ```

## 📖 Materi Pembelajaran

### Part 1: Setup dan Struktur Database (~40 menit)
- ✅ Instalasi XAMPP dan konfigurasi
- ✅ Perancangan ERD (6 entitas)
- ✅ Implementasi DDL dengan constraint lengkap
- ✅ Primary Key, Foreign Key, UNIQUE, CHECK, DEFAULT

### Part 2: CRUD dan Transaksi (~40 menit)
- ✅ INSERT data master (kategori, buku, anggota, petugas)
- ✅ SELECT queries (JOIN, GROUP BY, agregasi)
- ✅ UPDATE dan DELETE dengan validasi
- ✅ Stored Procedures untuk peminjaman & pengembalian
- ✅ Transaction handling dan error management

### Part 3: Query Kompleks dan Debugging (~40 menit)
- ✅ Query kompleks dengan multiple JOIN
- ✅ Subquery dan agregasi lanjutan
- ✅ Analisis data (anggota aktif, buku populer, denda)
- ✅ Testing dan validasi integritas data
- ✅ Debugging tips dan troubleshooting

## 💡 Fitur Unggulan

### 1. Stored Procedures
- **proses_peminjaman**: Validasi otomatis (max 2 buku, duplikasi)
- **proses_pengembalian**: Perhitungan denda otomatis

### 2. Complex Queries
- Daftar anggota dengan jumlah buku dipinjam
- Buku yang belum pernah dipinjam (3 metode)
- Total denda per anggota (filter by periode)

### 3. Data Integrity
- Foreign Key constraints dengan CASCADE/RESTRICT
- CHECK constraints untuk validasi nilai
- UNIQUE constraints untuk mencegah duplikasi

## 🛠️ Teknologi

- **Database**: MySQL 8.0 / MariaDB 10.5
- **Storage Engine**: InnoDB (untuk FK support)
- **Character Set**: UTF-8 (utf8mb4)
- **Tools**: phpMyAdmin, MySQL Workbench

## 📊 Entity Relationship Diagram

```
┌────────────────┐         ┌──────────────────┐
│ KATEGORI_BUKU  │1      N │ KOLEKSI_BUKU     │
│────────────────│◄────────│──────────────────│
│*kode_kategori  │         │*kode_buku        │
│ nama_kategori  │         │ judul_buku       │
│ keterangan     │         │ pengarang        │
│ created_at     │         │ penerbit         │
└────────────────┘         │ tahun_terbit     │
                           │ kode_kategori    │
                           │ jumlah_eksemplar │
                           │ tersedia         │
                           │ isbn             │
                           │ created_at       │
                           └────────┬─────────┘
                                    │ N
                                    │
                                    │ 1
                           ┌────────▼───────┐
                           │     DETAIL     │
                           │  PEMINJAMAN    │
                           │────────────────│
┌─────────────┐        1   │*id_detail      │
│  PETUGAS    │◄───────────│ kode_pinjam    │
│─────────────│            │ kode_buku      │
│*id_petugas  │            │ kondisi_pinjam │
│ nama_petugas│            │ kondisi_kembali│
│ username    │            │ denda_kerusakan│
│ password    │            └───────┬────────┘
│ jabatan     │                    │
│ no_telepon  │                    │N
│ created_at  │◄──┐ 1              │
└─────────────┘   │                │
                  │                │
                  │                │1
                  │        ┌───────▼────────┐
                  │        │  PEMINJAMAN    │
                  │        │────────────────│
                  │        │*kode_pinjam    │
                  │        │ id_anggota     │
                  │     N  │ id_petugas     │
                  └────────┤ tanggal_pinjam │
                           │ tanggal_kembali│
                        ┌──┤ batas_kembali  │
                        │N │ status_pinjam  │
                        │  │ denda          │
                        │  │ catatan        │
┌─────────────────┐     │  │ created_at     │
│  ANGGOTA        │◄────┘  └────────────────┘
│─────────────────│1
│*id_anggota      │
│ nama_lengkap    │
│ jenis_anggota   │
│ nomor_identitas │
│ email           │
│ no_telepon      │
│ alamat          │
│ tanggal_daftar  │
│ status_aktif    │
│ created_at      │
└─────────────────┘
```

## 🎓 Target Pembelajaran

Setelah mempelajari materi ini, peserta mampu:
1. ✅ Merancang ERD dan normalisasi database
2. ✅ Implementasi DDL dengan constraint lengkap
3. ✅ Melakukan operasi CRUD dengan SQL
4. ✅ Membuat stored procedures untuk transaksi bisnis
5. ✅ Menulis query kompleks dengan JOIN dan subquery
6. ✅ Debugging dan validasi integritas data
7. ✅ Mengelola transaction dan error handling

## 📝 Contoh Penggunaan

### Query Anggota dengan Buku Dipinjam
```sql
SELECT
    a.nama_lengkap,
    COUNT(dp.kode_buku) AS total_buku_dipinjam
FROM anggota a
INNER JOIN peminjaman p ON a.id_anggota = p.id_anggota
INNER JOIN detail_peminjaman dp ON p.kode_pinjam = dp.kode_pinjam
WHERE p.status_pinjam = 'dipinjam'
GROUP BY a.id_anggota, a.nama_lengkap
ORDER BY total_buku_dipinjam DESC;
```

### Query Buku Belum Pernah Dipinjam
```sql
SELECT b.judul_buku, k.nama_kategori
FROM koleksi_buku b
INNER JOIN kategori_buku k ON b.kode_kategori = k.kode_kategori
LEFT JOIN detail_peminjaman dp ON b.kode_buku = dp.kode_buku
WHERE dp.kode_buku IS NULL
ORDER BY k.nama_kategori, b.judul_buku;
```

## 🤝 Kontribusi

Kontribusi sangat diterima! Silakan:
1. Fork repository ini
2. Buat branch fitur (`git checkout -b feature/AmazingFeature`)
3. Commit perubahan (`git commit -m 'Add some AmazingFeature'`)
4. Push ke branch (`git push origin feature/AmazingFeature`)
5. Buat Pull Request

## 📄 Lisensi

Material ini dibuat untuk keperluan edukasi program VSGA 2025. Silakan digunakan untuk pembelajaran dengan mencantumkan sumber.

## 📞 Kontak & Support

Jika ada pertanyaan atau butuh bantuan:
- 💬 Buat [Issue](https://github.com/parcox/database-programmer-vsga2025/issues)
- 📧 Email: fitri.wibowo@polnep.ac.id
- 🌐 Website: https://owob.web.id

## 🙏 Acknowledgments

- VSGA 2025 - program pelatihan dan sertifikasi
- Komunitas Database Indonesia

---

**Happy Learning! 📚💻**

Made with ❤️ for VSGA 2025 Database Programmer Certification
