-- ==============================================================================
-- WAREHOUSE MANAGEMENT SYSTEM (WMS)
-- CLONE DATA LENGKAP KE SUPABASE BARU
-- Tanggal Backup: 2026-09-25T00:57:00.791Z
-- ==============================================================================

-- ==============================================================================
-- WAREHOUSE MANAGEMENT SYSTEM (WMS) - SUPABASE DATABASE SCHEMA
-- Compatible with PostgreSQL & Supabase API
-- ==============================================================================

-- 1. TABEL KARYAWAN & USER
CREATE TABLE IF NOT EXISTS karyawan (
    nik VARCHAR(50) PRIMARY KEY,
    nama VARCHAR(150) NOT NULL,
    divisi VARCHAR(100) NOT NULL DEFAULT 'Warehouse',
    username VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(30) NOT NULL DEFAULT 'user', -- 'admin' atau 'user'
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
    status VARCHAR(30) NOT NULL DEFAULT 'Hadir', -- 'Hadir', 'Terlambat', 'Ijin', 'Sakit', 'Alpha'
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
    status VARCHAR(30) NOT NULL DEFAULT 'Diajukan', -- 'Diajukan', 'Disetujui', 'Ditolak'
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
    jenis VARCHAR(50) NOT NULL DEFAULT 'Cuti Tahunan', -- 'Cuti Tahunan', 'Sakit', 'Ijin'
    tgl_mulai DATE NOT NULL,
    tgl_selesai DATE NOT NULL,
    jumlah_hari INTEGER NOT NULL DEFAULT 1,
    alasan TEXT NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'Diajukan', -- 'Diajukan', 'Disetujui', 'Ditolak'
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
    status VARCHAR(30) NOT NULL DEFAULT 'Aktif', -- 'Aktif', 'Lunas', 'Dibatalkan'
    catatan TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 8. TABEL PAYROLL BULANAN
CREATE TABLE IF NOT EXISTS payroll (
    id VARCHAR(50) PRIMARY KEY, -- e.g. PAY-2026-08-WH0001
    periode VARCHAR(20) NOT NULL, -- e.g. 2026-08
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
    status VARCHAR(30) NOT NULL DEFAULT 'Draft', -- 'Draft', 'Disetujui Finance', 'Dibayarkan'
    catatan TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(periode, nik)
);

-- 9. TABEL INVENTORY (KATALOG STOK & BIN LOCATION)
CREATE TABLE IF NOT EXISTS inventory_items (
    id SERIAL PRIMARY KEY,
    sku VARCHAR(100) UNIQUE NOT NULL,
    barcode VARCHAR(100),
    nama_barang VARCHAR(255) NOT NULL,
    kategori VARCHAR(100) DEFAULT 'General',
    unit VARCHAR(30) DEFAULT 'Pcs',
    lokasi_rak VARCHAR(100) DEFAULT 'A-01-01',
    qty_stok INTEGER NOT NULL DEFAULT 0,
    min_stok INTEGER NOT NULL DEFAULT 5,
    max_stok INTEGER NOT NULL DEFAULT 1000,
    status VARCHAR(30) NOT NULL DEFAULT 'Aktif',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 10. TABEL INBOUND & RECEIVING
CREATE TABLE IF NOT EXISTS inbound_orders (
    id VARCHAR(50) PRIMARY KEY,
    no_po VARCHAR(100) NOT NULL,
    supplier VARCHAR(150) NOT NULL,
    tanggal DATE NOT NULL,
    total_item INTEGER NOT NULL DEFAULT 0,
    status VARCHAR(30) NOT NULL DEFAULT 'Staging', -- 'Staging', 'QC Passed', 'Put-away Done'
    catatan TEXT,
    created_by VARCHAR(50) REFERENCES karyawan(nik),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 11. TABEL OUTBOUND & DISPATCH
CREATE TABLE IF NOT EXISTS outbound_orders (
    id VARCHAR(50) PRIMARY KEY,
    no_do VARCHAR(100) NOT NULL,
    customer VARCHAR(150) NOT NULL,
    ekspedisi VARCHAR(100),
    no_resi VARCHAR(100),
    tanggal DATE NOT NULL,
    total_item INTEGER NOT NULL DEFAULT 0,
    status VARCHAR(30) NOT NULL DEFAULT 'Pending', -- 'Pending', 'Packed', 'Dispatched'
    catatan TEXT,
    created_by VARCHAR(50) REFERENCES karyawan(nik),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 12. TABEL WAREHOUSE TASKS (PICKING & PACKING)
CREATE TABLE IF NOT EXISTS warehouse_tasks (
    id VARCHAR(50) PRIMARY KEY,
    task_type VARCHAR(50) NOT NULL, -- 'Picking', 'Packing', 'Stock Opname'
    ref_no VARCHAR(100),
    assigned_to_nik VARCHAR(50) REFERENCES karyawan(nik),
    priority VARCHAR(30) DEFAULT 'Normal', -- 'Low', 'Normal', 'Urgent'
    status VARCHAR(30) DEFAULT 'Assigned', -- 'Assigned', 'In Progress', 'Completed'
    due_date TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==============================================================================
-- WAREHOUSE TASKS (PICKING & PACKING)
-- ==============================================================================

-- 13. TABEL PENGAJUAN PERUBAHAN PROFIL
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

-- ==============================================================================
-- DEFAULT DATA SEEDING (DATA AWAL)
-- ==============================================================================

-- Seed Admin & Demo Karyawan
INSERT INTO karyawan (nik, nama, divisi, username, password, role, gaji_pokok, tunjangan, rate_lembur, saldo_kasbon, email, no_hp)
VALUES 
    ('WH0001', 'Administrator Warehouse', 'Management', 'admin', 'admin123', 'admin', 5000000, 1000000, 30000, 0, 'admin@warehouse.com', '081234567890'),
    ('WH0002', 'Budi Santoso', 'Staging & Inbound', 'budi', 'user123', 'user', 4500000, 500000, 25000, 0, 'budi@warehouse.com', '081234567891'),
    ('WH0003', 'Siti Rahma', 'Picking & Packing', 'siti', 'user123', 'user', 4500000, 500000, 25000, 0, 'siti@warehouse.com', '081234567892')
ON CONFLICT (nik) DO NOTHING;

-- Seed Master Shift
INSERT INTO master_shift (nama_shift, jam_masuk, jam_pulang, toleransi, status)
VALUES 
    ('Shift 1', '08:00:00', '17:00:00', 15, 'Aktif'),
    ('Shift 2', '09:00:00', '18:00:00', 15, 'Aktif'),
    ('Shift 3', '12:00:00', '21:00:00', 15, 'Aktif')
ON CONFLICT (nama_shift) DO NOTHING;

-- 13. TABEL INVENTORY STOCK MATRIX (FISIK VS DEALPOS)
CREATE TABLE IF NOT EXISTS inv_stock (
    id SERIAL PRIMARY KEY,
    sku VARCHAR(100) NOT NULL,
    nama_produk VARCHAR(255) NOT NULL,
    size VARCHAR(50),
    kategori VARCHAR(100) DEFAULT 'General',
    lokasi_rak VARCHAR(100) NOT NULL,
    area VARCHAR(50) NOT NULL, -- 'Gudang Utama', 'Barang Live', 'Sample Studio', 'Permak / Cuci', 'Barang Cacat', 'WH', 'QC', 'GA'
    kategori_area VARCHAR(50) NOT NULL, -- 'ONLINE', 'PERBAIKAN', 'OFFLINE'
    qty_fisik INTEGER NOT NULL DEFAULT 0,
    qty_dealpos INTEGER NOT NULL DEFAULT 0,
    selisih INTEGER GENERATED ALWAYS AS (qty_fisik - qty_dealpos) STORED,
    keterangan TEXT,
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(sku, lokasi_rak, area)
);

CREATE INDEX IF NOT EXISTS idx_inv_stock_sku ON inv_stock(sku);
CREATE INDEX IF NOT EXISTS idx_inv_stock_area ON inv_stock(area);
CREATE INDEX IF NOT EXISTS idx_inv_stock_kategori_area ON inv_stock(kategori_area);

-- 14. TABEL PEMINJAMAN SEMENTARA (SPS)
CREATE TABLE IF NOT EXISTS inv_peminjaman (
    id VARCHAR(50) PRIMARY KEY,
    no_sps VARCHAR(100) NOT NULL UNIQUE,
    peminjam VARCHAR(150) NOT NULL,
    divisi VARCHAR(100) NOT NULL,
    keperluan TEXT NOT NULL,
    tanggal_pinjam DATE NOT NULL,
    tanggal_kembali DATE,
    status VARCHAR(50) NOT NULL DEFAULT 'Dipinjam', -- 'Dipinjam', 'Dikembalikan', 'Terlambat', 'Dibatalkan'
    items JSONB NOT NULL DEFAULT '[]'::jsonb, -- Array of { sku, namaProduk, size, qty, catatan }
    total_qty INTEGER NOT NULL DEFAULT 1,
    catatan TEXT,
    approved_by VARCHAR(100),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 15. TABEL MONITORING & PERMINTAAN REFILL
CREATE TABLE IF NOT EXISTS inv_refill (
    id VARCHAR(50) PRIMARY KEY,
    no_refill VARCHAR(100) NOT NULL UNIQUE,
    sku VARCHAR(100) NOT NULL,
    nama_produk VARCHAR(255) NOT NULL,
    size VARCHAR(50),
    dari_lokasi VARCHAR(100) NOT NULL,
    ke_lokasi VARCHAR(100) NOT NULL,
    channel VARCHAR(100) NOT NULL DEFAULT 'Gudang Utama', -- 'MAP', 'Live', 'Studio', 'Shopee', 'TikTok'
    qty_diminta INTEGER NOT NULL DEFAULT 1,
    qty_dialokasi INTEGER NOT NULL DEFAULT 0,
    status VARCHAR(50) NOT NULL DEFAULT 'Pending', -- 'Pending', 'Dialokasi', 'Selesai', 'Dibatalkan'
    pemohon VARCHAR(150),
    catatan TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 16. TABEL LOG MUTASI & PERGERAKAN PRODUK
CREATE TABLE IF NOT EXISTS inv_log_mutasi (
    id SERIAL PRIMARY KEY,
    tanggal TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    sku VARCHAR(100) NOT NULL,
    nama_produk VARCHAR(255),
    size VARCHAR(50),
    lokasi_rak VARCHAR(100),
    area VARCHAR(50),
    type VARCHAR(30) NOT NULL, -- 'IN', 'OUT', 'SO', 'ADJ_IN', 'ADJ_OUT'
    qty INTEGER NOT NULL DEFAULT 1,
    invoice VARCHAR(100),
    operator VARCHAR(100),
    keterangan TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 17. TABEL STOCK OPNAME & ADJUSTMENT
CREATE TABLE IF NOT EXISTS inv_stock_opname (
    id VARCHAR(50) PRIMARY KEY,
    no_adj VARCHAR(100) NOT NULL UNIQUE,
    tanggal DATE NOT NULL,
    lokasi_rak VARCHAR(100) NOT NULL,
    sku VARCHAR(100) NOT NULL,
    nama_produk VARCHAR(255),
    size VARCHAR(50),
    qty_sistem INTEGER NOT NULL DEFAULT 0,
    qty_fisik INTEGER NOT NULL DEFAULT 0,
    selisih INTEGER GENERATED ALWAYS AS (qty_fisik - qty_sistem) STORED,
    status VARCHAR(50) NOT NULL DEFAULT 'Pending', -- 'Pending', 'Approved', 'Rejected'
    jenis VARCHAR(50) DEFAULT 'Opname', -- 'Opname', 'Manual'
    petugas VARCHAR(100),
    approved_by VARCHAR(100),
    catatan TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 18. TABEL INBOUND PRODUKSI (PO / VENDOR)
CREATE TABLE IF NOT EXISTS inv_produksi (
    id VARCHAR(50) PRIMARY KEY,
    no_po VARCHAR(100) NOT NULL,
    vendor VARCHAR(150),
    tanggal_masuk DATE NOT NULL,
    sku VARCHAR(100) NOT NULL,
    nama_produk VARCHAR(255),
    size VARCHAR(50),
    qty_kirim INTEGER NOT NULL DEFAULT 0,
    status VARCHAR(50) NOT NULL DEFAULT 'Dalam QC', -- 'Dalam QC', 'Selesai QC'
    keterangan TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 19. TABEL LAPORAN QUALITY CONTROL (QC)
CREATE TABLE IF NOT EXISTS inv_qc (
    id VARCHAR(50) PRIMARY KEY,
    no_qc VARCHAR(100) NOT NULL UNIQUE,
    no_po VARCHAR(100),
    sku VARCHAR(100) NOT NULL,
    nama_produk VARCHAR(255),
    size VARCHAR(50),
    qty_lolos INTEGER NOT NULL DEFAULT 0,
    qty_permak INTEGER NOT NULL DEFAULT 0,
    qty_defect INTEGER NOT NULL DEFAULT 0,
    inspektor VARCHAR(100),
    catatan TEXT,
    tanggal_qc DATE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==============================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- Enable read & write for anon key (Frontend API)
-- ==============================================================================
ALTER TABLE karyawan ENABLE ROW LEVEL SECURITY;
ALTER TABLE master_shift ENABLE ROW LEVEL SECURITY;
ALTER TABLE roster_shift ENABLE ROW LEVEL SECURITY;
ALTER TABLE presensi ENABLE ROW LEVEL SECURITY;
ALTER TABLE lembur ENABLE ROW LEVEL SECURITY;
ALTER TABLE perijinan_cuti ENABLE ROW LEVEL SECURITY;
ALTER TABLE kasbon ENABLE ROW LEVEL SECURITY;
ALTER TABLE payroll ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE inbound_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE outbound_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE warehouse_tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE inv_stock ENABLE ROW LEVEL SECURITY;
ALTER TABLE inv_peminjaman ENABLE ROW LEVEL SECURITY;
ALTER TABLE inv_refill ENABLE ROW LEVEL SECURITY;
ALTER TABLE inv_log_mutasi ENABLE ROW LEVEL SECURITY;
ALTER TABLE inv_stock_opname ENABLE ROW LEVEL SECURITY;
ALTER TABLE inv_produksi ENABLE ROW LEVEL SECURITY;
ALTER TABLE inv_qc ENABLE ROW LEVEL SECURITY;
ALTER TABLE pengajuan_profil ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public all access on karyawan" ON karyawan FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow public all access on master_shift" ON master_shift FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow public all access on roster_shift" ON roster_shift FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow public all access on presensi" ON presensi FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow public all access on lembur" ON lembur FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow public all access on perijinan_cuti" ON perijinan_cuti FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow public all access on kasbon" ON kasbon FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow public all access on payroll" ON payroll FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow public all access on inventory_items" ON inventory_items FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow public all access on inbound_orders" ON inbound_orders FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow public all access on outbound_orders" ON outbound_orders FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow public all access on warehouse_tasks" ON warehouse_tasks FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow public all access on inv_stock" ON inv_stock FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow public all access on inv_peminjaman" ON inv_peminjaman FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow public all access on inv_refill" ON inv_refill FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow public all access on inv_log_mutasi" ON inv_log_mutasi FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow public all access on inv_stock_opname" ON inv_stock_opname FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow public all access on inv_produksi" ON inv_produksi FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow public all access on inv_qc" ON inv_qc FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow public all access on pengajuan_profil" ON pengajuan_profil FOR ALL USING (true) WITH CHECK (true);



-- ==============================================================================
-- INSERT DATA DUMP DARI DATABASE LAMA
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- DATA TABEL: karyawan (10 baris)
-- ------------------------------------------------------------------------------
INSERT INTO karyawan (nik, nama, divisi, username, password, role, gaji_pokok, tunjangan, rate_lembur, saldo_kasbon, email, no_hp, created_at, updated_at, tgl_lahir, tgl_bergabung, alamat, hobi, kontak_darurat, foto)
VALUES
  ('WH0010', 'Nanang', 'OB', 'UserQC9', '12345', 'user', 2700000, 0, 10000, 0, '', '', '2026-08-17T13:23:07.284785+00:00', '2026-08-17T13:23:07.284785+00:00', NULL, NULL, NULL, NULL, NULL, NULL),
  ('WH0001', 'Warehouse', 'Warehouse', 'Admin', '00000', 'admin', 0, 0, 10000, 0, '', '', '2026-08-17T13:03:51.559295+00:00', '2026-08-17T21:11:36.719+00:00', NULL, NULL, NULL, NULL, NULL, NULL),
  ('WH0008', 'Navi Ilyah', 'QC', 'UserQC7', '12345', 'user', 2000000, 0, 10000, 0, '', '08972887338', '2026-08-17T13:23:07.284785+00:00', '2026-08-26T09:58:57.575+00:00', '2001-02-12', NULL, 'GERMAN', '', 'MAMA - Orang Tua - 089728273389', NULL),
  ('WH0003', 'Irma', 'QC', 'UserQC2', '12345', 'user', 2400000, 0, 10000, 0, '', '085691158913', '2026-08-17T13:03:51.559295+00:00', '2026-08-26T10:04:00.837+00:00', '2008-08-28', NULL, 'jakarta barat,cengkareng', '', 'nurrohmah - Orang Tua - +62 858-6754-0953', NULL),
  ('WH0005', 'Nur Halimah', 'QC', 'UserQC4', 'maulanaibrahim', 'user', 2450000, 0, 10000, 0, '', '082226088254', '2026-08-17T13:23:07.284785+00:00', '2026-08-26T10:03:55.376+00:00', '2005-03-05', NULL, 'Cengkareng, Jakarta barat', '', 'sayang - Orang Tua - 088101130881', NULL),
  ('WH0002', 'Sasi Novita', 'QC', 'UserQC1', 'Novita2112', 'user', 2400000, 0, 10000, 0, 'sasynovita@gmail.com', '083898252743', '2026-08-17T13:03:51.559295+00:00', '2026-08-26T10:11:54.369+00:00', '2004-12-21', NULL, 'Jakarta barat', '', '+62 838-5239-1304 - Orang Tua - +62 838-5239-1304', 'data:image/jpeg;base64,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'),
  ('WH0009', 'Ria Nur Fiana', 'QC', 'UserQC8', '12345', 'user', 2000000, 0, 10000, 0, 'rianurfiana718@gmail.com', '085742176153', '2026-08-17T13:23:07.284785+00:00', '2026-08-26T11:02:44.173+00:00', '2003-10-08', NULL, 'Sedayu square blok f 35 Cengkareng Barat Jakarta Barat', 'Membaca, bersepeda, makan', '085742176153 - Orang Tua - 085742176153', NULL),
  ('WH0004', 'Yesinta Agistisari', 'QC', 'UserQC3', '12345', 'user', 2200000, 0, 10000, 0, 'yesintaagistisari255@gmail.com', '083128676891', '2026-08-17T13:23:07.284785+00:00', '2026-08-26T11:10:02.098+00:00', '2004-08-11', '2025-04-07', 'Desa Gunungsari sibedil RT 05/02 Kel. Pulosari, Kab. Pemalang, Prov. Jawa tengah', 'Makann', 'Fajar - Orang Tua - 082297836347', NULL),
  ('WH0007', 'Novi Fatihatul', 'QC', 'UserQC6', 'niammusyafa2006', 'user', 2000000, 0, 10000, 0, 'nuriyahpulosari@gmail.com', '085188172704', '2026-08-17T13:23:07.284785+00:00', '2026-08-26T13:43:13.058+00:00', '2007-11-28', '2026-03-02', 'pulosari pemalang', 'badminton', 'nur - Orang Tua - 085895280982', ''),
  ('WH0006', 'Vina Kharisma', 'QC', 'UserQC5', 'pipinbae', 'user', 2000000, 0, 10000, 0, '', '085293877926', '2026-08-17T13:23:07.284785+00:00', '2026-08-27T00:23:16.274+00:00', '2007-06-07', NULL, 'jakarta barat', '', 'kharis - Orang Tua - +62 852-1351-8005', NULL)
ON CONFLICT (nik) DO NOTHING;

-- ------------------------------------------------------------------------------
-- DATA TABEL: master_shift (4 baris)
-- ------------------------------------------------------------------------------
INSERT INTO master_shift (id, nama_shift, jam_masuk, jam_pulang, toleransi, status, created_at)
VALUES
  (1, 'Shift 1', '08:00:00', '17:00:00', 5, 'Aktif', '2026-08-17T13:03:51.559295+00:00'),
  (2, 'Shift 2', '09:00:00', '18:00:00', 5, 'Aktif', '2026-08-17T13:03:51.559295+00:00'),
  (3, 'Shift 3a', '12:00:00', '21:00:00', 5, 'Aktif', '2026-08-17T13:03:51.559295+00:00'),
  (4, 'Shift 3b', '11:00:00', '20:00:00', 5, 'Aktif', '2026-08-17T13:21:57.333169+00:00')
ON CONFLICT (id) DO NOTHING;

-- ------------------------------------------------------------------------------
-- DATA TABEL: roster_shift (722 baris)
-- ------------------------------------------------------------------------------
INSERT INTO roster_shift (id, nik, tanggal, shift, jam_masuk, jam_pulang, keterangan, created_at)
VALUES
  (1176, 'WH0001', '2026-09-01', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1177, 'WH0001', '2026-09-02', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1178, 'WH0001', '2026-09-03', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1179, 'WH0001', '2026-09-04', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1180, 'WH0001', '2026-09-05', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1181, 'WH0001', '2026-09-06', 'Libur', '', '', 'Libur', '2026-08-31T12:14:29.094637+00:00'),
  (1182, 'WH0001', '2026-09-07', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1183, 'WH0001', '2026-09-08', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1184, 'WH0001', '2026-09-09', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1185, 'WH0001', '2026-09-10', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1186, 'WH0001', '2026-09-11', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1187, 'WH0001', '2026-09-12', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1188, 'WH0001', '2026-09-13', 'Libur', '', '', 'Libur', '2026-08-31T12:14:29.094637+00:00'),
  (1189, 'WH0001', '2026-09-14', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1190, 'WH0001', '2026-09-15', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1191, 'WH0001', '2026-09-16', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1192, 'WH0001', '2026-09-17', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1193, 'WH0001', '2026-09-18', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1194, 'WH0001', '2026-09-19', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1195, 'WH0001', '2026-09-20', 'Libur', '', '', 'Libur', '2026-08-31T12:14:29.094637+00:00'),
  (1196, 'WH0001', '2026-09-21', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1197, 'WH0001', '2026-09-22', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1198, 'WH0001', '2026-09-23', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1199, 'WH0001', '2026-09-24', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1200, 'WH0001', '2026-09-25', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1201, 'WH0001', '2026-09-26', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1202, 'WH0001', '2026-09-27', 'Libur', '', '', 'Libur', '2026-08-31T12:14:29.094637+00:00'),
  (1203, 'WH0001', '2026-09-28', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1204, 'WH0001', '2026-09-29', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1205, 'WH0001', '2026-09-30', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1206, 'WH0002', '2026-09-01', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1207, 'WH0002', '2026-09-02', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1208, 'WH0002', '2026-09-03', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1209, 'WH0002', '2026-09-04', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1210, 'WH0002', '2026-09-05', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1211, 'WH0002', '2026-09-06', 'Libur', '', '', 'Libur', '2026-08-31T12:14:29.094637+00:00'),
  (1212, 'WH0002', '2026-09-07', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1214, 'WH0002', '2026-09-09', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1215, 'WH0002', '2026-09-10', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1216, 'WH0002', '2026-09-11', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1217, 'WH0002', '2026-09-12', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1218, 'WH0002', '2026-09-13', 'Libur', '', '', 'Libur', '2026-08-31T12:14:29.094637+00:00'),
  (1219, 'WH0002', '2026-09-14', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1220, 'WH0002', '2026-09-15', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1221, 'WH0002', '2026-09-16', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1222, 'WH0002', '2026-09-17', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1223, 'WH0002', '2026-09-18', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1224, 'WH0002', '2026-09-19', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1225, 'WH0002', '2026-09-20', 'Libur', '', '', 'Libur', '2026-08-31T12:14:29.094637+00:00'),
  (1226, 'WH0002', '2026-09-21', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1227, 'WH0002', '2026-09-22', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1228, 'WH0002', '2026-09-23', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1229, 'WH0002', '2026-09-24', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (555, 'WH0001', '2026-08-19', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:16:46.945113+00:00'),
  (711, 'WH0006', '2026-08-01', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (712, 'WH0006', '2026-08-02', 'Libur', '', '', 'Libur', '2026-08-19T03:36:40.679726+00:00'),
  (713, 'WH0006', '2026-08-03', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (714, 'WH0006', '2026-08-04', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (715, 'WH0006', '2026-08-05', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (716, 'WH0006', '2026-08-06', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (717, 'WH0006', '2026-08-07', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (161, 'WH0006', '2026-08-08', 'Shift 1', '08:00', '17:00', '', '2026-08-17T13:23:14.704247+00:00'),
  (719, 'WH0006', '2026-08-09', 'Libur', '', '', 'Libur', '2026-08-19T03:36:40.679726+00:00'),
  (720, 'WH0006', '2026-08-10', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (721, 'WH0006', '2026-08-11', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (722, 'WH0006', '2026-08-12', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (166, 'WH0006', '2026-08-13', 'Shift 1', '08:00', '17:00', '', '2026-08-17T13:23:14.844709+00:00'),
  (51, 'WH0003', '2026-08-08', 'Shift 2', '09:00', '18:00', '', '2026-08-17T13:23:14.439859+00:00'),
  (56, 'WH0003', '2026-08-13', 'Shift 2', '09:00', '18:00', '', '2026-08-17T13:23:14.439859+00:00'),
  (57, 'WH0003', '2026-08-14', 'Shift 2', '09:00', '18:00', '', '2026-08-17T13:23:14.439859+00:00'),
  (58, 'WH0003', '2026-08-15', 'Shift 2', '09:00', '18:00', '', '2026-08-17T13:23:14.439859+00:00'),
  (59, 'WH0003', '2026-08-16', 'Libur', '', '', 'Libur', '2026-08-17T13:23:14.439859+00:00'),
  (60, 'WH0003', '2026-08-17', 'Shift 2', '09:00', '18:00', '', '2026-08-17T13:23:14.439859+00:00'),
  (61, 'WH0003', '2026-08-18', 'Shift 2', '09:00', '18:00', '', '2026-08-17T13:23:14.439859+00:00'),
  (62, 'WH0003', '2026-08-19', 'Shift 2', '09:00', '18:00', '', '2026-08-17T13:23:14.439859+00:00'),
  (63, 'WH0003', '2026-08-20', 'Shift 2', '09:00', '18:00', '', '2026-08-17T13:23:14.439859+00:00'),
  (64, 'WH0003', '2026-08-21', 'Shift 2', '09:00', '18:00', '', '2026-08-17T13:23:14.439859+00:00'),
  (65, 'WH0003', '2026-08-22', 'Shift 2', '09:00', '18:00', '', '2026-08-17T13:23:14.439859+00:00'),
  (66, 'WH0003', '2026-08-23', 'Libur', '', '', 'Libur', '2026-08-17T13:23:14.439859+00:00'),
  (67, 'WH0003', '2026-08-24', 'Shift 2', '09:00', '18:00', '', '2026-08-17T13:23:14.439859+00:00'),
  (68, 'WH0003', '2026-08-25', 'Shift 2', '09:00', '18:00', '', '2026-08-17T13:23:14.439859+00:00'),
  (75, 'WH0004', '2026-07-26', 'Libur', '', '', 'Minggu', '2026-08-17T13:23:14.439859+00:00'),
  (76, 'WH0004', '2026-07-27', 'Shift 3', '12.00', '21.00', '', '2026-08-17T13:23:14.439859+00:00'),
  (77, 'WH0004', '2026-07-28', 'Shift 3', '12.00', '21.00', '', '2026-08-17T13:23:14.439859+00:00'),
  (78, 'WH0004', '2026-07-29', 'Shift 3', '12.00', '21.00', '', '2026-08-17T13:23:14.439859+00:00'),
  (79, 'WH0004', '2026-07-30', 'Shift 3', '12.00', '21.00', '', '2026-08-17T13:23:14.439859+00:00'),
  (80, 'WH0004', '2026-07-31', 'Shift 3', '12.00', '21.00', '', '2026-08-17T13:23:14.439859+00:00'),
  (81, 'WH0004', '2026-01-08', 'Shift 3', '11.00', '20.00', '', '2026-08-17T13:23:14.439859+00:00'),
  (82, 'WH0004', '2026-02-08', 'Libur', '', '', 'Minggu', '2026-08-17T13:23:14.439859+00:00'),
  (83, 'WH0004', '2026-03-08', 'Shift 3', '12.00', '21.00', '', '2026-08-17T13:23:14.439859+00:00'),
  (84, 'WH0004', '2026-04-08', 'Shift 3', '12.00', '21.00', '', '2026-08-17T13:23:14.439859+00:00'),
  (85, 'WH0004', '2026-05-08', 'Shift 3', '12.00', '21.00', '', '2026-08-17T13:23:14.439859+00:00'),
  (86, 'WH0004', '2026-06-08', 'Shift 3', '12.00', '21.00', '', '2026-08-17T13:23:14.439859+00:00'),
  (87, 'WH0004', '2026-07-08', 'Shift 3', '12.00', '21.00', '', '2026-08-17T13:23:14.439859+00:00'),
  (69, 'WH0003', '2026-08-26', 'Shift 2', '09:00', '18:00', '', '2026-08-17T13:23:14.439859+00:00'),
  (90, 'WH0004', '2026-10-08', 'Shift 3', '12.00', '21.00', '', '2026-08-17T13:23:14.439859+00:00'),
  (91, 'WH0004', '2026-11-08', 'Shift 3', '12.00', '21.00', '', '2026-08-17T13:23:14.439859+00:00'),
  (92, 'WH0004', '2026-12-08', 'Shift 3', '12.00', '21.00', '', '2026-08-17T13:23:14.439859+00:00'),
  (70, 'WH0003', '2026-08-27', 'Shift 2', '09:00', '18:00', '', '2026-08-17T13:23:14.439859+00:00'),
  (71, 'WH0003', '2026-08-28', 'Shift 2', '09:00', '18:00', '', '2026-08-17T13:23:14.439859+00:00')
ON CONFLICT (id) DO NOTHING;

INSERT INTO roster_shift (id, nik, tanggal, shift, jam_masuk, jam_pulang, keterangan, created_at)
VALUES
  (53, 'WH0003', '2026-10-08', 'Shift 3', '12.00', '21.00', '', '2026-08-17T13:23:14.439859+00:00'),
  (54, 'WH0003', '2026-11-08', 'Shift 3', '12.00', '21.00', '', '2026-08-17T13:23:14.439859+00:00'),
  (55, 'WH0003', '2026-12-08', 'Shift 3', '12.00', '21.00', '', '2026-08-17T13:23:14.439859+00:00'),
  (1230, 'WH0002', '2026-09-25', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1231, 'WH0002', '2026-09-26', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1232, 'WH0002', '2026-09-27', 'Libur', '', '', 'Libur', '2026-08-31T12:14:29.094637+00:00'),
  (1233, 'WH0002', '2026-09-28', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1234, 'WH0002', '2026-09-29', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1235, 'WH0002', '2026-09-30', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1236, 'WH0003', '2026-09-01', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1237, 'WH0003', '2026-09-02', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1238, 'WH0003', '2026-09-03', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1239, 'WH0003', '2026-09-04', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1240, 'WH0003', '2026-09-05', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1241, 'WH0003', '2026-09-06', 'Libur', '', '', 'Libur', '2026-08-31T12:14:29.094637+00:00'),
  (1242, 'WH0003', '2026-09-07', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (52, 'WH0003', '2026-09-08', 'Shift 2', '09:00', '18:00', '', '2026-08-17T13:23:14.439859+00:00'),
  (556, 'WH0001', '2026-08-01', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (557, 'WH0001', '2026-08-02', 'Libur', '', '', 'Libur', '2026-08-19T03:36:40.679726+00:00'),
  (558, 'WH0001', '2026-08-03', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (1244, 'WH0003', '2026-09-09', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1245, 'WH0003', '2026-09-10', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1246, 'WH0003', '2026-09-11', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1247, 'WH0003', '2026-09-12', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1248, 'WH0003', '2026-09-13', 'Libur', '', '', 'Libur', '2026-08-31T12:14:29.094637+00:00'),
  (1249, 'WH0003', '2026-09-14', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1250, 'WH0003', '2026-09-15', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1251, 'WH0003', '2026-09-16', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1252, 'WH0003', '2026-09-17', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1253, 'WH0003', '2026-09-18', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1254, 'WH0003', '2026-09-19', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1255, 'WH0003', '2026-09-20', 'Libur', '', '', 'Libur', '2026-08-31T12:14:29.094637+00:00'),
  (1256, 'WH0003', '2026-09-21', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1257, 'WH0003', '2026-09-22', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1258, 'WH0003', '2026-09-23', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1259, 'WH0003', '2026-09-24', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1260, 'WH0003', '2026-09-25', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1261, 'WH0003', '2026-09-26', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1262, 'WH0003', '2026-09-27', 'Libur', '', '', 'Libur', '2026-08-31T12:14:29.094637+00:00'),
  (1263, 'WH0003', '2026-09-28', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1264, 'WH0003', '2026-09-29', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1265, 'WH0003', '2026-09-30', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1266, 'WH0004', '2026-09-01', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1267, 'WH0004', '2026-09-02', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1268, 'WH0004', '2026-09-03', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1269, 'WH0004', '2026-09-04', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1270, 'WH0004', '2026-09-05', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1271, 'WH0004', '2026-09-06', 'Libur', '', '', 'Libur', '2026-08-31T12:14:29.094637+00:00'),
  (1272, 'WH0004', '2026-09-07', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (89, 'WH0004', '2026-09-08', 'Shift 1', '08:00', '17:00', '', '2026-08-17T13:23:14.439859+00:00'),
  (1274, 'WH0004', '2026-09-09', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1275, 'WH0004', '2026-09-10', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1276, 'WH0004', '2026-09-11', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1277, 'WH0004', '2026-09-12', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1278, 'WH0004', '2026-09-13', 'Libur', '', '', 'Libur', '2026-08-31T12:14:29.094637+00:00'),
  (1279, 'WH0004', '2026-09-14', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (163, 'WH0006', '2026-10-08', 'Shift 1', '08.00', '17.00', '', '2026-08-17T13:23:14.844709+00:00'),
  (164, 'WH0006', '2026-11-08', 'Shift 1', '08.00', '17.00', '', '2026-08-17T13:23:14.844709+00:00'),
  (165, 'WH0006', '2026-12-08', 'Shift 1', '08.00', '17.00', '', '2026-08-17T13:23:14.844709+00:00'),
  (559, 'WH0001', '2026-08-04', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (560, 'WH0001', '2026-08-05', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (561, 'WH0001', '2026-08-06', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (562, 'WH0001', '2026-08-07', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (563, 'WH0001', '2026-08-08', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (564, 'WH0001', '2026-08-09', 'Libur', '', '', 'Libur', '2026-08-19T03:36:40.679726+00:00'),
  (565, 'WH0001', '2026-08-10', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (566, 'WH0001', '2026-08-11', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (567, 'WH0001', '2026-08-12', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (568, 'WH0001', '2026-08-13', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (569, 'WH0001', '2026-08-14', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (570, 'WH0001', '2026-08-15', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (571, 'WH0001', '2026-08-16', 'Libur', '', '', 'Libur', '2026-08-19T03:36:40.679726+00:00'),
  (572, 'WH0001', '2026-08-17', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (573, 'WH0001', '2026-08-18', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (575, 'WH0001', '2026-08-20', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (576, 'WH0001', '2026-08-21', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (577, 'WH0001', '2026-08-22', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (578, 'WH0001', '2026-08-23', 'Libur', '', '', 'Libur', '2026-08-19T03:36:40.679726+00:00'),
  (185, 'WH0007', '2026-07-26', 'Libur', '', '', 'Minggu', '2026-08-17T13:23:14.844709+00:00'),
  (186, 'WH0007', '2026-07-27', 'Shift 1', '08.00', '17.00', '', '2026-08-17T13:23:14.844709+00:00'),
  (187, 'WH0007', '2026-07-28', 'Shift 1', '08.00', '17.00', '', '2026-08-17T13:23:14.844709+00:00'),
  (188, 'WH0007', '2026-07-29', 'Shift 1', '08.00', '17.00', '', '2026-08-17T13:23:14.844709+00:00'),
  (189, 'WH0007', '2026-07-30', 'Shift 1', '08.00', '17.00', '', '2026-08-17T13:23:14.844709+00:00'),
  (190, 'WH0007', '2026-07-31', 'Shift 1', '08.00', '17.00', '', '2026-08-17T13:23:14.844709+00:00'),
  (191, 'WH0007', '2026-01-08', 'Shift 1', '08.00', '17.00', '', '2026-08-17T13:23:14.844709+00:00'),
  (192, 'WH0007', '2026-02-08', 'Libur', '', '', 'Minggu', '2026-08-17T13:23:14.844709+00:00'),
  (193, 'WH0007', '2026-03-08', 'Shift 1', '08.00', '17.00', '', '2026-08-17T13:23:14.844709+00:00'),
  (194, 'WH0007', '2026-04-08', 'Shift 1', '08.00', '17.00', '', '2026-08-17T13:23:14.844709+00:00'),
  (195, 'WH0007', '2026-05-08', 'Shift 1', '08.00', '17.00', '', '2026-08-17T13:23:14.844709+00:00'),
  (196, 'WH0007', '2026-06-08', 'Shift 1', '08.00', '17.00', '', '2026-08-17T13:23:14.844709+00:00'),
  (197, 'WH0007', '2026-07-08', 'Shift 1', '08.00', '17.00', '', '2026-08-17T13:23:14.844709+00:00'),
  (579, 'WH0001', '2026-08-24', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (200, 'WH0007', '2026-10-08', 'Shift 1', '08.00', '17.00', '', '2026-08-17T13:23:14.844709+00:00'),
  (201, 'WH0007', '2026-11-08', 'Shift 1', '08.00', '17.00', '', '2026-08-17T13:23:14.844709+00:00'),
  (202, 'WH0007', '2026-12-08', 'Shift 1', '08.00', '17.00', '', '2026-08-17T13:23:14.844709+00:00'),
  (580, 'WH0001', '2026-08-25', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (581, 'WH0001', '2026-08-26', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (582, 'WH0001', '2026-08-27', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (583, 'WH0001', '2026-08-28', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (584, 'WH0001', '2026-08-29', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00')
ON CONFLICT (id) DO NOTHING;

INSERT INTO roster_shift (id, nik, tanggal, shift, jam_masuk, jam_pulang, keterangan, created_at)
VALUES
  (585, 'WH0001', '2026-08-30', 'Libur', '', '', 'Libur', '2026-08-19T03:36:40.679726+00:00'),
  (586, 'WH0001', '2026-08-31', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (587, 'WH0002', '2026-08-01', 'Shift 2', '09:00', '18:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (588, 'WH0002', '2026-08-02', 'Libur', '', '', 'Libur', '2026-08-19T03:36:40.679726+00:00'),
  (589, 'WH0002', '2026-08-03', 'Shift 2', '09:00', '18:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (590, 'WH0002', '2026-08-04', 'Shift 2', '09:00', '18:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (591, 'WH0002', '2026-08-05', 'Shift 2', '09:00', '18:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (592, 'WH0002', '2026-08-06', 'Shift 2', '09:00', '18:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (15, 'WH0002', '2026-09-08', 'Shift 2', '09:00', '18:00', '', '2026-08-17T13:23:14.131888+00:00'),
  (1280, 'WH0004', '2026-09-15', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1281, 'WH0004', '2026-09-16', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1282, 'WH0004', '2026-09-17', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1283, 'WH0004', '2026-09-18', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1284, 'WH0004', '2026-09-19', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1285, 'WH0004', '2026-09-20', 'Libur', '', '', 'Libur', '2026-08-31T12:14:29.094637+00:00'),
  (1286, 'WH0004', '2026-09-21', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1287, 'WH0004', '2026-09-22', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1288, 'WH0004', '2026-09-23', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1289, 'WH0004', '2026-09-24', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1290, 'WH0004', '2026-09-25', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1291, 'WH0004', '2026-09-26', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1292, 'WH0004', '2026-09-27', 'Libur', '', '', 'Libur', '2026-08-31T12:14:29.094637+00:00'),
  (1293, 'WH0004', '2026-09-28', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1294, 'WH0004', '2026-09-29', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1295, 'WH0004', '2026-09-30', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1296, 'WH0005', '2026-09-01', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1297, 'WH0005', '2026-09-02', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1298, 'WH0005', '2026-09-03', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1299, 'WH0005', '2026-09-04', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1300, 'WH0005', '2026-09-05', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1301, 'WH0005', '2026-09-06', 'Libur', '', '', 'Libur', '2026-08-31T12:14:29.094637+00:00'),
  (1, 'WH0002', '2026-07-26', 'Libur', '', '', 'Minggu', '2026-08-17T13:23:14.131888+00:00'),
  (2, 'WH0002', '2026-07-27', 'Shift 2', '09.00', '18.00', '', '2026-08-17T13:23:14.131888+00:00'),
  (3, 'WH0002', '2026-07-28', 'Shift 2', '09.00', '18.00', '', '2026-08-17T13:23:14.131888+00:00'),
  (4, 'WH0002', '2026-07-29', 'Shift 2', '09.00', '18.00', '', '2026-08-17T13:23:14.131888+00:00'),
  (5, 'WH0002', '2026-07-30', 'Shift 2', '09.00', '18.00', '', '2026-08-17T13:23:14.131888+00:00'),
  (6, 'WH0002', '2026-07-31', 'Shift 2', '09.00', '18.00', '', '2026-08-17T13:23:14.131888+00:00'),
  (7, 'WH0002', '2026-01-08', 'Shift 2', '09.00', '18.00', '', '2026-08-17T13:23:14.131888+00:00'),
  (8, 'WH0002', '2026-02-08', 'Libur', '', '', 'Minggu', '2026-08-17T13:23:14.131888+00:00'),
  (9, 'WH0002', '2026-03-08', 'Shift 2', '09.00', '18.00', '', '2026-08-17T13:23:14.131888+00:00'),
  (10, 'WH0002', '2026-04-08', 'Shift 2', '09.00', '18.00', '', '2026-08-17T13:23:14.131888+00:00'),
  (11, 'WH0002', '2026-05-08', 'Shift 2', '09.00', '18.00', '', '2026-08-17T13:23:14.131888+00:00'),
  (12, 'WH0002', '2026-06-08', 'Shift 2', '09.00', '18.00', '', '2026-08-17T13:23:14.131888+00:00'),
  (13, 'WH0002', '2026-07-08', 'Shift 2', '09.00', '18.00', '', '2026-08-17T13:23:14.131888+00:00'),
  (16, 'WH0002', '2026-10-08', 'Shift 2', '09.00', '18.00', '', '2026-08-17T13:23:14.131888+00:00'),
  (17, 'WH0002', '2026-11-08', 'Shift 2', '09.00', '18.00', '', '2026-08-17T13:23:14.131888+00:00'),
  (18, 'WH0002', '2026-12-08', 'Shift 2', '09.00', '18.00', '', '2026-08-17T13:23:14.131888+00:00'),
  (1302, 'WH0005', '2026-09-07', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1304, 'WH0005', '2026-09-09', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1305, 'WH0005', '2026-09-10', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1306, 'WH0005', '2026-09-11', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1307, 'WH0005', '2026-09-12', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1308, 'WH0005', '2026-09-13', 'Libur', '', '', 'Libur', '2026-08-31T12:14:29.094637+00:00'),
  (1309, 'WH0005', '2026-09-14', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1310, 'WH0005', '2026-09-15', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1311, 'WH0005', '2026-09-16', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1312, 'WH0005', '2026-09-17', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1313, 'WH0005', '2026-09-18', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (38, 'WH0003', '2026-07-26', 'Libur', '', '', 'Minggu', '2026-08-17T13:23:14.131888+00:00'),
  (39, 'WH0003', '2026-07-27', 'Shift 3', '12.00', '21.00', '', '2026-08-17T13:23:14.131888+00:00'),
  (40, 'WH0003', '2026-07-28', 'Shift 3', '12.00', '21.00', '', '2026-08-17T13:23:14.131888+00:00'),
  (41, 'WH0003', '2026-07-29', 'Shift 3', '12.00', '21.00', '', '2026-08-17T13:23:14.131888+00:00'),
  (42, 'WH0003', '2026-07-30', 'Shift 3', '12.00', '21.00', '', '2026-08-17T13:23:14.131888+00:00'),
  (43, 'WH0003', '2026-07-31', 'Shift 3', '12.00', '21.00', '', '2026-08-17T13:23:14.131888+00:00'),
  (44, 'WH0003', '2026-01-08', 'Shift 3', '11.00', '20.00', '', '2026-08-17T13:23:14.131888+00:00'),
  (45, 'WH0003', '2026-02-08', 'Libur', '', '', 'Minggu', '2026-08-17T13:23:14.131888+00:00'),
  (14, 'WH0002', '2026-08-08', 'Shift 2', '09:00', '18:00', '', '2026-08-17T13:23:14.131888+00:00'),
  (19, 'WH0002', '2026-08-13', 'Shift 2', '09:00', '18:00', '', '2026-08-17T13:23:14.131888+00:00'),
  (20, 'WH0002', '2026-08-14', 'Shift 2', '09:00', '18:00', '', '2026-08-17T13:23:14.131888+00:00'),
  (222, 'WH0008', '2026-07-26', 'Libur', '', '', 'Minggu', '2026-08-17T13:23:14.985328+00:00'),
  (223, 'WH0008', '2026-07-27', 'Shift 1', '08.00', '17.00', '', '2026-08-17T13:23:14.985328+00:00'),
  (224, 'WH0008', '2026-07-28', 'Shift 1', '08.00', '17.00', '', '2026-08-17T13:23:14.985328+00:00'),
  (225, 'WH0008', '2026-07-29', 'Shift 1', '08.00', '17.00', '', '2026-08-17T13:23:14.985328+00:00'),
  (226, 'WH0008', '2026-07-30', 'Shift 1', '08.00', '17.00', '', '2026-08-17T13:23:14.985328+00:00'),
  (227, 'WH0008', '2026-07-31', 'Shift 1', '08.00', '17.00', '', '2026-08-17T13:23:14.985328+00:00'),
  (228, 'WH0008', '2026-01-08', 'Shift 1', '08.00', '17.00', '', '2026-08-17T13:23:14.985328+00:00'),
  (229, 'WH0008', '2026-02-08', 'Libur', '', '', 'Minggu', '2026-08-17T13:23:14.985328+00:00'),
  (230, 'WH0008', '2026-03-08', 'Shift 1', '08.00', '17.00', '', '2026-08-17T13:23:14.985328+00:00'),
  (1316, 'WH0005', '2026-09-21', 'Shift 3', '12:00', '21:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1314, 'WH0005', '2026-09-19', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1315, 'WH0005', '2026-09-20', 'Libur', '', '', 'Libur', '2026-08-31T12:14:29.094637+00:00'),
  (1317, 'WH0005', '2026-09-22', 'Shift 3', '12:00', '21:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1318, 'WH0005', '2026-09-23', 'Shift 3', '12:00', '21:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (21, 'WH0002', '2026-08-15', 'Shift 2', '09:00', '18:00', '', '2026-08-17T13:23:14.131888+00:00'),
  (22, 'WH0002', '2026-08-16', 'Libur', '', '', 'Libur', '2026-08-17T13:23:14.131888+00:00'),
  (23, 'WH0002', '2026-08-17', 'Shift 2', '09:00', '18:00', '', '2026-08-17T13:23:14.131888+00:00'),
  (24, 'WH0002', '2026-08-18', 'Shift 2', '09:00', '18:00', '', '2026-08-17T13:23:14.131888+00:00'),
  (25, 'WH0002', '2026-08-19', 'Shift 2', '09:00', '18:00', '', '2026-08-17T13:23:14.131888+00:00'),
  (26, 'WH0002', '2026-08-20', 'Shift 2', '09:00', '18:00', '', '2026-08-17T13:23:14.131888+00:00'),
  (27, 'WH0002', '2026-08-21', 'Shift 2', '09:00', '18:00', '', '2026-08-17T13:23:14.131888+00:00'),
  (28, 'WH0002', '2026-08-22', 'Shift 2', '09:00', '18:00', '', '2026-08-17T13:23:14.131888+00:00'),
  (29, 'WH0002', '2026-08-23', 'Libur', '', '', 'Libur', '2026-08-17T13:23:14.131888+00:00'),
  (30, 'WH0002', '2026-08-24', 'Shift 2', '09:00', '18:00', '', '2026-08-17T13:23:14.131888+00:00'),
  (31, 'WH0002', '2026-08-25', 'Shift 2', '09:00', '18:00', '', '2026-08-17T13:23:14.131888+00:00'),
  (32, 'WH0002', '2026-08-26', 'Shift 2', '09:00', '18:00', '', '2026-08-17T13:23:14.131888+00:00'),
  (33, 'WH0002', '2026-08-27', 'Shift 2', '09:00', '18:00', '', '2026-08-17T13:23:14.131888+00:00'),
  (34, 'WH0002', '2026-08-28', 'Shift 2', '09:00', '18:00', '', '2026-08-17T13:23:14.131888+00:00'),
  (35, 'WH0002', '2026-08-29', 'Shift 2', '09:00', '18:00', '', '2026-08-17T13:23:14.131888+00:00'),
  (36, 'WH0002', '2026-08-30', 'Libur', '', '', 'Libur', '2026-08-17T13:23:14.131888+00:00'),
  (37, 'WH0002', '2026-08-31', 'Shift 2', '09:00', '18:00', '', '2026-08-17T13:23:14.131888+00:00')
ON CONFLICT (id) DO NOTHING;

INSERT INTO roster_shift (id, nik, tanggal, shift, jam_masuk, jam_pulang, keterangan, created_at)
VALUES
  (628, 'WH0003', '2026-08-11', 'Shift 2', '09:00', '18:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (629, 'WH0003', '2026-08-12', 'Shift 2', '09:00', '18:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (649, 'WH0004', '2026-08-01', 'Shift 3b', '11:00', '20:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (650, 'WH0004', '2026-08-02', 'Libur', '', '', 'Libur', '2026-08-19T03:36:40.679726+00:00'),
  (651, 'WH0004', '2026-08-03', 'Shift 3a', '12:00', '21:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (652, 'WH0004', '2026-08-04', 'Shift 3a', '12:00', '21:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (653, 'WH0004', '2026-08-05', 'Shift 3a', '12:00', '21:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (654, 'WH0004', '2026-08-06', 'Shift 3a', '12:00', '21:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (655, 'WH0004', '2026-08-07', 'Shift 3a', '12:00', '21:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (657, 'WH0004', '2026-08-09', 'Libur', '', '', 'Libur', '2026-08-19T03:36:40.679726+00:00'),
  (658, 'WH0004', '2026-08-10', 'Shift 3a', '12:00', '21:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (659, 'WH0004', '2026-08-11', 'Shift 3a', '12:00', '21:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (46, 'WH0003', '2026-03-08', 'Shift 3', '12.00', '21.00', '', '2026-08-17T13:23:14.131888+00:00'),
  (47, 'WH0003', '2026-04-08', 'Shift 3', '12.00', '21.00', '', '2026-08-17T13:23:14.131888+00:00'),
  (48, 'WH0003', '2026-05-08', 'Shift 3', '12.00', '21.00', '', '2026-08-17T13:23:14.131888+00:00'),
  (49, 'WH0003', '2026-06-08', 'Shift 3', '12.00', '21.00', '', '2026-08-17T13:23:14.131888+00:00'),
  (50, 'WH0003', '2026-07-08', 'Shift 3', '12.00', '21.00', '', '2026-08-17T13:23:14.131888+00:00'),
  (407, 'WH0005', '2026-07-26', 'Libur', '', '', 'Minggu', '2026-08-17T13:23:58.888799+00:00'),
  (408, 'WH0005', '2026-07-27', 'Shift 2', '09.00', '18.00', '', '2026-08-17T13:23:58.888799+00:00'),
  (113, 'WH0005', '2026-07-28', 'Shift 2', '09.00', '18.00', '', '2026-08-17T13:23:14.704247+00:00'),
  (114, 'WH0005', '2026-07-29', 'Shift 2', '09.00', '18.00', '', '2026-08-17T13:23:14.704247+00:00'),
  (115, 'WH0005', '2026-07-30', 'Shift 2', '09.00', '18.00', '', '2026-08-17T13:23:14.704247+00:00'),
  (116, 'WH0005', '2026-07-31', 'Shift 2', '09.00', '18.00', '', '2026-08-17T13:23:14.704247+00:00'),
  (117, 'WH0005', '2026-01-08', 'Shift 2', '09.00', '18.00', '', '2026-08-17T13:23:14.704247+00:00'),
  (118, 'WH0005', '2026-02-08', 'Libur', '', '', 'Minggu', '2026-08-17T13:23:14.704247+00:00'),
  (119, 'WH0005', '2026-03-08', 'Shift 2', '09.00', '18.00', '', '2026-08-17T13:23:14.704247+00:00'),
  (120, 'WH0005', '2026-04-08', 'Shift 2', '09.00', '18.00', '', '2026-08-17T13:23:14.704247+00:00'),
  (121, 'WH0005', '2026-05-08', 'Shift 2', '09.00', '18.00', '', '2026-08-17T13:23:14.704247+00:00'),
  (122, 'WH0005', '2026-06-08', 'Shift 2', '09.00', '18.00', '', '2026-08-17T13:23:14.704247+00:00'),
  (123, 'WH0005', '2026-07-08', 'Shift 2', '09.00', '18.00', '', '2026-08-17T13:23:14.704247+00:00'),
  (126, 'WH0005', '2026-10-08', 'Shift 2', '09.00', '18.00', '', '2026-08-17T13:23:14.704247+00:00'),
  (127, 'WH0005', '2026-11-08', 'Shift 2', '09.00', '18.00', '', '2026-08-17T13:23:14.704247+00:00'),
  (128, 'WH0005', '2026-12-08', 'Shift 2', '09.00', '18.00', '', '2026-08-17T13:23:14.704247+00:00'),
  (125, 'WH0005', '2026-09-08', 'Shift 2', '09:00', '18:00', '', '2026-08-17T13:23:14.704247+00:00'),
  (1319, 'WH0005', '2026-09-24', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1322, 'WH0005', '2026-09-27', 'Libur', '', '', 'Libur', '2026-08-31T12:14:29.094637+00:00'),
  (1323, 'WH0005', '2026-09-28', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1324, 'WH0005', '2026-09-29', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1325, 'WH0005', '2026-09-30', 'Shift 2', '09:00', '18:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1326, 'WH0006', '2026-09-01', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1327, 'WH0006', '2026-09-02', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1328, 'WH0006', '2026-09-03', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (148, 'WH0006', '2026-07-26', 'Libur', '', '', 'Minggu', '2026-08-17T13:23:14.704247+00:00'),
  (149, 'WH0006', '2026-07-27', 'Shift 1', '08.00', '17.00', '', '2026-08-17T13:23:14.704247+00:00'),
  (150, 'WH0006', '2026-07-28', 'Shift 1', '08.00', '17.00', '', '2026-08-17T13:23:14.704247+00:00'),
  (151, 'WH0006', '2026-07-29', 'Shift 1', '08.00', '17.00', '', '2026-08-17T13:23:14.704247+00:00'),
  (152, 'WH0006', '2026-07-30', 'Shift 1', '08.00', '17.00', '', '2026-08-17T13:23:14.704247+00:00'),
  (153, 'WH0006', '2026-07-31', 'Shift 1', '08.00', '17.00', '', '2026-08-17T13:23:14.704247+00:00'),
  (154, 'WH0006', '2026-01-08', 'Shift 1', '08.00', '17.00', '', '2026-08-17T13:23:14.704247+00:00'),
  (155, 'WH0006', '2026-02-08', 'Libur', '', '', 'Minggu', '2026-08-17T13:23:14.704247+00:00'),
  (156, 'WH0006', '2026-03-08', 'Shift 1', '08.00', '17.00', '', '2026-08-17T13:23:14.704247+00:00'),
  (157, 'WH0006', '2026-04-08', 'Shift 1', '08.00', '17.00', '', '2026-08-17T13:23:14.704247+00:00'),
  (158, 'WH0006', '2026-05-08', 'Shift 1', '08.00', '17.00', '', '2026-08-17T13:23:14.704247+00:00'),
  (159, 'WH0006', '2026-06-08', 'Shift 1', '08.00', '17.00', '', '2026-08-17T13:23:14.704247+00:00'),
  (160, 'WH0006', '2026-07-08', 'Shift 1', '08.00', '17.00', '', '2026-08-17T13:23:14.704247+00:00'),
  (1329, 'WH0006', '2026-09-04', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (231, 'WH0008', '2026-04-08', 'Shift 1', '08.00', '17.00', '', '2026-08-17T13:23:14.985328+00:00'),
  (232, 'WH0008', '2026-05-08', 'Shift 1', '08.00', '17.00', '', '2026-08-17T13:23:14.985328+00:00'),
  (233, 'WH0008', '2026-06-08', 'Shift 1', '08.00', '17.00', '', '2026-08-17T13:23:14.985328+00:00'),
  (234, 'WH0008', '2026-07-08', 'Shift 1', '08.00', '17.00', '', '2026-08-17T13:23:14.985328+00:00'),
  (1330, 'WH0006', '2026-09-05', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (237, 'WH0008', '2026-10-08', 'Shift 1', '08.00', '17.00', '', '2026-08-17T13:23:14.985328+00:00'),
  (238, 'WH0008', '2026-11-08', 'Shift 1', '08.00', '17.00', '', '2026-08-17T13:23:14.985328+00:00'),
  (239, 'WH0008', '2026-12-08', 'Shift 1', '08.00', '17.00', '', '2026-08-17T13:23:14.985328+00:00'),
  (1331, 'WH0006', '2026-09-06', 'Libur', '', '', 'Libur', '2026-08-31T12:14:29.094637+00:00'),
  (1332, 'WH0006', '2026-09-07', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (162, 'WH0006', '2026-09-08', 'Shift 1', '08:00', '17:00', '', '2026-08-17T13:23:14.704247+00:00'),
  (1334, 'WH0006', '2026-09-09', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1335, 'WH0006', '2026-09-10', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1336, 'WH0006', '2026-09-11', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1337, 'WH0006', '2026-09-12', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1338, 'WH0006', '2026-09-13', 'Libur', '', '', 'Libur', '2026-08-31T12:14:29.094637+00:00'),
  (1339, 'WH0006', '2026-09-14', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1340, 'WH0006', '2026-09-15', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1341, 'WH0006', '2026-09-16', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1342, 'WH0006', '2026-09-17', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1343, 'WH0006', '2026-09-18', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1344, 'WH0006', '2026-09-19', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1345, 'WH0006', '2026-09-20', 'Libur', '', '', 'Libur', '2026-08-31T12:14:29.094637+00:00'),
  (1346, 'WH0006', '2026-09-21', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1347, 'WH0006', '2026-09-22', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1348, 'WH0006', '2026-09-23', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1349, 'WH0006', '2026-09-24', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1350, 'WH0006', '2026-09-25', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1351, 'WH0006', '2026-09-26', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1352, 'WH0006', '2026-09-27', 'Libur', '', '', 'Libur', '2026-08-31T12:14:29.094637+00:00'),
  (1353, 'WH0006', '2026-09-28', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1354, 'WH0006', '2026-09-29', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1355, 'WH0006', '2026-09-30', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1356, 'WH0007', '2026-09-01', 'Shift 3a', '12:00', '21:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1320, 'WH0005', '2026-09-25', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1321, 'WH0005', '2026-09-26', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (680, 'WH0005', '2026-08-01', 'Shift 2', '09:00', '18:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (681, 'WH0005', '2026-08-02', 'Libur', '', '', 'Libur', '2026-08-19T03:36:40.679726+00:00'),
  (682, 'WH0005', '2026-08-03', 'Shift 2', '09:00', '18:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (683, 'WH0005', '2026-08-04', 'Shift 2', '09:00', '18:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (684, 'WH0005', '2026-08-05', 'Shift 2', '09:00', '18:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (685, 'WH0005', '2026-08-06', 'Shift 2', '09:00', '18:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (686, 'WH0005', '2026-08-07', 'Shift 2', '09:00', '18:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (124, 'WH0005', '2026-08-08', 'Shift 2', '09:00', '18:00', '', '2026-08-17T13:23:14.704247+00:00')
ON CONFLICT (id) DO NOTHING;

INSERT INTO roster_shift (id, nik, tanggal, shift, jam_masuk, jam_pulang, keterangan, created_at)
VALUES
  (688, 'WH0005', '2026-08-09', 'Libur', '', '', 'Libur', '2026-08-19T03:36:40.679726+00:00'),
  (689, 'WH0005', '2026-08-10', 'Shift 2', '09:00', '18:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (690, 'WH0005', '2026-08-11', 'Shift 2', '09:00', '18:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (691, 'WH0005', '2026-08-12', 'Shift 2', '09:00', '18:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (129, 'WH0005', '2026-08-13', 'Shift 2', '09:00', '18:00', '', '2026-08-17T13:23:14.704247+00:00'),
  (130, 'WH0005', '2026-08-14', 'Shift 2', '09:00', '18:00', '', '2026-08-17T13:23:14.704247+00:00'),
  (131, 'WH0005', '2026-08-15', 'Shift 2', '09:00', '18:00', '', '2026-08-17T13:23:14.704247+00:00'),
  (132, 'WH0005', '2026-08-16', 'Libur', '', '', 'Libur', '2026-08-17T13:23:14.704247+00:00'),
  (133, 'WH0005', '2026-08-17', 'Shift 2', '09:00', '18:00', '', '2026-08-17T13:23:14.704247+00:00'),
  (134, 'WH0005', '2026-08-18', 'Shift 2', '09:00', '18:00', '', '2026-08-17T13:23:14.704247+00:00'),
  (135, 'WH0005', '2026-08-19', 'Shift 2', '09:00', '18:00', '', '2026-08-17T13:23:14.704247+00:00'),
  (136, 'WH0005', '2026-08-20', 'Shift 2', '09:00', '18:00', '', '2026-08-17T13:23:14.704247+00:00'),
  (365, 'WH0004', '2026-08-27', 'Shift 3a', '12:00', '21:00', '', '2026-08-17T13:23:58.888799+00:00'),
  (366, 'WH0004', '2026-08-28', 'Shift 3a', '12:00', '21:00', '', '2026-08-17T13:23:58.888799+00:00'),
  (367, 'WH0004', '2026-08-29', 'Shift 3b', '11:00', '20:00', '', '2026-08-17T13:23:58.888799+00:00'),
  (368, 'WH0004', '2026-08-30', 'Libur', '', '', 'Libur', '2026-08-17T13:23:58.888799+00:00'),
  (369, 'WH0004', '2026-08-31', 'Shift 3a', '12:00', '21:00', '', '2026-08-17T13:23:58.888799+00:00'),
  (1357, 'WH0007', '2026-09-02', 'Shift 3a', '12:00', '21:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1358, 'WH0007', '2026-09-03', 'Shift 3a', '12:00', '21:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1359, 'WH0007', '2026-09-04', 'Shift 3a', '12:00', '21:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1360, 'WH0007', '2026-09-05', 'Shift 3b', '11:00', '20:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1361, 'WH0007', '2026-09-06', 'Libur', '', '', 'Libur', '2026-08-31T12:14:29.094637+00:00'),
  (1362, 'WH0007', '2026-09-07', 'Shift 3a', '12:00', '21:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (199, 'WH0007', '2026-09-08', 'Shift 3a', '12:00', '21:00', '', '2026-08-17T13:23:14.844709+00:00'),
  (1364, 'WH0007', '2026-09-09', 'Shift 3a', '12:00', '21:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1365, 'WH0007', '2026-09-10', 'Shift 3a', '12:00', '21:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1366, 'WH0007', '2026-09-11', 'Shift 3a', '12:00', '21:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1367, 'WH0007', '2026-09-12', 'Shift 3b', '11:00', '20:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1368, 'WH0007', '2026-09-13', 'Libur', '', '', 'Libur', '2026-08-31T12:14:29.094637+00:00'),
  (1369, 'WH0007', '2026-09-14', 'Shift 3a', '12:00', '21:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1370, 'WH0007', '2026-09-15', 'Shift 3a', '12:00', '21:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1371, 'WH0007', '2026-09-16', 'Shift 3a', '12:00', '21:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1372, 'WH0007', '2026-09-17', 'Shift 3a', '12:00', '21:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1373, 'WH0007', '2026-09-18', 'Shift 3a', '12:00', '21:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1374, 'WH0007', '2026-09-19', 'Shift 3b', '11:00', '20:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1375, 'WH0007', '2026-09-20', 'Libur', '', '', 'Libur', '2026-08-31T12:14:29.094637+00:00'),
  (1376, 'WH0007', '2026-09-21', 'Shift 3a', '12:00', '21:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1377, 'WH0007', '2026-09-22', 'Shift 3a', '12:00', '21:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1378, 'WH0007', '2026-09-23', 'Shift 3a', '12:00', '21:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1379, 'WH0007', '2026-09-24', 'Shift 3a', '12:00', '21:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1380, 'WH0007', '2026-09-25', 'Shift 3a', '12:00', '21:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1381, 'WH0007', '2026-09-26', 'Shift 3b', '11:00', '20:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1382, 'WH0007', '2026-09-27', 'Libur', '', '', 'Libur', '2026-08-31T12:14:29.094637+00:00'),
  (1383, 'WH0007', '2026-09-28', 'Shift 3a', '12:00', '21:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1384, 'WH0007', '2026-09-29', 'Shift 3a', '12:00', '21:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1385, 'WH0007', '2026-09-30', 'Shift 3a', '12:00', '21:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1386, 'WH0008', '2026-09-01', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1387, 'WH0008', '2026-09-02', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1388, 'WH0008', '2026-09-03', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1389, 'WH0008', '2026-09-04', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1390, 'WH0008', '2026-09-05', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1391, 'WH0008', '2026-09-06', 'Libur', '', '', 'Libur', '2026-08-31T12:14:29.094637+00:00'),
  (1392, 'WH0008', '2026-09-07', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (236, 'WH0008', '2026-09-08', 'Shift 1', '08:00', '17:00', '', '2026-08-17T13:23:14.985328+00:00'),
  (1394, 'WH0008', '2026-09-09', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1395, 'WH0008', '2026-09-10', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1396, 'WH0008', '2026-09-11', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1397, 'WH0008', '2026-09-12', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1398, 'WH0008', '2026-09-13', 'Libur', '', '', 'Libur', '2026-08-31T12:14:29.094637+00:00'),
  (1399, 'WH0008', '2026-09-14', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1400, 'WH0008', '2026-09-15', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1401, 'WH0008', '2026-09-16', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1402, 'WH0008', '2026-09-17', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1403, 'WH0008', '2026-09-18', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1404, 'WH0008', '2026-09-19', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1405, 'WH0008', '2026-09-20', 'Libur', '', '', 'Libur', '2026-08-31T12:14:29.094637+00:00'),
  (1406, 'WH0008', '2026-09-21', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1407, 'WH0008', '2026-09-22', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1408, 'WH0008', '2026-09-23', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1409, 'WH0008', '2026-09-24', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1410, 'WH0008', '2026-09-25', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1411, 'WH0008', '2026-09-26', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1412, 'WH0008', '2026-09-27', 'Libur', '', '', 'Libur', '2026-08-31T12:14:29.094637+00:00'),
  (1413, 'WH0008', '2026-09-28', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1414, 'WH0008', '2026-09-29', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1415, 'WH0008', '2026-09-30', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1416, 'WH0009', '2026-09-01', 'Shift 3a', '12:00', '21:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1417, 'WH0009', '2026-09-02', 'Shift 3a', '12:00', '21:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1418, 'WH0009', '2026-09-03', 'Shift 3a', '12:00', '21:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1419, 'WH0009', '2026-09-04', 'Shift 3a', '12:00', '21:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1420, 'WH0009', '2026-09-05', 'Shift 3b', '11:00', '20:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1421, 'WH0009', '2026-09-06', 'Libur', '', '', 'Libur', '2026-08-31T12:14:29.094637+00:00'),
  (1422, 'WH0009', '2026-09-07', 'Shift 3a', '12:00', '21:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1423, 'WH0009', '2026-09-08', 'Shift 3a', '12:00', '21:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1424, 'WH0009', '2026-09-09', 'Shift 3a', '12:00', '21:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1425, 'WH0009', '2026-09-10', 'Shift 3a', '12:00', '21:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1426, 'WH0009', '2026-09-11', 'Shift 3a', '12:00', '21:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1427, 'WH0009', '2026-09-12', 'Shift 3b', '11:00', '20:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1428, 'WH0009', '2026-09-13', 'Libur', '', '', 'Libur', '2026-08-31T12:14:29.094637+00:00'),
  (1429, 'WH0009', '2026-09-14', 'Shift 3a', '12:00', '21:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1430, 'WH0009', '2026-09-15', 'Shift 3a', '12:00', '21:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1431, 'WH0009', '2026-09-16', 'Shift 3a', '12:00', '21:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1432, 'WH0009', '2026-09-17', 'Shift 3a', '12:00', '21:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1433, 'WH0009', '2026-09-18', 'Shift 3a', '12:00', '21:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1434, 'WH0009', '2026-09-19', 'Shift 3b', '11:00', '20:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1435, 'WH0009', '2026-09-20', 'Libur', '', '', 'Libur', '2026-08-31T12:14:29.094637+00:00'),
  (1436, 'WH0009', '2026-09-21', 'Shift 3a', '12:00', '21:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1437, 'WH0009', '2026-09-22', 'Shift 3a', '12:00', '21:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1438, 'WH0009', '2026-09-23', 'Shift 3a', '12:00', '21:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1439, 'WH0009', '2026-09-24', 'Shift 3a', '12:00', '21:00', '', '2026-08-31T12:14:29.094637+00:00')
ON CONFLICT (id) DO NOTHING;

INSERT INTO roster_shift (id, nik, tanggal, shift, jam_masuk, jam_pulang, keterangan, created_at)
VALUES
  (1440, 'WH0009', '2026-09-25', 'Shift 3a', '12:00', '21:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1441, 'WH0009', '2026-09-26', 'Shift 3b', '11:00', '20:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1442, 'WH0009', '2026-09-27', 'Libur', '', '', 'Libur', '2026-08-31T12:14:29.094637+00:00'),
  (1443, 'WH0009', '2026-09-28', 'Shift 3a', '12:00', '21:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1444, 'WH0009', '2026-09-29', 'Shift 3a', '12:00', '21:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1445, 'WH0009', '2026-09-30', 'Shift 3a', '12:00', '21:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1446, 'WH0010', '2026-09-01', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1447, 'WH0010', '2026-09-02', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1448, 'WH0010', '2026-09-03', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1449, 'WH0010', '2026-09-04', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1450, 'WH0010', '2026-09-05', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1451, 'WH0010', '2026-09-06', 'Libur', '', '', 'Libur', '2026-08-31T12:14:29.094637+00:00'),
  (1452, 'WH0010', '2026-09-07', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1453, 'WH0010', '2026-09-08', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1454, 'WH0010', '2026-09-09', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1455, 'WH0010', '2026-09-10', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1456, 'WH0010', '2026-09-11', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1457, 'WH0010', '2026-09-12', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1458, 'WH0010', '2026-09-13', 'Libur', '', '', 'Libur', '2026-08-31T12:14:29.094637+00:00'),
  (1459, 'WH0010', '2026-09-14', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1460, 'WH0010', '2026-09-15', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1461, 'WH0010', '2026-09-16', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1462, 'WH0010', '2026-09-17', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1463, 'WH0010', '2026-09-18', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1464, 'WH0010', '2026-09-19', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1465, 'WH0010', '2026-09-20', 'Libur', '', '', 'Libur', '2026-08-31T12:14:29.094637+00:00'),
  (1466, 'WH0010', '2026-09-21', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1467, 'WH0010', '2026-09-22', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1468, 'WH0010', '2026-09-23', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1469, 'WH0010', '2026-09-24', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1470, 'WH0010', '2026-09-25', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1471, 'WH0010', '2026-09-26', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1472, 'WH0010', '2026-09-27', 'Libur', '', '', 'Libur', '2026-08-31T12:14:29.094637+00:00'),
  (1473, 'WH0010', '2026-09-28', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1474, 'WH0010', '2026-09-29', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (1475, 'WH0010', '2026-09-30', 'Shift 1', '08:00', '17:00', '', '2026-08-31T12:14:29.094637+00:00'),
  (742, 'WH0007', '2026-08-01', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (743, 'WH0007', '2026-08-02', 'Libur', '', '', 'Libur', '2026-08-19T03:36:40.679726+00:00'),
  (744, 'WH0007', '2026-08-03', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (745, 'WH0007', '2026-08-04', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (746, 'WH0007', '2026-08-05', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (747, 'WH0007', '2026-08-06', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (748, 'WH0007', '2026-08-07', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (198, 'WH0007', '2026-08-08', 'Shift 1', '08:00', '17:00', '', '2026-08-17T13:23:14.844709+00:00'),
  (750, 'WH0007', '2026-08-09', 'Libur', '', '', 'Libur', '2026-08-19T03:36:40.679726+00:00'),
  (751, 'WH0007', '2026-08-10', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (752, 'WH0007', '2026-08-11', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (753, 'WH0007', '2026-08-12', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (203, 'WH0007', '2026-08-13', 'Shift 1', '08:00', '17:00', '', '2026-08-17T13:23:14.844709+00:00'),
  (204, 'WH0007', '2026-08-14', 'Shift 1', '08:00', '17:00', '', '2026-08-17T13:23:14.844709+00:00'),
  (205, 'WH0007', '2026-08-15', 'Shift 1', '08:00', '17:00', '', '2026-08-17T13:23:14.844709+00:00'),
  (206, 'WH0007', '2026-08-16', 'Libur', '', '', 'Libur', '2026-08-17T13:23:14.844709+00:00'),
  (207, 'WH0007', '2026-08-17', 'Shift 1', '08:00', '17:00', '', '2026-08-17T13:23:14.844709+00:00'),
  (208, 'WH0007', '2026-08-18', 'Shift 1', '08:00', '17:00', '', '2026-08-17T13:23:14.844709+00:00'),
  (209, 'WH0007', '2026-08-19', 'Shift 1', '08:00', '17:00', '', '2026-08-17T13:23:14.844709+00:00'),
  (210, 'WH0007', '2026-08-20', 'Shift 1', '08:00', '17:00', '', '2026-08-17T13:23:14.844709+00:00'),
  (211, 'WH0007', '2026-08-21', 'Shift 1', '08:00', '17:00', '', '2026-08-17T13:23:14.844709+00:00'),
  (212, 'WH0007', '2026-08-22', 'Shift 1', '08:00', '17:00', '', '2026-08-17T13:23:14.844709+00:00'),
  (213, 'WH0007', '2026-08-23', 'Libur', '', '', 'Libur', '2026-08-17T13:23:14.985328+00:00'),
  (214, 'WH0007', '2026-08-24', 'Shift 1', '08:00', '17:00', '', '2026-08-17T13:23:14.985328+00:00'),
  (215, 'WH0007', '2026-08-25', 'Shift 1', '08:00', '17:00', '', '2026-08-17T13:23:14.985328+00:00'),
  (216, 'WH0007', '2026-08-26', 'Shift 1', '08:00', '17:00', '', '2026-08-17T13:23:14.985328+00:00'),
  (217, 'WH0007', '2026-08-27', 'Shift 1', '08:00', '17:00', '', '2026-08-17T13:23:14.985328+00:00'),
  (218, 'WH0007', '2026-08-28', 'Shift 1', '08:00', '17:00', '', '2026-08-17T13:23:14.985328+00:00'),
  (219, 'WH0007', '2026-08-29', 'Shift 1', '08:00', '17:00', '', '2026-08-17T13:23:14.985328+00:00'),
  (220, 'WH0007', '2026-08-30', 'Libur', '', '', 'Libur', '2026-08-17T13:23:14.985328+00:00'),
  (221, 'WH0007', '2026-08-31', 'Shift 1', '08:00', '17:00', '', '2026-08-17T13:23:14.985328+00:00'),
  (773, 'WH0008', '2026-08-01', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (774, 'WH0008', '2026-08-02', 'Libur', '', '', 'Libur', '2026-08-19T03:36:40.679726+00:00'),
  (775, 'WH0008', '2026-08-03', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (776, 'WH0008', '2026-08-04', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (777, 'WH0008', '2026-08-05', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (778, 'WH0008', '2026-08-06', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (779, 'WH0008', '2026-08-07', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (235, 'WH0008', '2026-08-08', 'Shift 1', '08:00', '17:00', '', '2026-08-17T13:23:14.985328+00:00'),
  (781, 'WH0008', '2026-08-09', 'Libur', '', '', 'Libur', '2026-08-19T03:36:40.679726+00:00'),
  (782, 'WH0008', '2026-08-10', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (783, 'WH0008', '2026-08-11', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (784, 'WH0008', '2026-08-12', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (240, 'WH0008', '2026-08-13', 'Shift 1', '08:00', '17:00', '', '2026-08-17T13:23:14.985328+00:00'),
  (241, 'WH0008', '2026-08-14', 'Shift 1', '08:00', '17:00', '', '2026-08-17T13:23:14.985328+00:00'),
  (242, 'WH0008', '2026-08-15', 'Shift 1', '08:00', '17:00', '', '2026-08-17T13:23:14.985328+00:00'),
  (243, 'WH0008', '2026-08-16', 'Libur', '', '', 'Libur', '2026-08-17T13:23:14.985328+00:00'),
  (244, 'WH0008', '2026-08-17', 'Shift 1', '08:00', '17:00', '', '2026-08-17T13:23:14.985328+00:00'),
  (245, 'WH0008', '2026-08-18', 'Shift 1', '08:00', '17:00', '', '2026-08-17T13:23:14.985328+00:00'),
  (246, 'WH0008', '2026-08-19', 'Shift 1', '08:00', '17:00', '', '2026-08-17T13:23:14.985328+00:00'),
  (247, 'WH0008', '2026-08-20', 'Shift 1', '08:00', '17:00', '', '2026-08-17T13:23:14.985328+00:00'),
  (248, 'WH0008', '2026-08-21', 'Shift 1', '08:00', '17:00', '', '2026-08-17T13:23:14.985328+00:00'),
  (249, 'WH0008', '2026-08-22', 'Shift 1', '08:00', '17:00', '', '2026-08-17T13:23:14.985328+00:00'),
  (250, 'WH0008', '2026-08-23', 'Libur', '', '', 'Libur', '2026-08-17T13:23:14.985328+00:00'),
  (251, 'WH0008', '2026-08-24', 'Shift 1', '08:00', '17:00', '', '2026-08-17T13:23:14.985328+00:00'),
  (252, 'WH0008', '2026-08-25', 'Shift 1', '08:00', '17:00', '', '2026-08-17T13:23:14.985328+00:00'),
  (253, 'WH0008', '2026-08-26', 'Shift 1', '08:00', '17:00', '', '2026-08-17T13:23:14.985328+00:00'),
  (254, 'WH0008', '2026-08-27', 'Shift 1', '08:00', '17:00', '', '2026-08-17T13:23:14.985328+00:00'),
  (255, 'WH0008', '2026-08-28', 'Shift 1', '08:00', '17:00', '', '2026-08-17T13:23:14.985328+00:00'),
  (256, 'WH0008', '2026-08-29', 'Shift 1', '08:00', '17:00', '', '2026-08-17T13:23:14.985328+00:00'),
  (257, 'WH0008', '2026-08-30', 'Libur', '', '', 'Libur', '2026-08-17T13:23:14.985328+00:00'),
  (258, 'WH0008', '2026-08-31', 'Shift 1', '08:00', '17:00', '', '2026-08-17T13:23:14.985328+00:00'),
  (167, 'WH0006', '2026-08-14', 'Shift 1', '08:00', '17:00', '', '2026-08-17T13:23:14.844709+00:00'),
  (168, 'WH0006', '2026-08-15', 'Shift 1', '08:00', '17:00', '', '2026-08-17T13:23:14.844709+00:00')
ON CONFLICT (id) DO NOTHING;

INSERT INTO roster_shift (id, nik, tanggal, shift, jam_masuk, jam_pulang, keterangan, created_at)
VALUES
  (169, 'WH0006', '2026-08-16', 'Libur', '', '', 'Libur', '2026-08-17T13:23:14.844709+00:00'),
  (170, 'WH0006', '2026-08-17', 'Shift 1', '08:00', '17:00', '', '2026-08-17T13:23:14.844709+00:00'),
  (171, 'WH0006', '2026-08-18', 'Shift 1', '08:00', '17:00', '', '2026-08-17T13:23:14.844709+00:00'),
  (172, 'WH0006', '2026-08-19', 'Shift 1', '08:00', '17:00', '', '2026-08-17T13:23:14.844709+00:00'),
  (173, 'WH0006', '2026-08-20', 'Shift 1', '08:00', '17:00', '', '2026-08-17T13:23:14.844709+00:00'),
  (174, 'WH0006', '2026-08-21', 'Shift 1', '08:00', '17:00', '', '2026-08-17T13:23:14.844709+00:00'),
  (175, 'WH0006', '2026-08-22', 'Shift 1', '08:00', '17:00', '', '2026-08-17T13:23:14.844709+00:00'),
  (176, 'WH0006', '2026-08-23', 'Libur', '', '', 'Libur', '2026-08-17T13:23:14.844709+00:00'),
  (177, 'WH0006', '2026-08-24', 'Shift 1', '08:00', '17:00', '', '2026-08-17T13:23:14.844709+00:00'),
  (178, 'WH0006', '2026-08-25', 'Shift 1', '08:00', '17:00', '', '2026-08-17T13:23:14.844709+00:00'),
  (179, 'WH0006', '2026-08-26', 'Shift 1', '08:00', '17:00', '', '2026-08-17T13:23:14.844709+00:00'),
  (180, 'WH0006', '2026-08-27', 'Shift 1', '08:00', '17:00', '', '2026-08-17T13:23:14.844709+00:00'),
  (181, 'WH0006', '2026-08-28', 'Shift 1', '08:00', '17:00', '', '2026-08-17T13:23:14.844709+00:00'),
  (182, 'WH0006', '2026-08-29', 'Shift 1', '08:00', '17:00', '', '2026-08-17T13:23:14.844709+00:00'),
  (183, 'WH0006', '2026-08-30', 'Libur', '', '', 'Libur', '2026-08-17T13:23:14.844709+00:00'),
  (184, 'WH0006', '2026-08-31', 'Shift 1', '08:00', '17:00', '', '2026-08-17T13:23:14.844709+00:00'),
  (835, 'WH0010', '2026-08-01', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (836, 'WH0010', '2026-08-02', 'Libur', '', '', 'Libur', '2026-08-19T03:36:40.679726+00:00'),
  (837, 'WH0010', '2026-08-03', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (838, 'WH0010', '2026-08-04', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (839, 'WH0010', '2026-08-05', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (840, 'WH0010', '2026-08-06', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (841, 'WH0010', '2026-08-07', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (842, 'WH0010', '2026-08-08', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (843, 'WH0010', '2026-08-09', 'Libur', '', '', 'Libur', '2026-08-19T03:36:40.679726+00:00'),
  (844, 'WH0010', '2026-08-10', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (845, 'WH0010', '2026-08-11', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (846, 'WH0010', '2026-08-12', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (847, 'WH0010', '2026-08-13', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (848, 'WH0010', '2026-08-14', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (849, 'WH0010', '2026-08-15', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (850, 'WH0010', '2026-08-16', 'Libur', '', '', 'Libur', '2026-08-19T03:36:40.679726+00:00'),
  (851, 'WH0010', '2026-08-17', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (852, 'WH0010', '2026-08-18', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (853, 'WH0010', '2026-08-19', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (854, 'WH0010', '2026-08-20', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (855, 'WH0010', '2026-08-21', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (856, 'WH0010', '2026-08-22', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (857, 'WH0010', '2026-08-23', 'Libur', '', '', 'Libur', '2026-08-19T03:36:40.679726+00:00'),
  (858, 'WH0010', '2026-08-24', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (859, 'WH0010', '2026-08-25', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (860, 'WH0010', '2026-08-26', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (861, 'WH0010', '2026-08-27', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (862, 'WH0010', '2026-08-28', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (863, 'WH0010', '2026-08-29', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (864, 'WH0010', '2026-08-30', 'Libur', '', '', 'Libur', '2026-08-19T03:36:40.679726+00:00'),
  (865, 'WH0010', '2026-08-31', 'Shift 1', '08:00', '17:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (593, 'WH0002', '2026-08-07', 'Shift 2', '09:00', '18:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (595, 'WH0002', '2026-08-09', 'Libur', '', '', 'Libur', '2026-08-19T03:36:40.679726+00:00'),
  (596, 'WH0002', '2026-08-10', 'Shift 2', '09:00', '18:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (597, 'WH0002', '2026-08-11', 'Shift 2', '09:00', '18:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (598, 'WH0002', '2026-08-12', 'Shift 2', '09:00', '18:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (618, 'WH0003', '2026-08-01', 'Shift 2', '09:00', '18:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (619, 'WH0003', '2026-08-02', 'Libur', '', '', 'Libur', '2026-08-19T03:36:40.679726+00:00'),
  (620, 'WH0003', '2026-08-03', 'Shift 2', '09:00', '18:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (621, 'WH0003', '2026-08-04', 'Shift 2', '09:00', '18:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (622, 'WH0003', '2026-08-05', 'Shift 2', '09:00', '18:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (623, 'WH0003', '2026-08-06', 'Shift 2', '09:00', '18:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (624, 'WH0003', '2026-08-07', 'Shift 2', '09:00', '18:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (626, 'WH0003', '2026-08-09', 'Libur', '', '', 'Libur', '2026-08-19T03:36:40.679726+00:00'),
  (627, 'WH0003', '2026-08-10', 'Shift 2', '09:00', '18:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (72, 'WH0003', '2026-08-29', 'Shift 2', '09:00', '18:00', '', '2026-08-17T13:23:14.439859+00:00'),
  (73, 'WH0003', '2026-08-30', 'Libur', '', '', 'Libur', '2026-08-17T13:23:14.439859+00:00'),
  (74, 'WH0003', '2026-08-31', 'Shift 2', '09:00', '18:00', '', '2026-08-17T13:23:14.439859+00:00'),
  (137, 'WH0005', '2026-08-21', 'Shift 2', '09:00', '18:00', '', '2026-08-17T13:23:14.704247+00:00'),
  (138, 'WH0005', '2026-08-22', 'Shift 2', '09:00', '18:00', '', '2026-08-17T13:23:14.704247+00:00'),
  (139, 'WH0005', '2026-08-23', 'Libur', '', '', 'Libur', '2026-08-17T13:23:14.704247+00:00'),
  (140, 'WH0005', '2026-08-24', 'Shift 2', '09:00', '18:00', '', '2026-08-17T13:23:14.704247+00:00'),
  (141, 'WH0005', '2026-08-25', 'Shift 2', '09:00', '18:00', '', '2026-08-17T13:23:14.704247+00:00'),
  (142, 'WH0005', '2026-08-26', 'Shift 2', '09:00', '18:00', '', '2026-08-17T13:23:14.704247+00:00'),
  (143, 'WH0005', '2026-08-27', 'Shift 2', '09:00', '18:00', '', '2026-08-17T13:23:14.704247+00:00'),
  (144, 'WH0005', '2026-08-28', 'Shift 2', '09:00', '18:00', '', '2026-08-17T13:23:14.704247+00:00'),
  (145, 'WH0005', '2026-08-29', 'Shift 2', '09:00', '18:00', '', '2026-08-17T13:23:14.704247+00:00'),
  (146, 'WH0005', '2026-08-30', 'Libur', '', '', 'Libur', '2026-08-17T13:23:14.704247+00:00'),
  (147, 'WH0005', '2026-08-31', 'Shift 2', '09:00', '18:00', '', '2026-08-17T13:23:14.704247+00:00'),
  (88, 'WH0004', '2026-08-08', 'Shift 3b', '11:00', '20:00', '', '2026-08-17T13:23:14.439859+00:00'),
  (660, 'WH0004', '2026-08-12', 'Shift 3a', '12:00', '21:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (93, 'WH0004', '2026-08-13', 'Shift 3a', '12:00', '21:00', '', '2026-08-17T13:23:14.439859+00:00'),
  (94, 'WH0004', '2026-08-14', 'Shift 3a', '12:00', '21:00', '', '2026-08-17T13:23:14.439859+00:00'),
  (95, 'WH0004', '2026-08-15', 'Shift 3b', '11:00', '20:00', '', '2026-08-17T13:23:14.439859+00:00'),
  (96, 'WH0004', '2026-08-16', 'Libur', '', '', 'Libur', '2026-08-17T13:23:14.439859+00:00'),
  (97, 'WH0004', '2026-08-17', 'Shift 3a', '12:00', '21:00', '', '2026-08-17T13:23:14.439859+00:00'),
  (98, 'WH0004', '2026-08-18', 'Shift 3a', '12:00', '21:00', '', '2026-08-17T13:23:14.439859+00:00'),
  (99, 'WH0004', '2026-08-19', 'Shift 3a', '12:00', '21:00', '', '2026-08-17T13:23:14.439859+00:00'),
  (100, 'WH0004', '2026-08-20', 'Shift 3a', '12:00', '21:00', '', '2026-08-17T13:23:14.439859+00:00'),
  (359, 'WH0004', '2026-08-21', 'Shift 3a', '12:00', '21:00', '', '2026-08-17T13:23:58.888799+00:00'),
  (360, 'WH0004', '2026-08-22', 'Shift 3b', '11:00', '20:00', '', '2026-08-17T13:23:58.888799+00:00'),
  (361, 'WH0004', '2026-08-23', 'Libur', '', '', 'Libur', '2026-08-17T13:23:58.888799+00:00'),
  (362, 'WH0004', '2026-08-24', 'Shift 3a', '12:00', '21:00', '', '2026-08-17T13:23:58.888799+00:00'),
  (363, 'WH0004', '2026-08-25', 'Shift 3a', '12:00', '21:00', '', '2026-08-17T13:23:58.888799+00:00'),
  (364, 'WH0004', '2026-08-26', 'Shift 3a', '12:00', '21:00', '', '2026-08-17T13:23:58.888799+00:00'),
  (804, 'WH0009', '2026-08-01', 'Shift 3b', '11:00', '20:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (805, 'WH0009', '2026-08-02', 'Libur', '', '', 'Libur', '2026-08-19T03:36:40.679726+00:00'),
  (806, 'WH0009', '2026-08-03', 'Shift 3a', '12:00', '21:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (807, 'WH0009', '2026-08-04', 'Shift 3a', '12:00', '21:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (808, 'WH0009', '2026-08-05', 'Shift 3a', '12:00', '21:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (809, 'WH0009', '2026-08-06', 'Shift 3a', '12:00', '21:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (810, 'WH0009', '2026-08-07', 'Shift 3a', '12:00', '21:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (811, 'WH0009', '2026-08-08', 'Shift 3b', '11:00', '20:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (812, 'WH0009', '2026-08-09', 'Libur', '', '', 'Libur', '2026-08-19T03:36:40.679726+00:00')
ON CONFLICT (id) DO NOTHING;

INSERT INTO roster_shift (id, nik, tanggal, shift, jam_masuk, jam_pulang, keterangan, created_at)
VALUES
  (813, 'WH0009', '2026-08-10', 'Shift 3a', '12:00', '21:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (814, 'WH0009', '2026-08-11', 'Shift 3a', '12:00', '21:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (815, 'WH0009', '2026-08-12', 'Shift 3a', '12:00', '21:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (816, 'WH0009', '2026-08-13', 'Shift 3a', '12:00', '21:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (817, 'WH0009', '2026-08-14', 'Shift 3a', '12:00', '21:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (818, 'WH0009', '2026-08-15', 'Shift 3b', '11:00', '20:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (819, 'WH0009', '2026-08-16', 'Libur', '', '', 'Libur', '2026-08-19T03:36:40.679726+00:00'),
  (820, 'WH0009', '2026-08-17', 'Shift 3a', '12:00', '21:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (821, 'WH0009', '2026-08-18', 'Shift 3a', '12:00', '21:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (822, 'WH0009', '2026-08-19', 'Shift 3a', '12:00', '21:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (823, 'WH0009', '2026-08-20', 'Shift 3a', '12:00', '21:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (824, 'WH0009', '2026-08-21', 'Shift 3a', '12:00', '21:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (825, 'WH0009', '2026-08-22', 'Shift 3b', '11:00', '20:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (826, 'WH0009', '2026-08-23', 'Libur', '', '', 'Libur', '2026-08-19T03:36:40.679726+00:00'),
  (827, 'WH0009', '2026-08-24', 'Shift 3a', '12:00', '21:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (828, 'WH0009', '2026-08-25', 'Shift 3a', '12:00', '21:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (829, 'WH0009', '2026-08-26', 'Shift 3a', '12:00', '21:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (830, 'WH0009', '2026-08-27', 'Shift 3a', '12:00', '21:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (831, 'WH0009', '2026-08-28', 'Shift 3a', '12:00', '21:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (832, 'WH0009', '2026-08-29', 'Shift 3b', '11:00', '20:00', '', '2026-08-19T03:36:40.679726+00:00'),
  (833, 'WH0009', '2026-08-30', 'Libur', '', '', 'Libur', '2026-08-19T03:36:40.679726+00:00'),
  (834, 'WH0009', '2026-08-31', 'Shift 3a', '12:00', '21:00', '', '2026-08-19T03:36:40.679726+00:00')
ON CONFLICT (id) DO NOTHING;

-- ------------------------------------------------------------------------------
-- DATA TABEL: presensi (235 baris)
-- ------------------------------------------------------------------------------
INSERT INTO presensi (id, nik, tanggal, shift, status, jam_masuk, jam_pulang, catatan, created_at)
VALUES
  (27, 'WH0007', '2026-08-18', 'Shift 1', 'Hadir', '08:00:00', NULL, '', '2026-08-18T02:04:32.501111+00:00'),
  (28, 'WH0006', '2026-08-18', 'Shift 1', 'Hadir', '08:01:00', NULL, '', '2026-08-18T02:04:32.501111+00:00'),
  (29, 'WH0006', '2026-08-19', 'Shift 1', 'Hadir', '07:54:59', NULL, NULL, '2026-08-19T00:54:56.160032+00:00'),
  (31, 'WH0007', '2026-08-19', 'Shift 1', 'Hadir', '08:01:27', NULL, NULL, '2026-08-19T01:01:27.689886+00:00'),
  (32, 'WH0002', '2026-08-19', 'Shift 2', 'Hadir', '08:52:21', '18:00:10', NULL, '2026-08-19T01:52:21.451755+00:00'),
  (34, 'WH0004', '2026-08-19', 'Shift 3a', 'Hadir', '11:41:53', '21:00:36', NULL, '2026-08-19T04:41:54.068512+00:00'),
  (33, 'WH0009', '2026-08-19', 'Shift 3a', 'Hadir', '11:40:34', '21:02:04', NULL, '2026-08-19T04:40:35.012084+00:00'),
  (36, 'WH0005', '2026-08-20', 'Shift 2', 'Hadir', '08:56:21', '18:00:12', NULL, '2026-08-20T01:56:22.36724+00:00'),
  (35, 'WH0002', '2026-08-20', 'Shift 2', 'Hadir', '08:56:26', '18:00:18', NULL, '2026-08-20T01:56:19.933919+00:00'),
  (39, 'WH0004', '2026-08-20', 'Shift 3a', 'Hadir', '11:46:09', '21:00:13', NULL, '2026-08-20T04:46:09.989916+00:00'),
  (38, 'WH0009', '2026-08-20', 'Shift 3a', 'Hadir', '11:40:08', '21:00:13', NULL, '2026-08-20T04:40:08.819258+00:00'),
  (60, 'WH0006', '2026-08-24', 'Shift 1', 'Hadir', '07:53:29', '17:00:07', NULL, '2026-08-24T00:53:30.059037+00:00'),
  (61, 'WH0007', '2026-08-24', 'Shift 1', 'Hadir', '07:53:54', '17:01:18', NULL, '2026-08-24T00:53:54.167833+00:00'),
  (62, 'WH0008', '2026-08-24', 'Shift 1', 'Hadir', '08:05:26', '17:07:50', NULL, '2026-08-24T01:05:26.799129+00:00'),
  (40, 'WH0006', '2026-08-21', 'Shift 1', 'Hadir', '07:48:53', '17:00:02', NULL, '2026-08-21T00:48:53.314077+00:00'),
  (43, 'WH0003', '2026-08-21', 'Shift 2', 'Hadir', '08:55:20', '18:00:55', NULL, '2026-08-21T01:54:07.023269+00:00'),
  (42, 'WH0005', '2026-08-21', 'Shift 2', 'Hadir', '08:53:14', '18:00:02', NULL, '2026-08-21T01:53:15.214068+00:00'),
  (41, 'WH0002', '2026-08-21', 'Shift 2', 'Hadir', '08:53:11', '18:00:13', NULL, '2026-08-21T01:53:11.549616+00:00'),
  (45, 'WH0004', '2026-08-21', 'Shift 3a', 'Hadir', '11:42:37', '21:00:40', NULL, '2026-08-21T04:41:51.840017+00:00'),
  (44, 'WH0009', '2026-08-21', 'Shift 3a', 'Hadir', '11:40:09', '21:01:00', NULL, '2026-08-21T04:40:10.748686+00:00'),
  (51, 'WH0006', '2026-08-22', 'Shift 1', 'Hadir', '07:56:09', '17:00:52', NULL, '2026-08-22T00:56:09.686026+00:00'),
  (52, 'WH0007', '2026-08-22', 'Shift 1', 'Hadir', '07:56:19', '17:01:21', NULL, '2026-08-22T00:56:20.005177+00:00'),
  (58, 'WH0003', '2026-08-22', 'Shift 2', 'Hadir', '08:54:00', '18:00:51', NULL, '2026-08-22T01:52:46.204557+00:00'),
  (79, 'WH0005', '2026-08-27', 'Shift 2', 'Hadir', '07:50:17', '17:00:23', NULL, '2026-08-27T00:50:17.528627+00:00'),
  (67, 'WH0004', '2026-08-24', 'Shift 3a', 'Hadir', '11:46:48', '21:00:20', NULL, '2026-08-24T04:46:48.979923+00:00'),
  (66, 'WH0009', '2026-08-24', 'Shift 3a', 'Hadir', '11:45:28', '21:01:06', NULL, '2026-08-24T04:45:29.060064+00:00'),
  (54, 'WH0004', '2026-08-22', 'Shift 2', 'Hadir', '08:48:57', '18:00:08', NULL, '2026-08-22T01:47:21.329644+00:00'),
  (55, 'WH0002', '2026-08-22', 'Shift 2', 'Hadir', '08:47:22', '18:00:12', NULL, '2026-08-22T01:47:22.428064+00:00'),
  (78, 'WH0006', '2026-08-27', 'Shift 1', 'Hadir', '07:49:58', '17:00:43', NULL, '2026-08-27T00:49:59.156102+00:00'),
  (64, 'WH0005', '2026-08-24', 'Shift 2', 'Hadir', '08:45:00', '18:00:00', '', '2026-08-24T01:45:13.955348+00:00'),
  (63, 'WH0002', '2026-08-24', 'Shift 2', 'Hadir', '08:45:00', '18:00:00', '', '2026-08-24T01:45:09.174412+00:00'),
  (57, 'WH0005', '2026-08-22', 'Shift 2', 'Hadir', '08:52:00', '18:00:00', '', '2026-08-22T01:52:25.745143+00:00'),
  (82, 'WH0003', '2026-08-27', 'Shift 2', 'Hadir', '08:41:43', '18:02:16', NULL, '2026-08-27T01:40:24.133923+00:00'),
  (68, 'WH0006', '2026-08-25', 'Shift 1', 'Hadir', '07:58:20', NULL, NULL, '2026-08-25T00:58:20.918666+00:00'),
  (69, 'WH0007', '2026-08-25', 'Shift 1', 'Hadir', '07:58:55', NULL, NULL, '2026-08-25T00:58:55.49262+00:00'),
  (70, 'WH0005', '2026-08-25', 'Shift 2', 'Hadir', '08:50:17', NULL, NULL, '2026-08-25T01:50:18.007054+00:00'),
  (71, 'WH0002', '2026-08-25', 'Shift 2', 'Hadir', '08:50:29', NULL, NULL, '2026-08-25T01:50:29.427516+00:00'),
  (72, 'WH0003', '2026-08-25', 'Shift 2', 'Hadir', '08:52:23', NULL, NULL, '2026-08-25T01:51:07.010101+00:00'),
  (86, 'WH0009', '2026-08-27', 'Shift 3a', 'Hadir', '11:45:18', '21:05:08', NULL, '2026-08-27T04:45:20.604833+00:00'),
  (87, 'WH0004', '2026-08-27', 'Shift 3a', 'Hadir', '11:46:09', '21:09:20', NULL, '2026-08-27T04:46:10.687056+00:00'),
  (73, 'WH0009', '2026-08-25', 'Shift 3b', 'Hadir', '10:49:00', NULL, '', '2026-08-25T03:49:08.780869+00:00'),
  (74, 'WH0004', '2026-08-25', 'Shift 3b', 'Hadir', '10:50:00', NULL, '', '2026-08-25T03:50:38.446861+00:00'),
  (65, 'WH0003', '2026-08-24', 'Shift 2', 'Hadir', '08:49:00', '18:00:00', '', '2026-08-24T01:48:05.915878+00:00'),
  (53, 'WH0009', '2026-08-22', 'Shift 2', 'Hadir', '09:00:00', '18:00:00', '', '2026-08-22T01:46:58.165957+00:00'),
  (88, 'WH0006', '2026-08-28', 'Shift 1', 'Hadir', '07:53:48', NULL, NULL, '2026-08-28T00:53:49.259877+00:00'),
  (24, 'WH0002', '2026-08-17', 'Shift 2', 'Hadir', '09:00:00', '18:00:00', '', '2026-08-18T02:04:32.501111+00:00'),
  (108, 'WH0009', '2026-08-31', 'Shift 3a', 'Hadir', '11:46:52', '21:00:56', NULL, '2026-08-31T04:46:53.941871+00:00'),
  (25, 'WH0009', '2026-08-17', 'Shift 3a', 'Hadir', '12:00:00', '21:00:00', '', '2026-08-18T02:04:32.501111+00:00'),
  (100, 'WH0002', '2026-08-29', 'Shift 2', 'Hadir', '08:53:50', NULL, NULL, '2026-08-29T01:53:51.180471+00:00'),
  (90, 'WH0008', '2026-08-28', 'Shift 1', 'Hadir', '08:01:58', NULL, NULL, '2026-08-28T01:01:59.18369+00:00'),
  (98, 'WH0008', '2026-08-29', 'Shift 1', 'Hadir', '08:00:21', '17:00:01', NULL, '2026-08-29T01:00:21.704611+00:00'),
  (89, 'WH0007', '2026-08-28', 'Shift 1', 'Hadir', '08:00:29', '17:00:30', NULL, '2026-08-28T01:00:29.40084+00:00'),
  (96, 'WH0005', '2026-08-29', 'Shift 2', 'Hadir', '07:55:19', '17:01:12', NULL, '2026-08-29T00:55:19.766545+00:00'),
  (80, 'WH0002', '2026-08-27', 'Shift 2', 'Hadir', '08:41:00', '18:00:00', '', '2026-08-27T01:40:13.893761+00:00'),
  (75, 'WH0002', '2026-08-26', 'Shift 2', 'Hadir', '08:10:00', '18:00:00', '', '2026-08-26T10:10:43.191473+00:00'),
  (77, 'WH0009', '2026-08-26', 'Shift 3a', 'Hadir', '08:03:00', '21:01:00', '', '2026-08-26T11:03:42.632508+00:00'),
  (76, 'WH0005', '2026-08-26', 'Shift 2', 'Hadir', '08:12:00', '18:00:00', '', '2026-08-26T10:12:21.318064+00:00'),
  (97, 'WH0006', '2026-08-29', 'Shift 1', 'Hadir', '07:55:46', '17:02:17', NULL, '2026-08-29T00:55:46.628789+00:00'),
  (92, 'WH0005', '2026-08-28', 'Shift 2', 'Hadir', '08:51:06', '18:00:01', NULL, '2026-08-28T01:51:06.929448+00:00'),
  (93, 'WH0002', '2026-08-28', 'Shift 2', 'Hadir', '08:51:00', '18:00:03', '', '2026-08-28T01:51:29.023274+00:00'),
  (23, 'WH0003', '2026-08-17', 'Shift 2', 'Hadir', '09:02:00', '18:01:00', '', '2026-08-18T02:04:32.501111+00:00'),
  (94, 'WH0004', '2026-08-28', 'Shift 3a', 'Hadir', '11:50:55', '21:00:45', NULL, '2026-08-28T04:50:56.187662+00:00'),
  (99, 'WH0003', '2026-08-29', 'Shift 2', 'Hadir', '08:54:56', '18:01:34', NULL, '2026-08-29T01:53:37.09213+00:00'),
  (102, 'WH0009', '2026-08-29', 'Shift 3b', 'Hadir', '10:53:12', '20:04:46', NULL, '2026-08-29T03:53:13.587015+00:00'),
  (101, 'WH0004', '2026-08-29', 'Shift 3b', 'Hadir', '10:50:49', '20:05:01', NULL, '2026-08-29T03:50:50.304369+00:00'),
  (106, 'WH0005', '2026-08-31', 'Shift 2', 'Hadir', '08:50:04', NULL, NULL, '2026-08-31T01:50:05.12104+00:00'),
  (105, 'WH0008', '2026-08-31', 'Shift 1', 'Hadir', '07:59:22', '17:00:19', NULL, '2026-08-31T00:59:22.278453+00:00'),
  (103, 'WH0006', '2026-08-31', 'Shift 1', 'Hadir', '07:51:20', '17:01:36', NULL, '2026-08-31T00:51:20.864426+00:00'),
  (104, 'WH0007', '2026-08-31', 'Shift 1', 'Hadir', '07:51:30', '17:01:39', NULL, '2026-08-31T00:51:31.504392+00:00'),
  (107, 'WH0002', '2026-08-31', 'Shift 2', 'Hadir', '08:50:22', '18:02:06', NULL, '2026-08-31T01:50:22.71274+00:00'),
  (91, 'WH0003', '2026-08-28', 'Shift 2', 'Hadir', '08:01:00', '18:01:00', '', '2026-08-28T01:50:53.066919+00:00'),
  (26, 'WH0008', '2026-08-17', 'Shift 1', 'Hadir', '07:29:00', '17:29:00', '', '2026-08-18T02:04:32.501111+00:00'),
  (22, 'WH0005', '2026-08-17', 'Shift 2', 'Hadir', '09:00:00', '18:00:00', '', '2026-08-18T02:04:32.501111+00:00'),
  (109, 'WH0004', '2026-08-31', 'Shift 3a', 'Hadir', '11:50:00', '21:00:27', '', '2026-08-31T04:50:50.549152+00:00'),
  (113, 'WH0008', '2026-09-01', 'Shift 1', 'Hadir', '08:00:13', NULL, NULL, '2026-09-01T01:00:13.537491+00:00'),
  (111, 'WH0006', '2026-09-01', 'Shift 1', 'Hadir', '07:45:30', '17:04:08', NULL, '2026-09-01T00:45:30.773945+00:00'),
  (115, 'WH0005', '2026-09-01', 'Shift 2', 'Hadir', '08:49:19', '18:00:25', NULL, '2026-09-01T01:49:19.642619+00:00'),
  (117, 'WH0009', '2026-09-01', 'Shift 3a', 'Terlambat', '12:08:45', '21:01:07', NULL, '2026-09-01T05:08:45.948058+00:00'),
  (112, 'WH0004', '2026-09-01', 'Shift 1', 'Hadir', '07:45:55', '21:02:13', NULL, '2026-09-01T00:45:56.953029+00:00'),
  (114, 'WH0002', '2026-09-01', 'Shift 2', 'Hadir', '08:20:36', '21:03:07', NULL, '2026-09-01T01:20:36.952261+00:00'),
  (118, 'WH0006', '2026-09-02', 'Shift 1', 'Hadir', '07:49:00', NULL, NULL, '2026-09-02T00:49:00.125714+00:00'),
  (116, 'WH0007', '2026-09-01', 'Shift 3a', 'Hadir', '12:00:00', NULL, '', '2026-09-01T05:08:18.120125+00:00'),
  (122, 'WH0005', '2026-09-02', 'Shift 2', 'Hadir', '08:47:36', '18:00:13', NULL, '2026-09-02T01:47:36.52533+00:00'),
  (121, 'WH0002', '2026-09-02', 'Shift 2', 'Hadir', '08:39:19', '18:00:18', NULL, '2026-09-02T01:39:19.614124+00:00'),
  (119, 'WH0004', '2026-09-02', 'Shift 1', 'Hadir', '07:50:17', '20:10:53', NULL, '2026-09-02T00:50:14.568564+00:00'),
  (123, 'WH0003', '2026-09-02', 'Shift 2', 'Hadir', '08:54:04', '18:01:27', NULL, '2026-09-02T01:52:41.95134+00:00'),
  (124, 'WH0009', '2026-09-02', 'Shift 3a', 'Hadir', '11:52:45', '21:00:53', NULL, '2026-09-02T04:52:50.712386+00:00'),
  (174, 'WH0008', '2026-09-09', 'Shift 1', 'Hadir', '07:50:44', NULL, NULL, '2026-09-09T00:50:44.60058+00:00'),
  (128, 'WH0008', '2026-09-03', 'Shift 1', 'Hadir', '08:05:18', NULL, NULL, '2026-09-03T01:05:18.266044+00:00'),
  (126, 'WH0004', '2026-09-03', 'Shift 1', 'Hadir', '07:41:05', '17:01:02', NULL, '2026-09-03T00:41:03.155199+00:00'),
  (125, 'WH0006', '2026-09-03', 'Shift 1', 'Hadir', '07:40:52', '17:02:59', NULL, '2026-09-03T00:40:52.466093+00:00'),
  (130, 'WH0005', '2026-09-03', 'Shift 2', 'Hadir', '08:59:27', '18:00:19', NULL, '2026-09-03T01:59:27.3177+00:00'),
  (131, 'WH0003', '2026-09-03', 'Shift 2', 'Hadir', '09:04:08', '18:01:57', NULL, '2026-09-03T02:02:45.506117+00:00'),
  (129, 'WH0002', '2026-09-03', 'Shift 2', 'Hadir', '08:41:14', '18:01:08', NULL, '2026-09-03T01:41:14.845014+00:00'),
  (132, 'WH0009', '2026-09-03', 'Shift 3a', 'Hadir', '11:43:08', '21:00:30', NULL, '2026-09-03T04:43:08.912773+00:00'),
  (136, 'WH0003', '2026-09-04', 'Shift 2', 'Hadir', '08:39:08', NULL, NULL, '2026-09-04T01:37:45.315814+00:00'),
  (138, 'WH0002', '2026-09-04', 'Shift 2', 'Hadir', '08:52:42', NULL, NULL, '2026-09-04T01:52:42.430065+00:00'),
  (134, 'WH0004', '2026-09-04', 'Shift 1', 'Hadir', '07:55:42', '17:01:18', NULL, '2026-09-04T00:55:42.456623+00:00'),
  (133, 'WH0006', '2026-09-04', 'Shift 1', 'Hadir', '07:55:37', '17:02:13', NULL, '2026-09-04T00:55:38.016324+00:00'),
  (135, 'WH0008', '2026-09-04', 'Shift 1', 'Hadir', '08:01:03', '17:06:16', NULL, '2026-09-04T01:01:03.247011+00:00')
ON CONFLICT (id) DO NOTHING;

INSERT INTO presensi (id, nik, tanggal, shift, status, jam_masuk, jam_pulang, catatan, created_at)
VALUES
  (137, 'WH0005', '2026-09-04', 'Shift 2', 'Hadir', '08:52:27', '18:00:31', NULL, '2026-09-04T01:52:27.474248+00:00'),
  (139, 'WH0007', '2026-09-04', 'Shift 3a', 'Hadir', '11:43:14', '21:16:09', NULL, '2026-09-04T04:43:14.94301+00:00'),
  (140, 'WH0009', '2026-09-04', 'Shift 3a', 'Hadir', '11:43:48', '21:16:58', NULL, '2026-09-04T04:43:48.534141+00:00'),
  (147, 'WH0009', '2026-09-05', 'Shift 3b', 'Hadir', '10:44:29', NULL, NULL, '2026-09-05T03:44:29.225374+00:00'),
  (148, 'WH0007', '2026-09-05', 'Shift 3b', 'Hadir', '10:44:29', NULL, NULL, '2026-09-05T03:44:29.362037+00:00'),
  (143, 'WH0008', '2026-09-05', 'Shift 1', 'Hadir', '08:02:33', '17:00:09', NULL, '2026-09-05T01:02:30.185419+00:00'),
  (141, 'WH0004', '2026-09-05', 'Shift 1', 'Hadir', '07:53:04', '17:00:44', NULL, '2026-09-05T00:53:05.508534+00:00'),
  (142, 'WH0006', '2026-09-05', 'Shift 1', 'Hadir', '07:53:37', '17:01:40', NULL, '2026-09-05T00:53:37.217348+00:00'),
  (145, 'WH0002', '2026-09-05', 'Shift 2', 'Hadir', '08:50:43', '18:02:28', NULL, '2026-09-05T01:50:43.525029+00:00'),
  (146, 'WH0005', '2026-09-05', 'Shift 2', 'Hadir', '08:51:24', '18:03:20', NULL, '2026-09-05T01:51:24.547753+00:00'),
  (175, 'WH0005', '2026-09-09', 'Shift 2', 'Hadir', '07:53:11', '17:00:02', NULL, '2026-09-09T00:53:11.438837+00:00'),
  (172, 'WH0004', '2026-09-09', 'Shift 1', 'Hadir', '07:45:53', '17:00:04', NULL, '2026-09-09T00:45:53.861689+00:00'),
  (173, 'WH0006', '2026-09-09', 'Shift 1', 'Hadir', '07:46:10', '17:00:09', NULL, '2026-09-09T00:46:10.943723+00:00'),
  (190, 'WH0006', '2026-09-11', 'Shift 1', 'Hadir', '07:45:47', '17:02:27', NULL, '2026-09-11T00:45:48.528636+00:00'),
  (150, 'WH0004', '2026-09-07', 'Shift 1', 'Hadir', '07:48:32', '17:01:07', NULL, '2026-09-07T00:48:27.673626+00:00'),
  (149, 'WH0006', '2026-09-07', 'Shift 1', 'Hadir', '07:47:21', '17:01:39', NULL, '2026-09-07T00:47:21.880763+00:00'),
  (154, 'WH0003', '2026-09-07', 'Shift 2', 'Hadir', '08:53:36', '18:01:06', NULL, '2026-09-07T01:51:48.629593+00:00'),
  (153, 'WH0005', '2026-09-07', 'Shift 2', 'Hadir', '08:48:59', '18:00:05', NULL, '2026-09-07T01:48:59.620679+00:00'),
  (158, 'WH0002', '2026-09-07', 'Shift 2', 'Hadir', '08:51:58', '18:00:08', NULL, '2026-09-07T01:51:59.064278+00:00'),
  (162, 'WH0007', '2026-09-07', 'Shift 3a', 'Hadir', '11:44:29', '21:02:54', NULL, '2026-09-07T04:44:30.046016+00:00'),
  (165, 'WH0008', '2026-09-08', 'Shift 1', 'Hadir', '08:00:57', '17:00:24', NULL, '2026-09-08T01:00:57.90665+00:00'),
  (164, 'WH0006', '2026-09-08', 'Shift 1', 'Hadir', '07:46:21', '17:01:53', NULL, '2026-09-08T00:46:21.32579+00:00'),
  (163, 'WH0004', '2026-09-08', 'Shift 1', 'Hadir', '07:46:01', '17:02:45', NULL, '2026-09-08T00:46:01.754571+00:00'),
  (166, 'WH0005', '2026-09-08', 'Shift 2', 'Hadir', '08:47:46', '18:00:03', NULL, '2026-09-08T01:47:46.205839+00:00'),
  (176, 'WH0003', '2026-09-09', 'Shift 2', 'Hadir', '07:56:52', '17:01:43', NULL, '2026-09-09T00:55:25.669072+00:00'),
  (188, 'WH0008', '2026-09-11', 'Shift 1', 'Hadir', '07:41:52', '18:02:58', NULL, '2026-09-11T00:41:52.770223+00:00'),
  (168, 'WH0003', '2026-09-08', 'Shift 2', 'Hadir', '08:49:59', '18:02:10', NULL, '2026-09-08T01:48:32.627242+00:00'),
  (169, 'WH0007', '2026-09-08', 'Shift 3a', 'Hadir', '11:47:24', '21:01:05', NULL, '2026-09-08T04:47:25.19633+00:00'),
  (170, 'WH0009', '2026-09-08', 'Shift 3a', 'Hadir', '11:47:31', '21:08:14', NULL, '2026-09-08T04:47:32.039861+00:00'),
  (177, 'WH0002', '2026-09-09', 'Shift 2', 'Hadir', '08:50:26', '18:01:13', NULL, '2026-09-09T01:50:26.892028+00:00'),
  (178, 'WH0009', '2026-09-09', 'Shift 3a', 'Hadir', '11:52:57', '21:00:16', NULL, '2026-09-09T04:52:57.305289+00:00'),
  (167, 'WH0002', '2026-09-08', 'Shift 2', 'Hadir', '09:00:00', '18:00:00', '', '2026-09-08T01:48:01.569519+00:00'),
  (161, 'WH0009', '2026-09-07', 'Shift 3a', 'Hadir', '11:44:00', '21:05:00', '', '2026-09-07T04:44:08.752144+00:00'),
  (152, 'WH0008', '2026-09-07', 'Shift 1', 'Hadir', '08:00:00', '17:00:00', '', '2026-09-07T01:06:56.229254+00:00'),
  (193, 'WH0002', '2026-09-11', 'Shift 1', 'Terlambat', '08:55:12', '18:05:06', NULL, '2026-09-11T01:55:06.554912+00:00'),
  (184, 'WH0002', '2026-09-10', 'Shift 2', 'Hadir', '08:48:16', NULL, NULL, '2026-09-10T01:48:16.924939+00:00'),
  (185, 'WH0003', '2026-09-10', 'Shift 2', 'Hadir', '08:49:45', NULL, NULL, '2026-09-10T01:48:18.611566+00:00'),
  (179, 'WH0006', '2026-09-10', 'Shift 1', 'Hadir', '07:49:06', '17:04:20', NULL, '2026-09-10T00:49:06.837181+00:00'),
  (180, 'WH0005', '2026-09-10', 'Shift 2', 'Hadir', '07:49:49', '18:02:41', NULL, '2026-09-10T00:49:49.151554+00:00'),
  (183, 'WH0008', '2026-09-10', 'Shift 1', 'Hadir', '08:02:35', '19:02:12', NULL, '2026-09-10T01:02:35.193022+00:00'),
  (181, 'WH0004', '2026-09-10', 'Shift 1', 'Hadir', '07:50:43', '19:08:03', NULL, '2026-09-10T00:50:25.32428+00:00'),
  (187, 'WH0007', '2026-09-10', 'Shift 3a', 'Hadir', '11:48:17', '21:00:43', NULL, '2026-09-10T04:48:17.537598+00:00'),
  (186, 'WH0009', '2026-09-10', 'Shift 3a', 'Hadir', '11:44:30', '21:01:32', NULL, '2026-09-10T04:44:30.698151+00:00'),
  (189, 'WH0004', '2026-09-11', 'Shift 1', 'Hadir', '07:42:24', NULL, NULL, '2026-09-11T00:42:25.55982+00:00'),
  (203, 'WH0007', '2026-09-12', 'Shift 3b', 'Hadir', '10:47:30', '20:01:04', NULL, '2026-09-12T03:47:30.596515+00:00'),
  (191, 'WH0005', '2026-09-11', 'Shift 2', 'Hadir', '07:51:15', '17:00:23', NULL, '2026-09-11T00:51:15.257837+00:00'),
  (192, 'WH0003', '2026-09-11', 'Shift 2', 'Hadir', '08:56:19', '18:06:36', NULL, '2026-09-11T01:54:50.463366+00:00'),
  (196, 'WH0009', '2026-09-11', 'Shift 3a', 'Hadir', '11:44:47', '21:01:01', NULL, '2026-09-11T04:44:49.138335+00:00'),
  (195, 'WH0007', '2026-09-11', 'Shift 3a', 'Hadir', '11:44:13', '21:01:17', NULL, '2026-09-11T04:44:13.384873+00:00'),
  (200, 'WH0002', '2026-09-12', 'Shift 2', 'Hadir', '08:46:10', NULL, NULL, '2026-09-12T01:46:10.175473+00:00'),
  (197, 'WH0004', '2026-09-12', 'Shift 1', 'Hadir', '07:48:38', '17:01:03', NULL, '2026-09-12T00:48:39.68955+00:00'),
  (199, 'WH0008', '2026-09-12', 'Shift 1', 'Hadir', '08:00:50', '17:01:06', NULL, '2026-09-12T01:00:51.134071+00:00'),
  (198, 'WH0006', '2026-09-12', 'Shift 1', 'Hadir', '07:56:20', '17:02:11', NULL, '2026-09-12T00:56:20.785719+00:00'),
  (201, 'WH0005', '2026-09-12', 'Shift 2', 'Hadir', '08:46:11', '18:05:11', NULL, '2026-09-12T01:46:11.968121+00:00'),
  (202, 'WH0009', '2026-09-12', 'Shift 3b', 'Hadir', '10:47:22', '20:01:29', NULL, '2026-09-12T03:47:22.069796+00:00'),
  (206, 'WH0008', '2026-09-14', 'Shift 1', 'Terlambat', '08:07:39', '17:00:05', NULL, '2026-09-14T01:07:39.130628+00:00'),
  (205, 'WH0004', '2026-09-14', 'Shift 1', 'Hadir', '07:49:59', '17:00:12', NULL, '2026-09-14T00:50:00.278859+00:00'),
  (204, 'WH0006', '2026-09-14', 'Shift 1', 'Hadir', '07:49:58', '17:01:24', NULL, '2026-09-14T00:49:58.437597+00:00'),
  (208, 'WH0005', '2026-09-14', 'Shift 2', 'Hadir', '08:50:07', '18:00:06', NULL, '2026-09-14T01:50:08.319471+00:00'),
  (207, 'WH0002', '2026-09-14', 'Shift 2', 'Hadir', '08:46:33', '18:00:16', NULL, '2026-09-14T01:46:33.133761+00:00'),
  (209, 'WH0003', '2026-09-14', 'Shift 2', 'Hadir', '09:00:46', '18:01:41', NULL, '2026-09-14T01:59:17.249757+00:00'),
  (211, 'WH0007', '2026-09-14', 'Shift 3a', 'Hadir', '11:46:09', '21:00:27', NULL, '2026-09-14T04:46:09.657316+00:00'),
  (210, 'WH0009', '2026-09-14', 'Shift 3a', 'Hadir', '11:46:12', '21:00:56', NULL, '2026-09-14T04:45:43.870814+00:00'),
  (215, 'WH0008', '2026-09-15', 'Shift 1', 'Hadir', '08:01:30', '17:00:04', NULL, '2026-09-15T01:01:30.563717+00:00'),
  (213, 'WH0006', '2026-09-15', 'Shift 1', 'Hadir', '07:48:29', '17:02:33', NULL, '2026-09-15T00:48:30.398536+00:00'),
  (214, 'WH0004', '2026-09-15', 'Shift 1', 'Terlambat', '17:01:06', '17:01:11', NULL, '2026-09-15T00:50:00.642005+00:00'),
  (216, 'WH0005', '2026-09-15', 'Shift 2', 'Hadir', '08:45:16', '18:00:23', NULL, '2026-09-15T01:45:16.268373+00:00'),
  (217, 'WH0002', '2026-09-15', 'Shift 2', 'Hadir', '08:45:23', '18:03:41', NULL, '2026-09-15T01:45:24.043782+00:00'),
  (218, 'WH0007', '2026-09-15', 'Shift 3a', 'Hadir', '11:47:30', '21:02:19', NULL, '2026-09-15T04:47:30.957993+00:00'),
  (219, 'WH0009', '2026-09-15', 'Shift 3a', 'Hadir', '11:51:32', '21:18:18', NULL, '2026-09-15T04:51:34.094462+00:00'),
  (264, 'WH0004', '2026-09-22', 'Shift 1', 'Hadir', '07:51:01', '17:06:23', NULL, '2026-09-22T00:51:01.834388+00:00'),
  (268, 'WH0007', '2026-09-22', 'Shift 3a', 'Hadir', '11:44:15', '21:00:15', NULL, '2026-09-22T04:44:15.469066+00:00'),
  (222, 'WH0006', '2026-09-16', 'Shift 1', 'Hadir', '07:57:11', '07:54:04', NULL, '2026-09-16T00:50:40.084486+00:00'),
  (225, 'WH0008', '2026-09-16', 'Shift 1', 'Hadir', '08:00:39', NULL, NULL, '2026-09-16T01:00:39.505889+00:00'),
  (221, 'WH0004', '2026-09-16', 'Shift 1', 'Hadir', '07:46:17', '17:02:24', NULL, '2026-09-16T00:46:17.401639+00:00'),
  (228, 'WH0003', '2026-09-16', 'Shift 2', 'Hadir', '09:00:02', '18:01:11', NULL, '2026-09-16T01:58:31.604077+00:00'),
  (227, 'WH0005', '2026-09-16', 'Shift 2', 'Hadir', '08:46:28', '18:00:02', NULL, '2026-09-16T01:46:29.323985+00:00'),
  (270, 'WH0005', '2026-09-22', 'Shift 2', 'Terlambat', '11:51:03', '21:00:24', NULL, '2026-09-22T04:51:03.166098+00:00'),
  (269, 'WH0009', '2026-09-22', 'Shift 3a', 'Hadir', '11:45:16', '21:00:57', NULL, '2026-09-22T04:45:17.803663+00:00'),
  (226, 'WH0002', '2026-09-16', 'Shift 2', 'Hadir', '08:46:24', '18:00:35', NULL, '2026-09-16T01:46:24.485426+00:00'),
  (229, 'WH0007', '2026-09-16', 'Shift 3a', 'Hadir', '11:38:52', '21:00:38', NULL, '2026-09-16T04:38:52.956859+00:00'),
  (230, 'WH0009', '2026-09-16', 'Shift 3a', 'Hadir', '11:41:46', '21:01:32', NULL, '2026-09-16T04:41:47.092705+00:00'),
  (232, 'WH0004', '2026-09-17', 'Shift 1', 'Hadir', '07:54:51', '17:01:51', NULL, '2026-09-17T00:54:56.764911+00:00'),
  (231, 'WH0006', '2026-09-17', 'Shift 1', 'Hadir', '07:53:22', '17:02:03', NULL, '2026-09-17T00:53:23.027767+00:00'),
  (235, 'WH0003', '2026-09-17', 'Shift 2', 'Hadir', '08:49:55', '18:01:13', NULL, '2026-09-17T01:48:25.20998+00:00'),
  (234, 'WH0002', '2026-09-17', 'Shift 2', 'Hadir', '08:48:15', '18:00:19', NULL, '2026-09-17T01:48:15.228297+00:00'),
  (233, 'WH0005', '2026-09-17', 'Shift 2', 'Hadir', '08:47:58', '18:01:02', NULL, '2026-09-17T01:47:58.996354+00:00'),
  (236, 'WH0007', '2026-09-17', 'Shift 3a', 'Hadir', '11:43:24', '21:00:46', NULL, '2026-09-17T04:43:24.952492+00:00'),
  (237, 'WH0009', '2026-09-17', 'Shift 3a', 'Hadir', '11:43:28', '21:00:56', NULL, '2026-09-17T04:43:28.934797+00:00'),
  (239, 'WH0004', '2026-09-18', 'Shift 1', 'Hadir', '07:51:57', '17:00:37', NULL, '2026-09-18T00:51:58.564158+00:00'),
  (238, 'WH0006', '2026-09-18', 'Shift 1', 'Hadir', '07:51:12', '17:00:43', NULL, '2026-09-18T00:51:12.595218+00:00'),
  (240, 'WH0008', '2026-09-18', 'Shift 1', 'Hadir', '08:01:30', '17:01:09', NULL, '2026-09-18T01:01:30.840673+00:00'),
  (242, 'WH0003', '2026-09-18', 'Shift 2', 'Hadir', '08:56:32', '18:05:22', NULL, '2026-09-18T01:55:02.563265+00:00'),
  (241, 'WH0002', '2026-09-18', 'Shift 2', 'Hadir', '08:50:04', '18:03:53', NULL, '2026-09-18T01:50:04.974247+00:00'),
  (245, 'WH0009', '2026-09-18', 'Shift 3a', 'Hadir', '11:49:09', '21:00:06', NULL, '2026-09-18T04:49:10.705232+00:00'),
  (244, 'WH0007', '2026-09-18', 'Shift 3a', 'Hadir', '11:48:59', '21:00:18', NULL, '2026-09-18T04:48:59.716117+00:00'),
  (243, 'WH0005', '2026-09-18', 'Shift 2', 'Terlambat', '11:48:26', '21:04:06', NULL, '2026-09-18T04:48:26.257693+00:00'),
  (247, 'WH0005', '2026-09-19', 'Shift 2', 'Hadir', '07:58:12', NULL, NULL, '2026-09-19T00:58:14.216519+00:00'),
  (272, 'WH0004', '2026-09-23', 'Shift 1', 'Hadir', '07:51:11', NULL, NULL, '2026-09-23T00:51:12.721797+00:00'),
  (251, 'WH0003', '2026-09-19', 'Shift 2', 'Hadir', '08:44:57', NULL, NULL, '2026-09-19T01:43:27.313933+00:00')
ON CONFLICT (id) DO NOTHING;

INSERT INTO presensi (id, nik, tanggal, shift, status, jam_masuk, jam_pulang, catatan, created_at)
VALUES
  (252, 'WH0002', '2026-09-19', 'Shift 2', 'Hadir', '08:43:36', NULL, NULL, '2026-09-19T01:43:36.570312+00:00'),
  (248, 'WH0004', '2026-09-19', 'Shift 1', 'Hadir', '07:58:39', '17:02:04', NULL, '2026-09-19T00:58:36.903907+00:00'),
  (250, 'WH0008', '2026-09-19', 'Shift 1', 'Hadir', '08:00:38', '17:02:08', NULL, '2026-09-19T01:00:40.561693+00:00'),
  (246, 'WH0006', '2026-09-19', 'Shift 1', 'Hadir', '07:50:46', '17:03:13', NULL, '2026-09-19T00:50:46.452652+00:00'),
  (253, 'WH0007', '2026-09-19', 'Shift 3b', 'Hadir', '10:45:13', '20:00:09', NULL, '2026-09-19T03:45:13.253506+00:00'),
  (254, 'WH0009', '2026-09-19', 'Shift 3b', 'Hadir', '10:46:10', '20:00:27', NULL, '2026-09-19T03:46:12.536676+00:00'),
  (257, 'WH0008', '2026-09-21', 'Shift 1', 'Hadir', '08:02:33', NULL, NULL, '2026-09-21T01:02:33.614661+00:00'),
  (260, 'WH0005', '2026-09-21', 'Shift 2', 'Terlambat', '11:28:23', NULL, NULL, '2026-09-21T04:28:24.10556+00:00'),
  (262, 'WH0007', '2026-09-21', 'Shift 3a', 'Hadir', '11:42:39', NULL, NULL, '2026-09-21T04:42:39.683274+00:00'),
  (256, 'WH0004', '2026-09-21', 'Shift 1', 'Hadir', '07:50:07', '17:02:48', NULL, '2026-09-21T00:50:07.905153+00:00'),
  (255, 'WH0006', '2026-09-21', 'Shift 1', 'Hadir', '07:49:35', '17:07:25', NULL, '2026-09-21T00:49:36.177212+00:00'),
  (259, 'WH0003', '2026-09-21', 'Shift 2', 'Hadir', '08:58:12', '18:01:28', NULL, '2026-09-21T01:56:42.677073+00:00'),
  (258, 'WH0002', '2026-09-21', 'Shift 2', 'Hadir', '08:54:37', '18:00:07', NULL, '2026-09-21T01:54:38.044992+00:00'),
  (261, 'WH0009', '2026-09-21', 'Shift 3a', 'Hadir', '11:41:45', '21:03:02', NULL, '2026-09-21T04:41:46.391307+00:00'),
  (263, 'WH0006', '2026-09-22', 'Shift 1', 'Hadir', '07:48:03', NULL, NULL, '2026-09-22T00:48:03.432338+00:00'),
  (265, 'WH0008', '2026-09-22', 'Shift 1', 'Hadir', '08:00:31', NULL, NULL, '2026-09-22T01:00:31.576523+00:00'),
  (266, 'WH0003', '2026-09-22', 'Shift 2', 'Hadir', '08:48:22', NULL, NULL, '2026-09-22T01:46:47.472507+00:00'),
  (267, 'WH0002', '2026-09-22', 'Shift 2', 'Hadir', '08:46:48', NULL, NULL, '2026-09-22T01:46:48.449375+00:00'),
  (273, 'WH0008', '2026-09-23', 'Shift 1', 'Terlambat', '08:10:58', NULL, NULL, '2026-09-23T01:10:58.959314+00:00'),
  (274, 'WH0002', '2026-09-23', 'Shift 2', 'Hadir', '08:48:46', NULL, NULL, '2026-09-23T01:48:46.97593+00:00'),
  (275, 'WH0003', '2026-09-23', 'Shift 2', 'Hadir', '09:03:52', NULL, NULL, '2026-09-23T02:02:17.248915+00:00'),
  (276, 'WH0007', '2026-09-23', 'Shift 3a', 'Hadir', '11:32:29', NULL, NULL, '2026-09-23T04:32:29.815662+00:00'),
  (278, 'WH0005', '2026-09-23', 'Shift 2', 'Terlambat', '11:34:19', NULL, NULL, '2026-09-23T04:34:19.941028+00:00'),
  (277, 'WH0009', '2026-09-23', 'Shift 3a', 'Hadir', '11:34:08', '21:00:58', NULL, '2026-09-23T04:34:08.919082+00:00'),
  (271, 'WH0006', '2026-09-23', 'Shift 1', 'Hadir', '07:50:57', '21:05:30', NULL, '2026-09-23T00:50:57.636272+00:00'),
  (279, 'WH0004', '2026-09-24', 'Shift 1', 'Hadir', '07:10:23', NULL, NULL, '2026-09-24T00:10:24.131633+00:00'),
  (280, 'WH0008', '2026-09-24', 'Shift 1', 'Hadir', '07:10:38', NULL, NULL, '2026-09-24T00:10:39.006083+00:00'),
  (281, 'WH0005', '2026-09-24', 'Shift 2', 'Hadir', '07:50:42', NULL, NULL, '2026-09-24T00:50:42.442856+00:00'),
  (283, 'WH0002', '2026-09-24', 'Shift 2', 'Hadir', '08:52:46', NULL, NULL, '2026-09-24T01:52:46.666691+00:00'),
  (288, 'WH0003', '2026-09-24', 'Shift 2', 'Hadir', '08:58:11', NULL, NULL, '2026-09-24T01:56:36.1785+00:00'),
  (282, 'WH0006', '2026-09-24', 'Shift 1', 'Hadir', '07:57:59', '17:48:01', NULL, '2026-09-24T00:57:59.463065+00:00'),
  (285, 'WH0007', '2026-09-24', 'Shift 3a', 'Hadir', '08:54:00', '21:03:06', '', '2026-09-24T01:53:50.61088+00:00'),
  (284, 'WH0009', '2026-09-24', 'Shift 3a', 'Hadir', '08:53:32', '21:05:43', NULL, '2026-09-24T01:53:32.67798+00:00'),
  (289, 'WH0004', '2026-09-25', 'Shift 1', 'Hadir', '07:51:36', NULL, NULL, '2026-09-25T00:51:37.307199+00:00'),
  (290, 'WH0005', '2026-09-25', 'Shift 1', 'Hadir', '07:56:45', NULL, NULL, '2026-09-25T00:56:45.559126+00:00')
ON CONFLICT (id) DO NOTHING;

-- ------------------------------------------------------------------------------
-- DATA TABEL: lembur (38 baris)
-- ------------------------------------------------------------------------------
INSERT INTO lembur (id, nik, nama, divisi, tanggal, deskripsi, jam_mulai, jam_selesai, durasi_jam, rate_lembur, total_lembur, status, approved_by, approved_at, catatan, created_at)
VALUES
  ('LMB-1787839936996-712', 'WH0009', 'Ria Nur Fiana', 'QC', '2026-07-27', 'Photoshoot', '06:00:00', '08:00:00', 2, 10000, 20000, 'Diajukan', NULL, NULL, 'Photoshoot diluar', '2026-08-27T14:12:17.444366+00:00'),
  ('LMB-1787842253165-675', 'WH0009', 'Ria Nur Fiana', 'QC', '2026-07-27', 'Photoshoot', '05:00:00', '08:00:00', 3, 10000, 30000, 'Diajukan', NULL, NULL, 'Ptohoshoot lanjutan', '2026-08-27T14:50:54.405981+00:00'),
  ('LMB-1787842308404-534', 'WH0009', 'Ria Nur Fiana', 'QC', '2026-07-28', 'Bis ', '05:00:00', '06:00:00', 1, 10000, 10000, 'Diajukan', NULL, NULL, 'Bis cargo', '2026-08-27T14:51:48.597864+00:00'),
  ('LMB-1787842586351-712', 'WH0009', 'Ria Nur Fiana', 'QC', '2026-07-30', 'Konten ', '05:00:00', '07:55:00', 2.92, 10000, 29200, 'Diajukan', NULL, NULL, 'Konten', '2026-08-27T14:56:27.242211+00:00'),
  ('1786962451542', 'WH0008', 'Navi Ilyah', 'QC', '2026-08-27', 'photoshot', '17:00:00', '20:00:00', 0, 0, 0, '2026-08-17T10:27:31.291Z', '', NULL, 'Diajukan', '2026-08-17T13:23:29.415719+00:00'),
  ('LMB-1787842636420-490', 'WH0009', 'Ria Nur Fiana', 'QC', '2026-07-31', 'Steam ', '05:00:00', '06:00:00', 1, 10000, 10000, 'Diajukan', NULL, NULL, 'Steam display shopee tiktok', '2026-08-27T14:57:16.561849+00:00'),
  ('LMB-1788360553674-882', 'WH0008', 'Navi Ilyah', 'QC', '2026-09-02', 'konten', '17:00:00', '20:00:00', 3, 10000, 30000, 'Diajukan', NULL, NULL, '', '2026-09-02T14:49:13.963376+00:00'),
  ('LMB-1788483534724-712', 'WH0008', 'Navi Ilyah', 'QC', '2026-09-03', 'photoshot ', '17:00:00', '20:00:00', 3, 10000, 30000, 'Diajukan', NULL, NULL, '', '2026-09-04T00:58:54.766694+00:00'),
  ('LMB-1787277071774-818', 'WH0008', 'Navi Ilyah', 'QC', '2026-08-19', 'konten', '17:00:00', '19:00:00', 2, 10000, 20000, 'Diajukan', NULL, NULL, '', '2026-08-21T01:51:13.079824+00:00'),
  ('LMB-1787722054931-184', 'WH0008', 'Navi Ilyah', 'QC', '2026-07-27', 'photoshot ', '17:00:00', '20:00:00', 3, 10000, 30000, 'Diajukan', NULL, NULL, '', '2026-08-26T05:27:35.069782+00:00'),
  ('LMB-1787722094322-567', 'WH0008', 'Navi Ilyah', 'QC', '2026-08-20', 'konten', '17:00:00', '19:00:00', 2, 10000, 20000, 'Diajukan', NULL, NULL, '', '2026-08-26T05:28:14.433739+00:00'),
  ('LMB-1787742347581-120', 'WH0007', 'Novi Fatihatul', 'QC', '2026-07-27', 'bis', '18:00:00', '20:00:00', 2, 10000, 20000, 'Diajukan', NULL, NULL, '', '2026-08-26T11:05:48.098322+00:00'),
  ('LMB-1787742347581-395', 'WH0007', 'Novi Fatihatul', 'QC', '2026-08-07', 'contentshoot', '07:00:00', '08:00:00', 1, 10000, 10000, 'Diajukan', NULL, NULL, '', '2026-08-26T11:05:48.098322+00:00'),
  ('LMB-1787742347581-522', 'WH0007', 'Novi Fatihatul', 'QC', '2026-08-12', 'contentshoot', '17:00:00', '19:00:00', 2, 10000, 20000, 'Diajukan', NULL, NULL, '', '2026-08-26T11:05:48.098322+00:00'),
  ('LMB-1787742347582-783', 'WH0007', 'Novi Fatihatul', 'QC', '2026-08-20', 'contentshoot', '17:00:00', '19:00:00', 2, 10000, 20000, 'Diajukan', NULL, NULL, '', '2026-08-26T11:05:48.098322+00:00'),
  ('LMB-1787742347582-492', 'WH0007', 'Novi Fatihatul', 'QC', '2026-08-19', 'content', '17:00:00', '19:00:00', 2, 10000, 20000, 'Diajukan', NULL, NULL, '', '2026-08-26T11:05:48.098322+00:00'),
  ('LMB-1787721945046-31', 'WH0008', 'Navi Ilyah', 'QC', '2026-08-20', 'konten', '17:00:00', '18:00:00', 1, 25000, 25000, 'Diajukan', NULL, NULL, '', '2026-08-26T05:25:46.193003+00:00'),
  ('1786962452527', 'WH0008', 'Navi Ilyah', 'QC', '2026-08-12', 'konten', '17:00:00', '18:00:00', 1, 25000, 25000, '2026-08-17T10:27:32.086Z', '', NULL, '', '2026-08-17T13:23:29.415719+00:00'),
  ('1786960850084', 'WH0002', 'Sasi Novita', 'QC', '2026-08-08', 'Qc orderan', '08:00:00', '09:00:00', 1, 25000, 25000, '2026-08-17T10:00:49.089Z', '', NULL, '', '2026-08-17T13:23:29.415719+00:00'),
  ('1786962452399', 'WH0008', 'Navi Ilyah', 'QC', '2026-08-07', 'konten', '17:00:00', '18:00:00', 1, 25000, 25000, '2026-08-17T10:27:31.924Z', '', NULL, '', '2026-08-17T13:23:29.415719+00:00'),
  ('1786961962808', 'WH0008', 'Navi Ilyah', 'QC', '2026-08-04', 'photoshot', '17:00:00', '20:00:00', 3, 25000, 75000, '2026-08-17T10:19:22.151Z', '', NULL, '', '2026-08-17T13:23:29.415719+00:00'),
  ('1786961962761', 'WH0008', 'Navi Ilyah', 'QC', '2026-08-04', 'photoshot', '07:00:00', '08:00:00', 1, 25000, 25000, '2026-08-17T10:19:21.813Z', '', NULL, '', '2026-08-17T13:23:29.415719+00:00'),
  ('1786962452675', 'WH0008', 'Navi Ilyah', 'QC', '2026-07-28', 'bis', '17:00:00', '18:00:00', 1, 25000, 25000, '2026-08-17T10:27:31.753Z', '', NULL, '', '2026-08-17T13:23:29.415719+00:00'),
  ('1786962451561', 'WH0008', 'Navi Ilyah', 'QC', '2026-07-27', 'photoshot', '06:00:00', '08:00:00', 2, 25000, 50000, '2026-08-17T10:27:31.195Z', '', NULL, '', '2026-08-17T13:23:29.415719+00:00'),
  ('LMB-1787742347581-533', 'WH0007', 'Novi Fatihatul', 'QC', '2026-08-04', 'photoshoot', '17:00:00', '20:00:00', 3, 25000, 75000, 'Diajukan', NULL, NULL, '', '2026-08-26T11:05:48.098322+00:00'),
  ('LMB-1788483658531-170', 'WH0008', 'Navi Ilyah', 'QC', '2026-08-27', 'konten', '17:00:00', '18:00:00', 1, 10000, 10000, 'Diajukan', NULL, NULL, '', '2026-09-04T01:00:59.102784+00:00'),
  ('LMB-1788531458212-77', 'WH0007', 'Novi Fatihatul', 'QC', '2026-09-04', 'bis ', '21:00:00', '21:17:00', 0.28, 10000, 2800, 'Diajukan', NULL, NULL, '', '2026-09-04T14:17:38.651346+00:00'),
  ('LMB-1788531489103-761', 'WH0009', 'Ria Nur Fiana', 'QC', '2026-09-04', 'Bis izbel', '21:00:00', '21:15:00', 0.25, 10000, 2500, 'Diajukan', NULL, NULL, 'Biz izbel dalam kota', '2026-09-04T14:18:09.584819+00:00'),
  ('LMB-1788962421003-665', 'WH0007', 'Novi Fatihatul', 'QC', '2026-09-09', 'orderan', '08:00:00', '12:00:00', 4, 10000, 40000, 'Diajukan', NULL, NULL, '', '2026-09-09T14:00:21.20239+00:00'),
  ('LMB-1788962441735-457', 'WH0009', 'Ria Nur Fiana', 'QC', '2026-09-09', 'Orderan', '08:00:00', '12:00:00', 4, 10000, 40000, 'Diajukan', NULL, NULL, 'Orderan 9.9', '2026-09-09T14:00:41.745231+00:00'),
  ('LMB-1789002188722-79', 'WH0008', 'Navi Ilyah', 'QC', '2026-09-09', 'konten', '17:00:00', '19:00:00', 2, 10000, 20000, 'Diajukan', NULL, NULL, '', '2026-09-10T01:03:08.872471+00:00'),
  ('LMB-1789048939039-869', 'WH0005', 'Nur Halimah', 'QC', '2026-09-10', 'barcode bis', '17:00:00', '18:00:00', 1, 10000, 10000, 'Diajukan', NULL, NULL, '', '2026-09-10T14:02:19.411613+00:00'),
  ('LMB-1789521998423-235', 'WH0008', 'Navi Ilyah', 'QC', '2026-09-10', 'nyiapin photoshot ', '17:00:00', '19:00:00', 2, 10000, 20000, 'Diajukan', NULL, NULL, '', '2026-09-16T01:26:38.509338+00:00'),
  ('LMB-1789522062873-553', 'WH0008', 'Navi Ilyah', 'QC', '2026-09-11', 'photoshot ', '17:00:00', '18:00:00', 1, 10000, 10000, 'Diajukan', NULL, NULL, '', '2026-09-16T01:27:43.312627+00:00'),
  ('LMB-1789693317883-582', 'WH0008', 'Navi Ilyah', 'QC', '2026-09-17', 'konten', '17:00:00', '18:00:00', 1, 10000, 10000, 'Diajukan', NULL, NULL, '', '2026-09-18T01:01:58.125819+00:00'),
  ('LMB-1790211560186-37', 'WH0006', 'Vina Kharisma', 'QC', '2026-09-23', 'new up', '17:00:00', '21:00:00', 4, 10000, 40000, 'Diajukan', NULL, NULL, '', '2026-09-24T00:59:20.820233+00:00'),
  ('LMB-1790258819668-821', 'WH0009', 'Ria Nur Fiana', 'QC', '2026-09-24', 'New up', '09:00:00', '12:00:00', 3, 10000, 30000, 'Diajukan', NULL, NULL, 'New up gaia dan gst 327-330', '2026-09-24T14:06:59.808981+00:00'),
  ('LMB-1790259210424-388', 'WH0007', 'Novi Fatihatul', 'QC', '2026-09-24', 'new up ', '09:00:00', '12:00:00', 3, 25000, 75000, 'Diajukan', NULL, NULL, 'sj gaia & tarikan', '2026-09-24T14:13:30.547053+00:00')
ON CONFLICT (id) DO NOTHING;

-- ------------------------------------------------------------------------------
-- DATA TABEL: perijinan_cuti (7 baris)
-- ------------------------------------------------------------------------------
INSERT INTO perijinan_cuti (id, nik, nama, divisi, jenis, tgl_mulai, tgl_selesai, jumlah_hari, alasan, status, approved_by, approved_at, catatan, created_at)
VALUES
  ('CUTI-1787060840800-878', 'WH0010', 'Nanang', 'OB', 'Cuti Tahunan', '2026-08-31', '2026-09-03', 4, 'Acara Keluarga', 'Disetujui', NULL, NULL, '', '2026-08-18T13:47:22.961735+00:00'),
  ('CUTI-1788578857523-734', 'WH0006', 'Vina Kharisma', 'QC', 'Cuti Tahunan', '2026-09-25', '2026-09-29', 5, 'keperluan keluarga', 'Disetujui', NULL, NULL, '', '2026-09-05T03:27:38.091078+00:00'),
  ('1786960903075', 'WH0003', 'Irma', 'QC', 'Cuti Tahunan', '2026-09-30', '2026-10-04', 5, 'keperluan keluarga', 'Disetujui', '', NULL, '', '2026-08-17T13:23:31.779698+00:00'),
  ('CUTI-1787744515100-628', 'WH0004', 'Yesinta Agistisari', 'QC', 'Cuti Tahunan', '2026-10-07', '2026-10-10', 4, 'Keperluan keluarga ', 'Disetujui', NULL, NULL, '', '2026-08-26T11:41:56.196962+00:00'),
  ('1787011960241', 'WH0007', 'Novi Fatihatul', 'QC', 'Cuti Tahunan', '2026-10-14', '2026-10-18', 5, 'acara keluarga', 'Disetujui', NULL, NULL, '', '2026-08-18T04:59:42.216884+00:00'),
  ('1786961742264', 'WH0008', 'Navi Ilyah', 'QC', 'Cuti Tahunan', '2026-10-29', '2026-10-31', 3, 'keperluan keluarga', 'Disetujui', '', NULL, '', '2026-08-17T13:23:31.779698+00:00'),
  ('1786960931791', 'WH0002', 'Sasi Novita', 'QC', 'Cuti Tahunan', '2026-11-04', '2026-11-08', 5, 'Keperluan keluarga', 'Disetujui', '', NULL, '', '2026-08-17T13:23:31.779698+00:00')
ON CONFLICT (id) DO NOTHING;

-- Tabel pengajuan_profil: Tidak ada data

-- Tabel kasbon: Tidak ada data

-- Tabel payroll: Tidak ada data


-- Sinkronisasi urutan auto-increment ID
SELECT setval('master_shift_id_seq', COALESCE((SELECT MAX(id) FROM master_shift), 1), true);
SELECT setval('roster_shift_id_seq', COALESCE((SELECT MAX(id) FROM roster_shift), 1), true);
SELECT setval('presensi_id_seq', COALESCE((SELECT MAX(id) FROM presensi), 1), true);
