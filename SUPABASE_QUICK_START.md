# 🚀 Supabase Quick Start Guide

## Langkah Cepat Setup (5 Menit)

### 1️⃣ Disable Email Confirmation (WAJIB!)
1. Buka [Supabase Dashboard](https://supabase.com/dashboard)
2. Pilih project Anda
3. Klik **Authentication** (ikon kunci di sidebar)
4. Klik **Providers**
5. Klik **Email**
6. Scroll ke bawah, cari **"Confirm email"**
7. **MATIKAN** toggle "Confirm email"
8. Klik **Save**

✅ **Done!** Sekarang user bisa langsung login tanpa verifikasi email.

---

### 2️⃣ Run SQL Script
1. Klik **SQL Editor** (ikon `</>` di sidebar)
2. Klik **"+ New query"**
3. Buka file **`supabase_schema.sql`** di VS Code
4. Copy semua isinya (Ctrl+A, Ctrl+C)
5. Paste ke SQL Editor (Ctrl+V)
6. Klik **"Run"** atau tekan Ctrl+Enter
7. Tunggu sampai muncul **"Success. No rows returned"**

✅ **Done!** Database sudah ready.

---

### 3️⃣ Copy API Keys ke main.dart
1. Di Supabase Dashboard, klik **Settings** (ikon ⚙️)
2. Klik **API**
3. Copy **URL** dan **anon/public key**
4. Buka `lib/main.dart`
5. Ganti di bagian:
```dart
await Supabase.initialize(
  url: 'YOUR_URL_DISINI',
  anonKey: 'YOUR_ANON_KEY_DISINI',
);
```

✅ **Done!** App siap connect ke Supabase.

---

### 4️⃣ Test Register & Login
1. Run app: `flutter run -d chrome`
2. Klik **Get Started**
3. Klik **Register**
4. Isi form:
   - Full Name: `Test User`
   - Email: `test@example.com`
   - Password: `123456`
5. Klik **Register**
6. Harus langsung masuk ke HomePage

✅ **Done!** Auth sudah berfungsi.

---

### 5️⃣ Verifikasi Database
1. Kembali ke Supabase Dashboard
2. Klik **Table Editor** (ikon tabel)
3. Klik table **profiles**
4. Harus ada 1 row baru dengan:
   - `id`: UUID
   - `full_name`: "Test User"
   - `registered_at`: timestamp

✅ **Done!** Setup complete! 🎉

---

## ❌ Troubleshooting

### "Database error saving new user" (ERROR 500)
- **Penyebab:** RLS policy issue
- **Solusi:** 
  1. Buka file `supabase_fix_trigger.sql`
  2. Copy semua → Paste ke SQL Editor → Run
  3. Hapus user yang error di Authentication → Users
  4. Register ulang

### "Email not confirmed"
- **Solusi:** Ulangi langkah 1️⃣ - pastikan email confirmation di-disable

### "Invalid API key"
- **Solusi:** Check URL dan anon key di main.dart
- Pastikan tidak ada spasi atau karakter tambahan

### Table tidak ada
- **Solusi:** Ulangi langkah 2️⃣
- Check di SQL Editor apakah ada error message

### User bisa register tapi profile kosong
- **Solusi:** Check trigger `on_auth_user_created` sudah dibuat
- Run query: `SELECT * FROM pg_trigger WHERE tgname = 'on_auth_user_created';`

---

## 📚 Documentation Lengkap
Untuk detail lengkap, lihat file **`SUPABASE_AUTH_SETUP.md`**
