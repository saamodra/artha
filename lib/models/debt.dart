class Debt {
  final String id;
  final DebtType type;
  final String name;
  final String description;
  final String account;
  final double originalAmount;
  final double currentAmount;
  final DateTime dateCreated;
  final DateTime dueDate;

  Debt({
    required this.id,
    required this.type,
    required this.name,
    required this.description,
    required this.account,
    required this.originalAmount,
    required this.currentAmount,
    required this.dateCreated,
    required this.dueDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString(),
      'name': name,
      'description': description,
      'account': account,
      'originalAmount': originalAmount,
      'currentAmount': currentAmount,
      'dateCreated': dateCreated.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
    };
  }

  factory Debt.fromJson(Map<String, dynamic> json) {
    return Debt(
      id: json['id'],
      type: DebtType.values.firstWhere((e) => e.toString() == json['type']),
      name: json['name'],
      description: json['description'],
      account: json['account'],
      originalAmount: json['originalAmount'].toDouble(),
      currentAmount: json['currentAmount'].toDouble(),
      dateCreated: DateTime.parse(json['dateCreated']),
      dueDate: DateTime.parse(json['dueDate']),
    );
  }

  Debt copyWith({
    String? id,
    DebtType? type,
    String? name,
    String? description,
    String? account,
    double? originalAmount,
    double? currentAmount,
    DateTime? dateCreated,
    DateTime? dueDate,
  }) {
    return Debt(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      description: description ?? this.description,
      account: account ?? this.account,
      originalAmount: originalAmount ?? this.originalAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      dateCreated: dateCreated ?? this.dateCreated,
      dueDate: dueDate ?? this.dueDate,
    );
  }

  bool get isOverdue => DateTime.now().isAfter(dueDate) && currentAmount > 0;
  bool get isPaid => currentAmount == 0;
  double get paidAmount => originalAmount - currentAmount;
  double get paidPercentage =>
      originalAmount > 0 ? (paidAmount / originalAmount) * 100 : 0;
}

enum DebtType { iLent, iOwe }

class DebtRecord {
  final String id;
  final String debtId;
  final DebtAction action;
  final String account;
  final double amount;
  final DateTime dateTime;
  final String? note;

  DebtRecord({
    required this.id,
    required this.debtId,
    required this.action,
    required this.account,
    required this.amount,
    required this.dateTime,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'debtId': debtId,
      'action': action.toString(),
      'account': account,
      'amount': amount,
      'dateTime': dateTime.toIso8601String(),
      'note': note,
    };
  }

  factory DebtRecord.fromJson(Map<String, dynamic> json) {
    return DebtRecord(
      id: json['id'],
      debtId: json['debtId'],
      action: DebtAction.values.firstWhere(
        (e) => e.toString() == json['action'],
      ),
      account: json['account'],
      amount: json['amount'].toDouble(),
      dateTime: DateTime.parse(json['dateTime']),
      note: json['note'],
    );
  }
}

enum DebtAction { repay, increaseDebt }
