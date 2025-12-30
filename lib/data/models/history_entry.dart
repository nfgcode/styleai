import 'scan_result.dart';
import 'product_link.dart';

/// Type of history entry
enum HistoryType {
  scan,
  chat,
  tryon;

  String get displayName {
    switch (this) {
      case HistoryType.scan:
        return 'Outfit Scan';
      case HistoryType.chat:
        return 'AI Recommendation';
      case HistoryType.tryon:
        return 'Virtual Try-On';
    }
  }
}

/// History entry for user activities
class HistoryEntry {
  final String id;
  final HistoryType type;
  final DateTime createdAt;
  final String title;
  final String? description;
  final String? thumbnailUrl;
  final String? localThumbnailPath;
  final Map<String, dynamic> payload;
  final bool isFavorite;

  HistoryEntry({
    required this.id,
    required this.type,
    required this.createdAt,
    required this.title,
    this.description,
    this.thumbnailUrl,
    this.localThumbnailPath,
    required this.payload,
    this.isFavorite = false,
  });

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    return HistoryEntry(
      id: json['id'] as String,
      type: HistoryType.values.firstWhere(
        (type) => type.name == json['type'],
        orElse: () => HistoryType.scan,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      title: json['title'] as String,
      description: json['description'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      localThumbnailPath: json['local_thumbnail_path'] as String?,
      payload: json['payload'] as Map<String, dynamic>,
      isFavorite: json['is_favorite'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'created_at': createdAt.toIso8601String(),
      'title': title,
      'description': description,
      'thumbnail_url': thumbnailUrl,
      'local_thumbnail_path': localThumbnailPath,
      'payload': payload,
      'is_favorite': isFavorite,
    };
  }

  /// Create from scan result
  factory HistoryEntry.fromScanResult(ScanResult scanResult) {
    return HistoryEntry(
      id: scanResult.id,
      type: HistoryType.scan,
      createdAt: scanResult.timestamp,
      title: 'Outfit Scan',
      description: scanResult.itemsSummary,
      thumbnailUrl: scanResult.imageUrl,
      localThumbnailPath: scanResult.localImagePath,
      payload: scanResult.toJson(),
    );
  }

  /// Create from recommendation
  factory HistoryEntry.fromRecommendation(RecommendationResponse recommendation) {
    return HistoryEntry(
      id: recommendation.id,
      type: HistoryType.chat,
      createdAt: recommendation.timestamp,
      title: 'AI Recommendation',
      description: recommendation.adviceText.length > 100
          ? '${recommendation.adviceText.substring(0, 100)}...'
          : recommendation.adviceText,
      payload: recommendation.toJson(),
    );
  }

  HistoryEntry copyWith({
    String? id,
    HistoryType? type,
    DateTime? createdAt,
    String? title,
    String? description,
    String? thumbnailUrl,
    String? localThumbnailPath,
    Map<String, dynamic>? payload,
    bool? isFavorite,
  }) {
    return HistoryEntry(
      id: id ?? this.id,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      localThumbnailPath: localThumbnailPath ?? this.localThumbnailPath,
      payload: payload ?? this.payload,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
