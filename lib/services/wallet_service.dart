import 'package:flutter/material.dart';
import '../models/wallet.dart';

class WalletService extends ChangeNotifier {
  static final WalletService _instance = WalletService._internal();
  factory WalletService() => _instance;
  WalletService._internal() {
    _initializeDefaultWallets();
  }

  final List<Wallet> _wallets = [];

  List<Wallet> get wallets => List.unmodifiable(_wallets);

  void _initializeDefaultWallets() {
    // Convert existing hardcoded wallets to the new Wallet model
    final defaultWallets = [
      Wallet(
        id: 'cashfile',
        name: 'Cashfile',
        type: WalletType.manualInput,
        color: const Color(0xFF8D6E63),
        initialValue: 90000.00,
        accountType: 'Cash',
      ),
      Wallet(
        id: 'cash',
        name: 'Cash',
        type: WalletType.manualInput,
        color: const Color(0xFF8D6E63),
        initialValue: 349000.00,
        accountType: 'Cash',
      ),
      Wallet(
        id: 'bri',
        name: 'BRI',
        type: WalletType.manualInput,
        color: Colors.blue,
        initialValue: 262337.00,
        accountType: 'Bank Account',
      ),
      Wallet(
        id: 'ajaib_stocks',
        name: 'Ajaib Stocks',
        type: WalletType.investment,
        color: Colors.blue,
        initialValue: 41693789.00,
        assetType: AssetType.stocks,
      ),
      Wallet(
        id: 'ajaib_kripto',
        name: 'Ajaib Kripto',
        type: WalletType.investment,
        color: Colors.purple,
        initialValue: 11485644.00,
        assetType: AssetType.crypto,
      ),
      Wallet(
        id: 'bibit',
        name: 'Bibit',
        type: WalletType.investment,
        color: Colors.green,
        initialValue: 236371256.00,
        assetType: AssetType.stocks,
      ),
      Wallet(
        id: 'seabank',
        name: 'SeaBank',
        type: WalletType.manualInput,
        color: Colors.orange,
        initialValue: 4263340.00,
        accountType: 'Bank Account',
      ),
      Wallet(
        id: 'bca',
        name: 'BCA',
        type: WalletType.manualInput,
        color: Colors.blue,
        initialValue: 16237019.00,
        accountType: 'Bank Account',
      ),
      Wallet(
        id: 'bibit_saham',
        name: 'Bibit Saham',
        type: WalletType.investment,
        color: Colors.grey,
        initialValue: 16065682.00,
        assetType: AssetType.stocks,
      ),
      Wallet(
        id: 'bibit_saham_2',
        name: 'Bibit Saham 2',
        type: WalletType.investment,
        color: Colors.orange,
        initialValue: 92196754.00,
        assetType: AssetType.stocks,
      ),
      Wallet(
        id: 'shopeepay',
        name: 'Shopeepay',
        type: WalletType.manualInput,
        color: Colors.orange,
        initialValue: 372623.00,
        accountType: 'E-Wallet',
      ),
      Wallet(
        id: 'permata',
        name: 'Permata',
        type: WalletType.manualInput,
        color: Colors.green,
        initialValue: 6570.00,
        accountType: 'Bank Account',
      ),
    ];

    _wallets.addAll(defaultWallets);
  }

  // Add a new wallet
  void addWallet(Wallet wallet) {
    _wallets.add(wallet);
    notifyListeners();
  }

  // Update an existing wallet
  void updateWallet(Wallet updatedWallet) {
    final index = _wallets.indexWhere((w) => w.id == updatedWallet.id);
    if (index != -1) {
      _wallets[index] = updatedWallet;
      notifyListeners();
    }
  }

  // Delete a wallet
  void deleteWallet(String walletId) {
    _wallets.removeWhere((w) => w.id == walletId);
    notifyListeners();
  }

  // Get a wallet by ID
  Wallet? getWalletById(String id) {
    try {
      return _wallets.firstWhere((w) => w.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get a wallet by name
  Wallet? getWalletByName(String name) {
    try {
      return _wallets.firstWhere((w) => w.name == name);
    } catch (e) {
      return null;
    }
  }

  // Get wallets by type
  List<Wallet> getWalletsByType(WalletType type) {
    return _wallets.where((w) => w.type == type).toList();
  }

  // Check if wallet name already exists
  bool isWalletNameExists(String name, {String? excludeId}) {
    return _wallets.any(
      (w) =>
          w.name.toLowerCase() == name.toLowerCase() &&
          (excludeId == null || w.id != excludeId),
    );
  }

  // Convert wallets to legacy format for backward compatibility
  List<Map<String, dynamic>> getWalletsInLegacyFormat() {
    return _wallets.map((wallet) => wallet.toLegacyFormat()).toList();
  }

  // Generate a unique ID for new wallets
  String generateWalletId() {
    return 'wallet_${DateTime.now().millisecondsSinceEpoch}';
  }

  // Get total balance across all wallets
  double getTotalBalance() {
    return _wallets.fold(0.0, (sum, wallet) => sum + wallet.initialValue);
  }

  // Get formatted total balance
  String getFormattedTotalBalance() {
    final total = getTotalBalance();
    return 'IDR ${_formatCurrency(total)}';
  }

  String _formatCurrency(double amount) {
    return amount
        .toStringAsFixed(2)
        .replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  // Predefined colors for wallets
  static const List<Color> walletColors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.teal,
    Colors.indigo,
    Colors.pink,
    Colors.cyan,
    Colors.amber,
    Color(0xFF8D6E63), // Brown
    Colors.grey,
    Colors.deepOrange,
    Colors.lightBlue,
    Colors.lime,
    Colors.deepPurple,
  ];
}
