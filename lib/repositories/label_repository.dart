import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/label.dart';

class LabelRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get current user ID
  String? get _currentUserId => _supabase.auth.currentUser?.id;

  /// Get all labels for the current user
  Future<List<Label>> getLabels() async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('labels')
          .select()
          .eq('user_id', _currentUserId!)
          .order('name', ascending: true);

      return response.map((json) => Label.fromSupabaseJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch labels: $e');
    }
  }

  /// Get a label by ID
  Future<Label?> getLabelById(String id) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('labels')
          .select()
          .eq('id', id)
          .eq('user_id', _currentUserId!)
          .single();

      return Label.fromSupabaseJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Create a new label
  Future<Label> createLabel(Label label) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final labelData = label.toSupabaseJson();
      // Remove the id field to let Supabase generate it automatically
      labelData.remove('id');
      labelData['user_id'] = _currentUserId!;

      final response = await _supabase
          .from('labels')
          .insert(labelData)
          .select()
          .single();

      return Label.fromSupabaseJson(response);
    } catch (e) {
      throw Exception('Failed to create label: $e');
    }
  }

  /// Update an existing label
  Future<Label> updateLabel(Label label) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('labels')
          .update(label.toSupabaseJson())
          .eq('id', label.id)
          .eq('user_id', _currentUserId!)
          .select()
          .single();

      return Label.fromSupabaseJson(response);
    } catch (e) {
      throw Exception('Failed to update label: $e');
    }
  }

  /// Delete a label
  Future<void> deleteLabel(String id) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      await _supabase
          .from('labels')
          .delete()
          .eq('id', id)
          .eq('user_id', _currentUserId!);
    } catch (e) {
      throw Exception('Failed to delete label: $e');
    }
  }

  /// Check if label name exists for the current user
  Future<bool> isLabelNameExists(String name, {String? excludeId}) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      var query = _supabase
          .from('labels')
          .select('id')
          .eq('name', name)
          .eq('user_id', _currentUserId!);

      if (excludeId != null) {
        query = query.neq('id', excludeId);
      }

      final response = await query;
      return response.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get labels for a specific wallet record
  Future<List<Label>> getLabelsForWalletRecord(String walletRecordId) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('wallet_record_labels')
          .select('''
            label_id,
            labels!inner(
              id,
              name,
              color,
              created_at
            )
          ''')
          .eq('wallet_record_id', walletRecordId);

      return response
          .map((json) => Label.fromSupabaseJson(json['labels']))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch labels for wallet record: $e');
    }
  }

  /// Add labels to a wallet record
  Future<void> addLabelsToWalletRecord(
    String walletRecordId,
    List<String> labelIds,
  ) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final labelRecords = labelIds
          .map(
            (labelId) => {
              'wallet_record_id': walletRecordId,
              'label_id': labelId,
            },
          )
          .toList();

      await _supabase.from('wallet_record_labels').insert(labelRecords);
    } catch (e) {
      throw Exception('Failed to add labels to wallet record: $e');
    }
  }

  /// Remove labels from a wallet record
  Future<void> removeLabelsFromWalletRecord(
    String walletRecordId,
    List<String> labelIds,
  ) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      await _supabase
          .from('wallet_record_labels')
          .delete()
          .eq('wallet_record_id', walletRecordId)
          .inFilter('label_id', labelIds);
    } catch (e) {
      throw Exception('Failed to remove labels from wallet record: $e');
    }
  }

  /// Update labels for a wallet record (replace all existing labels)
  Future<void> updateLabelsForWalletRecord(
    String walletRecordId,
    List<String> labelIds,
  ) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // First, remove all existing labels
      await _supabase
          .from('wallet_record_labels')
          .delete()
          .eq('wallet_record_id', walletRecordId);

      // Then add the new labels
      if (labelIds.isNotEmpty) {
        await addLabelsToWalletRecord(walletRecordId, labelIds);
      }
    } catch (e) {
      throw Exception('Failed to update labels for wallet record: $e');
    }
  }
}
