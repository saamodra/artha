import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/wallet_record.dart';
import '../services/record_service.dart';
import '../services/wallet_service.dart';
import '../widgets/record_item.dart';
import '../widgets/filterable_records.dart';
import 'add_record_page.dart';

class WalletDetailsPage extends StatefulWidget {
  final Map<String, dynamic> wallet;

  const WalletDetailsPage({super.key, required this.wallet});

  @override
  State<WalletDetailsPage> createState() => _WalletDetailsPageState();
}

class _WalletDetailsPageState extends State<WalletDetailsPage> {
  final RecordService recordService = RecordService();
  final WalletService walletService = WalletService();
  String selectedPeriod = 'This Month';
  final List<String> periods = [
    'This Week',
    'This Month',
    'This Year',
    'All Time',
  ];

  @override
  Widget build(BuildContext context) {
    final walletName = widget.wallet['name'] as String;

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        title: Text(
          walletName,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () => _showWalletOptions(),
            icon: const Icon(Icons.more_vert, color: Colors.white70),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: recordService,
        builder: (context, child) {
          return SingleChildScrollView(
            child: Column(
              children: [
                // Balance Trend Section
                _buildBalanceTrendSection(),

                // Cash Flow Section
                _buildCashFlowSection(),

                // Recent Records Section
                _buildRecentRecordsSection(),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddRecord(),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBalanceTrendSection() {
    final walletName = widget.wallet['name'] as String;
    final trendData = _generateTrendData(walletName);
    final balance = recordService.getFormattedBalanceForAccount(walletName);

    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        color: const Color(0xFF1A1A1A),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Balance and Change
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Current Balance',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          balance,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getBalanceChangeColor().withValues(
                              alpha: 0.2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getBalanceChangeText(),
                            style: TextStyle(
                              color: _getBalanceChangeColor(),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    initialValue: selectedPeriod,
                    onSelected: (value) {
                      setState(() {
                        selectedPeriod = value;
                      });
                    },
                    itemBuilder: (context) => periods
                        .map(
                          (period) =>
                              PopupMenuItem(value: period, child: Text(period)),
                        )
                        .toList(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            selectedPeriod,
                            style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.blue,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: trendData.isNotEmpty
                          ? (trendData
                                        .map((e) => e.y)
                                        .reduce((a, b) => a > b ? a : b) -
                                    trendData
                                        .map((e) => e.y)
                                        .reduce((a, b) => a < b ? a : b)) /
                                4
                          : 100000,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.white.withValues(alpha: 0.1),
                          strokeWidth: 1,
                        );
                      },
                    ),
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
                          reservedSize: 60,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              _formatChartValue(value),
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
                            return Text(
                              _getDateLabel(value.toInt()),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: trendData,
                        isCurved: true,
                        color: widget.wallet['color'] as Color,
                        barWidth: 3,
                        belowBarData: BarAreaData(
                          show: true,
                          color: (widget.wallet['color'] as Color).withValues(
                            alpha: 0.3,
                          ),
                        ),
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 4,
                              color: widget.wallet['color'] as Color,
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCashFlowSection() {
    final walletName = widget.wallet['name'] as String;
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    // Get today's records for this wallet
    final todayRecords = recordService
        .getRecordsByDateRange(startOfDay, endOfDay)
        .where(
          (record) =>
              record.account == walletName ||
              (record.transferToAccount == walletName &&
                  record.type == RecordType.transfer),
        )
        .toList();

    double income = 0;
    double expenses = 0;

    for (final record in todayRecords) {
      if (record.account == walletName) {
        switch (record.type) {
          case RecordType.income:
            income += record.amount;
            break;
          case RecordType.expense:
            expenses += record.amount;
            break;
          case RecordType.transfer:
            expenses += record.amount; // Outgoing transfer
            break;
        }
      }
      // Incoming transfers to this wallet
      if (record.transferToAccount == walletName &&
          record.type == RecordType.transfer) {
        income += record.amount;
      }
    }

    final netCashFlow = income - expenses;

    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        color: const Color(0xFF1A1A1A),
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
                'IDR ${netCashFlow >= 0 ? '+' : ''}${_formatAmount(netCashFlow.abs())}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: netCashFlow >= 0 ? Colors.green : Colors.red,
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
                    'IDR ${_formatAmount(income)}',
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
                value: (income + expenses) > 0
                    ? income / (income + expenses)
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
                    '-IDR ${_formatAmount(expenses)}',
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
                value: (income + expenses) > 0
                    ? expenses / (income + expenses)
                    : 0.0,
                backgroundColor: Colors.grey[800],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                minHeight: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentRecordsSection() {
    final walletName = widget.wallet['name'] as String;
    final records = recordService.getRecordsForAccount(walletName);
    final recentRecords = records.take(10).toList();

    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        color: const Color(0xFF1A1A1A),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Records',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _showAllRecords(),
                    child: const Text(
                      'See All',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
            if (recentRecords.isEmpty)
              Padding(
                padding: const EdgeInsets.all(40),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long,
                        size: 48,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No records yet',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap the + button to add your first record',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.3),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: recentRecords
                    .map(
                      (record) => RecordItem(
                        record: record,
                        wallets: walletService.getWalletsInLegacyFormat(),
                        recordService: recordService,
                        onRecordChanged: () => setState(() {}),
                        contextWalletName: widget.wallet['name'] as String,
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  void _showWalletOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text(
                'Edit Wallet',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _showComingSoonDialog('Edit Wallet');
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart, color: Colors.blue),
              title: const Text(
                'View Analytics',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _showComingSoonDialog('Analytics');
              },
            ),
            ListTile(
              leading: const Icon(Icons.file_download, color: Colors.blue),
              title: const Text(
                'Export Records',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _showComingSoonDialog('Export Records');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAllRecords() {
    final walletName = widget.wallet['name'] as String;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FilterableRecords(
          title: '$walletName Records',
          specificWallet: walletName,
          recordService: recordService,
          wallets: walletService.getWalletsInLegacyFormat(),
        ),
      ),
    );
  }

  void _navigateToAddRecord() {
    final walletName = widget.wallet['name'] as String;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddRecordPage(preSelectedWallet: walletName),
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

  // Helper methods
  Color _getBalanceChangeColor() {
    // For demo purposes, randomly showing positive trend
    return Colors.green;
  }

  String _getBalanceChangeText() {
    // For demo purposes, showing positive change
    return '+2.5%';
  }

  List<FlSpot> _generateTrendData(String walletName) {
    // Generate sample trend data based on wallet balance
    final currentBalance = recordService.getTotalBalanceForAccount(walletName);
    final baseBalance = currentBalance * 0.8;

    return [
      FlSpot(0, baseBalance),
      FlSpot(1, baseBalance * 1.05),
      FlSpot(2, baseBalance * 0.98),
      FlSpot(3, baseBalance * 1.12),
      FlSpot(4, baseBalance * 1.08),
      FlSpot(5, baseBalance * 1.15),
      FlSpot(6, currentBalance),
    ];
  }

  String _formatChartValue(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    } else {
      return value.toStringAsFixed(0);
    }
  }

  String _getDateLabel(int index) {
    final now = DateTime.now();
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    switch (selectedPeriod) {
      case 'This Week':
        return days[index % 7];
      case 'This Month':
        return 'W${index + 1}';
      case 'This Year':
        final months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];
        return months[index % 12];
      default:
        return '${now.year - 6 + index}';
    }
  }

  String _formatAmount(double amount) {
    return amount
        .toStringAsFixed(2)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}
