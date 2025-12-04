import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import '../utils/global_variable.dart';

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
  String strAnswer = '';
  String purchaseLink = '';
  bool _isLoading = false;
  bool _isFavorite = false;
  final _supabase = Supabase.instance.client;

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
      floatingActionButton: (imageFile != null || imageBytes != null) && !_isLoading
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
    return Column(
      children: [
        // Input Image Section
        Expanded(
          flex: resultImageBytes != null ? 1 : 2,
          child: _buildImageUploadCard(),
        ),
        // Result Image Section
        if (resultImageBytes != null)
          Expanded(
            flex: 2,
            child: _buildResultCard(),
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
                  const Text(
                    'Upload Full Body Photo',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Let AI find your perfect outfit',
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
                      imageFile != null || imageBytes != null ? 'Change Photo' : AppLocalizations.of(context).tryOnUpload,
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
                    const Text(
                      'Analyzing your style...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'AI is finding perfect outfits for you',
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
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 20),
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
                        strAnswer = '';
                        purchaseLink = '';
                        _isFavorite = false;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          // Image Display
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
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
                ),
              ),
            ),
          ),
          // Description Card with full text (scrollable)
          if (strAnswer.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_awesome, color: Colors.blue.shade600, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'AI Recommendations',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      strAnswer,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),
          // Purchase Button with gradient
          if (purchaseLink.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade400, Colors.teal.shade400],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withValues(alpha: 0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _launchPurchaseLink,
                  icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
                  label: const Text(
                    'Shop Now',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Widget _buildStyleItem(String imageUrl) {
  //   return Container(
  //     width: 80,
  //     margin: const EdgeInsets.only(right: 15),
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(15),
  //       image: DecorationImage(
  //         image: NetworkImage(imageUrl),
  //         fit: BoxFit.cover,
  //       ),
  //     ),
  //   );
  // }

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
          strAnswer = '';
        });
      } else {
        setState(() {
          imageFile = File(pickedFile.path);
          imageBytes = null;
          strAnswer = '';
        });
      }
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
    });

    try {
      final GenerativeModel model = GenerativeModel(
          model: 'gemini-3-pro', apiKey: apiKey);

      final List<Content> contents = [
        Content.multi([
          TextPart(AppLocalizations.of(context).tryOnPrompt),
          if (imageBytes != null)
            DataPart('image/jpeg', imageBytes!)
          else if (imageFile != null)
            DataPart('image/jpeg', File(imageFile!.path).readAsBytesSync()),
        ])
      ];

      final response = await model.generateContent(contents);
      final resultText = response.text ?? 'No analysis available.';
      
      // Extract all links (including search suggestions)
      final linkPattern = RegExp(r'https?://[^\s]+');
      final matches = linkPattern.allMatches(resultText);
      String firstLink = '';
      if (matches.isNotEmpty) {
        firstLink = matches.first.group(0) ?? '';
      }
      
      setState(() {
        strAnswer = resultText;
        purchaseLink = firstLink;
        // Set resultImageBytes to show result card (use input image as placeholder)
        resultImageBytes = imageBytes ?? File(imageFile!.path).readAsBytesSync();
        _isFavorite = false; // Reset favorite status for new analysis
      });

    } catch (e) {
      setState(() {
        strAnswer = 'Error: ${e.toString()}';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Analysis failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (resultImageBytes == null || strAnswer.isEmpty) return;

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

      if (_isFavorite) {
        // Remove from favorites (optional: implement removal from database)
        setState(() {
          _isFavorite = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Removed from favorites'),
              backgroundColor: Colors.grey,
            ),
          );
        }
      } else {
        // Add to favorites
        final prefs = await SharedPreferences.getInstance();
        final favoritesList = prefs.getStringList('favorites') ?? [];
        
        // Save to local storage
        final favoriteItem = '${DateTime.now().millisecondsSinceEpoch}|||$strAnswer|||$purchaseLink';
        favoritesList.add(favoriteItem);
        await prefs.setStringList('favorites', favoritesList);

        // Optionally save to Supabase
        try {
          await _supabase.from('user_favorites').insert({
            'user_id': user.id,
            'outfit_description': strAnswer,
            'purchase_link': purchaseLink,
            'created_at': DateTime.now().toIso8601String(),
          });
        } catch (e) {
          // Supabase save failed, but local save succeeded
          debugPrint('Supabase save failed: $e');
        }

        setState(() {
          _isFavorite = true;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Added to favorites! ❤️'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _launchPurchaseLink() async {
    if (purchaseLink.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No purchase link available')),
      );
      return;
    }

    final uri = Uri.parse(purchaseLink);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open purchase link')),
        );
      }
    }
  }
}
