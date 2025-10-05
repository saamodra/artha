import 'package:flutter/material.dart';
import '../services/record_service.dart';
import '../services/wallet_service.dart';
import 'wallet_details_page.dart';
import 'add_wallet_page.dart';

class WalletListPage extends StatefulWidget {
  const WalletListPage({super.key});

  @override
  State<WalletListPage> createState() => _WalletListPageState();
}

class _WalletListPageState extends State<WalletListPage> {
  final RecordService recordService = RecordService();
  final WalletService walletService = WalletService();

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
          animation: Listenable.merge([recordService, walletService]),
          builder: (context, child) {
            if (walletService.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              );
            }

            if (walletService.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading wallets',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      walletService.error!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => walletService.refreshWallets(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

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
    final totalBalance = walletService.getFormattedTotalBalance();

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
                    '${walletService.wallets.length}',
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
    final accounts = walletService.getWalletsInLegacyFormat();

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
            onTap: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AddWalletPage()),
              );

              // Refresh the page if a wallet was added
              if (result == true && mounted) {
                setState(() {});
              }
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
              onTap: () async {
                Navigator.of(context).pop();
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AddWalletPage(),
                  ),
                );

                // Refresh the page if a wallet was added
                if (result == true && mounted) {
                  setState(() {});
                }
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
}
