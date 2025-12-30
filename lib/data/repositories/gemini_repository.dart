import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/product_link.dart';
import '../models/scan_result.dart';

/// Repository for Gemini AI recommendations
class GeminiRepository {
  final GenerativeModel _model;

  GeminiRepository(String apiKey)
      : _model = GenerativeModel(
          model: 'gemini-pro',
          apiKey: apiKey,
        );

  /// Get style recommendations based on scan result
  Future<RecommendationResponse> getRecommendations({
    required ScanResult scanResult,
    String? userPreference,
  }) async {
    final prompt = _buildRecommendationPrompt(scanResult, userPreference);

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      // Parse response and extract product links
      final adviceText = response.text ?? 'No recommendations available';
      final productLinks = _parseProductLinks(adviceText);
      final styleRecommendations = _parseStyleRecommendations(adviceText);

      return RecommendationResponse(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now(),
        adviceText: adviceText,
        styleRecommendations: styleRecommendations,
        productLinks: productLinks,
      );
    } catch (e) {
      throw Exception('Failed to get recommendations: $e');
    }
  }

  /// Get chat response from Gemini
  Future<String> getChatResponse(String message) async {
    try {
      final content = [Content.text(message)];
      final response = await _model.generateContent(content);
      return response.text ?? 'No response available';
    } catch (e) {
      throw Exception('Failed to get chat response: $e');
    }
  }

  /// Build prompt for outfit recommendations
  String _buildRecommendationPrompt(
    ScanResult scanResult,
    String? userPreference,
  ) {
    final buffer = StringBuffer();

    buffer.writeln('Sebagai fashion stylist AI, berikan rekomendasi untuk outfit ini:');
    buffer.writeln();
    buffer.writeln('Detail Outfit:');
    buffer.writeln('- Item: ${scanResult.itemsSummary}');
    buffer.writeln('- Warna: ${scanResult.colorSummary}');
    buffer.writeln('- Pola: ${scanResult.patterns.join(", ")}');
    buffer.writeln('- Tingkat Formalitas: ${scanResult.formalityLevel.displayName}');
    buffer.writeln();

    if (userPreference != null && userPreference.isNotEmpty) {
      buffer.writeln('Preferensi User: $userPreference');
      buffer.writeln();
    }

    buffer.writeln('Berikan rekomendasi dengan format berikut:');
    buffer.writeln();
    buffer.writeln('1. ANALISIS GAYA:');
    buffer.writeln('   - Jelaskan kesan outfit saat ini');
    buffer.writeln('   - Sebutkan 3-5 poin kekuatan outfit');
    buffer.writeln();
    buffer.writeln('2. REKOMENDASI STYLING:');
    buffer.writeln('   - Berikan 3-5 saran item pelengkap atau pengganti');
    buffer.writeln('   - Jelaskan bagaimana meningkatkan outfit untuk berbagai acara');
    buffer.writeln();
    buffer.writeln('3. PRODUCT SUGGESTIONS:');
    buffer.writeln('   Sertakan 3-5 link produk dari marketplace Indonesia (Tokopedia, Shopee, Zalora)');
    buffer.writeln('   Format: [PRODUCT] Nama Item | Marketplace | URL');
    buffer.writeln();
    buffer.writeln('Contoh:');
    buffer.writeln('[PRODUCT] Kemeja Putih Formal Pria | Tokopedia | https://tokopedia.link/kemeja-putih');

    return buffer.toString();
  }

  /// Parse product links from AI response
  List<ProductLink> _parseProductLinks(String text) {
    final links = <ProductLink>[];
    final regex = RegExp(
      r'\[PRODUCT\]\s*(.+?)\s*\|\s*(.+?)\s*\|\s*(https?://\S+)',
      caseSensitive: false,
    );

    final matches = regex.allMatches(text);

    for (var match in matches) {
      try {
        final title = match.group(1)?.trim() ?? '';
        final source = match.group(2)?.trim().toLowerCase() ?? '';
        final url = match.group(3)?.trim() ?? '';

        if (title.isNotEmpty && url.isNotEmpty) {
          links.add(ProductLink(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: title,
            url: url,
            source: source,
          ));
        }
      } catch (e) {
        // Skip invalid links
        continue;
      }
    }

    // If no links found, add some default suggestions
    if (links.isEmpty) {
      links.addAll(_getDefaultProductLinks());
    }

    return links;
  }

  /// Parse style recommendations from AI response
  List<String> _parseStyleRecommendations(String text) {
    final recommendations = <String>[];

    // Look for recommendation section
    final lines = text.split('\n');
    bool inRecommendationSection = false;

    for (var line in lines) {
      final trimmed = line.trim();

      if (trimmed.toUpperCase().contains('REKOMENDASI')) {
        inRecommendationSection = true;
        continue;
      }

      if (trimmed.toUpperCase().contains('PRODUCT')) {
        inRecommendationSection = false;
        break;
      }

      if (inRecommendationSection && trimmed.isNotEmpty) {
        // Remove list markers
        final cleaned = trimmed.replaceAll(RegExp(r'^[-*•]\s*'), '');
        if (cleaned.isNotEmpty && !cleaned.contains(':')) {
          recommendations.add(cleaned);
        }
      }
    }

    return recommendations;
  }

  /// Default product links as fallback
  List<ProductLink> _getDefaultProductLinks() {
    return [
      ProductLink(
        id: '1',
        title: 'Kemeja Putih Formal Pria Lengan Panjang',
        url: 'https://www.tokopedia.com/search?st=product&q=kemeja%20putih%20formal',
        source: 'tokopedia',
      ),
      ProductLink(
        id: '2',
        title: 'Celana Chino Slim Fit Pria',
        url: 'https://www.tokopedia.com/search?st=product&q=celana%20chino%20pria',
        source: 'tokopedia',
      ),
      ProductLink(
        id: '3',
        title: 'Sepatu Formal Pantofel Pria',
        url: 'https://www.tokopedia.com/search?st=product&q=sepatu%20pantofel%20pria',
        source: 'tokopedia',
      ),
    ];
  }
}
