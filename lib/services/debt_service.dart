import 'package:flutter/foundation.dart';
import '../models/debt.dart';
import '../models/wallet_record.dart';
import 'record_service.dart';

class DebtService extends ChangeNotifier {
  static final DebtService _instance = DebtService._internal();
  factory DebtService() => _instance;
  DebtService._internal() {
    _initializeSampleData();
  }

  final List<Debt> _debts = [];
  final List<DebtRecord> _debtRecords = [];
  final RecordService _recordService = RecordService();

  void _initializeSampleData() {
    // Add sample debts from the image
    _debts.addAll([
      Debt(
        id: 'debt_1',
        type: DebtType.iLent,
        name: 'Mbak Lis',
        description: '',
        account: 'Cash',
        originalAmount: 300000.00,
        currentAmount: 300000.00,
        dateCreated: DateTime(2025, 7, 3),
        dueDate: DateTime(2025, 7, 3),
      ),
      Debt(
        id: 'debt_2',
        type: DebtType.iLent,
        name: 'Richard',
        description: 'Kos',
        account: 'Cash',
        originalAmount: 200000.00,
        currentAmount: 200000.00,
        dateCreated: DateTime(2024, 2, 11),
        dueDate: DateTime(2024, 2, 11),
      ),
      Debt(
        id: 'debt_3',
        type: DebtType.iLent,
        name: 'Ario Eko Saputro',
        description: 'Laptop',
        account: 'Cash',
        originalAmount: 200000.00,
        currentAmount: 200000.00,
        dateCreated: DateTime(2023, 7, 11),
        dueDate: DateTime(2023, 7, 11),
      ),
      Debt(
        id: 'debt_4',
        type: DebtType.iOwe,
        name: 'Mas Sabrang',
        description: 'Rumah',
        account: 'Cash',
        originalAmount: 130000000.00,
        currentAmount: 130000000.00,
        dateCreated: DateTime(2023, 7, 14),
        dueDate: DateTime(2023, 7, 14),
      ),
    ]);
  }

  List<Debt> get debts => List.unmodifiable(_debts);
  List<DebtRecord> get debtRecords => List.unmodifiable(_debtRecords);

  void addDebt(Debt debt) {
    _debts.add(debt);
    _debts.sort((a, b) => b.dateCreated.compareTo(a.dateCreated));
    notifyListeners();
  }

  void updateDebt(Debt updatedDebt) {
    final index = _debts.indexWhere((d) => d.id == updatedDebt.id);
    if (index != -1) {
      _debts[index] = updatedDebt;
      _debts.sort((a, b) => b.dateCreated.compareTo(a.dateCreated));
      notifyListeners();
    }
  }

  void deleteDebt(String debtId) {
    _debts.removeWhere((d) => d.id == debtId);
    _debtRecords.removeWhere((dr) => dr.debtId == debtId);
    notifyListeners();
  }

  List<Debt> getDebtsByType(DebtType type) {
    return _debts.where((d) => d.type == type).toList();
  }

  List<Debt> getActiveDebts(DebtType type) {
    return _debts.where((d) => d.type == type && !d.isPaid).toList();
  }

  List<Debt> getClosedDebts(DebtType type) {
    return _debts.where((d) => d.type == type && d.isPaid).toList();
  }

  List<Debt> getOverdueDebts(DebtType type) {
    return _debts.where((d) => d.type == type && d.isOverdue).toList();
  }

  List<DebtRecord> getDebtRecords(String debtId) {
    return _debtRecords.where((dr) => dr.debtId == debtId).toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  void addDebtRecord(DebtRecord debtRecord) {
    _debtRecords.add(debtRecord);

    // Update the debt's current amount
    final debtIndex = _debts.indexWhere((d) => d.id == debtRecord.debtId);
    if (debtIndex != -1) {
      final debt = _debts[debtIndex];
      double newCurrentAmount = debt.currentAmount;

      if (debtRecord.action == DebtAction.repay) {
        newCurrentAmount -= debtRecord.amount;
      } else if (debtRecord.action == DebtAction.increaseDebt) {
        newCurrentAmount += debtRecord.amount;
      }

      // Ensure current amount doesn't go below 0
      newCurrentAmount = newCurrentAmount < 0 ? 0 : newCurrentAmount;

      final updatedDebt = debt.copyWith(currentAmount: newCurrentAmount);
      _debts[debtIndex] = updatedDebt;

      // Create corresponding wallet record
      _createWalletRecord(debtRecord, debt);
    }

    notifyListeners();
  }

  void _createWalletRecord(DebtRecord debtRecord, Debt debt) {
    // Create a wallet record based on the debt record
    WalletRecord walletRecord;

    if (debt.type == DebtType.iLent) {
      // If I lent money
      if (debtRecord.action == DebtAction.repay) {
        // They're paying me back - income to my account
        walletRecord = WalletRecord(
          id: 'debt_${debtRecord.id}',
          type: RecordType.income,
          category: 'Debt Repayment',
          account: debtRecord.account,
          amount: debtRecord.amount,
          dateTime: debtRecord.dateTime,
          note:
              'Debt repayment from ${debt.name}${debtRecord.note != null ? ' - ${debtRecord.note}' : ''}',
          label: 'Debt Repayment',
        );
      } else {
        // I'm lending more money - expense from my account
        walletRecord = WalletRecord(
          id: 'debt_${debtRecord.id}',
          type: RecordType.expense,
          category: 'Debt Increase',
          account: debtRecord.account,
          amount: debtRecord.amount,
          dateTime: debtRecord.dateTime,
          note:
              'Additional loan to ${debt.name}${debtRecord.note != null ? ' - ${debtRecord.note}' : ''}',
          label: 'Debt Increase',
        );
      }
    } else {
      // If I owe money
      if (debtRecord.action == DebtAction.repay) {
        // I'm paying them back - expense from my account
        walletRecord = WalletRecord(
          id: 'debt_${debtRecord.id}',
          type: RecordType.expense,
          category: 'Debt Repayment',
          account: debtRecord.account,
          amount: debtRecord.amount,
          dateTime: debtRecord.dateTime,
          note:
              'Debt repayment to ${debt.name}${debtRecord.note != null ? ' - ${debtRecord.note}' : ''}',
          label: 'Debt Repayment',
        );
      } else {
        // They're lending me more money - income to my account
        walletRecord = WalletRecord(
          id: 'debt_${debtRecord.id}',
          type: RecordType.income,
          category: 'Debt Increase',
          account: debtRecord.account,
          amount: debtRecord.amount,
          dateTime: debtRecord.dateTime,
          note:
              'Additional loan from ${debt.name}${debtRecord.note != null ? ' - ${debtRecord.note}' : ''}',
          label: 'Debt Increase',
        );
      }
    }

    _recordService.addRecord(walletRecord);
  }

  void deleteDebtRecord(String debtRecordId) {
    final debtRecord = _debtRecords.firstWhere((dr) => dr.id == debtRecordId);
    final debt = _debts.firstWhere((d) => d.id == debtRecord.debtId);

    // Reverse the amount change
    double newCurrentAmount = debt.currentAmount;
    if (debtRecord.action == DebtAction.repay) {
      newCurrentAmount += debtRecord.amount;
    } else if (debtRecord.action == DebtAction.increaseDebt) {
      newCurrentAmount -= debtRecord.amount;
    }

    final updatedDebt = debt.copyWith(currentAmount: newCurrentAmount);
    final debtIndex = _debts.indexWhere((d) => d.id == debt.id);
    _debts[debtIndex] = updatedDebt;

    // Remove the debt record
    _debtRecords.removeWhere((dr) => dr.id == debtRecordId);

    // Remove the corresponding wallet record
    _recordService.deleteRecord('debt_$debtRecordId');

    notifyListeners();
  }

  double getTotalAmountByType(DebtType type) {
    return _debts
        .where((d) => d.type == type && !d.isPaid)
        .fold(0.0, (sum, debt) => sum + debt.currentAmount);
  }

  String getFormattedTotalAmountByType(DebtType type) {
    final total = getTotalAmountByType(type);
    return 'IDR ${total.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  int getActiveDebtCount(DebtType type) {
    return getActiveDebts(type).length;
  }

  int getOverdueDebtCount(DebtType type) {
    return getOverdueDebts(type).length;
  }

  // Get debt by ID
  Debt? getDebtById(String debtId) {
    try {
      return _debts.firstWhere((d) => d.id == debtId);
    } catch (e) {
      return null;
    }
  }
}
