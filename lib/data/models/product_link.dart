/// Product link recommendation
class ProductLink {
  final String id;
  final String title;
  final String url;
  final String source; // tokopedia, shopee, zalora, dll
  final double? price;
  final String? imageUrl;
  final String? category;
  final Map<String, dynamic>? metadata;

  ProductLink({
    required this.id,
    required this.title,
    required this.url,
    required this.source,
    this.price,
    this.imageUrl,
    this.category,
    this.metadata,
  });

  factory ProductLink.fromJson(Map<String, dynamic> json) {
    return ProductLink(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] as String,
      url: json['url'] as String,
      source: json['source'] as String,
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      imageUrl: json['image_url'] as String?,
      category: json['category'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'source': source,
      'price': price,
      'image_url': imageUrl,
      'category': category,
      'metadata': metadata,
    };
  }

  /// Format price as currency string
  String get formattedPrice {
    if (price == null) return 'Price not available';
    return 'Rp ${price!.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}';
  }
}

/// Gemini recommendation response
class RecommendationResponse {
  final String id;
  final DateTime timestamp;
  final String adviceText;
  final List<String> styleRecommendations;
  final List<ProductLink> productLinks;
  final Map<String, dynamic>? metadata;

  RecommendationResponse({
    required this.id,
    required this.timestamp,
    required this.adviceText,
    required this.styleRecommendations,
    required this.productLinks,
    this.metadata,
  });

  factory RecommendationResponse.fromJson(Map<String, dynamic> json) {
    return RecommendationResponse(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      adviceText: json['advice_text'] as String,
      styleRecommendations: List<String>.from(json['style_recommendations'] as List),
      productLinks: (json['product_links'] as List)
          .map((link) => ProductLink.fromJson(link as Map<String, dynamic>))
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'advice_text': adviceText,
      'style_recommendations': styleRecommendations,
      'product_links': productLinks.map((link) => link.toJson()).toList(),
      'metadata': metadata,
    };
  }
}
