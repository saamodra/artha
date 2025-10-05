import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/wallet_record.dart';
import '../models/label.dart';

class WalletRecordRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get current user ID
  String? get _currentUserId => _supabase.auth.currentUser?.id;

  /// Get all wallet records for the current user with labels
  Future<List<WalletRecord>> getWalletRecords() async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // First get all wallet records
      final response = await _supabase
          .from('wallet_records')
          .select('''
            *,
            wallets!wallet_records_wallet_id_fkey(name),
            categories!inner(name),
            transfer_wallets:transfer_to_wallet_id(name)
          ''')
          .eq('wallets.user_id', _currentUserId!)
          .order('date_time', ascending: false);

      List<WalletRecord> records = [];

      for (final record in response) {
        // Get labels for this record
        final labelsResponse = await _supabase
            .from('wallet_record_labels')
            .select('''
              labels!inner(
                id,
                name,
                color,
                created_at
              )
            ''')
            .eq('wallet_record_id', record['id']);

        final labels = labelsResponse
            .map((labelJson) => Label.fromSupabaseJson(labelJson['labels']))
            .toList();

        // Create wallet record with resolved names and labels
        final walletRecord = WalletRecord(
          id: record['id'],
          type: RecordType.values.firstWhere(
            (e) => e.toString().split('.').last == record['record_type'],
          ),
          category: record['categories']['name'],
          account: record['wallets']['name'],
          transferToAccount: record['transfer_wallets']?['name'],
          amount: record['amount'].toDouble(),
          dateTime: DateTime.parse(record['date_time']),
          note: record['note'],
          labels: labels,
        );

        records.add(walletRecord);
      }

      return records;
    } catch (e) {
      throw Exception('Failed to fetch wallet records: $e');
    }
  }

  /// Get wallet records for a specific wallet
  Future<List<WalletRecord>> getWalletRecordsForWallet(String walletId) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('wallet_records')
          .select('''
            *,
            wallets!wallet_records_wallet_id_fkey(name),
            categories!inner(name),
            transfer_wallets:transfer_to_wallet_id(name)
          ''')
          .eq('wallet_id', walletId)
          .eq('wallets.user_id', _currentUserId!)
          .order('date_time', ascending: false);

      List<WalletRecord> records = [];

      for (final record in response) {
        // Get labels for this record
        final labelsResponse = await _supabase
            .from('wallet_record_labels')
            .select('''
              labels!inner(
                id,
                name,
                color,
                created_at
              )
            ''')
            .eq('wallet_record_id', record['id']);

        final labels = labelsResponse
            .map((labelJson) => Label.fromSupabaseJson(labelJson['labels']))
            .toList();

        final walletRecord = WalletRecord(
          id: record['id'],
          type: RecordType.values.firstWhere(
            (e) => e.toString().split('.').last == record['record_type'],
          ),
          category: record['categories']['name'],
          account: record['wallets']['name'],
          transferToAccount: record['transfer_wallets']?['name'],
          amount: record['amount'].toDouble(),
          dateTime: DateTime.parse(record['date_time']),
          note: record['note'],
          labels: labels,
        );

        records.add(walletRecord);
      }

      return records;
    } catch (e) {
      throw Exception('Failed to fetch wallet records for wallet: $e');
    }
  }

  /// Get a wallet record by ID
  Future<WalletRecord?> getWalletRecordById(String id) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('wallet_records')
          .select('''
            *,
            wallets!wallet_records_wallet_id_fkey(name),
            categories!inner(name),
            transfer_wallets:transfer_to_wallet_id(name)
          ''')
          .eq('id', id)
          .eq('wallets.user_id', _currentUserId!)
          .single();

      // Get labels for this record
      final labelsResponse = await _supabase
          .from('wallet_record_labels')
          .select('''
            labels!inner(
              id,
              name,
              color,
              created_at
            )
          ''')
          .eq('wallet_record_id', id);

      final labels = labelsResponse
          .map((labelJson) => Label.fromSupabaseJson(labelJson['labels']))
          .toList();

      return WalletRecord(
        id: response['id'],
        type: RecordType.values.firstWhere(
          (e) => e.toString().split('.').last == response['record_type'],
        ),
        category: response['categories']['name'],
        account: response['wallets']['name'],
        transferToAccount: response['transfer_wallets']?['name'],
        amount: response['amount'].toDouble(),
        dateTime: DateTime.parse(response['date_time']),
        note: response['note'],
        labels: labels,
      );
    } catch (e) {
      return null;
    }
  }

  /// Create a new wallet record
  Future<WalletRecord> createWalletRecord(
    WalletRecord record, {
    List<String>? labelIds,
  }) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Get wallet ID from wallet name
      final walletResponse = await _supabase
          .from('wallets')
          .select('id')
          .eq('name', record.account)
          .eq('user_id', _currentUserId!)
          .single();

      // Get category ID from category name
      final categoryResponse = await _supabase
          .from('categories')
          .select('id')
          .eq('name', record.category)
          .single();

      String? transferToWalletId;
      if (record.transferToAccount != null) {
        final transferWalletResponse = await _supabase
            .from('wallets')
            .select('id')
            .eq('name', record.transferToAccount!)
            .eq('user_id', _currentUserId!)
            .single();
        transferToWalletId = transferWalletResponse['id'];
      }

      final recordData = {
        'record_type': record.type.toString().split('.').last,
        'category_id': categoryResponse['id'],
        'wallet_id': walletResponse['id'],
        'transfer_to_wallet_id': transferToWalletId,
        'amount': record.amount,
        'date_time': record.dateTime.toIso8601String(),
        'note': record.note,
      };

      final response = await _supabase
          .from('wallet_records')
          .insert(recordData)
          .select()
          .single();

      // Add labels if provided
      if (labelIds != null && labelIds.isNotEmpty) {
        final labelRecords = labelIds
            .map(
              (labelId) => {
                'wallet_record_id': response['id'],
                'label_id': labelId,
              },
            )
            .toList();

        await _supabase.from('wallet_record_labels').insert(labelRecords);
      }

      // Return the created record with labels
      return await getWalletRecordById(response['id']) ?? record;
    } catch (e) {
      throw Exception('Failed to create wallet record: $e');
    }
  }

  /// Update an existing wallet record
  Future<WalletRecord> updateWalletRecord(
    WalletRecord record, {
    List<String>? labelIds,
  }) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Get wallet ID from wallet name
      final walletResponse = await _supabase
          .from('wallets')
          .select('id')
          .eq('name', record.account)
          .eq('user_id', _currentUserId!)
          .single();

      // Get category ID from category name
      final categoryResponse = await _supabase
          .from('categories')
          .select('id')
          .eq('name', record.category)
          .single();

      String? transferToWalletId;
      if (record.transferToAccount != null) {
        final transferWalletResponse = await _supabase
            .from('wallets')
            .select('id')
            .eq('name', record.transferToAccount!)
            .eq('user_id', _currentUserId!)
            .single();
        transferToWalletId = transferWalletResponse['id'];
      }

      final recordData = {
        'record_type': record.type.toString().split('.').last,
        'category_id': categoryResponse['id'],
        'wallet_id': walletResponse['id'],
        'transfer_to_wallet_id': transferToWalletId,
        'amount': record.amount,
        'date_time': record.dateTime.toIso8601String(),
        'note': record.note,
      };

      await _supabase
          .from('wallet_records')
          .update(recordData)
          .eq('id', record.id);

      // Update labels if provided
      if (labelIds != null) {
        // Remove all existing labels
        await _supabase
            .from('wallet_record_labels')
            .delete()
            .eq('wallet_record_id', record.id);

        // Add new labels
        if (labelIds.isNotEmpty) {
          final labelRecords = labelIds
              .map(
                (labelId) => {
                  'wallet_record_id': record.id,
                  'label_id': labelId,
                },
              )
              .toList();

          await _supabase.from('wallet_record_labels').insert(labelRecords);
        }
      }

      // Return the updated record with labels
      return await getWalletRecordById(record.id) ?? record;
    } catch (e) {
      throw Exception('Failed to update wallet record: $e');
    }
  }

  /// Delete a wallet record
  Future<void> deleteWalletRecord(String id) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Delete the record (labels will be deleted automatically due to CASCADE)
      await _supabase.from('wallet_records').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete wallet record: $e');
    }
  }

  /// Get wallet records by date range
  Future<List<WalletRecord>> getWalletRecordsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('wallet_records')
          .select('''
            *,
            wallets!wallet_records_wallet_id_fkey(name),
            categories!inner(name),
            transfer_wallets:transfer_to_wallet_id(name)
          ''')
          .eq('wallets.user_id', _currentUserId!)
          .gte('date_time', startDate.toIso8601String())
          .lte('date_time', endDate.toIso8601String())
          .order('date_time', ascending: false);

      List<WalletRecord> records = [];

      for (final record in response) {
        // Get labels for this record
        final labelsResponse = await _supabase
            .from('wallet_record_labels')
            .select('''
              labels!inner(
                id,
                name,
                color,
                created_at
              )
            ''')
            .eq('wallet_record_id', record['id']);

        final labels = labelsResponse
            .map((labelJson) => Label.fromSupabaseJson(labelJson['labels']))
            .toList();

        final walletRecord = WalletRecord(
          id: record['id'],
          type: RecordType.values.firstWhere(
            (e) => e.toString().split('.').last == record['record_type'],
          ),
          category: record['categories']['name'],
          account: record['wallets']['name'],
          transferToAccount: record['transfer_wallets']?['name'],
          amount: record['amount'].toDouble(),
          dateTime: DateTime.parse(record['date_time']),
          note: record['note'],
          labels: labels,
        );

        records.add(walletRecord);
      }

      return records;
    } catch (e) {
      throw Exception('Failed to fetch wallet records by date range: $e');
    }
  }
}
