import 'package:flutter/foundation.dart';
import '../models/wallet_record.dart';

class RecordService extends ChangeNotifier {
  static final RecordService _instance = RecordService._internal();
  factory RecordService() => _instance;
  RecordService._internal();

  final List<WalletRecord> _records = [];
  final Map<String, double> _initialBalances = {
    'Cashfile': 90000.00,
    'Cash': 349000.00,
    'BRI': 262337.00,
    'Ajaib Stocks': 41693789.00,
    'Ajaib Kripto': 11485644.00,
    'Bibit': 236371256.00,
    'SeaBank': 4263340.00,
    'BCA': 16237019.00,
    'Bibit Saham': 16065682.00,
    'Bibit Saham 2': 92196754.00,
    'Shopeepay': 372623.00,
    'Permata': 6570.00,
    'MQ Sekuritas': 18450715.00,
    'Bareksa Gold': 0.00,
    'Bareksa RD': 75512.00,
    'Jago': 169297.00,
    'Gopay': 144346.00,
    'DANA': 824.00,
    'pluang': 56518.00,
    'Gopay Coins': 0.00,
    'Flip': 2935.00,
    'Shopee Koin': 0.00,
    'blu': 942.00,
    'NeoBank': 643.00,
    'Line Bank': 36.00,
    'OVO': 58659.00,
    'LinkAja': 5250.00,
    'Bukalapak': 12326.00,
    'Blibay': 0.00,
    'GoTrade': 0.00, // USD converted or kept as 0 for simplicity
    'Shopback': 0.00,
    'Mandiri E-Money': 2500.00,
    'Brizzi': 11000.00,
    'BNI TapCash': 15500.00,
    'Flazz': 7000.00,
    'Sbux Card': 135000.00,
    'Jenius': 0.00,
    'Kaspro': 22100.00,
    'MotionPay': 40.00,
  };

  List<WalletRecord> get records => List.unmodifiable(_records);

  void addRecord(WalletRecord record) {
    _records.add(record);
    _records.sort(
      (a, b) => b.dateTime.compareTo(a.dateTime),
    ); // Sort by date descending
    notifyListeners();
  }

  void updateRecord(WalletRecord updatedRecord) {
    final index = _records.indexWhere((r) => r.id == updatedRecord.id);
    if (index != -1) {
      _records[index] = updatedRecord;
      _records.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      notifyListeners();
    }
  }

  void deleteRecord(String recordId) {
    _records.removeWhere((r) => r.id == recordId);
    notifyListeners();
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
    // Start with initial balance
    double balance = _initialBalances[accountName] ?? 0.0;

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
