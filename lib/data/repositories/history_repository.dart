import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/history_entry.dart';

/// Repository for managing history entries
/// Supports both local storage (SharedPreferences) and cloud sync (Supabase)
class HistoryRepository {
  static const String _historyKey = 'history_entries';
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Save history entry to both local and Supabase
  /// Returns the Supabase-generated ID if successful, null otherwise
  Future<String?> saveHistory(HistoryEntry entry) async {
    String? supabaseId;
    
    try {
      // 1. Save to Supabase first
      final user = _supabase.auth.currentUser;
      if (user != null) {
        // Don't send 'id' - let Supabase auto-generate UUID
        final response = await _supabase.from('user_history').insert({
          'user_id': user.id,
          'type': entry.type.name,
          'title': entry.title,
          'description': entry.description,
          'thumbnail_url': entry.thumbnailUrl,
          'payload': entry.payload,
          'is_favorite': entry.isFavorite,
        }).select('id').single();
        
        supabaseId = response['id'] as String;
        print('✅ History saved to Supabase with ID $supabaseId: ${entry.title}');
      }
    } catch (e) {
      print('⚠️ Failed to save to Supabase: $e');
    }

    // 2. Save to local storage as backup
    try {
      final prefs = await SharedPreferences.getInstance();
      final histories = await _getLocalHistories();

      histories.insert(0, entry);

      // Keep only last 100 entries locally
      if (histories.length > 100) {
        histories.removeRange(100, histories.length);
      }

      final jsonList = histories.map((h) => h.toJson()).toList();
      await prefs.setString(_historyKey, jsonEncode(jsonList));
      print('✅ History saved locally: ${entry.id}');
    } catch (e) {
      print('⚠️ Failed to save locally: $e');
    }
    
    return supabaseId;
  }

  /// Get all history entries (from Supabase, fallback to local)
  Future<List<HistoryEntry>> getAll() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        final response = await _supabase
            .from('user_history')
            .select()
            .eq('user_id', user.id)
            .order('created_at', ascending: false);

        final List<HistoryEntry> histories = (response as List)
            .map((json) => HistoryEntry.fromJson({
                  'id': json['id'],
                  'type': json['type'],
                  'created_at': json['created_at'],
                  'title': json['title'],
                  'description': json['description'],
                  'thumbnail_url': json['thumbnail_url'],
                  'local_thumbnail_path': null,
                  'payload': json['payload'],
                  'is_favorite': json['is_favorite'],
                }))
            .toList();

        print('✅ Loaded ${histories.length} histories from Supabase');
        
        // Sync to local storage
        await _syncToLocal(histories);
        
        return histories;
      }
    } catch (e) {
      print('⚠️ Failed to load from Supabase: $e');
    }

    // Fallback to local storage
    print('📱 Loading from local storage...');
    return _getLocalHistories();
  }

  /// Get history by type
  Future<List<HistoryEntry>> getByType(HistoryType type) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        final response = await _supabase
            .from('user_history')
            .select()
            .eq('user_id', user.id)
            .eq('type', type.name)
            .order('created_at', ascending: false);

        return (response as List)
            .map((json) => HistoryEntry.fromJson({
                  'id': json['id'],
                  'type': json['type'],
                  'created_at': json['created_at'],
                  'title': json['title'],
                  'description': json['description'],
                  'thumbnail_url': json['thumbnail_url'],
                  'local_thumbnail_path': null,
                  'payload': json['payload'],
                  'is_favorite': json['is_favorite'],
                }))
            .toList();
      }
    } catch (e) {
      print('⚠️ Failed to filter by type from Supabase: $e');
    }

    // Fallback to local
    final all = await _getLocalHistories();
    return all.where((entry) => entry.type == type).toList();
  }

  /// Get favorite histories
  Future<List<HistoryEntry>> getFavorites() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        final response = await _supabase
            .from('user_history')
            .select()
            .eq('user_id', user.id)
            .eq('is_favorite', true)
            .order('created_at', ascending: false);

        return (response as List)
            .map((json) => HistoryEntry.fromJson({
                  'id': json['id'],
                  'type': json['type'],
                  'created_at': json['created_at'],
                  'title': json['title'],
                  'description': json['description'],
                  'thumbnail_url': json['thumbnail_url'],
                  'local_thumbnail_path': null,
                  'payload': json['payload'],
                  'is_favorite': json['is_favorite'],
                }))
            .toList();
      }
    } catch (e) {
      print('⚠️ Failed to get favorites from Supabase: $e');
    }

    // Fallback to local
    final all = await _getLocalHistories();
    return all.where((entry) => entry.isFavorite).toList();
  }

  /// Delete history entry
  Future<void> delete(String id) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        await _supabase
            .from('user_history')
            .delete()
            .eq('id', id)
            .eq('user_id', user.id);
        
        print('✅ History deleted from Supabase: $id');
      }
    } catch (e) {
      print('⚠️ Failed to delete from Supabase: $e');
    }

    // Delete from local storage
    try {
      final prefs = await SharedPreferences.getInstance();
      final histories = await _getLocalHistories();
      histories.removeWhere((entry) => entry.id == id);

      final jsonList = histories.map((h) => h.toJson()).toList();
      await prefs.setString(_historyKey, jsonEncode(jsonList));
      print('✅ History deleted locally: $id');
    } catch (e) {
      print('⚠️ Failed to delete locally: $e');
    }
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(String id) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        // Get current status
        final response = await _supabase
            .from('user_history')
            .select('is_favorite')
            .eq('id', id)
            .eq('user_id', user.id)
            .single();

        final currentStatus = response['is_favorite'] as bool;
        final newStatus = !currentStatus;

        // Update in Supabase
        await _supabase
            .from('user_history')
            .update({'is_favorite': newStatus})
            .eq('id', id)
            .eq('user_id', user.id);

        print('✅ Favorite toggled in Supabase: $id -> $newStatus');
      }
    } catch (e) {
      print('⚠️ Failed to toggle favorite in Supabase: $e');
    }

    // Update local storage
    try {
      final prefs = await SharedPreferences.getInstance();
      final histories = await _getLocalHistories();

      final index = histories.indexWhere((entry) => entry.id == id);
      if (index != -1) {
        final wasFavorite = histories[index].isFavorite;
        histories[index] = histories[index].copyWith(
          isFavorite: !wasFavorite,
        );

        final jsonList = histories.map((h) => h.toJson()).toList();
        await prefs.setString(_historyKey, jsonEncode(jsonList));
        
        print('✅ Favorite toggled locally: $id -> ${!wasFavorite}');
      }
    } catch (e) {
      print('⚠️ Failed to toggle favorite locally: $e');
    }
  }

  /// Clear all history
  Future<void> clearAll() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        await _supabase
            .from('user_history')
            .delete()
            .eq('user_id', user.id);
        
        print('✅ All history cleared from Supabase');
      }
    } catch (e) {
      print('⚠️ Failed to clear from Supabase: $e');
    }

    // Clear local storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
    print('✅ All history cleared locally');
  }

  /// Get histories from local storage only
  Future<List<HistoryEntry>> _getLocalHistories() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_historyKey);

    if (jsonString == null) return [];

    try {
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList
          .map((json) => HistoryEntry.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('⚠️ Failed to parse local histories: $e');
      return [];
    }
  }

  /// Sync Supabase data to local storage
  Future<void> _syncToLocal(List<HistoryEntry> histories) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = histories.take(100).map((h) => h.toJson()).toList();
      await prefs.setString(_historyKey, jsonEncode(jsonList));
      print('✅ Synced ${histories.length} histories to local storage');
    } catch (e) {
      print('⚠️ Failed to sync to local: $e');
    }
  }

  /// Migrate local data to Supabase (one-time sync)
  Future<void> migrateLocalToSupabase() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('⚠️ No user logged in, cannot migrate');
        return;
      }

      final localHistories = await _getLocalHistories();
      if (localHistories.isEmpty) {
        print('ℹ️ No local data to migrate');
        return;
      }

      print('🔄 Migrating ${localHistories.length} local histories to Supabase...');

      for (var entry in localHistories) {
        try {
          await _supabase.from('user_history').insert({
            'id': entry.id,
            'user_id': user.id,
            'type': entry.type.name,
            'title': entry.title,
            'description': entry.description,
            'thumbnail_url': entry.thumbnailUrl,
            'payload': entry.payload,
            'is_favorite': entry.isFavorite,
            'created_at': entry.createdAt.toIso8601String(),
          });
        } catch (e) {
          // Skip if already exists
          if (!e.toString().contains('duplicate')) {
            print('⚠️ Failed to migrate entry ${entry.id}: $e');
          }
        }
      }

      print('✅ Migration completed');
    } catch (e) {
      print('⚠️ Migration failed: $e');
    }
  }
}

