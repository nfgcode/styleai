# StyleAI - AI-Powered Fashion Assistant

Flutter application dengan fitur AI fashion assistant dan authentication menggunakan Supabase.

## 🚀 Quick Start

### 1. Setup API Keys

#### Gemini API (untuk AI Assistant)
```bash
# Copy template file
cp lib/utils/global_variable.dart.example lib/utils/global_variable.dart

# Edit file dan ganti dengan API key Anda
# Dapatkan API key di: https://makersuite.google.com/app/apikey
```

#### Supabase (untuk Authentication)
Ikuti langkah mudah di file **[SUPABASE_QUICK_START.md](SUPABASE_QUICK_START.md)**

Atau lihat dokumentasi lengkap di **[SUPABASE_AUTH_SETUP.md](SUPABASE_AUTH_SETUP.md)**

### 2. Run Aplikasi
```bash
flutter run -d chrome
```

## 📁 File Penting

- **`supabase_schema.sql`** - SQL script untuk setup database (copy-paste ke Supabase SQL Editor)
- **`supabase_fix_trigger.sql`** - Fix untuk error "Database error saving new user"
- **`SUPABASE_QUICK_START.md`** - Panduan cepat 5 menit
- **`SUPABASE_AUTH_SETUP.md`** - Dokumentasi lengkap setup & troubleshooting

## ✨ Features

- ✅ **Authentication** - Login/Register dengan Supabase
- ✅ **User Profile** - Auto-create profile saat register
- ✅ **AI Assistant** - Chat dengan Gemini AI untuk fashion advice
- ✅ **Product Catalog** - Browse fashion items
- ✅ **Try-On History** - Simpan riwayat AI try-on (coming soon)
- ✅ **Multi-language** - Support Bahasa Indonesia & English

## 🛠 Tech Stack

- **Flutter** - UI Framework
- **Supabase** - Backend & Authentication
- **Google Generative AI** - AI Assistant (Gemini)
- **SharedPreferences** - Local storage (fallback auth)

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
