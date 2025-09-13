class WalletRecord {
  final String id;
  final RecordType type;
  final String category;
  final String account;
  final String? transferToAccount; // For transfer records
  final double amount;
  final DateTime dateTime;
  final String? note;
  final String? label;

  WalletRecord({
    required this.id,
    required this.type,
    required this.category,
    required this.account,
    this.transferToAccount,
    required this.amount,
    required this.dateTime,
    this.note,
    this.label,
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
      'label': label,
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
      label: json['label'],
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
