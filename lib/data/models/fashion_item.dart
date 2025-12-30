/// Fashion item detected from image
class FashionItem {
  final String category; // Atasan, Bawahan, Sepatu, Kacamata, Topi
  final double confidence;
  final BoundingBox? bbox;
  final String color;
  final String pattern; // Polos, Bergaris, Kotak-kotak, Bermotif
  final Map<String, dynamic>? metadata;

  FashionItem({
    required this.category,
    required this.confidence,
    this.bbox,
    required this.color,
    required this.pattern,
    this.metadata,
  });

  factory FashionItem.fromJson(Map<String, dynamic> json) {
    return FashionItem(
      category: json['category'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      bbox: json['bbox'] != null 
          ? BoundingBox.fromJson(json['bbox'] as Map<String, dynamic>)
          : null,
      color: json['color'] as String,
      pattern: json['pattern'] as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'confidence': confidence,
      'bbox': bbox?.toJson(),
      'color': color,
      'pattern': pattern,
      'metadata': metadata,
    };
  }
}

/// Bounding box for detected item
class BoundingBox {
  final double x;
  final double y;
  final double width;
  final double height;

  BoundingBox({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  factory BoundingBox.fromJson(Map<String, dynamic> json) {
    return BoundingBox(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      'width': width,
      'height': height,
    };
  }
}
