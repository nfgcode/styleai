import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/models/scan_result.dart';
import '../../../data/models/product_link.dart';
import '../../../data/models/history_entry.dart';
import '../../../data/repositories/gemini_repository.dart';
import '../../../data/repositories/history_repository.dart';
import '../../../utils/global_variable.dart' as global_var;

class ScanResultPage extends StatefulWidget {
  final ScanResult scanResult;

  const ScanResultPage({
    super.key,
    required this.scanResult,
  });

  @override
  State<ScanResultPage> createState() => _ScanResultPageState();
}

class _ScanResultPageState extends State<ScanResultPage> {
  final HistoryRepository _historyRepo = HistoryRepository();
  late final GeminiRepository _geminiRepo;
  bool _isLoadingRecommendation = false;
  List<ProductLink>? _productLinks;
  String? _recommendations;

  @override
  void initState() {
    super.initState();
    _geminiRepo = GeminiRepository(global_var.apiKey);
    _saveToHistory();
  }

  Future<void> _saveToHistory() async {
    try {
      final entry = HistoryEntry.fromScanResult(widget.scanResult);
      await _historyRepo.saveHistory(entry);
    } catch (e) {
      debugPrint('Failed to save history: $e');
    }
  }

  Future<void> _getRecommendations() async {
    setState(() => _isLoadingRecommendation = true);

    try {
      final response = await _geminiRepo.getRecommendations(
        scanResult: widget.scanResult,
      );

      if (mounted) {
        setState(() {
          _recommendations = response.adviceText;
          _productLinks = response.productLinks;
        });

        // Save recommendation to history
        final entry = HistoryEntry.fromRecommendation(response);
        await _historyRepo.saveHistory(entry);
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to get recommendations: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingRecommendation = false);
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

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showError('Could not open link');
      }
    } catch (e) {
      _showError('Invalid URL');
    }
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
                      'Scan Result',
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image
                      if (widget.scanResult.localImagePath != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            File(widget.scanResult.localImagePath!),
                            width: double.infinity,
                            height: 300,
                            fit: BoxFit.cover,
                          ),
                        ),

                      const SizedBox(height: 24),

                      // Formality Badge
                      _buildFormalityBadge(),

                      const SizedBox(height: 24),

                      // Detected Items
                      _buildSection(
                        title: 'Detected Items',
                        child: Column(
                          children: widget.scanResult.items
                              .map((item) => _buildItemCard(item))
                              .toList(),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Colors & Patterns
                      _buildSection(
                        title: 'Colors & Patterns',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.palette, size: 20),
                                const SizedBox(width: 8),
                                Text(widget.scanResult.colorSummary),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.texture, size: 20),
                                const SizedBox(width: 8),
                                Text(widget.scanResult.patterns.join(', ')),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Get Recommendations Button
                      if (_recommendations == null && !_isLoadingRecommendation)
                        _buildRecommendationButton(),

                      // Loading Recommendations
                      if (_isLoadingRecommendation)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: CircularProgressIndicator(),
                          ),
                        ),

                      // Recommendations
                      if (_recommendations != null) ...[
                        _buildSection(
                          title: 'AI Recommendations',
                          child: Text(
                            _recommendations!,
                            style: const TextStyle(height: 1.6),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Product Links
                      if (_productLinks != null && _productLinks!.isNotEmpty) ...[
                        _buildSection(
                          title: 'Product Suggestions',
                          child: Column(
                            children: _productLinks!
                                .map((link) => _buildProductCard(link))
                                .toList(),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormalityBadge() {
    Color color;
    IconData icon;

    switch (widget.scanResult.formalityLevel) {
      case FormalityLevel.formal:
        color = Colors.blue.shade700;
        icon = Icons.business_center;
        break;
      case FormalityLevel.businessCasual:
        color = Colors.purple.shade600;
        icon = Icons.work_outline;
        break;
      case FormalityLevel.casual:
        color = Colors.orange.shade600;
        icon = Icons.weekend;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.scanResult.formalityLevel.displayName,
                style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Score: ${widget.scanResult.formalityScore.toStringAsFixed(0)}/100',
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildItemCard(item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.purple.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getCategoryIcon(item.category),
              color: Colors.purple.shade700,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.category,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${item.color} • ${item.pattern}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${(item.confidence * 100).toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationButton() {
    return InkWell(
      onTap: _getRecommendations,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade400, Colors.purple.shade400],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Get AI Recommendations',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(ProductLink link) {
    return InkWell(
      onTap: () => _launchUrl(link.url),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.shopping_bag,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    link.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    link.source.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.open_in_new, size: 20),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'atasan':
        return Icons.checkroom;
      case 'bawahan':
        return Icons.checkroom_outlined;
      case 'sepatu':
        return Icons.shopping_bag;
      case 'kacamata':
        return Icons.visibility;
      case 'topi':
        return Icons.brightness_5;
      default:
        return Icons.shopping_basket;
    }
  }
}
