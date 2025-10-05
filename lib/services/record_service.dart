import 'package:flutter/foundation.dart';
import '../models/wallet_record.dart';
import '../repositories/wallet_record_repository.dart';
import 'wallet_service.dart';

class RecordService extends ChangeNotifier {
  static final RecordService _instance = RecordService._internal();
  factory RecordService() => _instance;
  RecordService._internal() {
    _walletService = WalletService();
  }

  final List<WalletRecord> _records = [];
  late final WalletService _walletService;
  final WalletRecordRepository _repository = WalletRecordRepository();
  bool _isLoading = false;
  String? _error;

  List<WalletRecord> get records => List.unmodifiable(_records);
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load records from Supabase
  Future<void> loadRecords() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final records = await _repository.getWalletRecords();
      print('Records: $records');
      _records.clear();
      _records.addAll(records);
      _records.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh records from Supabase
  Future<void> refreshRecords() async {
    await loadRecords();
  }

  Future<void> addRecord(WalletRecord record, {List<String>? labelIds}) async {
    try {
      // Add to Supabase first
      final createdRecord = await _repository.createWalletRecord(
        record,
        labelIds: labelIds,
      );

      // Add to local list
      _records.add(createdRecord);
      _records.sort(
        (a, b) => b.dateTime.compareTo(a.dateTime),
      ); // Sort by date descending
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateRecord(
    WalletRecord updatedRecord, {
    List<String>? labelIds,
  }) async {
    try {
      // Update in Supabase first
      final updatedRecordFromDb = await _repository.updateWalletRecord(
        updatedRecord,
        labelIds: labelIds,
      );

      // Update local list
      final index = _records.indexWhere((r) => r.id == updatedRecord.id);
      if (index != -1) {
        _records[index] = updatedRecordFromDb;
        _records.sort((a, b) => b.dateTime.compareTo(a.dateTime));
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteRecord(String recordId) async {
    try {
      // Delete from Supabase first
      await _repository.deleteWalletRecord(recordId);

      // Remove from local list
      _records.removeWhere((r) => r.id == recordId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  List<WalletRecord> getRecordsForAccount(String accountName) {
    return _records
        .where(
          (r) =>
              r.account == accountName || (r.transferToAccount == accountName),
        )
        .toList();
  }

  List<WalletRecord> getRecordsByType(RecordType type) {
    return _records.where((r) => r.type == type).toList();
  }

  List<WalletRecord> getRecordsByDateRange(DateTime start, DateTime end) {
    return _records
        .where(
          (r) =>
              r.dateTime.isAfter(start.subtract(const Duration(days: 1))) &&
              r.dateTime.isBefore(end.add(const Duration(days: 1))),
        )
        .toList();
  }

  double getTotalBalanceForAccount(String accountName) {
    // Start with initial balance from wallet service
    final wallet = _walletService.getWalletByName(accountName);
    double balance = wallet?.initialValue ?? 0.0;

    // Add/subtract records
    for (final record in _records) {
      if (record.account == accountName) {
        switch (record.type) {
          case RecordType.income:
            balance += record.amount;
            break;
          case RecordType.expense:
            balance -= record.amount;
            break;
          case RecordType.transfer:
            balance -= record.amount; // Outgoing transfer
            break;
        }
      }
      // Incoming transfers to this account
      if (record.transferToAccount == accountName &&
          record.type == RecordType.transfer) {
        balance += record.amount;
      }
    }
    return balance;
  }

  String getFormattedBalanceForAccount(String accountName) {
    final balance = getTotalBalanceForAccount(accountName);
    return 'IDR ${balance.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  double getTotalBalanceForAccounts(List<String> accountNames) {
    double total = 0;
    for (final accountName in accountNames) {
      total += getTotalBalanceForAccount(accountName);
    }
    return total;
  }

  String getFormattedTotalBalance(List<String> accountNames) {
    final total = getTotalBalanceForAccounts(accountNames);
    return 'IDR ${total.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  Map<String, double> getCashFlowSummary(DateTime start, DateTime end) {
    final recordsInRange = getRecordsByDateRange(start, end);
    double income = 0;
    double expenses = 0;

    for (final record in recordsInRange) {
      switch (record.type) {
        case RecordType.income:
          income += record.amount;
          break;
        case RecordType.expense:
          expenses += record.amount;
          break;
        case RecordType.transfer:
          // Transfers don't affect overall cash flow
          break;
      }
    }

    return {'income': income, 'expenses': expenses, 'net': income - expenses};
  }
}
