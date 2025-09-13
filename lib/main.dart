import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'reorder_wallets_page.dart';
import 'auth_service.dart';
import 'login_page.dart';
import 'profile_page.dart';
import 'services/record_service.dart';
import 'main_navigation.dart';
import 'pages/wallet_details_page.dart';

void main() {
  runApp(const ArthaDiamondWalletApp());
}

class ArthaDiamondWalletApp extends StatelessWidget {
  const ArthaDiamondWalletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Artha Diamond Wallet',
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.dark(
          primary: Colors.blue,
          secondary: Colors.blueAccent,
          surface: const Color(0xFF1A1A1A),
        ),
        scaffoldBackgroundColor: const Color(0xFF111111),
        cardTheme: const CardThemeData(
          color: Color(0xFF1A1A1A),
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      ),
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const MainNavigation(),
        '/profile': (context) => const ProfilePage(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AuthService(),
      builder: (context, child) {
        if (AuthService().isAuthenticated) {
          return const MainNavigation();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}

class WalletHomePage extends StatefulWidget {
  const WalletHomePage({super.key});

  @override
  State<WalletHomePage> createState() => _WalletHomePageState();
}

class _WalletHomePageState extends State<WalletHomePage> {
  Set<String> selectedWallets = {};
  bool isAllSelected = true;
  List<Map<String, dynamic>>? _reorderedWallets;
  final RecordService recordService = RecordService();

  @override
  void initState() {
    super.initState();
    // Initialize with all wallets selected
    selectedWallets = getWallets()
        .map((account) => account['name'] as String)
        .toSet();
  }

  List<Map<String, dynamic>> getWallets() {
    return _reorderedWallets ?? getAllAccounts();
  }

  void toggleWalletSelection(String walletName) {
    setState(() {
      if (selectedWallets.contains(walletName)) {
        // If wallet is selected and we're clicking it, deselect all others
        if (selectedWallets.length > 1) {
          selectedWallets = {walletName};
          isAllSelected = false;
        }
      } else {
        // If wallet is not selected, select only this wallet
        selectedWallets = {walletName};
        isAllSelected = false;
      }
    });
  }

  void selectAllWallets() {
    setState(() {
      selectedWallets = getWallets()
          .map((account) => account['name'] as String)
          .toSet();
      isAllSelected = true;
    });
  }

  void _onWalletsReordered(List<Map<String, dynamic>> reorderedWallets) {
    setState(() {
      _reorderedWallets = reorderedWallets;
      // Update selected wallets to maintain the selection after reordering
      selectedWallets = getWallets()
          .map((account) => account['name'] as String)
          .toSet()
          .intersection(selectedWallets);
    });
  }

  void _showAccountDetail() {
    final selectedAccount = getWallets().firstWhere(
      (account) => selectedWallets.contains(account['name']),
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WalletDetailsPage(wallet: selectedAccount),
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
              leading: const Icon(Icons.edit, color: Colors.white70),
              title: const Text(
                'Edit Accounts',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.of(context).pop();
                // Add edit functionality here
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
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ReorderWalletsPage(
                      initialWallets: getWallets(),
                      onReorder: _onWalletsReordered,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.visibility, color: Colors.white70),
              title: const Text(
                'Show/Hide Accounts',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.of(context).pop();
                // Add show/hide functionality here
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

  String _getSelectedWalletsBalance() {
    if (isAllSelected) {
      // Return total of all wallets
      final allWalletNames = getWallets()
          .map((account) => account['name'] as String)
          .toList();
      return recordService.getFormattedTotalBalance(allWalletNames);
    } else {
      // Calculate balance for selected wallets
      return recordService.getFormattedTotalBalance(selectedWallets.toList());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: recordService,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFF111111),
            title: const Text(
              'Home',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            automaticallyImplyLeading: false,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Accounts List Section
                  _buildAccountsListSection(),
                  const SizedBox(height: 24),

                  // Quick Actions
                  _buildQuickActions(),
                  const SizedBox(height: 24),

                  // Balance Trend Card
                  _buildBalanceTrendCard(),
                  const SizedBox(height: 24),

                  // Cash Flow Card
                  _buildCashFlowCard(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAccountsListSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'List of accounts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            IconButton(
              onPressed: () {
                // Settings functionality
                _showAccountSettings();
              },
              icon: const Icon(Icons.settings, color: Colors.white70, size: 20),
            ),
          ],
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...getWallets().map(
                  (account) =>
                      _buildCompactAccountCard(account, constraints.maxWidth),
                ),
                _buildAddAccountCard(constraints.maxWidth),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        // Action buttons at the bottom
        Row(
          children: [
            if (!isAllSelected && selectedWallets.length == 1) ...[
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Show account detail functionality
                    _showAccountDetail();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Account Detail',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: ElevatedButton(
                onPressed: selectAllWallets,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isAllSelected ? Colors.grey : Colors.green,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  isAllSelected ? 'All Selected' : 'Select All',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {'icon': Icons.credit_card, 'label': 'Debts', 'color': Colors.red},
      {'icon': Icons.trending_up, 'label': 'Cash-flow', 'color': Colors.teal},
      {
        'icon': Icons.account_balance_wallet,
        'label': 'Balance',
        'color': Colors.blue,
      },
      {
        'icon': Icons.card_membership,
        'label': 'Loyalty card',
        'color': Colors.purple,
      },
    ];

    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: actions.length,
        itemBuilder: (context, index) {
          final action = actions[index];
          final isSelected = index == 2; // Balance is selected

          return Container(
            margin: const EdgeInsets.only(right: 24),
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? action['color'] as Color
                        : Colors.grey[800],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    action['icon'] as IconData,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  action['label'] as String,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontSize: 12,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBalanceTrendCard() {
    // Calculate total balance for selected wallets
    String displayBalance = _getSelectedWalletsBalance();
    String displayTitle = isAllSelected
        ? 'Balance Trend'
        : selectedWallets.length == 1
        ? '${selectedWallets.first} Balance'
        : 'Selected Wallets Balance';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  displayTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_vert, color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'TODAY',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  displayBalance,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '+59%',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${(value / 1000000).toInt()}M',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 0:
                              return const Text(
                                'Jul 28',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                ),
                              );
                            case 1:
                              return const Text(
                                'Aug 7',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                ),
                              );
                            case 2:
                              return const Text(
                                'Aug 17',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                ),
                              );
                            case 3:
                              return const Text(
                                'Today',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                ),
                              );
                            default:
                              return const Text('');
                          }
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        const FlSpot(0, 350000000),
                        const FlSpot(0.5, 480000000),
                        const FlSpot(1, 470000000),
                        const FlSpot(1.5, 485000000),
                        const FlSpot(2, 460000000),
                        const FlSpot(2.5, 440000000),
                        const FlSpot(3, 433565157),
                      ],
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withValues(alpha: 0.3),
                      ),
                      dotData: FlDotData(show: false),
                    ),
                  ],
                  minY: 300000000,
                  maxY: 500000000,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {},
              child: const Text(
                'SHOW MORE',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCashFlowCard() {
    // Get today's cash flow
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final cashFlow = recordService.getCashFlowSummary(startOfDay, endOfDay);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Cash Flow',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_vert, color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'TODAY',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'IDR ${(cashFlow['net']! >= 0 ? '+' : '')}${cashFlow['net']!.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: cashFlow['net']! >= 0 ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 20),

            // Income row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Income',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                Text(
                  'IDR ${cashFlow['income']!.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: (cashFlow['income']! + cashFlow['expenses']!) > 0
                  ? cashFlow['income']! /
                        (cashFlow['income']! + cashFlow['expenses']!)
                  : 0.0,
              backgroundColor: Colors.grey[800],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              minHeight: 8,
            ),
            const SizedBox(height: 20),

            // Expenses row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Expenses',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                Text(
                  '-IDR ${cashFlow['expenses']!.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: (cashFlow['income']! + cashFlow['expenses']!) > 0
                  ? cashFlow['expenses']! /
                        (cashFlow['income']! + cashFlow['expenses']!)
                  : 0.0,
              backgroundColor: Colors.grey[800],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
              minHeight: 8,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactAccountCard(
    Map<String, dynamic> account,
    double containerWidth,
  ) {
    // Calculate card width to fit 3 cards per row with spacing
    double cardWidth = (containerWidth - 16) / 3; // 16 = spacing (8*2)
    final accountName = account['name'] as String;
    final isSelected = selectedWallets.contains(accountName);

    return SizedBox(
      width: cardWidth,
      height: 40, // Smaller height
      child: GestureDetector(
        onTap: () => toggleWalletSelection(accountName),
        child: Card(
          color: isSelected
              ? account['color'] as Color
              : (account['color'] as Color).withValues(alpha: 0.3),
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border:
                  isSelected && !isAllSelected && selectedWallets.length == 1
                  ? Border.all(color: Colors.blue, width: 2)
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 0), // No icon, just spacing
                  Expanded(
                    child: Text(
                      accountName,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w600,
                        fontSize: 10, // Smaller font
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    recordService.getFormattedBalanceForAccount(accountName),
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w500,
                      fontSize: 10, // Smaller font
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddAccountCard(double containerWidth) {
    // Calculate card width to fit 3 cards per row with spacing
    double cardWidth = (containerWidth - 16) / 3; // 16 = spacing (8*2)

    return SizedBox(
      width: cardWidth,
      height: 40, // Same height as account cards
      child: Card(
        color: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.add, color: Colors.blue, size: 16),
              SizedBox(width: 4),
              Text(
                'ADD ACCOUNT',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> getAllAccounts() {
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
      {
        'name': 'MQ Sekuritas',
        'balance': 'IDR 18,450,715.00',
        'color': Colors.orange,
        'hasIcon': false,
      },
      {
        'name': 'Bareksa Gold',
        'balance': 'IDR 0',
        'color': Colors.orange,
        'hasIcon': false,
      },
      {
        'name': 'Bareksa RD',
        'balance': 'IDR 75,512.00',
        'color': Colors.green,
        'hasIcon': false,
      },
      {
        'name': 'Jago',
        'balance': 'IDR 169,297.00',
        'color': Colors.orange,
        'hasIcon': false,
      },
      {
        'name': 'Gopay',
        'balance': 'IDR 144,346.00',
        'color': Colors.green,
        'hasIcon': false,
      },
      {
        'name': 'DANA',
        'balance': 'IDR 824.00',
        'color': Colors.lightBlue,
        'hasIcon': false,
      },
      {
        'name': 'pluang',
        'balance': 'IDR 56,518.00',
        'color': Colors.blue,
        'hasIcon': false,
      },
      {
        'name': 'Gopay Coins',
        'balance': 'IDR 0',
        'color': Colors.green,
        'hasIcon': false,
      },
      {
        'name': 'Flip',
        'balance': 'IDR 2,935.00',
        'color': Colors.orange,
        'hasIcon': false,
      },
      {
        'name': 'Shopee Koin',
        'balance': 'IDR 0',
        'color': Colors.orange,
        'hasIcon': false,
      },
      {
        'name': 'blu',
        'balance': 'IDR 942.00',
        'color': Colors.cyan,
        'hasIcon': false,
      },
      {
        'name': 'NeoBank',
        'balance': 'IDR 643.00',
        'color': Colors.orange,
        'hasIcon': false,
      },
      {
        'name': 'Line Bank',
        'balance': 'IDR 36.00',
        'color': Colors.green,
        'hasIcon': false,
      },
      {
        'name': 'OVO',
        'balance': 'IDR 58,659.00',
        'color': Colors.purple,
        'hasIcon': false,
      },
      {
        'name': 'LinkAja',
        'balance': 'IDR 5,250.00',
        'color': Colors.red,
        'hasIcon': false,
      },
      {
        'name': 'Bukalapak',
        'balance': 'IDR 12,326.00',
        'color': Colors.blue,
        'hasIcon': false,
      },
      {
        'name': 'Blibay',
        'balance': 'IDR 0',
        'color': Colors.cyan,
        'hasIcon': false,
      },
      {
        'name': 'GoTrade',
        'balance': '\$0.00',
        'color': Colors.teal,
        'hasIcon': false,
      },
      {
        'name': 'Shopback',
        'balance': 'IDR 0',
        'color': Colors.red,
        'hasIcon': false,
      },
      {
        'name': 'Mandiri E-Money',
        'balance': 'IDR 2,500.00',
        'color': Colors.blue,
        'hasIcon': false,
      },
      {
        'name': 'Brizzi',
        'balance': 'IDR 11,000.00',
        'color': Colors.blue,
        'hasIcon': false,
      },
      {
        'name': 'BNI TapCash',
        'balance': 'IDR 15,500.00',
        'color': Colors.red,
        'hasIcon': false,
      },
      {
        'name': 'Flazz',
        'balance': 'IDR 7,000.00',
        'color': Colors.green,
        'hasIcon': false,
      },
      {
        'name': 'Sbux Card',
        'balance': 'IDR 135,000.00',
        'color': Colors.teal,
        'hasIcon': false,
      },
      {
        'name': 'Jenius',
        'balance': 'IDR 0',
        'color': Colors.grey,
        'hasIcon': false,
      },
      {
        'name': 'Kaspro',
        'balance': 'IDR 22,100.00',
        'color': Colors.orange,
        'hasIcon': false,
      },
      {
        'name': 'MotionPay',
        'balance': 'IDR 40.00',
        'color': Colors.blue,
        'hasIcon': false,
      },
    ];
  }
}

class AccountsListPage extends StatelessWidget {
  const AccountsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        title: const Text(
          'Home',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header section
            Container(
              color: const Color(0xFF111111),
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 2,
                        width: 120,
                        color: Colors.white,
                        margin: const EdgeInsets.only(bottom: 8),
                      ),
                      const Text(
                        'ACCOUNTS',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'BUDGETS & GOALS',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            // List of accounts header
            Container(
              color: const Color(0xFF1A1A1A),
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'List of accounts',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.settings,
                      color: Colors.blue,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            // Accounts grid
            Expanded(
              child: Container(
                color: const Color(0xFF1A1A1A),
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ...getAllAccounts().map(
                            (account) => _buildCompactAccountCard(
                              account,
                              constraints.maxWidth,
                            ),
                          ),
                          _buildAddAccountCard(constraints.maxWidth),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),

            // Bottom section with RECORDS button
            Container(
              color: const Color(0xFF111111),
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.view_list, color: Colors.white70),
                        SizedBox(width: 8),
                        Text(
                          'RECORDS',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactAccountCard(
    Map<String, dynamic> account,
    double containerWidth,
  ) {
    // Calculate card width to fit 3 cards per row with spacing
    double cardWidth = (containerWidth - 16) / 3; // 16 = spacing (8*2)

    return SizedBox(
      width: cardWidth,
      height: 70, // Smaller height
      child: Card(
        color: account['color'] as Color,
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(6), // Smaller padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (account['hasIcon'] == true)
                    const Icon(
                      Icons.trending_up,
                      color: Colors.white,
                      size: 12,
                    ),
                  const Spacer(),
                ],
              ),
              Expanded(
                child: Text(
                  account['name'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 9, // Smaller font
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                account['balance'] as String,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 8, // Smaller font
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddAccountCard(double containerWidth) {
    // Calculate card width to fit 3 cards per row with spacing
    double cardWidth = (containerWidth - 16) / 3; // 16 = spacing (8*2)

    return SizedBox(
      width: cardWidth,
      height: 70, // Same height as account cards
      child: Card(
        color: Colors.transparent,
        margin: EdgeInsets.zero,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: Colors.blue, size: 20), // Smaller icon
              SizedBox(height: 2),
              Text(
                'ADD ACCOUNT',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 8, // Smaller font
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> getAllAccounts() {
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
      {
        'name': 'MQ Sekuritas',
        'balance': 'IDR 18,450,715.00',
        'color': Colors.orange,
        'hasIcon': false,
      },
      {
        'name': 'Bareksa Gold',
        'balance': 'IDR 0',
        'color': Colors.orange,
        'hasIcon': false,
      },
      {
        'name': 'Bareksa RD',
        'balance': 'IDR 75,512.00',
        'color': Colors.green,
        'hasIcon': false,
      },
      {
        'name': 'Jago',
        'balance': 'IDR 169,297.00',
        'color': Colors.orange,
        'hasIcon': false,
      },
      {
        'name': 'Gopay',
        'balance': 'IDR 144,346.00',
        'color': Colors.green,
        'hasIcon': false,
      },
      {
        'name': 'DANA',
        'balance': 'IDR 824.00',
        'color': Colors.lightBlue,
        'hasIcon': false,
      },
      {
        'name': 'pluang',
        'balance': 'IDR 56,518.00',
        'color': Colors.blue,
        'hasIcon': false,
      },
      {
        'name': 'Gopay Coins',
        'balance': 'IDR 0',
        'color': Colors.green,
        'hasIcon': false,
      },
      {
        'name': 'Flip',
        'balance': 'IDR 2,935.00',
        'color': Colors.orange,
        'hasIcon': false,
      },
      {
        'name': 'Shopee Koin',
        'balance': 'IDR 0',
        'color': Colors.orange,
        'hasIcon': false,
      },
      {
        'name': 'blu',
        'balance': 'IDR 942.00',
        'color': Colors.cyan,
        'hasIcon': false,
      },
      {
        'name': 'NeoBank',
        'balance': 'IDR 643.00',
        'color': Colors.orange,
        'hasIcon': false,
      },
      {
        'name': 'Line Bank',
        'balance': 'IDR 36.00',
        'color': Colors.green,
        'hasIcon': false,
      },
      {
        'name': 'OVO',
        'balance': 'IDR 58,659.00',
        'color': Colors.purple,
        'hasIcon': false,
      },
      {
        'name': 'LinkAja',
        'balance': 'IDR 5,250.00',
        'color': Colors.red,
        'hasIcon': false,
      },
      {
        'name': 'Bukalapak',
        'balance': 'IDR 12,326.00',
        'color': Colors.blue,
        'hasIcon': false,
      },
      {
        'name': 'Blibay',
        'balance': 'IDR 0',
        'color': Colors.cyan,
        'hasIcon': false,
      },
      {
        'name': 'GoTrade',
        'balance': '\$0.00',
        'color': Colors.teal,
        'hasIcon': false,
      },
      {
        'name': 'Shopback',
        'balance': 'IDR 0',
        'color': Colors.red,
        'hasIcon': false,
      },
      {
        'name': 'Mandiri E-Money',
        'balance': 'IDR 2,500.00',
        'color': Colors.blue,
        'hasIcon': false,
      },
      {
        'name': 'Brizzi',
        'balance': 'IDR 11,000.00',
        'color': Colors.blue,
        'hasIcon': false,
      },
      {
        'name': 'BNI TapCash',
        'balance': 'IDR 15,500.00',
        'color': Colors.red,
        'hasIcon': false,
      },
      {
        'name': 'Flazz',
        'balance': 'IDR 7,000.00',
        'color': Colors.green,
        'hasIcon': false,
      },
      {
        'name': 'Sbux Card',
        'balance': 'IDR 135,000.00',
        'color': Colors.teal,
        'hasIcon': false,
      },
      {
        'name': 'Jenius',
        'balance': 'IDR 0',
        'color': Colors.grey,
        'hasIcon': false,
      },
      {
        'name': 'Kaspro',
        'balance': 'IDR 22,100.00',
        'color': Colors.orange,
        'hasIcon': false,
      },
      {
        'name': 'MotionPay',
        'balance': 'IDR 40.00',
        'color': Colors.blue,
        'hasIcon': false,
      },
    ];
  }
}
