import 'package:flutter/material.dart';
import '../../../data/repositories/vision_repository.dart';
import 'scan_result_page.dart';

class ScanOutfitPage extends StatefulWidget {
  const ScanOutfitPage({super.key});

  @override
  State<ScanOutfitPage> createState() => _ScanOutfitPageState();
}

class _ScanOutfitPageState extends State<ScanOutfitPage> {
  final VisionRepository _visionRepo = VisionRepository();
  bool _isScanning = false;

  Future<void> _scanFromCamera() async {
    setState(() => _isScanning = true);

    try {
      final result = await _visionRepo.scanFromCamera();

      if (result != null && mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ScanResultPage(scanResult: result),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to scan outfit: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isScanning = false);
      }
    }
  }

  Future<void> _scanFromGallery() async {
    setState(() => _isScanning = true);

    try {
      final result = await _visionRepo.scanFromGallery();

      if (result != null && mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ScanResultPage(scanResult: result),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to scan outfit: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isScanning = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

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
              // AppBar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Scan Outfit',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: Center(
                  child: _isScanning
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: Colors.purple.shade400,
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Analyzing outfit...',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        )
                      : Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Icon
                              Container(
                                padding: const EdgeInsets.all(32),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.blue.shade400,
                                      Colors.purple.shade400,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.purple.withOpacity(0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.photo_camera,
                                  size: 64,
                                  color: Colors.white,
                                ),
                              ),

                              const SizedBox(height: 32),

                              // Title
                              const Text(
                                'Scan Your Outfit',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Description
                              Text(
                                'Take a photo or select from gallery to analyze your outfit and get AI-powered style recommendations',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade700,
                                  height: 1.5,
                                ),
                              ),

                              const SizedBox(height: 48),

                              // Camera Button
                              _buildActionButton(
                                icon: Icons.camera_alt,
                                label: 'Take Photo',
                                onTap: _scanFromCamera,
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blue.shade400,
                                    Colors.purple.shade400,
                                  ],
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Gallery Button
                              _buildActionButton(
                                icon: Icons.photo_library,
                                label: 'Choose from Gallery',
                                onTap: _scanFromGallery,
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.purple.shade400,
                                    Colors.pink.shade400,
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Gradient gradient,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
