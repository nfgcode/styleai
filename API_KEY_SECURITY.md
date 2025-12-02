# 🔐 Cara Melindungi API Key dari Git

## ✅ Yang Sudah Dilakukan

1. **File `global_variable.dart` sudah di-gitignore**
   - Ditambahkan ke `.gitignore` sebagai `lib/utils/global_variable.dart`
   - File ini TIDAK akan ter-commit ke repository
   - Aman dari tersebar ke public

2. **File sudah di-remove dari git cache**
   - Jika sebelumnya sudah ter-commit, sekarang sudah di-remove
   - History lama masih ada, tapi commit baru tidak akan include file ini

3. **File template dibuat**
   - File `global_variable.dart.example` sebagai contoh
   - Bisa di-share ke repository dengan aman
   - Developer lain bisa copy dan setup sendiri

## 📋 Untuk Developer Lain (Cara Setup)

### Step 1: Copy Template
```bash
cp lib/utils/global_variable.dart.example lib/utils/global_variable.dart
```

### Step 2: Dapatkan Gemini API Key
1. Buka https://makersuite.google.com/app/apikey
2. Login dengan Google Account
3. Klik **"Create API Key"**
4. Copy API key yang muncul

### Step 3: Update File
Edit `lib/utils/global_variable.dart`:
```dart
const String apiKey = 'PASTE_API_KEY_DISINI';
```

### Step 4: Verifikasi
```bash
# File ini TIDAK boleh muncul di git status
git status

# Jika muncul, berarti gitignore belum bekerja
# Jalankan: git rm --cached lib/utils/global_variable.dart
```

## ⚠️ PENTING: Jika API Key Sudah Ter-commit

Jika API key Anda sudah pernah ter-commit dan ter-push ke GitHub:

### 1. Revoke API Key Lama
1. Buka https://makersuite.google.com/app/apikey
2. Delete API key yang ter-expose
3. Buat API key baru

### 2. Clean Git History (Advanced)
```bash
# HATI-HATI: Ini akan rewrite history!
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch lib/utils/global_variable.dart" \
  --prune-empty --tag-name-filter cat -- --all

# Force push (DANGER!)
git push origin --force --all
```

> ⚠️ **WARNING:** Force push akan mengubah git history dan bisa break repository orang lain!

### 3. Solusi Lebih Aman
Buat repository baru dan migrate code tanpa file sensitif.

## 🔒 Best Practices

### DO ✅
- ✅ Selalu gunakan `.gitignore` untuk file dengan API keys
- ✅ Buat file `.example` sebagai template
- ✅ Dokumentasikan cara setup di README
- ✅ Gunakan environment variables untuk production
- ✅ Revoke API key jika ter-expose

### DON'T ❌
- ❌ JANGAN commit API keys langsung
- ❌ JANGAN hardcode API keys di code
- ❌ JANGAN share API keys via chat/email
- ❌ JANGAN gunakan API key yang sama untuk dev & production

## 📁 File Structure

```
styleai/
├── .gitignore                           # Include: lib/utils/global_variable.dart
├── lib/
│   └── utils/
│       ├── global_variable.dart         # ❌ GITIGNORED (your real API key)
│       └── global_variable.dart.example # ✅ SAFE (template tanpa API key)
└── README.md                            # Instruksi setup
```

## 🔍 Cara Cek Keamanan

### 1. Local Check
```bash
# File tidak boleh muncul di sini:
git status

# Cek gitignore bekerja:
git check-ignore -v lib/utils/global_variable.dart
# Output: .gitignore:36:lib/utils/global_variable.dart
```

### 2. GitHub Check
```bash
# Search di GitHub (setelah push)
# https://github.com/nfgcode/styleai
# Cari file: global_variable.dart
# Seharusnya TIDAK ketemu (kecuali .example)
```

### 3. Git History Check
```bash
# Cek apakah file pernah di-commit:
git log --all --full-history -- lib/utils/global_variable.dart

# Jika ada output, berarti pernah ter-commit
# Lakukan revoke API key!
```

## 🆘 Emergency: API Key Ter-expose

1. **Segera revoke** API key di Google AI Studio
2. **Buat API key baru** 
3. **Update** file `global_variable.dart` dengan key baru
4. **JANGAN** commit file dengan key lama
5. **Check** git history dengan command di atas

## ✅ Verification Checklist

- [ ] File `global_variable.dart` di-gitignore
- [ ] File `global_variable.dart` tidak muncul di `git status`
- [ ] File `global_variable.dart.example` di-commit
- [ ] README memiliki instruksi setup
- [ ] API key lama sudah di-revoke (jika pernah ter-commit)
- [ ] API key baru sudah di-setup

---

**Status Saat Ini:** ✅ AMAN - File sudah di-gitignore dan removed dari cache
