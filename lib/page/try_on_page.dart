import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../l10n/app_localizations.dart';
import '../utils/global_variable.dart';
import '../data/repositories/history_repository.dart';
import '../data/models/history_entry.dart';
import '../data/models/product_link.dart';

class OutfitItem {
  final String category;
  final String description;
  final String link;

  OutfitItem({
    required this.category,
    required this.description,
    required this.link,
  });

  factory OutfitItem.fromJson(Map<String, dynamic> json) {
    return OutfitItem(
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      link: json['link'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'description': description,
      'link': link,
    };
  }
}

class TryOnPage extends StatefulWidget {
  final bool isTab;
  const TryOnPage({super.key, this.isTab = false});

  @override
  State<TryOnPage> createState() => _TryOnPageState();
}

class _TryOnPageState extends State<TryOnPage> {
  File? imageFile;
  Uint8List? imageBytes;
  Uint8List? resultImageBytes;
  final imagePicker = ImagePicker();
  List<OutfitItem> outfitItems = [];
  String aiAnalysisMarkdown = '';
  bool _isLoading = false;
  bool _isFavorite = false;
  String? _currentHistoryId; // Track current saved history entry
  final _supabase = Supabase.instance.client;
  final HistoryRepository _historyRepo = HistoryRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade50,
              Colors.purple.shade50,
              Colors.pink.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom AppBar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    if (!widget.isTab)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    if (!widget.isTab) const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context).tryOnTitle,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Main Content
              Expanded(
                child: _buildMainContent(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: (imageFile != null || imageBytes != null) && !_isLoading && resultImageBytes == null
          ? Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.purple.shade400],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                onPressed: _analyzeImage,
                backgroundColor: Colors.transparent,
                elevation: 0,
                icon: const Icon(Icons.auto_awesome, color: Colors.white),
                label: const Text(
                  'Analyze Style',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildMainContent() {
    // Jika ada result, tampilkan full result card saja tanpa upload card
    if (resultImageBytes != null) {
      return _buildResultCard();
    }
    
    // Jika belum ada result, tampilkan upload card
    return Column(
      children: [
        Expanded(
          child: _buildImageUploadCard(),
        ),
      ],
    );
  }

  Widget _buildImageUploadCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Image Display
          if (imageBytes != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Image.memory(
                imageBytes!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            )
          else if (imageFile != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Image.file(
                imageFile!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            )
          else
            // Empty State
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue.shade100.withValues(alpha: 0.3),
                    Colors.purple.shade100.withValues(alpha: 0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withValues(alpha: 0.2),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.person_outline,
                      size: 80,
                      color: Colors.blue.shade400,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    AppLocalizations.of(context).tryOnUploadBody,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    AppLocalizations.of(context).tryOnLetAI,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

          // Upload Button
          Positioned(
            bottom: 24,
            child: GestureDetector(
              onTap: _showImagePickerOptions,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.purple.shade400],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withValues(alpha: 0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add_photo_alternate, size: 20, color: Colors.white),
                    const SizedBox(width: 10),
                    Text(
                      imageFile != null || imageBytes != null ? AppLocalizations.of(context).tryOnChangePhoto : AppLocalizations.of(context).tryOnUpload,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Loading Overlay
          if (_isLoading)
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      AppLocalizations.of(context).tryOnAnalyzing,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context).tryOnFindingOutfits,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
          // Header with gradient
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade400, Colors.purple.shade400],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'AI Recommended Outfit',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    icon: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      size: 20,
                      color: _isFavorite ? Colors.red.shade300 : Colors.white,
                    ),
                    onPressed: _toggleFavorite,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close, size: 20, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        resultImageBytes = null;
                        outfitItems = [];
                        aiAnalysisMarkdown = '';
                        _isFavorite = false;
                        _currentHistoryId = null;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          // Image Display
          Container(
            margin: const EdgeInsets.all(16),
            height: 400,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.memory(
                resultImageBytes!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
          // AI Analysis Markdown Output
          if (aiAnalysisMarkdown.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: MarkdownBody(
                  data: aiAnalysisMarkdown,
                  styleSheet: MarkdownStyleSheet(
                    h1: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                    h2: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade800,
                      height: 2,
                    ),
                    h3: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink.shade700,
                      height: 1.8,
                    ),
                    p: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: Colors.grey.shade800,
                    ),
                    strong: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                    listBullet: TextStyle(
                      color: Colors.purple.shade600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          // Quick Shopping Links
          if (outfitItems.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.shopping_bag, color: Colors.blue.shade700, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          Localizations.localeOf(context).languageCode == 'id'
                              ? '🛍️ Link Belanja Cepat'
                              : '🛍️ Quick Shopping Links',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...outfitItems.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _launchLink(item.link),
                          icon: const Icon(Icons.shopping_cart_outlined, size: 16),
                          label: Text(item.category),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    )).toList(),
                  ],
                ),
              ),
            ),
        ],
      ),
    ),
    );
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(AppLocalizations.of(context).gallery),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(AppLocalizations.of(context).camera),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await imagePicker.pickImage(source: source);
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          imageBytes = bytes;
          imageFile = null;
          outfitItems = [];
          _currentHistoryId = null;
          _isFavorite = false;
        });
      } else {
        setState(() {
          imageFile = File(pickedFile.path);
          imageBytes = null;
          outfitItems = [];
          _currentHistoryId = null;
          _isFavorite = false;
        });
      }
    }
  }

  Future<String?> _saveToHistory(String analysis, List<OutfitItem> items, bool isIndonesian) async {
    try {
      // Create product links from outfit items
      final productLinks = items.asMap().entries.map((entry) => ProductLink(
        id: '${DateTime.now().millisecondsSinceEpoch}_${entry.key}',
        title: entry.value.category,
        source: isIndonesian ? 'Rekomendasi AI' : 'AI Recommendation',
        url: entry.value.link,
      )).toList();

      // Create history entry with current favorite state
      final entry = HistoryEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: HistoryType.tryon,
        title: isIndonesian ? 'Rekomendasi Style AI' : 'AI Style Recommendation',
        description: analysis.length > 150 
            ? '${analysis.substring(0, 150)}...' 
            : analysis,
        thumbnailUrl: null, // Could upload image to Supabase Storage in future
        createdAt: DateTime.now(),
        payload: {
          'analysis': analysis,
          'outfitItems': items.map((item) => item.toJson()).toList(),
          'productLinks': productLinks.map((link) => link.toJson()).toList(),
        },
        isFavorite: _isFavorite, // Use current favorite state
      );

      final savedId = await _historyRepo.saveHistory(entry);
      debugPrint('✅ Try-on history saved successfully with ID: $savedId');
      return savedId;
    } catch (e) {
      debugPrint('⚠️ Failed to save try-on history: $e');
      return null;
    }
  }

  Future<void> _analyzeImage() async {
    if (imageFile == null && imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).pleaseUpload)),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      aiAnalysisMarkdown = '';
      outfitItems = [];
    });

    // Detect user's language
    final isIndonesian = Localizations.localeOf(context).languageCode == 'id';

    try {
      // Initialize Gemini AI
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: apiKey,
      );

      // Prepare image data
      final imageData = imageBytes ?? await File(imageFile!.path).readAsBytes();

      // Create prompt based on language
      final prompt = isIndonesian
          ? '''Analisis foto ini dan berikan rekomendasi style outfit yang cocok.

Format output HARUS dalam Markdown dengan struktur berikut:

# 🎨 Analisis Style

## 👤 Deskripsi Penampilan Saat Ini
[Jelaskan apa yang terlihat di foto - warna, style, karakteristik]

## ✨ Rekomendasi Outfit

### 1. Casual Style
**Deskripsi:** [Penjelasan detail outfit casual yang cocok]
**Item Utama:** [List item-item pakaian]
**Warna:** [Kombinasi warna yang disarankan]
**Cocok untuk:** [Occasion/acara yang sesuai]

### 2. Smart Casual
**Deskripsi:** [Penjelasan detail outfit smart casual yang cocok]
**Item Utama:** [List item-item pakaian]
**Warna:** [Kombinasi warna yang disarankan]
**Cocok untuk:** [Occasion/acara yang sesuai]

### 3. Formal Look
**Deskripsi:** [Penjelasan detail outfit formal yang cocok]
**Item Utama:** [List item-item pakaian]
**Warna:** [Kombinasi warna yang disarankan]
**Cocok untuk:** [Occasion/acara yang sesuai]

### 4. Street Style
**Deskripsi:** [Penjelasan detail outfit street style yang cocok]
**Item Utama:** [List item-item pakaian]
**Warna:** [Kombinasi warna yang disarankan]
**Cocok untuk:** [Occasion/acara yang sesuai]

## 💡 Tips Styling
- [Tip 1]
- [Tip 2]
- [Tip 3]

Berikan rekomendasi yang spesifik, praktis, dan mudah diterapkan.'''
          : '''Analyze this photo and provide suitable outfit style recommendations.

Output MUST be in Markdown format with the following structure:

# 🎨 Style Analysis

## 👤 Current Appearance Description
[Describe what you see in the photo - colors, style, characteristics]

## ✨ Outfit Recommendations

### 1. Casual Style
**Description:** [Detailed explanation of suitable casual outfit]
**Main Items:** [List of clothing items]
**Colors:** [Suggested color combinations]
**Perfect for:** [Suitable occasions/events]

### 2. Smart Casual
**Description:** [Detailed explanation of suitable smart casual outfit]
**Main Items:** [List of clothing items]
**Colors:** [Suggested color combinations]
**Perfect for:** [Suitable occasions/events]

### 3. Formal Look
**Description:** [Detailed explanation of suitable formal outfit]
**Main Items:** [List of clothing items]
**Colors:** [Suggested color combinations]
**Perfect for:** [Suitable occasions/events]

### 4. Street Style
**Description:** [Detailed explanation of suitable street style outfit]
**Main Items:** [List of clothing items]
**Colors:** [Suggested color combinations]
**Perfect for:** [Suitable occasions/events]

## 💡 Styling Tips
- [Tip 1]
- [Tip 2]
- [Tip 3]

Provide specific, practical, and easy-to-apply recommendations.''';

      // Generate AI response
      final content = [
        Content.multi([
          DataPart('image/jpeg', imageData),
          TextPart(prompt),
        ])
      ];

      final response = await model.generateContent(content).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('AI analysis timed out');
        },
      );

      final markdownText = response.text ?? '';

      if (markdownText.isEmpty) {
        throw Exception(isIndonesian ? 'AI tidak memberikan respons' : 'AI did not provide a response');
      }

      // Parse markdown to extract outfit items for shopping links
      final List<OutfitItem> items = _parseMarkdownToOutfitItems(markdownText, isIndonesian);

      setState(() {
        aiAnalysisMarkdown = markdownText;
        outfitItems = items;
        resultImageBytes = imageData;
        _isFavorite = false;
      });

      // Save to history and store the ID
      final savedId = await _saveToHistory(markdownText, items, isIndonesian);
      if (savedId != null) {
        setState(() {
          _currentHistoryId = savedId;
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isIndonesian 
              ? '✨ Analisis style berhasil! Scroll untuk melihat rekomendasi lengkap.'
              : '✨ Style analysis complete! Scroll to see full recommendations.'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }

    } catch (e) {
      setState(() {
        aiAnalysisMarkdown = '';
        outfitItems = [];
      });
      
      if (mounted) {
        String errorMessage = e.toString();
        if (e is TimeoutException) {
          errorMessage = isIndonesian
              ? 'Timeout: Analisis memakan waktu terlalu lama. Silakan coba lagi.'
              : 'Timeout: Analysis took too long. Please try again.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isIndonesian
              ? 'Terjadi kesalahan: $errorMessage'
              : 'An error occurred: $errorMessage'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Helper function to parse markdown and extract outfit items for shopping
  List<OutfitItem> _parseMarkdownToOutfitItems(String markdown, bool isIndonesian) {
    final List<OutfitItem> items = [];
    
    // Simple regex patterns to extract outfit sections
    final casualMatch = RegExp(r'### 1\. (.*?)\n', multiLine: true).firstMatch(markdown);
    final smartMatch = RegExp(r'### 2\. (.*?)\n', multiLine: true).firstMatch(markdown);
    final formalMatch = RegExp(r'### 3\. (.*?)\n', multiLine: true).firstMatch(markdown);
    final streetMatch = RegExp(r'### 4\. (.*?)\n', multiLine: true).firstMatch(markdown);
    
    if (casualMatch != null) {
      items.add(OutfitItem(
        category: casualMatch.group(1) ?? 'Casual Style',
        description: isIndonesian ? 'Lihat detail lengkap di analisis AI' : 'See full details in AI analysis',
        link: 'https://www.google.com/search?tbm=shop&q=casual+outfit',
      ));
    }
    
    if (smartMatch != null) {
      items.add(OutfitItem(
        category: smartMatch.group(1) ?? 'Smart Casual',
        description: isIndonesian ? 'Lihat detail lengkap di analisis AI' : 'See full details in AI analysis',
        link: 'https://www.google.com/search?tbm=shop&q=smart+casual+outfit',
      ));
    }
    
    if (formalMatch != null) {
      items.add(OutfitItem(
        category: formalMatch.group(1) ?? 'Formal Look',
        description: isIndonesian ? 'Lihat detail lengkap di analisis AI' : 'See full details in AI analysis',
        link: 'https://www.google.com/search?tbm=shop&q=formal+outfit',
      ));
    }
    
    if (streetMatch != null) {
      items.add(OutfitItem(
        category: streetMatch.group(1) ?? 'Street Style',
        description: isIndonesian ? 'Lihat detail lengkap di analisis AI' : 'See full details in AI analysis',
        link: 'https://www.google.com/search?tbm=shop&q=street+style+outfit',
      ));
    }
    
    return items;
  }

  Future<void> _toggleFavorite() async {
    if (resultImageBytes == null || outfitItems.isEmpty) return;

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please login to save favorites'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final isIndonesian = Localizations.localeOf(context).languageCode == 'id';
      
      // Update favorite state first
      setState(() {
        _isFavorite = !_isFavorite;
      });

      // If not saved yet, save to history with favorite state
      if (_currentHistoryId == null) {
        debugPrint('📝 Saving new history entry with favorite state: $_isFavorite');
        final savedId = await _saveToHistory(aiAnalysisMarkdown, outfitItems, isIndonesian);
        if (savedId != null) {
          setState(() {
            _currentHistoryId = savedId;
          });
          debugPrint('✅ History saved with ID: $savedId, isFavorite: $_isFavorite');
        }
      } else {
        // If already saved, toggle favorite in database
        debugPrint('🔄 Toggling favorite for existing entry: $_currentHistoryId');
        await _historyRepo.toggleFavorite(_currentHistoryId!);
        debugPrint('✅ Favorite toggled successfully for ID: $_currentHistoryId, new state: $_isFavorite');
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isFavorite 
              ? (isIndonesian ? 'Berhasil ditambahkan ke favorit! ❤️' : 'Added to favorites! ❤️')
              : (isIndonesian ? 'Dihapus dari favorit' : 'Removed from favorites')),
            backgroundColor: _isFavorite ? Colors.green : Colors.grey,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Failed to toggle favorite: $e');
      // Revert state on error
      setState(() {
        _isFavorite = !_isFavorite;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save favorite: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _launchLink(String link) async {
    if (link.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No shopping link available')),
      );
      return;
    }

    final uri = Uri.parse(link);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open shopping link')),
        );
      }
    }
  }
}
