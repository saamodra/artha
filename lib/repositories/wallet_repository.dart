import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/wallet.dart';

class WalletRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get current user ID
  String? get _currentUserId => _supabase.auth.currentUser?.id;

  /// Get all wallets for the current user
  Future<List<Wallet>> getWallets() async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('wallets')
          .select()
          .eq('user_id', _currentUserId!)
          .order('display_order', ascending: true)
          .order('created_at', ascending: true);

      return response.map((json) => Wallet.fromSupabaseJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch wallets: $e');
    }
  }

  /// Get a wallet by ID
  Future<Wallet?> getWalletById(String id) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('wallets')
          .select()
          .eq('id', id)
          .eq('user_id', _currentUserId!)
          .single();

      return Wallet.fromSupabaseJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Create a new wallet
  Future<Wallet> createWallet(Wallet wallet) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final walletData = wallet.toSupabaseJson();
      // Remove the id field to let Supabase generate it automatically
      walletData.remove('id');
      walletData['user_id'] = _currentUserId!;

      final response = await _supabase
          .from('wallets')
          .insert(walletData)
          .select()
          .single();

      return Wallet.fromSupabaseJson(response);
    } catch (e) {
      throw Exception('Failed to create wallet: $e');
    }
  }

  /// Update an existing wallet
  Future<Wallet> updateWallet(Wallet wallet) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('wallets')
          .update(wallet.toSupabaseJson())
          .eq('id', wallet.id)
          .eq('user_id', _currentUserId!)
          .select()
          .single();

      return Wallet.fromSupabaseJson(response);
    } catch (e) {
      throw Exception('Failed to update wallet: $e');
    }
  }

  /// Delete a wallet
  Future<void> deleteWallet(String id) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      await _supabase
          .from('wallets')
          .delete()
          .eq('id', id)
          .eq('user_id', _currentUserId!);
    } catch (e) {
      throw Exception('Failed to delete wallet: $e');
    }
  }

  /// Check if wallet name exists for the current user
  Future<bool> isWalletNameExists(String name, {String? excludeId}) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      var query = _supabase
          .from('wallets')
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

  /// Update display order for multiple wallets
  Future<void> updateWalletDisplayOrder(
    List<Map<String, dynamic>> walletOrders,
  ) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Update each wallet's display order
      for (final walletOrder in walletOrders) {
        await _supabase
            .from('wallets')
            .update({'display_order': walletOrder['display_order']})
            .eq('id', walletOrder['wallet_id'])
            .eq('user_id', _currentUserId!);
      }
    } catch (e) {
      throw Exception('Failed to update wallet display order: $e');
    }
  }

  /// Get the next display order for a new wallet
  Future<int> getNextDisplayOrder() async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('wallets')
          .select('display_order')
          .eq('user_id', _currentUserId!)
          .order('display_order', ascending: false)
          .limit(1);

      if (response.isEmpty) {
        return 0;
      }

      return (response.first['display_order'] as int) + 1;
    } catch (e) {
      return 0;
    }
  }
}
