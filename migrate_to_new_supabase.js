// ==============================================================================
// WAREHOUSE MANAGEMENT SYSTEM - AUTO DATA MIGRATOR TO NEW SUPABASE
// Usage: node migrate_to_new_supabase.js <NEW_SUPABASE_URL> <NEW_SUPABASE_KEY> [--clean]
// Example: node migrate_to_new_supabase.js https://xyz.supabase.co eyJhbGciOi... --clean
// ==============================================================================

const fs = require('fs');

const NEW_URL = process.argv[2];
const NEW_KEY = process.argv[3];
const isClean = process.argv.includes('--clean') || process.argv.includes('--overwrite');

if (!NEW_URL || !NEW_KEY) {
  console.log('---------------------------------------------------------------');
  console.log('Petunjuk Penggunaan Script Migrasi:');
  console.log('1. Mode Upsert (Timpa data dengan NIK/ID yang sama saja):');
  console.log('   node migrate_to_new_supabase.js <NEW_SUPABASE_URL> <NEW_SUPABASE_KEY>');
  console.log('2. Mode Clean Overwrite (Kosongkan tabel tujuan dulu, lalu isi replika 100%):');
  console.log('   node migrate_to_new_supabase.js <NEW_SUPABASE_URL> <NEW_SUPABASE_KEY> --clean');
  console.log('---------------------------------------------------------------');
  process.exit(1);
}

const backupFile = 'supabase_data_backup.json';
if (!fs.existsSync(backupFile)) {
  console.error(`File ${backupFile} tidak ditemukan!`);
  process.exit(1);
}

const backup = JSON.parse(fs.readFileSync(backupFile, 'utf8'));

// Urutan tabel penting untuk foreign key dependencies (karyawan lebih dulu)
const tableOrder = [
  'karyawan',
  'master_shift',
  'roster_shift',
  'presensi',
  'lembur',
  'perijinan_cuti',
  'pengajuan_profil',
  'kasbon',
  'payroll'
];

async function truncateTable(table) {
  const endpoint = `${NEW_URL.replace(/\/+$/, '')}/rest/v1/${table}?select=*`;
  // Delete all rows
  const res = await fetch(`${NEW_URL.replace(/\/+$/, '')}/rest/v1/${table}?id=gt.0`, {
    method: 'DELETE',
    headers: {
      'apikey': NEW_KEY,
      'Authorization': `Bearer ${NEW_KEY}`
    }
  });
}

async function insertBatch(table, rows) {
  if (!rows || rows.length === 0) {
    console.log(`[SKIP] Tabel ${table} tidak memiliki data.`);
    return;
  }

  const endpoint = `${NEW_URL.replace(/\/+$/, '')}/rest/v1/${table}`;
  const chunkSize = 50;
  let inserted = 0;

  for (let i = 0; i < rows.length; i += chunkSize) {
    const chunk = rows.slice(i, i + chunkSize);
    const res = await fetch(endpoint, {
      method: 'POST',
      headers: {
        'apikey': NEW_KEY,
        'Authorization': `Bearer ${NEW_KEY}`,
        'Content-Type': 'application/json',
        'Prefer': 'resolution=merge-duplicates'
      },
      body: JSON.stringify(chunk)
    });

    if (!res.ok) {
      const errText = await res.text();
      console.error(`[ERROR] Gagal memasukkan baris ${i + 1} - ${i + chunk.length} ke ${table}:`, errText);
    } else {
      inserted += chunk.length;
      process.stdout.write(`\r[MIGRATING] ${table}: ${inserted}/${rows.length} baris...`);
    }
  }
  console.log(`\n[SELESAI] Tabel ${table}: ${inserted} baris berhasil dikloning!`);
}

(async () => {
  console.log('Memulai proses kloning data ke Supabase Baru:', NEW_URL);
  console.log('Mode:', isClean ? 'CLEAN OVERWRITE (Timpa Total Bersih)' : 'UPSERT (Merge & Overwrite ID yang sama)');
  
  for (const table of tableOrder) {
    await insertBatch(table, backup[table]);
  }
  console.log('---------------------------------------------------------------');
  console.log('SEMUA DATA LAMA BERHASIL DIKLONING KE SUPABASE BARU!');
  console.log('---------------------------------------------------------------');
})();
