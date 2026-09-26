-- ==============================================================================
-- WAREHOUSE MANAGEMENT SYSTEM (WMS)
-- SCRIPT PEMBUATAN TABEL LENGKAP & RLS POLICY UNTUK SUPABASE BARU
-- AMAN: Menggunakan 'IF NOT EXISTS', tidak akan merusak tabel yang sudah ada.
-- ==============================================================================

-- 1. TABEL KARYAWAN
CREATE TABLE IF NOT EXISTS karyawan (
    nik VARCHAR(50) PRIMARY KEY,
    nama VARCHAR(150) NOT NULL,
    divisi VARCHAR(100) NOT NULL DEFAULT 'Warehouse',
    username VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(30) NOT NULL DEFAULT 'user',
    gaji_pokok NUMERIC(15, 2) NOT NULL DEFAULT 0,
    tunjangan NUMERIC(15, 2) NOT NULL DEFAULT 0,
    rate_lembur NUMERIC(15, 2) NOT NULL DEFAULT 0,
    saldo_kasbon NUMERIC(15, 2) NOT NULL DEFAULT 0,
    email VARCHAR(150),
    no_hp VARCHAR(50),
    tgl_lahir DATE,
    tgl_bergabung DATE,
    alamat TEXT,
    hobi VARCHAR(255),
    kontak_darurat VARCHAR(255),
    foto TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. TABEL MASTER SHIFT
CREATE TABLE IF NOT EXISTS master_shift (
    id SERIAL PRIMARY KEY,
    nama_shift VARCHAR(50) NOT NULL UNIQUE,
    jam_masuk TIME NOT NULL,
    jam_pulang TIME NOT NULL,
    toleransi INTEGER NOT NULL DEFAULT 15,
    status VARCHAR(30) NOT NULL DEFAULT 'Aktif',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. TABEL ROSTER SHIFT HARIAN
CREATE TABLE IF NOT EXISTS roster_shift (
    id SERIAL PRIMARY KEY,
    nik VARCHAR(50) REFERENCES karyawan(nik) ON DELETE CASCADE,
    tanggal DATE NOT NULL,
    shift VARCHAR(50) NOT NULL,
    jam_masuk VARCHAR(10),
    jam_pulang VARCHAR(10),
    keterangan TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(nik, tanggal)
);

-- 4. TABEL PRESENSI & ABSENSI HARIAN
CREATE TABLE IF NOT EXISTS presensi (
    id SERIAL PRIMARY KEY,
    nik VARCHAR(50) REFERENCES karyawan(nik) ON DELETE CASCADE,
    tanggal DATE NOT NULL,
    shift VARCHAR(50) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'Hadir',
    jam_masuk TIME,
    jam_pulang TIME,
    catatan TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(nik, tanggal)
);

-- 5. TABEL PENGAJUAN LEMBUR
CREATE TABLE IF NOT EXISTS lembur (
    id VARCHAR(50) PRIMARY KEY,
    nik VARCHAR(50) REFERENCES karyawan(nik) ON DELETE CASCADE,
    nama VARCHAR(150) NOT NULL,
    divisi VARCHAR(100),
    tanggal DATE NOT NULL,
    deskripsi TEXT NOT NULL,
    jam_mulai TIME NOT NULL,
    jam_selesai TIME NOT NULL,
    durasi_jam NUMERIC(6, 2) NOT NULL DEFAULT 0,
    rate_lembur NUMERIC(15, 2) NOT NULL DEFAULT 0,
    total_lembur NUMERIC(15, 2) NOT NULL DEFAULT 0,
    status VARCHAR(30) NOT NULL DEFAULT 'Diajukan',
    approved_by VARCHAR(100),
    approved_at TIMESTAMPTZ,
    catatan TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. TABEL PERIJINAN & CUTI
CREATE TABLE IF NOT EXISTS perijinan_cuti (
    id VARCHAR(50) PRIMARY KEY,
    nik VARCHAR(50) REFERENCES karyawan(nik) ON DELETE CASCADE,
    nama VARCHAR(150) NOT NULL,
    divisi VARCHAR(100),
    jenis VARCHAR(50) NOT NULL DEFAULT 'Cuti Tahunan',
    tgl_mulai DATE NOT NULL,
    tgl_selesai DATE NOT NULL,
    jumlah_hari INTEGER NOT NULL DEFAULT 1,
    alasan TEXT NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'Diajukan',
    approved_by VARCHAR(100),
    approved_at TIMESTAMPTZ,
    catatan TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. TABEL KASBON KARYAWAN
CREATE TABLE IF NOT EXISTS kasbon (
    id VARCHAR(50) PRIMARY KEY,
    nik VARCHAR(50) REFERENCES karyawan(nik) ON DELETE CASCADE,
    tanggal DATE NOT NULL,
    jumlah NUMERIC(15, 2) NOT NULL DEFAULT 0,
    cicilan NUMERIC(15, 2) NOT NULL DEFAULT 0,
    sisa_saldo NUMERIC(15, 2) NOT NULL DEFAULT 0,
    status VARCHAR(30) NOT NULL DEFAULT 'Aktif',
    catatan TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 8. TABEL PAYROLL BULANAN
CREATE TABLE IF NOT EXISTS payroll (
    id VARCHAR(50) PRIMARY KEY,
    periode VARCHAR(20) NOT NULL,
    nik VARCHAR(50) REFERENCES karyawan(nik) ON DELETE CASCADE,
    nama VARCHAR(150) NOT NULL,
    divisi VARCHAR(100),
    gaji_pokok NUMERIC(15, 2) NOT NULL DEFAULT 0,
    tunjangan NUMERIC(15, 2) NOT NULL DEFAULT 0,
    total_jam_lembur NUMERIC(6, 2) NOT NULL DEFAULT 0,
    rate_lembur NUMERIC(15, 2) NOT NULL DEFAULT 0,
    uang_lembur NUMERIC(15, 2) NOT NULL DEFAULT 0,
    potongan_kasbon NUMERIC(15, 2) NOT NULL DEFAULT 0,
    potongan_absensi NUMERIC(15, 2) NOT NULL DEFAULT 0,
    potongan_lain NUMERIC(15, 2) NOT NULL DEFAULT 0,
    gaji_bersih NUMERIC(15, 2) NOT NULL DEFAULT 0,
    status VARCHAR(30) NOT NULL DEFAULT 'Draft',
    catatan TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(periode, nik)
);

-- 9. TABEL PENGAJUAN PERUBAHAN PROFIL
CREATE TABLE IF NOT EXISTS pengajuan_profil (
    id VARCHAR(50) PRIMARY KEY,
    nik VARCHAR(50) REFERENCES karyawan(nik) ON DELETE CASCADE,
    nama_lama VARCHAR(150),
    nama_baru VARCHAR(150),
    no_hp_baru VARCHAR(50),
    email_baru VARCHAR(150),
    tgl_lahir_baru DATE,
    alamat_baru TEXT,
    hobi_baru VARCHAR(255),
    kontak_darurat_baru VARCHAR(255),
    alasan TEXT,
    status VARCHAR(30) DEFAULT 'Diajukan',
    tanggal DATE,
    alasan_tolak TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 10. TABEL INVENTORI TAMBAHAN
CREATE TABLE IF NOT EXISTS inv_stock (
    id SERIAL PRIMARY KEY,
    sku VARCHAR(100) NOT NULL,
    nama_produk VARCHAR(255) NOT NULL,
    size VARCHAR(50),
    kategori VARCHAR(100) DEFAULT 'General',
    stok_dealpos INTEGER NOT NULL DEFAULT 0,
    stok_fisik INTEGER NOT NULL DEFAULT 0,
    selisih INTEGER GENERATED ALWAYS AS (stok_fisik - stok_dealpos) STORED,
    lokasi_rak VARCHAR(100) DEFAULT 'A-01-01',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS inv_peminjaman (
    id VARCHAR(50) PRIMARY KEY,
    tanggal DATE NOT NULL,
    peminjam VARCHAR(150) NOT NULL,
    divisi VARCHAR(100),
    sku VARCHAR(100) NOT NULL,
    nama_produk VARCHAR(255) NOT NULL,
    size VARCHAR(50),
    qty INTEGER NOT NULL DEFAULT 1,
    keperluan TEXT,
    tgl_kembali DATE,
    status VARCHAR(30) DEFAULT 'Dipinjam',
    catatan TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS inv_refill (
    id VARCHAR(50) PRIMARY KEY,
    tanggal DATE NOT NULL,
    sku VARCHAR(100) NOT NULL,
    nama_produk VARCHAR(255) NOT NULL,
    size VARCHAR(50),
    qty INTEGER NOT NULL DEFAULT 1,
    asal_rak VARCHAR(100),
    tujuan_rak VARCHAR(100),
    petugas VARCHAR(150),
    status VARCHAR(30) DEFAULT 'Selesai',
    catatan TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS inv_log_mutasi (
    id SERIAL PRIMARY KEY,
    tanggal TIMESTAMPTZ DEFAULT NOW(),
    jenis_mutasi VARCHAR(50) NOT NULL,
    sku VARCHAR(100) NOT NULL,
    nama_produk VARCHAR(255) NOT NULL,
    size VARCHAR(50),
    qty_sebelum INTEGER DEFAULT 0,
    qty_mutasi INTEGER NOT NULL,
    qty_sesudah INTEGER NOT NULL,
    referensi_id VARCHAR(100),
    petugas VARCHAR(150),
    catatan TEXT
);

CREATE TABLE IF NOT EXISTS inv_stock_opname (
    id VARCHAR(50) PRIMARY KEY,
    tanggal DATE NOT NULL,
    sku VARCHAR(100) NOT NULL,
    nama_produk VARCHAR(255) NOT NULL,
    size VARCHAR(50),
    stok_sistem INTEGER NOT NULL DEFAULT 0,
    stok_fisik INTEGER NOT NULL DEFAULT 0,
    selisih INTEGER NOT NULL DEFAULT 0,
    petugas VARCHAR(150),
    status VARCHAR(30) DEFAULT 'Draft',
    catatan TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS inv_produksi (
    id VARCHAR(50) PRIMARY KEY,
    tanggal DATE NOT NULL,
    no_spk VARCHAR(100),
    sku VARCHAR(100) NOT NULL,
    nama_produk VARCHAR(255) NOT NULL,
    size VARCHAR(50),
    qty_target INTEGER NOT NULL DEFAULT 0,
    qty_selesai INTEGER NOT NULL DEFAULT 0,
    divisi_produksi VARCHAR(100),
    status VARCHAR(30) DEFAULT 'Proses',
    catatan TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS inv_qc (
    id VARCHAR(50) PRIMARY KEY,
    tanggal DATE NOT NULL,
    ref_spk VARCHAR(100),
    sku VARCHAR(100) NOT NULL,
    nama_produk VARCHAR(255) NOT NULL,
    size VARCHAR(50),
    qty_check INTEGER NOT NULL DEFAULT 0,
    qty_pass INTEGER NOT NULL DEFAULT 0,
    qty_reject INTEGER NOT NULL DEFAULT 0,
    inspector VARCHAR(150),
    status VARCHAR(30) DEFAULT 'Selesai',
    catatan TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==============================================================================
-- ENABLE ROW LEVEL SECURITY & OPEN REST ACCESS (KHUSUS TABEL WMS)
-- ==============================================================================
ALTER TABLE karyawan ENABLE ROW LEVEL SECURITY;
ALTER TABLE master_shift ENABLE ROW LEVEL SECURITY;
ALTER TABLE roster_shift ENABLE ROW LEVEL SECURITY;
ALTER TABLE presensi ENABLE ROW LEVEL SECURITY;
ALTER TABLE lembur ENABLE ROW LEVEL SECURITY;
ALTER TABLE perijinan_cuti ENABLE ROW LEVEL SECURITY;
ALTER TABLE kasbon ENABLE ROW LEVEL SECURITY;
ALTER TABLE payroll ENABLE ROW LEVEL SECURITY;
ALTER TABLE pengajuan_profil ENABLE ROW LEVEL SECURITY;
ALTER TABLE inv_stock ENABLE ROW LEVEL SECURITY;
ALTER TABLE inv_peminjaman ENABLE ROW LEVEL SECURITY;
ALTER TABLE inv_refill ENABLE ROW LEVEL SECURITY;
ALTER TABLE inv_log_mutasi ENABLE ROW LEVEL SECURITY;
ALTER TABLE inv_stock_opname ENABLE ROW LEVEL SECURITY;
ALTER TABLE inv_produksi ENABLE ROW LEVEL SECURITY;
ALTER TABLE inv_qc ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow public all access on karyawan" ON karyawan;
CREATE POLICY "Allow public all access on karyawan" ON karyawan FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Allow public all access on master_shift" ON master_shift;
CREATE POLICY "Allow public all access on master_shift" ON master_shift FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Allow public all access on roster_shift" ON roster_shift;
CREATE POLICY "Allow public all access on roster_shift" ON roster_shift FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Allow public all access on presensi" ON presensi;
CREATE POLICY "Allow public all access on presensi" ON presensi FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Allow public all access on lembur" ON lembur;
CREATE POLICY "Allow public all access on lembur" ON lembur FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Allow public all access on perijinan_cuti" ON perijinan_cuti;
CREATE POLICY "Allow public all access on perijinan_cuti" ON perijinan_cuti FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Allow public all access on kasbon" ON kasbon;
CREATE POLICY "Allow public all access on kasbon" ON kasbon FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Allow public all access on payroll" ON payroll;
CREATE POLICY "Allow public all access on payroll" ON payroll FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Allow public all access on pengajuan_profil" ON pengajuan_profil;
CREATE POLICY "Allow public all access on pengajuan_profil" ON pengajuan_profil FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Allow public all access on inv_stock" ON inv_stock;
CREATE POLICY "Allow public all access on inv_stock" ON inv_stock FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Allow public all access on inv_peminjaman" ON inv_peminjaman;
CREATE POLICY "Allow public all access on inv_peminjaman" ON inv_peminjaman FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Allow public all access on inv_refill" ON inv_refill;
CREATE POLICY "Allow public all access on inv_refill" ON inv_refill FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Allow public all access on inv_log_mutasi" ON inv_log_mutasi;
CREATE POLICY "Allow public all access on inv_log_mutasi" ON inv_log_mutasi FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Allow public all access on inv_stock_opname" ON inv_stock_opname;
CREATE POLICY "Allow public all access on inv_stock_opname" ON inv_stock_opname FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Allow public all access on inv_produksi" ON inv_produksi;
CREATE POLICY "Allow public all access on inv_produksi" ON inv_produksi FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Allow public all access on inv_qc" ON inv_qc;
CREATE POLICY "Allow public all access on inv_qc" ON inv_qc FOR ALL USING (true) WITH CHECK (true);
