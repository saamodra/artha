import 'label.dart';

class WalletRecord {
  final String id;
  final RecordType type;
  final String category;
  final String account;
  final String? transferToAccount; // For transfer records
  final double amount;
  final DateTime dateTime;
  final String? note;
  final List<Label> labels; // Changed from single label to multiple labels

  WalletRecord({
    required this.id,
    required this.type,
    required this.category,
    required this.account,
    this.transferToAccount,
    required this.amount,
    required this.dateTime,
    this.note,
    this.labels = const [], // Default to empty list
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString(),
      'category': category,
      'account': account,
      'transferToAccount': transferToAccount,
      'amount': amount,
      'dateTime': dateTime.toIso8601String(),
      'note': note,
      'labels': labels.map((label) => label.toJson()).toList(),
    };
  }

  factory WalletRecord.fromJson(Map<String, dynamic> json) {
    return WalletRecord(
      id: json['id'],
      type: RecordType.values.firstWhere((e) => e.toString() == json['type']),
      category: json['category'],
      account: json['account'],
      transferToAccount: json['transferToAccount'],
      amount: json['amount'].toDouble(),
      dateTime: DateTime.parse(json['dateTime']),
      note: json['note'],
      labels: json['labels'] != null
          ? (json['labels'] as List)
                .map((labelJson) => Label.fromJson(labelJson))
                .toList()
          : [],
    );
  }

  Map<String, dynamic> toSupabaseJson() {
    return {
      'id': id,
      'record_type': type.toString().split('.').last,
      'category_id': category, // This should be category ID, not name
      'wallet_id': account, // This should be wallet ID, not name
      'transfer_to_wallet_id':
          transferToAccount, // This should be wallet ID, not name
      'amount': amount,
      'date_time': dateTime.toIso8601String(),
      'note': note,
    };
  }

  factory WalletRecord.fromSupabaseJson(Map<String, dynamic> json) {
    return WalletRecord(
      id: json['id'],
      type: RecordType.values.firstWhere(
        (e) => e.toString().split('.').last == json['record_type'],
      ),
      category:
          json['category_id'], // This will need to be resolved to category name
      account:
          json['wallet_id'], // This will need to be resolved to wallet name
      transferToAccount:
          json['transfer_to_wallet_id'], // This will need to be resolved to wallet name
      amount: json['amount'].toDouble(),
      dateTime: DateTime.parse(json['date_time']),
      note: json['note'],
      labels: [], // Labels will be loaded separately via junction table
    );
  }

  WalletRecord copyWith({
    String? id,
    RecordType? type,
    String? category,
    String? account,
    String? transferToAccount,
    double? amount,
    DateTime? dateTime,
    String? note,
    List<Label>? labels,
  }) {
    return WalletRecord(
      id: id ?? this.id,
      type: type ?? this.type,
      category: category ?? this.category,
      account: account ?? this.account,
      transferToAccount: transferToAccount ?? this.transferToAccount,
      amount: amount ?? this.amount,
      dateTime: dateTime ?? this.dateTime,
      note: note ?? this.note,
      labels: labels ?? this.labels,
    );
  }
}

enum RecordType { income, expense, transfer }

class RecordCategories {
  static const Map<RecordType, List<String>> categories = {
    RecordType.income: [
      'Salary',
      'Freelance',
      'Business Income',
      'Investment Returns',
      'Bonus',
      'Gift Received',
      'Refund',
      'Debt Repayment',
      'Debt Increase',
      'Other Income',
    ],
    RecordType.expense: [
      'Food & Drinks',
      'Shopping',
      'Transportation',
      'Vehicle',
      'Healthcare',
      'Entertainment',
      'Education',
      'Bills & Utilities',
      'Insurance',
      'Groceries',
      'Travel',
      'Charity',
      'Personal Care',
      'Home & Garden',
      'Technology',
      'Clothing & Accessories',
      'Sports & Fitness',
      'Subscriptions',
      'Taxes',
      'Debt Repayment',
      'Debt Increase',
      'Other Expenses',
    ],
    RecordType.transfer: [
      'Wallet Transfer',
      'Savings Transfer',
      'Investment Transfer',
      'Loan Repayment',
      'Other Transfer',
    ],
  };

  static List<String> getCategoriesForType(RecordType type) {
    return categories[type] ?? [];
  }
}
