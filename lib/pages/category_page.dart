import 'package:flutter/material.dart';
import '../services/record_service.dart';
import '../models/wallet_record.dart';

class RecordsFilterPage extends StatefulWidget {
  const RecordsFilterPage({super.key});

  @override
  State<RecordsFilterPage> createState() => _RecordsFilterPageState();
}

class _RecordsFilterPageState extends State<RecordsFilterPage> {
  final RecordService recordService = RecordService();

  // Filter states
  String? selectedWallet; // null means all wallets
  DateTimeRange? selectedDateRange;
  String dateFilterType =
      'All Time'; // 'All Time', 'Date Range', 'This Year', 'This Month'

  List<WalletRecord> get filteredRecords {
    List<WalletRecord> records = recordService.records;

    // Filter by wallet
    if (selectedWallet != null) {
      records = records.where((record) {
        return record.account == selectedWallet ||
            (record.transferToAccount == selectedWallet);
      }).toList();
    }

    // Filter by date
    if (dateFilterType == 'Date Range' && selectedDateRange != null) {
      records = records.where((record) {
        return record.dateTime.isAfter(
              selectedDateRange!.start.subtract(const Duration(days: 1)),
            ) &&
            record.dateTime.isBefore(
              selectedDateRange!.end.add(const Duration(days: 1)),
            );
      }).toList();
    } else if (dateFilterType == 'This Year') {
      final now = DateTime.now();
      final startOfYear = DateTime(now.year, 1, 1);
      final endOfYear = DateTime(now.year, 12, 31, 23, 59, 59);
      records = records.where((record) {
        return record.dateTime.isAfter(
              startOfYear.subtract(const Duration(days: 1)),
            ) &&
            record.dateTime.isBefore(endOfYear.add(const Duration(days: 1)));
      }).toList();
    } else if (dateFilterType == 'This Month') {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
      records = records.where((record) {
        return record.dateTime.isAfter(
              startOfMonth.subtract(const Duration(days: 1)),
            ) &&
            record.dateTime.isBefore(endOfMonth.add(const Duration(days: 1)));
      }).toList();
    }

    // Sort by date (newest first)
    records.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return records;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        title: const Text(
          'Records',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: _showFilters,
            icon: Stack(
              children: [
                const Icon(Icons.filter_list, color: Colors.white70),
                if (_hasActiveFilters())
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: recordService,
          builder: (context, child) {
            return Column(
              children: [
                // Filter summary
                _buildFilterSummary(),

                // Records list
                Expanded(child: _buildRecordsList()),
              ],
            );
          },
        ),
      ),
    );
  }

  bool _hasActiveFilters() {
    return selectedWallet != null ||
        dateFilterType != 'All Time' ||
        selectedDateRange != null;
  }

  Widget _buildFilterSummary() {
    if (!_hasActiveFilters()) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        color: const Color(0xFF1A1A1A),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Active Filters',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  TextButton(
                    onPressed: _clearAllFilters,
                    child: const Text(
                      'Clear All',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  if (selectedWallet != null)
                    _buildFilterChip(
                      'Wallet: $selectedWallet',
                      () => setState(() => selectedWallet = null),
                    ),
                  if (dateFilterType != 'All Time')
                    _buildFilterChip(
                      _getDateFilterDisplay(),
                      () => setState(() {
                        dateFilterType = 'All Time';
                        selectedDateRange = null;
                      }),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(color: Colors.blue, fontSize: 12)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, color: Colors.blue, size: 14),
          ),
        ],
      ),
    );
  }

  String _getDateFilterDisplay() {
    switch (dateFilterType) {
      case 'This Year':
        return 'This Year (${DateTime.now().year})';
      case 'This Month':
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
        final now = DateTime.now();
        return 'This Month (${months[now.month - 1]} ${now.year})';
      case 'Date Range':
        if (selectedDateRange != null) {
          return 'Custom Range: ${_formatDate(selectedDateRange!.start)} - ${_formatDate(selectedDateRange!.end)}';
        }
        return 'Custom Range';
      default:
        return dateFilterType;
    }
  }

  Widget _buildRecordsList() {
    final records = filteredRecords;

    if (records.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long, size: 64, color: Colors.white54),
            const SizedBox(height: 16),
            Text(
              _hasActiveFilters()
                  ? 'No records match filters'
                  : 'No records found',
              style: const TextStyle(color: Colors.white54, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              _hasActiveFilters()
                  ? 'Try adjusting your filters or clear them to see all records'
                  : 'Tap the + button to add your first record',
              style: const TextStyle(color: Colors.white38, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return _buildRecordItem(record);
      },
    );
  }

  Widget _buildRecordItem(WalletRecord record) {
    final isPositive = record.type == RecordType.income;
    final isTransfer = record.type == RecordType.transfer;

    Color amountColor;
    String amountPrefix;

    if (isTransfer) {
      amountColor = Colors.blue;
      amountPrefix = '';
    } else if (isPositive) {
      amountColor = Colors.green;
      amountPrefix = '+';
    } else {
      amountColor = Colors.red;
      amountPrefix = '-';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Card(
        color: const Color(0xFF1A1A1A),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Category icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getIconColorForCategory(record.category, record.type),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getIconForCategory(record.category, record.type),
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // Record details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isTransfer
                          ? '${record.account} → ${record.transferToAccount}'
                          : record.account,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    if (record.note != null && record.note!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        '"${record.note}"',
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    if (record.label != null && record.label!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          record.label!,
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Amount and date
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$amountPrefix IDR ${_formatAmount(record.amount)}',
                    style: TextStyle(
                      color: amountColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDateRelative(record.dateTime),
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),

              // Checkmark
              const SizedBox(width: 8),
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _clearAllFilters() {
    setState(() {
      selectedWallet = null;
      dateFilterType = 'All Time';
      selectedDateRange = null;
    });
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (context, scrollController) {
          return StatefulBuilder(
            builder: (context, setModalState) {
              return Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Handle bar
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.white54,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    // Header
                    const Row(
                      children: [
                        Icon(Icons.filter_list, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Filter Records',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        children: [
                          // Wallet Filter
                          _buildFilterSection(
                            'Wallet / Account',
                            _buildWalletFilter(setModalState),
                          ),

                          const SizedBox(height: 24),

                          // Date Filter
                          _buildFilterSection(
                            'Date Range',
                            _buildDateFilter(setModalState),
                          ),
                        ],
                      ),
                    ),

                    // Apply button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {}); // Refresh the main page
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Apply Filters',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFilterSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        content,
      ],
    );
  }

  Widget _buildWalletFilter(StateSetter setModalState) {
    final wallets = _getAllWallets();

    return Column(
      children: [
        // All Wallets option
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Radio<String?>(
            value: null,
            groupValue: selectedWallet,
            activeColor: Colors.blue,
            onChanged: (value) {
              setModalState(() => selectedWallet = value);
            },
          ),
          title: const Text(
            'All Wallets',
            style: TextStyle(color: Colors.white),
          ),
          onTap: () {
            setModalState(() => selectedWallet = null);
          },
        ),

        // Individual wallet options
        ...wallets.map(
          (wallet) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Radio<String?>(
              value: wallet,
              groupValue: selectedWallet,
              activeColor: Colors.blue,
              onChanged: (value) {
                setModalState(() => selectedWallet = value);
              },
            ),
            title: Text(wallet, style: const TextStyle(color: Colors.white)),
            onTap: () {
              setModalState(() => selectedWallet = wallet);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDateFilter(StateSetter setModalState) {
    return Column(
      children: [
        // Date filter options
        ...['All Time', 'This Year', 'This Month', 'Date Range'].map(
          (option) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Radio<String>(
              value: option,
              groupValue: dateFilterType,
              activeColor: Colors.blue,
              onChanged: (value) {
                setModalState(() {
                  dateFilterType = value!;
                  if (value != 'Date Range') {
                    selectedDateRange = null;
                  }
                });
              },
            ),
            title: Text(option, style: const TextStyle(color: Colors.white)),
            onTap: () {
              setModalState(() {
                dateFilterType = option;
                if (option != 'Date Range') {
                  selectedDateRange = null;
                }
              });
            },
          ),
        ),

        // Date range picker
        if (dateFilterType == 'Date Range') ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final dateRange = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  initialDateRange: selectedDateRange,
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.dark(
                          primary: Colors.blue,
                          surface: Color(0xFF1A1A1A),
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (dateRange != null) {
                  setModalState(() => selectedDateRange = dateRange);
                }
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.blue),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.date_range, color: Colors.blue),
              label: Text(
                selectedDateRange != null
                    ? '${_formatDate(selectedDateRange!.start)} - ${_formatDate(selectedDateRange!.end)}'
                    : 'Select Date Range',
                style: const TextStyle(color: Colors.blue),
              ),
            ),
          ),
        ],
      ],
    );
  }

  List<String> _getAllWallets() {
    return [
      'Cashfile',
      'Cash',
      'BRI',
      'Ajaib Stocks',
      'Ajaib Kripto',
      'Bibit',
      'SeaBank',
      'BCA',
      'Bibit Saham',
      'Bibit Saham 2',
      'Shopeepay',
      'Permata',
      'MQ Sekuritas',
      'Bareksa Gold',
      'Bareksa RD',
      'Jago',
      'Gopay',
      'DANA',
      'pluang',
      'Gopay Coins',
    ];
  }

  String _formatAmount(double amount) {
    return amount
        .toStringAsFixed(2)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  String _formatDateRelative(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  IconData _getIconForCategory(String category, RecordType type) {
    switch (type) {
      case RecordType.income:
        return Icons.monetization_on;
      case RecordType.transfer:
        return Icons.swap_horiz;
      case RecordType.expense:
        switch (category.toLowerCase()) {
          case 'food & drinks':
            return Icons.restaurant;
          case 'shopping':
            return Icons.shopping_bag;
          case 'transportation':
          case 'vehicle':
            return Icons.directions_car;
          case 'healthcare':
            return Icons.local_hospital;
          case 'entertainment':
            return Icons.movie;
          case 'education':
            return Icons.school;
          case 'bills & utilities':
            return Icons.receipt;
          case 'insurance':
            return Icons.security;
          case 'groceries':
            return Icons.shopping_cart;
          case 'travel':
            return Icons.flight;
          case 'charity':
            return Icons.favorite;
          case 'personal care':
            return Icons.spa;
          case 'home & garden':
            return Icons.home;
          case 'technology':
            return Icons.computer;
          case 'clothing & accessories':
            return Icons.checkroom;
          case 'sports & fitness':
            return Icons.fitness_center;
          case 'subscriptions':
            return Icons.subscriptions;
          case 'taxes':
            return Icons.account_balance;
          default:
            return Icons.category;
        }
    }
  }

  Color _getIconColorForCategory(String category, RecordType type) {
    switch (type) {
      case RecordType.income:
        return Colors.green;
      case RecordType.transfer:
        return Colors.blue;
      case RecordType.expense:
        switch (category.toLowerCase()) {
          case 'food & drinks':
            return Colors.red;
          case 'shopping':
            return Colors.purple;
          case 'transportation':
          case 'vehicle':
            return Colors.orange;
          case 'healthcare':
            return Colors.pink;
          case 'entertainment':
            return Colors.indigo;
          case 'education':
            return Colors.teal;
          case 'bills & utilities':
            return Colors.brown;
          case 'insurance':
            return Colors.cyan;
          case 'groceries':
            return Colors.lime;
          case 'travel':
            return Colors.deepPurple;
          case 'charity':
            return Colors.red[300]!;
          case 'personal care':
            return Colors.pink[300]!;
          case 'home & garden':
            return Colors.green[700]!;
          case 'technology':
            return Colors.blue[600]!;
          case 'clothing & accessories':
            return Colors.lightBlue;
          case 'sports & fitness':
            return Colors.green;
          case 'subscriptions':
            return Colors.amber;
          case 'taxes':
            return Colors.grey;
          default:
            return Colors.grey;
        }
    }
  }
}
