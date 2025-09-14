import 'package:flutter/material.dart';
import '../services/record_service.dart';
import '../models/wallet_record.dart';
import 'record_item.dart';

class FilterableRecordsPage extends StatefulWidget {
  final String title;
  final String?
  specificWallet; // If provided, only shows records for this wallet
  final RecordService recordService;
  final List<Map<String, dynamic>> wallets;
  final bool showBackButton; // Controls whether to show back button

  const FilterableRecordsPage({
    super.key,
    required this.title,
    required this.recordService,
    required this.wallets,
    this.specificWallet,
    this.showBackButton = true, // Default to true for backward compatibility
  });

  @override
  State<FilterableRecordsPage> createState() => _FilterableRecordsPageState();
}

class _FilterableRecordsPageState extends State<FilterableRecordsPage> {
  // Filter states
  String? selectedWallet; // null means all wallets
  DateTimeRange? selectedDateRange;
  String dateFilterType =
      'All Time'; // 'All Time', 'Date Range', 'This Year', 'This Month'

  @override
  void initState() {
    super.initState();
    // If we have a specific wallet, set it as the default filter
    if (widget.specificWallet != null) {
      selectedWallet = widget.specificWallet;
    }
  }

  List<WalletRecord> get filteredRecords {
    // Create a mutable copy of the records list
    List<WalletRecord> records = List<WalletRecord>.from(
      widget.recordService.records,
    );

    // If we have a specific wallet context, filter by it first
    if (widget.specificWallet != null) {
      records = widget.recordService.getRecordsForAccount(
        widget.specificWallet!,
      );
    }

    // Apply additional wallet filter (only if we don't have a specific wallet context)
    if (widget.specificWallet == null && selectedWallet != null) {
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
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        leading: widget.showBackButton
            ? IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              )
            : null,
        automaticallyImplyLeading: widget.showBackButton,
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
          animation: widget.recordService,
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
    // For specific wallet context, don't count the wallet filter as active
    // since it's automatically set
    bool hasWalletFilter =
        widget.specificWallet == null && selectedWallet != null;
    return hasWalletFilter ||
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
                  // Only show wallet filter if we're not in specific wallet context
                  if (widget.specificWallet == null && selectedWallet != null)
                    _buildFilterChip(
                      selectedWallet!,
                      () => setState(() => selectedWallet = null),
                      isWallet: true,
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

  Widget _buildFilterChip(
    String label,
    VoidCallback onRemove, {
    bool isWallet = false,
  }) {
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
          if (isWallet) ...[
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getWalletColor(label),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: const TextStyle(color: Colors.blue, fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return RecordItem(
          record: record,
          wallets: widget.wallets,
          recordService: widget.recordService,
          onRecordChanged: () => setState(() {}),
          contextWalletName: widget.specificWallet,
        );
      },
    );
  }

  void _clearAllFilters() {
    setState(() {
      // Only clear wallet filter if we're not in specific wallet context
      if (widget.specificWallet == null) {
        selectedWallet = null;
      }
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
                          // Wallet Filter (only show if not in specific wallet context)
                          if (widget.specificWallet == null) ...[
                            _buildFilterSection(
                              'Wallet / Account',
                              _buildWalletFilter(setModalState),
                            ),
                            const SizedBox(height: 24),
                          ],

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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF222222),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: selectedWallet,
          isExpanded: true,
          dropdownColor: const Color(0xFF222222),
          style: const TextStyle(color: Colors.white, fontSize: 16),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
          hint: const Text(
            'All Wallets',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          items: [
            // All Wallets option
            const DropdownMenuItem<String?>(
              value: null,
              child: Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    color: Colors.blue,
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'All Wallets',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
            // Divider
            const DropdownMenuItem<String?>(
              enabled: false,
              value: 'divider',
              child: Divider(color: Colors.white24, height: 1),
            ),
            // Individual wallet options
            ...wallets.map(
              (wallet) => DropdownMenuItem<String?>(
                value: wallet,
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: _getWalletColor(wallet),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        wallet,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          onChanged: (String? newValue) {
            if (newValue != 'divider') {
              setModalState(() {
                selectedWallet = newValue;
              });
            }
          },
        ),
      ),
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
    return widget.wallets.map((wallet) => wallet['name'] as String).toList();
  }

  Color _getWalletColor(String walletName) {
    // Find the wallet in the wallets list and return its color
    final wallet = widget.wallets.firstWhere(
      (w) => w['name'] == walletName,
      orElse: () => {'color': Colors.grey},
    );
    return wallet['color'] as Color;
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
