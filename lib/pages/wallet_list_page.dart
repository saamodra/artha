import 'package:flutter/material.dart';
import '../services/record_service.dart';
import 'wallet_details_page.dart';

class WalletListPage extends StatefulWidget {
  const WalletListPage({super.key});

  @override
  State<WalletListPage> createState() => _WalletListPageState();
}

class _WalletListPageState extends State<WalletListPage> {
  final RecordService recordService = RecordService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        title: const Text(
          'Wallet List',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              _showAccountSettings();
            },
            icon: const Icon(Icons.settings, color: Colors.white70),
          ),
        ],
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: recordService,
          builder: (context, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Section
                  _buildSummarySection(),
                  const SizedBox(height: 24),

                  // Accounts Grid
                  const Text(
                    'All Accounts',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildAccountsGrid(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummarySection() {
    final allWalletNames = _getAllAccounts()
        .map((account) => account['name'] as String)
        .toList();
    final totalBalance = recordService.getFormattedTotalBalance(allWalletNames);

    return Card(
      color: const Color(0xFF1A1A1A),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Total Balance',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              totalBalance,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Active Accounts',
                    '${_getAllAccounts().length}',
                    Icons.account_balance_wallet,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryItem(
                    'This Month',
                    '+2.5%',
                    Icons.trending_up,
                    Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountsGrid() {
    final accounts = _getAllAccounts();

    return Column(
      children: [
        ...accounts.map((account) => _buildAccountRow(account)),
        _buildAddAccountRow(),
      ],
    );
  }

  Widget _buildAccountRow(Map<String, dynamic> account) {
    final accountName = account['name'] as String;
    final balance = recordService.getFormattedBalanceForAccount(accountName);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Card(
        color: const Color(0xFF1A1A1A),
        child: ListTile(
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: account['color'] as Color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: account['hasIcon'] == true
                ? const Icon(Icons.trending_up, color: Colors.white, size: 24)
                : const SizedBox(),
          ),
          title: Text(
            accountName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            balance,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: IconButton(
            onPressed: () => _showAccountOptions(account),
            icon: const Icon(Icons.more_vert, color: Colors.white70, size: 20),
          ),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => WalletDetailsPage(wallet: account),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddAccountRow() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Card(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.add, color: Colors.blue, size: 24),
            ),
            title: const Text(
              'Add New Account',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: const Text(
              'Create a new wallet account',
              style: TextStyle(color: Colors.blue, fontSize: 12),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              color: Colors.blue,
              size: 16,
            ),
            onTap: () {
              _showComingSoonDialog('Add Account');
            },
          ),
        ),
      ),
    );
  }

  void _showAccountOptions(Map<String, dynamic> account) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              account['name'] as String,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.visibility, color: Colors.blue),
              title: const Text(
                'View Details',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => WalletDetailsPage(wallet: account),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text(
                'Edit Account',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _showComingSoonDialog('Edit Account');
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Delete Account',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _showComingSoonDialog('Delete Account');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAccountSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Account Settings',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.add, color: Colors.white70),
              title: const Text(
                'Add Account',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.of(context).pop();
                _showComingSoonDialog('Add Account');
              },
            ),
            ListTile(
              leading: const Icon(Icons.reorder, color: Colors.white70),
              title: const Text(
                'Reorder Accounts',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.of(context).pop();
                _showComingSoonDialog('Reorder Accounts');
              },
            ),
            ListTile(
              leading: const Icon(Icons.import_export, color: Colors.white70),
              title: const Text(
                'Import/Export',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.of(context).pop();
                _showComingSoonDialog('Import/Export');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(feature, style: const TextStyle(color: Colors.white)),
        content: const Text(
          'This feature is coming soon!',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getAllAccounts() {
    return [
      {
        'name': 'Cashfile',
        'balance': 'IDR 90,000.00',
        'color': const Color(0xFF8D6E63),
        'hasIcon': false,
      },
      {
        'name': 'Cash',
        'balance': 'IDR 349,000.00',
        'color': const Color(0xFF8D6E63),
        'hasIcon': false,
      },
      {
        'name': 'BRI',
        'balance': 'IDR 262,337.00',
        'color': Colors.blue,
        'hasIcon': false,
      },
      {
        'name': 'Ajaib Stocks',
        'balance': 'IDR 41,693,789.00',
        'color': Colors.blue,
        'hasIcon': true,
      },
      {
        'name': 'Ajaib Kripto',
        'balance': 'IDR 11,485,644.00',
        'color': Colors.purple,
        'hasIcon': false,
      },
      {
        'name': 'Bibit',
        'balance': 'IDR 236,371,256.00',
        'color': Colors.green,
        'hasIcon': false,
      },
      {
        'name': 'SeaBank',
        'balance': 'IDR 4,263,340.00',
        'color': Colors.orange,
        'hasIcon': false,
      },
      {
        'name': 'BCA',
        'balance': 'IDR 16,237,019.00',
        'color': Colors.blue,
        'hasIcon': false,
      },
      {
        'name': 'Bibit Saham',
        'balance': 'IDR 16,065,682.00',
        'color': Colors.grey,
        'hasIcon': true,
      },
      {
        'name': 'Bibit Saham 2',
        'balance': 'IDR 92,196,754.00',
        'color': Colors.orange,
        'hasIcon': true,
      },
      {
        'name': 'Shopeepay',
        'balance': 'IDR 372,623.00',
        'color': Colors.orange,
        'hasIcon': false,
      },
      {
        'name': 'Permata',
        'balance': 'IDR 6,570.00',
        'color': Colors.green,
        'hasIcon': false,
      },
    ];
  }
}
