# 🚀 Quick Start - Auth Gate Service

## Setup dalam 5 Menit!

### Step 1: Pastikan Supabase sudah initialized

Buka `lib/main.dart` dan pastikan ada:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );

  runApp(const MyApp());
}
```

### Step 2: Tambahkan StreamAuthGate

Ganti `home:` di MaterialApp dengan `StreamAuthGate`:

```dart
import 'services/auth_gate.dart'; // ← Tambah import ini

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StyleAI',
      home: const StreamAuthGate(), // ← Ganti dengan ini
    );
  }
}
```

### Step 3: Test!

Run aplikasi:
```bash
flutter run -d chrome
```

**Hasil:**
- ✅ Jika belum login → otomatis ke `SupabaseLoginPage`
- ✅ Jika sudah login → otomatis ke `HomePage`
- ✅ Setelah logout → otomatis kembali ke login

---

## 🎯 Use Case Umum

### 1. Protect Halaman Profile

```dart
import 'package:styleai/services/auth_gate.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      child: Scaffold(
        appBar: AppBar(title: Text('My Profile')),
        body: Text('Protected content'),
      ),
    );
  }
}
```

### 2. Check Login Status

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

final user = Supabase.instance.client.auth.currentUser;

if (user != null) {
  print('Logged in as: ${user.email}');
} else {
  print('Not logged in');
}
```

### 3. Logout

```dart
import 'package:styleai/services/auth_service.dart';

final authService = SupabaseAuthService();

// Logout
await authService.signOut();

// StreamAuthGate akan auto redirect ke login!
```

---

## 🔥 Advanced Features

### Admin-Only Page

```dart
import 'package:styleai/services/auth_gate.dart';

class AdminPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RoleGuard(
      allowedRoles: ['admin'],
      child: Scaffold(
        appBar: AppBar(title: Text('Admin Panel')),
        body: Text('Admin only content'),
      ),
    );
  }
}
```

**Untuk set role saat register:**

```dart
import 'package:styleai/services/auth_service.dart';

final authService = SupabaseAuthService();

await authService.signUp(
  email: 'admin@example.com',
  password: 'password123',
  fullName: 'Admin User',
  metadata: {'role': 'admin'}, // ← Set role di sini
);
```

### Check User Role

```dart
import 'package:styleai/services/auth_service.dart';

final authService = SupabaseAuthService();

// Get role
final role = authService.userRole; // 'admin', 'user', dll

// Check specific role
if (authService.hasRole('admin')) {
  print('User is admin!');
}

// Check multiple roles
if (authService.hasAnyRole(['admin', 'moderator'])) {
  print('User is admin or moderator!');
}
```

---

## 📱 Contoh Implementasi Lengkap

### main.dart
```dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://xxxxx.supabase.co',
    anonKey: 'eyJhbGciOiJIUz...',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StyleAI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFF9D9)
        ),
        useMaterial3: false,
      ),
      home: const StreamAuthGate(), // ← Magic happens here!
    );
  }
}
```

### Header Widget dengan Login Status
```dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:styleai/services/auth_service.dart';

class AppHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return AppBar(
      title: Text('StyleAI'),
      actions: [
        if (user != null) ...[
          // Logged in
          Chip(
            label: Text(user.email ?? 'User'),
            avatar: Icon(Icons.person, size: 16),
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await SupabaseAuthService().signOut();
              // Auto redirect oleh StreamAuthGate
            },
          ),
        ] else ...[
          // Not logged in
          TextButton(
            onPressed: () {
              // Akan redirect by StreamAuthGate
            },
            child: Text('Login'),
          ),
        ],
      ],
    );
  }
}
```

---

## ✅ Checklist

Pastikan sudah:
- [ ] Install `supabase_flutter` package
- [ ] Run `flutter pub get`
- [ ] Setup Supabase URL & anon key di main.dart
- [ ] Import `auth_gate.dart` di main.dart
- [ ] Ganti `home:` dengan `StreamAuthGate()`
- [ ] Test login & logout

---

## 🐛 Troubleshooting

**"StreamAuthGate tidak ditemukan"**
```dart
// Pastikan import ini ada:
import 'services/auth_gate.dart';
```

**"User tetap di login page setelah login"**
- Check apakah ada multiple Navigator.push
- Pastikan tidak ada `Navigator.pop()` setelah login
- Lihat console untuk error

**"Cannot read properties of null"**
- Pastikan Supabase sudah di-initialize di main()
- Check URL dan anon key sudah benar
- Test koneksi internet

---

## 📚 Dokumentasi Lengkap

Baca file lengkap:
- `AUTH_GATE_GUIDE.md` - Panduan lengkap semua fitur
- `SUPABASE_AUTH_SETUP.md` - Setup Supabase dari awal
- `lib/examples/auth_gate_examples.dart` - Contoh kode

---

## 🎉 Done!

Auth Gate sudah siap digunakan! Aplikasi akan otomatis:
- ✅ Redirect ke login jika belum login
- ✅ Redirect ke home jika sudah login
- ✅ Update real-time saat login/logout
- ✅ Protect halaman dengan AuthGuard
- ✅ Role-based access dengan RoleGuard

Happy coding! 🚀
