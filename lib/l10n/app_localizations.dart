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
      'navHome': 'Home',
      'navTryOn': 'Try-On',
      'navCart': 'Cart',
      'navProfile': 'Profile',
      'tryOnTitle': 'Try-On AI Image',
      'tryOnUpload': 'Upload Photo',
      'tryOnAnalysis': 'AI Analysis',
      'tryOnPrompt': 'Analyze this outfit and provide style advice in English. Include purchase links for suggested items.',
      'gallery': 'Gallery',
      'camera': 'Camera',
      'pleaseUpload': 'Please upload an image first',
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
      'navHome': 'Beranda',
      'navTryOn': 'Coba Gaya',
      'navCart': 'Keranjang',
      'navProfile': 'Profil',
      'tryOnTitle': 'Coba Gaya AI',
      'tryOnUpload': 'Unggah Foto',
      'tryOnAnalysis': 'Saran AI',
      'tryOnPrompt': 'Analisis pakaian ini dan berikan saran gaya yang cocok dalam bahasa Indonesia. Sertakan juga link pembelian untuk item yang disarankan (bisa berupa link pencarian ke e-commerce seperti Shopee atau Tokopedia).',
      'gallery': 'Galeri',
      'camera': 'Kamera',
      'pleaseUpload': 'Silakan unggah gambar terlebih dahulu',
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
