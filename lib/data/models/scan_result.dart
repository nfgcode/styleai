import 'fashion_item.dart';

/// Formality level of outfit
enum FormalityLevel {
  casual,
  businessCasual,
  formal;

  String get displayName {
    switch (this) {
      case FormalityLevel.casual:
        return 'Casual';
      case FormalityLevel.businessCasual:
        return 'Business Casual';
      case FormalityLevel.formal:
        return 'Formal';
    }
  }
}

/// Result from scanning an outfit
class ScanResult {
  final String id;
  final DateTime timestamp;
  final List<FashionItem> items;
  final List<String> primaryColors;
  final List<String> patterns;
  final FormalityLevel formalityLevel;
  final double formalityScore; // 0-100
  final String? imageUrl;
  final String? localImagePath;
  final Map<String, dynamic>? metadata;

  ScanResult({
    required this.id,
    required this.timestamp,
    required this.items,
    required this.primaryColors,
    required this.patterns,
    required this.formalityLevel,
    required this.formalityScore,
    this.imageUrl,
    this.localImagePath,
    this.metadata,
  });

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    return ScanResult(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      items: (json['items'] as List)
          .map((item) => FashionItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      primaryColors: List<String>.from(json['primary_colors'] as List),
      patterns: List<String>.from(json['patterns'] as List),
      formalityLevel: FormalityLevel.values.firstWhere(
        (level) => level.name == json['formality_level'],
        orElse: () => FormalityLevel.casual,
      ),
      formalityScore: (json['formality_score'] as num).toDouble(),
      imageUrl: json['image_url'] as String?,
      localImagePath: json['local_image_path'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'primary_colors': primaryColors,
      'patterns': patterns,
      'formality_level': formalityLevel.name,
      'formality_score': formalityScore,
      'image_url': imageUrl,
      'local_image_path': localImagePath,
      'metadata': metadata,
    };
  }

  /// Get summary of detected items
  String get itemsSummary {
    final categories = items.map((item) => item.category).toSet();
    return categories.join(', ');
  }

  /// Get color palette summary
  String get colorSummary {
    return primaryColors.take(3).join(', ');
  }
}
