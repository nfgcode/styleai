import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:styleai/service/database_service.dart';
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
  final imagePicker = ImagePicker();
  String strAnswer = '';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: widget.isTab
            ? null
            : IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade400,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                ),
                onPressed: () => Navigator.pop(context),
              ),
        automaticallyImplyLeading: !widget.isTab,
        title: Text(
          AppLocalizations.of(context).tryOnTitle,
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Main Image Area
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFD4E4E7),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Placeholder or Selected Image
                  if (imageBytes != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.memory(imageBytes!, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                    )
                  else if (imageFile != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.file(imageFile!, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                    )
                  else
                    Image.network(
                      'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?q=80&w=1000&auto=format&fit=crop',
                      fit: BoxFit.cover,
                    ),
                  
                  // Upload Button Overlay
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: GestureDetector(
                      onTap: _showImagePickerOptions,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                            )
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.camera_alt, size: 16, color: Colors.blue),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context).tryOnUpload, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // AI Analysis Result Overlay
                  if (strAnswer.isNotEmpty)
                     Positioned(
                      bottom: 80,
                      left: 20,
                      right: 20,
                      child: Container(
                        constraints: const BoxConstraints(maxHeight: 200),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            )
                          ],
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(AppLocalizations.of(context).tryOnAnalysis, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                                  GestureDetector(
                                    onTap: () => setState(() => strAnswer = ''),
                                    child: const Icon(Icons.close, size: 16, color: Colors.grey),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              MarkdownBody(
                                data: strAnswer,
                                selectable: true,
                                onTapLink: (text, href, title) async {
                                  if (href != null) {
                                    final Uri url = Uri.parse(href);
                                    if (await canLaunchUrl(url)) {
                                      await launchUrl(url);
                                    }
                                  }
                                },
                                styleSheet: MarkdownStyleSheet(
                                  p: const TextStyle(fontSize: 14, height: 1.4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator()),
                ],
              ),
            ),
          ),

        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _analyzeImage,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.auto_awesome),
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
          model: 'gemini-2.5-flash', apiKey: apiKey);

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
      
      setState(() {
        strAnswer = resultText;
      });

      // Save to Supabase
      if (resultText.isNotEmpty) {
        await DatabaseService().saveTryOnHistory(
          analysisResult: resultText,
          // imagePath: ... (If we implement storage upload later)
        );
      }
    } catch (e) {
      setState(() {
        strAnswer = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
