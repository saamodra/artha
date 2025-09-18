import 'package:flutter/material.dart';

class Wallet {
  final String id;
  final String name;
  final WalletType type;
  final Color color;
  final double initialValue;
  final String? accountNumber; // For manual input wallets
  final String? accountType; // For manual input wallets (Bank, E-wallet, etc.)
  final AssetType? assetType; // For investment wallets
  final DateTime createdAt;

  Wallet({
    required this.id,
    required this.name,
    required this.type,
    required this.color,
    required this.initialValue,
    this.accountNumber,
    this.accountType,
    this.assetType,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert to Map for storage/serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'color': color.value, // Note: Using deprecated .value for backward compatibility
      'initialValue': initialValue,
      'accountNumber': accountNumber,
      'accountType': accountType,
      'assetType': assetType?.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from Map for deserialization
  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'],
      name: json['name'],
      type: WalletType.values.firstWhere((e) => e.name == json['type']),
      color: Color(json['color']),
      initialValue: json['initialValue'].toDouble(),
      accountNumber: json['accountNumber'],
      accountType: json['accountType'],
      assetType: json['assetType'] != null
          ? AssetType.values.firstWhere((e) => e.name == json['assetType'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  // Create a copy with updated values
  Wallet copyWith({
    String? id,
    String? name,
    WalletType? type,
    Color? color,
    double? initialValue,
    String? accountNumber,
    String? accountType,
    AssetType? assetType,
    DateTime? createdAt,
  }) {
    return Wallet(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      color: color ?? this.color,
      initialValue: initialValue ?? this.initialValue,
      accountNumber: accountNumber ?? this.accountNumber,
      accountType: accountType ?? this.accountType,
      assetType: assetType ?? this.assetType,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Convert to the legacy format used in the app
  Map<String, dynamic> toLegacyFormat() {
    return {
      'name': name,
      'balance': 'IDR ${_formatCurrency(initialValue)}',
      'color': color,
      'hasIcon': type == WalletType.investment,
    };
  }

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}

enum WalletType {
  manualInput,
  investment,
}

enum AssetType {
  stocks,
  crypto,
}

// Extension to get display names
extension WalletTypeExtension on WalletType {
  String get displayName {
    switch (this) {
      case WalletType.manualInput:
        return 'Manual Input';
      case WalletType.investment:
        return 'Investment';
    }
  }
}

extension AssetTypeExtension on AssetType {
  String get displayName {
    switch (this) {
      case AssetType.stocks:
        return 'Stocks';
      case AssetType.crypto:
        return 'Crypto';
    }
  }
}

// Predefined account types for manual input wallets
class AccountTypes {
  static const List<String> manualInputTypes = [
    'Bank Account',
    'E-Wallet',
    'Cash',
    'Savings',
    'Credit Card',
    'Debit Card',
    'Investment Account',
    'Business Account',
    'Other',
  ];
}
