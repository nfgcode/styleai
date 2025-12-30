import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../data/models/history_entry.dart';
import '../../../data/models/product_link.dart';
import '../../../data/repositories/history_repository.dart';
import 'dart:io';

class HistoryPage extends StatefulWidget {
  final String? initialFilter;
  const HistoryPage({super.key, this.initialFilter});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final HistoryRepository _historyRepo = HistoryRepository();
  List<HistoryEntry> _histories = [];
  bool _isLoading = true;
  String _filter = 'all';
  bool _hasMigrated = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialFilter != null) {
      _filter = widget.initialFilter!;
    }
    _initializeHistory();
  }

  Future<void> _initializeHistory() async {
    // Migrate local data to Supabase (one-time)
    if (!_hasMigrated) {
      await _historyRepo.migrateLocalToSupabase();
      _hasMigrated = true;
    }
    
    // Load histories
    await _loadHistories();
  }

  Future<void> _loadHistories() async {
    setState(() => _isLoading = true);

    try {
      List<HistoryEntry> histories;

      switch (_filter) {
        case 'scan':
          histories = await _historyRepo.getByType(HistoryType.scan);
          break;
        case 'chat':
          histories = await _historyRepo.getByType(HistoryType.chat);
          break;
        case 'tryon':
          histories = await _historyRepo.getByType(HistoryType.tryon);
          break;
        case 'favorites':
          histories = await _historyRepo.getFavorites();
          break;
        default:
          histories = await _historyRepo.getAll();
      }

      if (mounted) {
        setState(() {
          _histories = histories;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Failed to load history: $e');
      }
    }
  }

  Future<void> _toggleFavorite(String id) async {
    try {
      await _historyRepo.toggleFavorite(id);
      await _loadHistories();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Favorite updated'),
            duration: const Duration(seconds: 1),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showError('Failed to update favorite: $e');
    }
  }

  Future<void> _deleteEntry(String id) async {
    try {
      await _historyRepo.delete(id);
      await _loadHistories();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('History deleted'),
            duration: Duration(seconds: 1),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      _showError('Failed to delete: $e');
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
                      'History & Inspirasi',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Filter Tabs
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildFilterChip('All', 'all'),
                    _buildFilterChip('Scans', 'scan'),
                    _buildFilterChip('Recommendations', 'chat'),
                    _buildFilterChip('Try-On', 'tryon'),
                    _buildFilterChip('Favorites', 'favorites'),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Content
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _histories.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _histories.length,
                            itemBuilder: (context, index) {
                              return _buildHistoryCard(_histories[index]);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filter == value;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _filter = value);
          _loadHistories();
        },
        backgroundColor: Colors.white,
        selectedColor: Colors.purple.shade100,
        labelStyle: TextStyle(
          color: isSelected ? Colors.purple.shade700 : Colors.grey.shade700,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    String message;
    String subtitle;
    IconData icon;

    switch (_filter) {
      case 'favorites':
        icon = Icons.favorite_border;
        message = 'No favorites yet';
        subtitle = 'Tap the heart icon to add favorites';
        break;
      case 'scan':
        icon = Icons.photo_camera;
        message = 'No scans yet';
        subtitle = 'Start scanning outfits to see them here';
        break;
      case 'chat':
        icon = Icons.chat_bubble_outline;
        message = 'No recommendations yet';
        subtitle = 'Get AI recommendations to see them here';
        break;
      case 'tryon':
        icon = Icons.checkroom;
        message = 'No try-ons yet';
        subtitle = 'Use virtual try-on to see results here';
        break;
      default:
        icon = Icons.history;
        message = 'No history yet';
        subtitle = 'Start scanning outfits to see your history';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(HistoryEntry entry) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: InkWell(
        onTap: () => _showHistoryDetail(entry),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getTypeColor(entry.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getTypeIcon(entry.type),
                      color: _getTypeColor(entry.type),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _formatDate(entry.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      entry.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: entry.isFavorite ? Colors.red : Colors.grey,
                    ),
                    onPressed: () => _toggleFavorite(entry.id),
                  ),
                ],
              ),

              // Thumbnail/Description
              if (entry.localThumbnailPath != null ||
                  entry.description != null) ...[
                const SizedBox(height: 12),
                if (entry.localThumbnailPath != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(entry.localThumbnailPath!),
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                if (entry.description != null)
                  Text(
                    entry.description!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showHistoryDetail(HistoryEntry entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return _buildDetailSheet(entry, scrollController);
        },
      ),
    );
  }

  Widget _buildDetailSheet(HistoryEntry entry, ScrollController controller) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: ListView(
        controller: controller,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            entry.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatDate(entry.createdAt),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 24),

          // Image if available
          if (entry.localThumbnailPath != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(entry.localThumbnailPath!),
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Description
          if (entry.description != null) ...[
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // For try-on, show full analysis from payload
            if (entry.type == HistoryType.tryon && entry.payload['analysis'] != null)
              MarkdownBody(
                data: entry.payload['analysis'] as String,
                styleSheet: MarkdownStyleSheet(
                  h1: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                  h2: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade800,
                    height: 2,
                  ),
                  h3: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink.shade700,
                    height: 1.8,
                  ),
                  p: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                  ),
                  strong: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              )
            else
              Text(
                entry.description!,
                style: const TextStyle(height: 1.6),
              ),
            const SizedBox(height: 24),
          ],

          // Product Links (if any)
          if ((entry.type == HistoryType.chat && entry.payload['product_links'] != null) ||
              (entry.type == HistoryType.tryon && entry.payload['productLinks'] != null)) ...[
            const Text(
              'Product Links',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ..._buildProductLinks(
              entry.type == HistoryType.tryon 
                ? entry.payload['productLinks'] 
                : entry.payload['product_links']
            ),
          ],

          // Delete button
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _deleteEntry(entry.id);
            },
            icon: const Icon(Icons.delete),
            label: const Text('Delete'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildProductLinks(dynamic linksData) {
    final links = (linksData as List)
        .map((item) => ProductLink.fromJson(item as Map<String, dynamic>))
        .toList();

    return links.map((link) {
      return InkWell(
        onTap: () async {
          final uri = Uri.parse(link.url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
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
              Icon(Icons.shopping_bag, color: Colors.blue.shade700),
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
    }).toList();
  }

  Color _getTypeColor(HistoryType type) {
    switch (type) {
      case HistoryType.scan:
        return Colors.blue;
      case HistoryType.chat:
        return Colors.purple;
      case HistoryType.tryon:
        return Colors.pink;
    }
  }

  IconData _getTypeIcon(HistoryType type) {
    switch (type) {
      case HistoryType.scan:
        return Icons.photo_camera;
      case HistoryType.chat:
        return Icons.chat_bubble;
      case HistoryType.tryon:
        return Icons.auto_awesome;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        if (diff.inMinutes == 0) {
          return 'Just now';
        }
        return '${diff.inMinutes}m ago';
      }
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
