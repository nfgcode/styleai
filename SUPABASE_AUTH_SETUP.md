# Setup Supabase Authentication untuk StyleAI

## ✅ Checklist Setup (Ikuti Urutan Ini!)

- [ ] **1. Buat Project Supabase** (section 1)
- [ ] **2. Copy API Keys** (section 2)
- [ ] **3. Update main.dart** dengan URL & anon key (section 3)
- [ ] **4. DISABLE Email Confirmation** ⚠️ PENTING! (section 4)
- [ ] **5. Run SQL Script** dari file `supabase_schema.sql` (section 5)
- [ ] **6. Test Register & Login** (section 6)
- [ ] **7. Verifikasi table & storage di Table Editor** (section 6)

> ⚠️ **JANGAN SKIP langkah 4!** Tanpa disable email confirmation, Anda harus verifikasi email dulu sebelum bisa login.

---

## Langkah-langkah Setup:

### 1. Buat Project Supabase
1. Kunjungi [supabase.com](https://supabase.com)
2. Buat akun atau login
3. Klik "New Project"
4. Isi detail project dan tunggu hingga selesai dibuat

### 2. Dapatkan API Keys
1. Di dashboard Supabase, buka **Settings** > **API**
2. Copy **URL** dan **anon key**

### 3. Update main.dart
Buka `lib/main.dart` dan ganti:
```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL', // Ganti dengan URL Anda
  anonKey: 'YOUR_SUPABASE_ANON_KEY', // Ganti dengan anon key Anda
);
```

### 4. PENTING: Disable Email Confirmation (Untuk Testing)
**Lakukan ini TERLEBIH DAHULU sebelum setup database:**

1. Buka Supabase Dashboard
2. Pergi ke **Authentication** → **Providers**
3. Klik **Email** provider
4. Scroll ke bawah, cari **"Confirm email"**
5. **MATIKAN/DISABLE** toggle "Confirm email"
6. Klik **Save**

> ⚠️ **Tanpa langkah ini, user harus verifikasi email dulu sebelum bisa login!**

### 5. Setup Database (WAJIB untuk Fitur Lengkap)

#### ✅ Gunakan File `supabase_schema.sql` (MUDAH - Direkomendasikan)

File ini sudah include semua yang dibutuhkan:
- ✅ Profiles table (untuk user data)
- ✅ Try-on history table (untuk AI fashion try-on)
- ✅ Storage bucket (untuk upload avatar)
- ✅ Row Level Security policies
- ✅ Triggers untuk auto-create profile

**Langkah eksekusi:**
1. Buka file **`supabase_schema.sql`** di root project
2. Copy semua isinya (Ctrl+A, Ctrl+C)
3. Buka Supabase Dashboard → **SQL Editor** → klik **"+ New query"**
4. Paste SQL code (Ctrl+V)
5. Klik **"Run"** atau tekan Ctrl+Enter
6. Tunggu hingga selesai (akan muncul "Success. No rows returned")
7. Verifikasi di **Table Editor**:
   - Harus ada table **profiles**
   - Harus ada table **try_on_history**
8. Verifikasi di **Storage**:
   - Harus ada bucket **avatars**

> 💡 **Tips:** Jika ada error "already exists", itu normal - artinya sudah di-setup sebelumnya.

#### Manual Setup (Alternatif)
Jika mau setup manual, lihat isi file `supabase_schema.sql` untuk detail lengkap.

**Struktur Table Profiles:**
```sql
id           UUID (PRIMARY KEY, references auth.users)
full_name    TEXT
avatar_url   TEXT  
updated_at   TIMESTAMPTZ
registered_at TIMESTAMPTZ (default: now())
```

**Struktur Table Try-On History:**
```sql
id              UUID (PRIMARY KEY)
user_id         UUID (references auth.users)
image_path      TEXT
analysis_result TEXT
created_at      TIMESTAMPTZ (default: now())
```

> 💡 **Catatan:** 
> - User metadata (`full_name`, `avatar_url`) otomatis disimpan saat register
> - Table `try_on_history` untuk menyimpan riwayat AI fashion try-on
> - Storage bucket `avatars` untuk upload foto profil
> - Semua table protected dengan Row Level Security (RLS)

### 5. Cara Menggunakan

#### Login dengan Supabase
```dart
// File: login_page.dart (sudah tersedia di lib/page/auth/)
import 'package:styleai/page/auth/login_page.dart';

// Navigate ke login page
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const SupabaseLoginPage()),
);
```

#### Register dengan Supabase
```dart
// File: register_page.dart (sudah tersedia di lib/page/auth/)
import 'package:styleai/page/auth/register_page.dart';

// Navigate ke register page
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const SupabaseRegisterPage()),
);
```

#### Menggunakan Auth Service
```dart
import 'package:styleai/services/auth_service.dart';

final authService = SupabaseAuthService();

// Check if logged in
if (authService.isLoggedIn) {
  // User is logged in
  final user = authService.currentUser;
  print('User email: ${user?.email}');
  print('User name: ${user?.userMetadata?['full_name']}');
}

// Sign up with metadata
await authService.signUp(
  email: 'user@example.com',
  password: 'password123',
  fullName: 'John Doe', // Akan disimpan ke user metadata & profiles table
);

// Sign in
await authService.signIn(
  email: 'user@example.com',
  password: 'password123',
);

// Sign out
await authService.signOut();

// Reset password
await authService.resetPassword('user@email.com');

// Check user role (jika sudah setup roles)
if (authService.hasRole('admin')) {
  print('User is admin');
}

// Check multiple roles
if (authService.hasAnyRole(['admin', 'moderator'])) {
  print('User has special permissions');
}
```

### 6. Testing
1. Jalankan aplikasi: `flutter run -d chrome`
2. Klik tombol "Get Started" di landing page
3. Klik "Register" untuk buat akun baru
4. Isi:
   - **Full Name:** (contoh: John Doe)
   - **Email:** (contoh: test@example.com)
   - **Password:** minimal 6 karakter
5. Klik **Register**
6. **Jika email confirmation DISABLED:** Langsung redirect ke HomePage
7. **Jika email confirmation ENABLED:** Check email untuk verifikasi
8. Verifikasi data berhasil:
   - Buka Supabase Dashboard → **Table Editor** → **profiles**
   - Harus ada 1 row baru dengan `full_name` dan `registered_at`
   - Check **Table Editor** → **try_on_history** (masih kosong, itu normal)
   - Check **Storage** → harus ada bucket **avatars**
   - Check **Authentication** → **Users** (harus ada user baru)
9. Test login dengan credentials yang sama
10. Check ProfilePage di app - harus muncul nama user

> 📝 **Catatan:** Table `try_on_history` akan terisi saat user menggunakan fitur AI Try-On di aplikasi.

### 7. Dual Auth System (SharedPreferences + Supabase)
Aplikasi ini mendukung 2 sistem auth:

#### Priority 1: Supabase Auth (Direkomendasikan)
- User baru akan otomatis menggunakan Supabase
- Data tersimpan di cloud
- Lebih aman dengan row-level security
- Support reset password via email

#### Fallback: SharedPreferences (Legacy)
- User lama yang sudah login sebelumnya masih bisa akses
- Data tersimpan lokal di device
- Akan tetap berfungsi sampai user logout

**Cara kerja:**
- `get_started_page.dart` → Check Supabase dulu, lalu SharedPreferences
- `home_page.dart` (ProfilePage) → Load data dari Supabase/SharedPreferences
- Sign out → Clear both Supabase session & SharedPreferences

## File-file Penting

- **Auth Service**: `lib/services/auth_service.dart` (SupabaseAuthService)
- **Auth Gate**: `lib/services/auth_gate.dart` (StreamAuthGate, AuthGuard, RoleGuard)
- **Login Page**: `lib/page/auth/login_page.dart` (class: SupabaseLoginPage)
- **Register Page**: `lib/page/auth/register_page.dart` (class: SupabaseRegisterPage)
- **Get Started**: `lib/page/get_started_page.dart` (dengan dual auth check)
- **Home Page**: `lib/page/home_page.dart` (ProfilePage dengan dual auth)
- **Main**: `lib/main.dart` (Supabase initialization)

## Fitur Auth Service

✅ **Sign Up** - Register dengan email, password, dan full name (metadata)
✅ **Sign In** - Login dengan email & password
✅ **Sign Out** - Logout dan clear session
✅ **Get Current User** - Akses user yang sedang login
✅ **Check Login Status** - `isLoggedIn` getter
✅ **Reset Password** - Kirim reset password link via email
✅ **Role-Based Access** - `hasRole()` dan `hasAnyRole()` untuk authorization
✅ **User Metadata** - Simpan data tambahan (full_name, role, dll)

## Fitur Auth Gate (Advanced)

✅ **StreamAuthGate** - Auto-redirect berdasarkan auth state
✅ **AuthGuard** - Protect pages, require authentication
✅ **RoleGuard** - Protect pages by user role (admin, moderator, etc)
✅ **AuthStateProvider** - Global auth state management

## Troubleshooting

**Error: "Database error saving new user" (status 500)**
- **Penyebab:** RLS policy mencegah trigger insert ke table profiles
- **SOLUSI CEPAT:** 
  1. Buka file **`supabase_fix_trigger.sql`**
  2. Copy semua isinya
  3. Paste ke Supabase SQL Editor → Run
  4. Test register ulang dengan email baru
- **Atau:** Delete user yang error di Authentication → Users, lalu run `supabase_schema.sql` yang sudah diperbaiki

**Error: "Email not confirmed" / Tidak bisa login setelah register**
- **SOLUSI:** Disable email confirmation di Supabase
- **Path:** Authentication → Providers → Email → Matikan "Confirm email" → Save
- Atau check email inbox/spam untuk link verifikasi

**Error: "Invalid API key"**
- Pastikan URL dan anon key sudah benar di `main.dart`
- Check di Supabase Dashboard → Settings → API
- Copy ulang dan paste ke main.dart

**Table profiles tidak ada data setelah register**
- Check apakah trigger sudah dibuat dengan benar
- Cek di Supabase → Database → Triggers → harus ada `on_auth_user_created`
- Test: Register user baru, lalu refresh table profiles
- Check Console browser untuk error messages

**Error: duplicate key value violates unique constraint**
- User dengan email tersebut sudah ada
- **Solusi 1:** Gunakan email berbeda
- **Solusi 2:** Hapus user lama di Authentication → Users → klik user → Delete

**Profile tidak muncul di app**
- Check browser console untuk error
- Pastikan user sudah login (check auth state)
- Verifikasi RLS policies sudah di-enable
- Test query manual di SQL Editor:
  ```sql
  SELECT * FROM profiles WHERE id = 'USER_ID_DISINI';
  ```

## Advanced: Menggunakan Auth Gate

### Setup StreamAuthGate (Auto-routing)
```dart
// Di main.dart
import 'services/auth_gate.dart';

MaterialApp(
  home: StreamAuthGate(
    loginPage: const SupabaseLoginPage(),
    homePage: const HomePage(),
  ),
);
```

### Protect Pages dengan AuthGuard
```dart
import 'package:styleai/services/auth_gate.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      child: Scaffold(
        appBar: AppBar(title: Text('Settings')),
        body: Text('Protected content'),
      ),
    );
  }
}
```

### Role-Based Protection
```dart
import 'package:styleai/services/auth_gate.dart';

class AdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RoleGuard(
      requiredRoles: ['admin'],
      child: Scaffold(
        appBar: AppBar(title: Text('Admin Dashboard')),
        body: Text('Admin only content'),
      ),
    );
  }
}
```

## Next Steps

Setelah setup berhasil, Anda bisa:

### Quick Wins (Mudah)
1. ✅ Sudah ada: Basic auth dengan email/password
2. ✅ Sudah ada: User profile dengan metadata
3. ✅ Sudah ada: Role-based access control
4. 🔲 Tambahkan forgot password UI (service sudah ada)
5. 🔲 Tambahkan edit profile page

### Medium (Butuh effort)
6. 🔲 Upload avatar image ke Supabase Storage
7. 🔲 Implementasi social auth (Google, GitHub)
8. 🔲 Email verification flow dengan custom UI
9. 🔲 User settings & preferences

### Advanced (Complex)
10. 🔲 Multi-factor authentication (MFA)
11. 🔲 Admin panel untuk manage users
12. 🔲 Real-time user presence/status
13. 🔲 Audit log untuk track user actions

## Resources

- 📚 [Supabase Auth Docs](https://supabase.com/docs/guides/auth)
- 🎥 [Supabase Flutter Tutorial](https://supabase.com/docs/guides/getting-started/tutorials/with-flutter)
- 💬 [Supabase Discord](https://discord.supabase.com)
- 🐛 [Report Issues](https://github.com/supabase/supabase/issues)
