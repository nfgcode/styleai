# Auth Gate Service - Dokumentasi

Auth Gate adalah service yang mengatur routing otomatis berdasarkan status autentikasi user di aplikasi StyleAI.

## 📦 Komponen yang Tersedia

### 1. **AuthGate** (Basic)
Auth gate dasar yang mengecek status login sekali saat widget dibuat.

**Penggunaan:**
```dart
import 'package:styleai/services/auth_gate.dart';

// Di main.dart, ganti SplashScreen dengan AuthGate
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AuthGate(), // Otomatis redirect ke login/home
    );
  }
}
```

**Cara Kerja:**
- ✅ Cek status login saat pertama kali dibuka
- ✅ Jika sudah login → HomePage
- ✅ Jika belum login → SupabaseLoginPage

---

### 2. **StreamAuthGate** (Recommended)
Auth gate berbasis stream yang mendengarkan perubahan status autentikasi secara real-time.

**Penggunaan:**
```dart
import 'package:styleai/services/auth_gate.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StreamAuthGate(), // Real-time auth monitoring
    );
  }
}
```

**Keuntungan:**
- ✅ Otomatis update saat user login/logout
- ✅ Tidak perlu manual navigation
- ✅ Sinkron dengan auth state Supabase

---

### 3. **AuthGuard**
Melindungi halaman tertentu agar hanya bisa diakses oleh user yang sudah login.

**Penggunaan:**
```dart
import 'package:styleai/services/auth_gate.dart';

// Proteksi halaman profile
class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      child: Scaffold(
        appBar: AppBar(title: Text('Profile')),
        body: Text('Ini halaman profile'),
      ),
      fallback: SupabaseLoginPage(), // Redirect jika belum login
    );
  }
}

// Atau wrap di Navigator
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => AuthGuard(
      child: MyProtectedPage(),
    ),
  ),
);
```

---

### 4. **RoleGuard**
Melindungi halaman berdasarkan role user (admin, user, dll).

**Penggunaan:**
```dart
import 'package:styleai/services/auth_gate.dart';

class AdminPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RoleGuard(
      allowedRoles: ['admin', 'moderator'],
      child: Scaffold(
        appBar: AppBar(title: Text('Admin Panel')),
        body: Text('Hanya admin yang bisa lihat'),
      ),
      fallback: Scaffold(
        body: Center(child: Text('Access Denied')),
      ),
    );
  }
}
```

**Setup Role di Supabase:**
Saat register, tambahkan role di metadata:
```dart
final response = await _authService.signUp(
  email: email,
  password: password,
  fullName: name,
  metadata: {'role': 'user'}, // atau 'admin'
);
```

---

### 5. **AuthStateProvider & Wrapper**
Menyediakan auth state ke seluruh widget tree menggunakan InheritedWidget.

**Penggunaan:**
```dart
import 'package:styleai/services/auth_gate.dart';

// Di main.dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AuthStateWrapper(
      child: MaterialApp(
        home: HomePage(),
      ),
    );
  }
}

// Di widget manapun, akses auth state
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authState = AuthStateProvider.of(context);
    final user = authState?.user;
    
    if (user != null) {
      return Text('Hello, ${user.email}');
    } else {
      return Text('Not logged in');
    }
  }
}
```

---

## 🚀 Implementasi di Main.dart

### Option 1: Simple Auth Gate
```dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
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
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFFFFF9D9)),
        useMaterial3: false,
      ),
      home: AuthGate(), // ← Tambahkan ini
    );
  }
}
```

### Option 2: Stream-based (Recommended)
```dart
import 'services/auth_gate.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StyleAI',
      home: StreamAuthGate(), // ← Lebih responsive
    );
  }
}
```

### Option 3: With State Provider
```dart
import 'services/auth_gate.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthStateWrapper(
      child: MaterialApp(
        title: 'StyleAI',
        home: StreamAuthGate(),
      ),
    );
  }
}
```

---

## 💡 Contoh Use Cases

### 1. Protected Profile Page
```dart
class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      child: _buildProfileContent(),
    );
  }

  Widget _buildProfileContent() {
    final user = Supabase.instance.client.auth.currentUser!;
    
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: Column(
        children: [
          Text('Email: ${user.email}'),
          Text('ID: ${user.id}'),
          ElevatedButton(
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              // StreamAuthGate akan auto redirect ke login
            },
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }
}
```

### 2. Admin-Only Settings
```dart
class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RoleGuard(
      allowedRoles: ['admin'],
      child: AdminSettings(),
      fallback: UserSettings(),
    );
  }
}
```

### 3. Check Auth State Anywhere
```dart
class HeaderWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    
    return Row(
      children: [
        if (user != null)
          Text('Welcome, ${user.email}')
        else
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SupabaseLoginPage(),
                ),
              );
            },
            child: Text('Login'),
          ),
      ],
    );
  }
}
```

---

## 🔧 Kustomisasi

### Custom Loading Widget
```dart
class CustomAuthGate extends StatefulWidget {
  @override
  State<CustomAuthGate> createState() => _CustomAuthGateState();
}

class _CustomAuthGateState extends State<CustomAuthGate> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(Duration(seconds: 2)); // Splash screen delay
    
    final session = Supabase.instance.client.auth.currentSession;
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => session != null 
            ? HomePage() 
            : SupabaseLoginPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome, size: 100),
            SizedBox(height: 20),
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('StyleAI Loading...'),
          ],
        ),
      ),
    );
  }
}
```

---

## ⚠️ Troubleshooting

**Problem: "StreamBuilder tidak update setelah login"**
- ✅ Gunakan `StreamAuthGate` bukan `AuthGate`
- ✅ Pastikan tidak ada multiple Navigator.push yang conflict

**Problem: "User masih bisa akses protected page"**
- ✅ Wrap page dengan `AuthGuard`
- ✅ Check apakah Supabase sudah di-initialize

**Problem: "Infinite loading"**
- ✅ Pastikan Supabase URL dan key sudah benar
- ✅ Check internet connection
- ✅ Tambah error handling

---

## 📚 Best Practices

1. ✅ Gunakan `StreamAuthGate` untuk auto-redirect
2. ✅ Wrap protected pages dengan `AuthGuard`
3. ✅ Simpan sensitive data di `user.userMetadata`
4. ✅ Selalu handle error state
5. ✅ Test di berbagai kondisi (online/offline)

---

## 🎯 Next Steps

Setelah setup Auth Gate, Anda bisa:
- [ ] Tambah Remember Me feature
- [ ] Implement biometric auth
- [ ] Add session timeout
- [ ] Create user onboarding flow
- [ ] Implement role-based navigation
