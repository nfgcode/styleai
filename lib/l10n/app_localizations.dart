import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'getStartedTitle': 'StyleAI',
      'getStartedSubtitle': 'Take your Style\neverywhere with us',
      'getStartedButton': 'Get Started',
      'loginWelcome': 'Welcome Back',
      'loginButton': 'Login',
      'registerTitle': 'Create Account',
      'registerButton': 'Register',
      'homeTrending': 'Trending Now',
      'homeNew': 'New Arrivals',
      'homeShoes': 'Shoes',
      'homePromo': 'Special Promo!',
      'homeGetStyle': 'Get Style\nAdvice',
      'homeAskAI': 'Ask AI Now',
      'homeScanOutfit': 'Scan Outfit',
      'homeScanSubtitle': 'Analyze your style',
      'homeHistory': 'History',
      'homeHistorySubtitle': 'View past scans',
      'navHome': 'Home',
      'navTryOn': 'Try-On',
      'navCart': 'Cart',
      'navProfile': 'Profile',
      'tryOnTitle': 'Try-On AI Image',
      'tryOnUpload': 'Upload Photo',
      'tryOnAnalysis': 'AI Analysis',
      'tryOnPrompt': 'Analyze the person in this photo and recommend a complete outfit that matches their body type and style from head to toe. For each clothing item (top, bottom, shoes, accessories), provide: 1) Specific item recommendation, 2) Style description, 3) Shopping search link (e.g., "Search on Amazon: [item name]" or similar e-commerce platform). Format your response clearly with item categories.',
      'gallery': 'Gallery',
      'camera': 'Camera',
      'pleaseUpload': 'Please upload an image first',
      'tryOnUploadBody': 'Upload Full Body Photo',
      'tryOnLetAI': 'Let AI find your perfect outfit',
      'tryOnChangePhoto': 'Change Photo',
      'tryOnAnalyzing': 'Analyzing your style...',
      'tryOnFindingOutfits': 'AI is finding perfect outfits for you',
      'tryOnQuickShopping': 'Quick Shopping Links',
      'tryOnShopRecommendations': 'Shop Recommendations',
      'profileSettings': 'Profile Settings',
      'profileLogout': 'Logout',
      'profileConfirmLogout': 'Are you sure you want to logout?',
      'profileCancel': 'Cancel',
      'language': 'Language',
      'email': 'Email',
      'password': 'Password',
      'fullName': 'Full Name',
      'dontHaveAccount': "Don't have an account?",
      'alreadyHaveAccount': 'Already have an account?',
    },
    'id': {
      'getStartedTitle': 'StyleAI',
      'getStartedSubtitle': 'Bawa Gayamu\nke mana saja bersama kami',
      'getStartedButton': 'Mulai Sekarang',
      'loginWelcome': 'Selamat Datang Kembali',
      'loginButton': 'Masuk',
      'registerTitle': 'Buat Akun',
      'registerButton': 'Daftar',
      'homeTrending': 'Sedang Tren',
      'homeNew': 'Terbaru',
      'homeShoes': 'Sepatu',
      'homePromo': 'Promo Spesial!',
      'homeGetStyle': 'Dapatkan Saran\nGaya',
      'homeAskAI': 'Tanya AI Sekarang',
      'homeScanOutfit': 'Pindai Outfit',
      'homeScanSubtitle': 'Analisis gayamu',
      'homeHistory': 'Riwayat',
      'homeHistorySubtitle': 'Lihat riwayat scan',
      'navHome': 'Beranda',
      'navTryOn': 'Coba Gaya',
      'navCart': 'Keranjang',
      'navProfile': 'Profil',
      'tryOnTitle': 'Coba Gaya AI',
      'tryOnUpload': 'Unggah Foto',
      'tryOnAnalysis': 'Saran AI',
      'tryOnPrompt': 'Analisis orang dalam foto ini dan rekomendasikan outfit lengkap yang cocok dengan tipe tubuh dan gaya mereka dari kepala hingga kaki. Untuk setiap item pakaian (atasan, bawahan, sepatu, aksesoris), berikan: 1) Rekomendasi item spesifik, 2) Deskripsi gaya, 3) Link pencarian belanja (contoh: "Cari di Shopee: [nama item]" atau "Cari di Tokopedia: [nama item]"). Format jawaban Anda dengan jelas berdasarkan kategori item.',
      'gallery': 'Galeri',
      'camera': 'Kamera',
      'pleaseUpload': 'Silakan unggah gambar terlebih dahulu',
      'tryOnUploadBody': 'Unggah Foto Seluruh Badan',
      'tryOnLetAI': 'Biarkan AI temukan outfit sempurna Anda',
      'tryOnChangePhoto': 'Ganti Foto',
      'tryOnAnalyzing': 'Menganalisis gaya Anda...',
      'tryOnFindingOutfits': 'AI sedang menemukan outfit sempurna untuk Anda',
      'tryOnQuickShopping': 'Link Belanja Cepat',
      'tryOnShopRecommendations': 'Belanja Rekomendasi',
      'profileSettings': 'Pengaturan Profil',
      'profileLogout': 'Keluar',
      'profileConfirmLogout': 'Yakin ingin keluar?',
      'profileCancel': 'Batal',
      'language': 'Bahasa',
      'email': 'Email',
      'password': 'Kata Sandi',
      'fullName': 'Nama Lengkap',
      'dontHaveAccount': 'Belum punya akun?',
      'alreadyHaveAccount': 'Sudah punya akun?',
    },
  };

  String get getStartedTitle => _localizedValues[locale.languageCode]!['getStartedTitle']!;
  String get getStartedSubtitle => _localizedValues[locale.languageCode]!['getStartedSubtitle']!;
  String get getStartedButton => _localizedValues[locale.languageCode]!['getStartedButton']!;
  String get loginWelcome => _localizedValues[locale.languageCode]!['loginWelcome']!;
  String get loginButton => _localizedValues[locale.languageCode]!['loginButton']!;
  String get registerTitle => _localizedValues[locale.languageCode]!['registerTitle']!;
  String get registerButton => _localizedValues[locale.languageCode]!['registerButton']!;
  String get homeTrending => _localizedValues[locale.languageCode]!['homeTrending']!;
  String get homeNew => _localizedValues[locale.languageCode]!['homeNew']!;
  String get homeShoes => _localizedValues[locale.languageCode]!['homeShoes']!;
  String get homePromo => _localizedValues[locale.languageCode]!['homePromo']!;
  String get homeGetStyle => _localizedValues[locale.languageCode]!['homeGetStyle']!;
  String get homeAskAI => _localizedValues[locale.languageCode]!['homeAskAI']!;
  String get homeScanOutfit => _localizedValues[locale.languageCode]!['homeScanOutfit']!;
  String get homeScanSubtitle => _localizedValues[locale.languageCode]!['homeScanSubtitle']!;
  String get homeHistory => _localizedValues[locale.languageCode]!['homeHistory']!;
  String get homeHistorySubtitle => _localizedValues[locale.languageCode]!['homeHistorySubtitle']!;
  String get navHome => _localizedValues[locale.languageCode]!['navHome']!;
  String get navTryOn => _localizedValues[locale.languageCode]!['navTryOn']!;
  String get navCart => _localizedValues[locale.languageCode]!['navCart']!;
  String get navProfile => _localizedValues[locale.languageCode]!['navProfile']!;
  String get tryOnTitle => _localizedValues[locale.languageCode]!['tryOnTitle']!;
  String get tryOnUpload => _localizedValues[locale.languageCode]!['tryOnUpload']!;
  String get tryOnAnalysis => _localizedValues[locale.languageCode]!['tryOnAnalysis']!;
  String get tryOnPrompt => _localizedValues[locale.languageCode]!['tryOnPrompt']!;
  String get gallery => _localizedValues[locale.languageCode]!['gallery']!;
  String get camera => _localizedValues[locale.languageCode]!['camera']!;
  String get pleaseUpload => _localizedValues[locale.languageCode]!['pleaseUpload']!;
  String get tryOnUploadBody => _localizedValues[locale.languageCode]!['tryOnUploadBody']!;
  String get tryOnLetAI => _localizedValues[locale.languageCode]!['tryOnLetAI']!;
  String get tryOnChangePhoto => _localizedValues[locale.languageCode]!['tryOnChangePhoto']!;
  String get tryOnAnalyzing => _localizedValues[locale.languageCode]!['tryOnAnalyzing']!;
  String get tryOnFindingOutfits => _localizedValues[locale.languageCode]!['tryOnFindingOutfits']!;
  String get tryOnQuickShopping => _localizedValues[locale.languageCode]!['tryOnQuickShopping']!;
  String get tryOnShopRecommendations => _localizedValues[locale.languageCode]!['tryOnShopRecommendations']!;
  String get profileSettings => _localizedValues[locale.languageCode]!['profileSettings']!;
  String get profileLogout => _localizedValues[locale.languageCode]!['profileLogout']!;
  String get profileConfirmLogout => _localizedValues[locale.languageCode]!['profileConfirmLogout']!;
  String get profileCancel => _localizedValues[locale.languageCode]!['profileCancel']!;
  String get language => _localizedValues[locale.languageCode]!['language']!;
  String get email => _localizedValues[locale.languageCode]!['email']!;
  String get password => _localizedValues[locale.languageCode]!['password']!;
  String get fullName => _localizedValues[locale.languageCode]!['fullName']!;
  String get dontHaveAccount => _localizedValues[locale.languageCode]!['dontHaveAccount']!;
  String get alreadyHaveAccount => _localizedValues[locale.languageCode]!['alreadyHaveAccount']!;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'id'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
