import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../models/scan_result.dart';
import '../models/fashion_item.dart';

/// Repository for computer vision / fashion detection
class VisionRepository {
  // Untuk implementasi real, ini akan connect ke Vision API
  // Sementara gunakan mock data untuk development

  /// Scan outfit from image file
  Future<ScanResult> scanOutfit(File imageFile) async {
    // TODO: Implementasi real API call ke Vision API
    // await Future.delayed(const Duration(milliseconds: 500));
    
    // Mock implementation
    await Future.delayed(const Duration(seconds: 2));

    // Simulate API response
    return _mockScanResult(imageFile.path);
  }

  /// Scan outfit from camera
  Future<ScanResult?> scanFromCamera() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (image == null) return null;

    return scanOutfit(File(image.path));
  }

  /// Scan outfit from gallery
  Future<ScanResult?> scanFromGallery() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image == null) return null;

    return scanOutfit(File(image.path));
  }

  /// Mock scan result for development
  ScanResult _mockScanResult(String imagePath) {
    final items = [
      FashionItem(
        category: 'Atasan',
        confidence: 0.95,
        color: 'Putih',
        pattern: 'Polos',
        bbox: BoundingBox(x: 120, y: 150, width: 200, height: 250),
      ),
      FashionItem(
        category: 'Bawahan',
        confidence: 0.92,
        color: 'Biru Gelap',
        pattern: 'Denim',
        bbox: BoundingBox(x: 100, y: 400, width: 240, height: 300),
      ),
      FashionItem(
        category: 'Sepatu',
        confidence: 0.88,
        color: 'Hitam',
        pattern: 'Polos',
        bbox: BoundingBox(x: 90, y: 700, width: 260, height: 120),
      ),
    ];

    // Calculate formality score based on detected items
    double formalityScore = _calculateFormalityScore(items);
    FormalityLevel level = _determineFormalityLevel(formalityScore);

    return ScanResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      items: items,
      primaryColors: ['Putih', 'Biru Gelap', 'Hitam'],
      patterns: ['Polos', 'Denim'],
      formalityLevel: level,
      formalityScore: formalityScore,
      localImagePath: imagePath,
    );
  }

  /// Calculate formality score (0-100)
  double _calculateFormalityScore(List<FashionItem> items) {
    // Simple heuristic for formality
    double score = 50.0; // Base casual

    for (var item in items) {
      if (item.category == 'Atasan') {
        if (item.pattern.toLowerCase().contains('polo') ||
            item.pattern.toLowerCase().contains('kemeja')) {
          score += 15;
        }
      }
      if (item.category == 'Bawahan') {
        if (item.pattern.toLowerCase().contains('celana bahan') ||
            item.color.toLowerCase().contains('hitam')) {
          score += 15;
        }
        if (item.pattern.toLowerCase().contains('jeans') ||
            item.pattern.toLowerCase().contains('denim')) {
          score -= 10;
        }
      }
      if (item.category == 'Sepatu') {
        if (item.pattern.toLowerCase().contains('formal') ||
            item.pattern.toLowerCase().contains('pantofel')) {
          score += 20;
        }
      }
    }

    return score.clamp(0, 100);
  }

  /// Determine formality level from score
  FormalityLevel _determineFormalityLevel(double score) {
    if (score >= 70) return FormalityLevel.formal;
    if (score >= 40) return FormalityLevel.businessCasual;
    return FormalityLevel.casual;
  }

  /// Real API implementation template
  /// 
  /// ```dart
  /// Future<ScanResult> _callVisionAPI(File imageFile) async {
  ///   final request = http.MultipartRequest(
  ///     'POST',
  ///     Uri.parse('YOUR_VISION_API_URL/detect'),
  ///   );
  ///   
  ///   request.files.add(
  ///     await http.MultipartFile.fromPath('image', imageFile.path),
  ///   );
  ///   
  ///   final response = await request.send();
  ///   final responseData = await response.stream.bytesToString();
  ///   final json = jsonDecode(responseData);
  ///   
  ///   return ScanResult.fromJson(json);
  /// }
  /// ```
}
