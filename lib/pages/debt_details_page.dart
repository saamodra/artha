import 'package:flutter/material.dart';
import '../models/debt.dart';
import '../services/debt_service.dart';
import 'add_debt_page.dart';
import 'add_debt_record_page.dart';

class DebtDetailsPage extends StatefulWidget {
  final Debt debt;

  const DebtDetailsPage({super.key, required this.debt});

  @override
  State<DebtDetailsPage> createState() => _DebtDetailsPageState();
}

class _DebtDetailsPageState extends State<DebtDetailsPage> {
  final DebtService _debtService = DebtService();
  late Debt _currentDebt;

  @override
  void initState() {
    super.initState();
    _currentDebt = widget.debt;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _debtService,
      builder: (context, child) {
        // Get the updated debt without calling setState
        final updatedDebt = _debtService.getDebtById(_currentDebt.id);
        if (updatedDebt != null) {
          _currentDebt = updatedDebt;
        }

        return Scaffold(
          backgroundColor: const Color(0xFF111111),
          appBar: AppBar(
            backgroundColor: const Color(0xFF111111),
            title: Text(
              _currentDebt.name,
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            actions: [
              IconButton(
                onPressed: _showDebtOptions,
                icon: const Icon(Icons.more_vert, color: Colors.white70),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Debt Summary Card
                _buildDebtSummaryCard(),
                const SizedBox(height: 24),

                // Progress Card (if not fully paid)
                if (!_currentDebt.isPaid) ...[
                  _buildProgressCard(),
                  const SizedBox(height: 24),
                ],

                // Recent Records Section
                _buildRecentRecordsSection(),
              ],
            ),
          ),
          floatingActionButton: !_currentDebt.isPaid
              ? FloatingActionButton.extended(
                  onPressed: () => _navigateToAddRecord(),
                  backgroundColor: Colors.blue,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: Text(
                    _currentDebt.type == DebtType.iLent
                        ? 'Add Payment'
                        : 'Add Payment',
                    style: const TextStyle(color: Colors.white),
                  ),
                )
              : null,
        );
      },
    );
  }

  Widget _buildDebtSummaryCard() {
    return Card(
      color: const Color(0xFF1A1A1A),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey[700],
                  radius: 24,
                  child: Text(
                    _currentDebt.name.isNotEmpty
                        ? _currentDebt.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentDebt.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (_currentDebt.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          _currentDebt.description,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        (_currentDebt.type == DebtType.iLent
                                ? Colors.green
                                : Colors.red)
                            .withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _currentDebt.type == DebtType.iLent ? 'I Lent' : 'I Owe',
                    style: TextStyle(
                      color: _currentDebt.type == DebtType.iLent
                          ? Colors.green
                          : Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Amount Information
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Amount',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'IDR ${_currentDebt.currentAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                        style: TextStyle(
                          color: _currentDebt.type == DebtType.iLent
                              ? Colors.green
                              : Colors.red,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Original: IDR ${_currentDebt.originalAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Account: ${_currentDebt.account}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Due Date and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Due Date',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(_currentDebt.dueDate),
                      style: TextStyle(
                        color: _currentDebt.isOverdue
                            ? Colors.red
                            : Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(),
                    style: TextStyle(
                      color: _getStatusColor(),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    if (_currentDebt.paidAmount <= 0) return const SizedBox.shrink();

    return Card(
      color: const Color(0xFF1A1A1A),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Progress',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            LinearProgressIndicator(
              value: _currentDebt.paidPercentage / 100,
              backgroundColor: Colors.grey[800],
              valueColor: AlwaysStoppedAnimation<Color>(
                _currentDebt.type == DebtType.iLent
                    ? Colors.green
                    : Colors.blue,
              ),
              minHeight: 8,
            ),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Paid: IDR ${_currentDebt.paidAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  '${_currentDebt.paidPercentage.toStringAsFixed(1)}% Complete',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentRecordsSection() {
    final debtRecords = _debtService.getDebtRecords(_currentDebt.id);

    return Card(
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
                  'Transaction History',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${debtRecords.length} ${debtRecords.length == 1 ? 'transaction' : 'transactions'}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),

          if (debtRecords.isEmpty)
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
                      'No transactions yet',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add a payment or debt increase to see history',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.3),
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: debtRecords
                  .map((record) => _buildDebtRecordItem(record))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildDebtRecordItem(DebtRecord record) {
    final isRepayment = record.action == DebtAction.repay;
    final isIncoming =
        (_currentDebt.type == DebtType.iLent && isRepayment) ||
        (_currentDebt.type == DebtType.iOwe && !isRepayment);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (isIncoming ? Colors.green : Colors.red).withValues(
                alpha: 0.2,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isRepayment ? Icons.payments : Icons.add_circle,
              color: isIncoming ? Colors.green : Colors.red,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isRepayment ? 'Payment' : 'Debt Increase',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${record.account} • ${_formatDateTime(record.dateTime)}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                if (record.note != null && record.note!.isNotEmpty)
                  Text(
                    record.note!,
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Text(
            '${isIncoming ? '+' : '-'}IDR ${record.amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
            style: TextStyle(
              color: isIncoming ? Colors.green : Colors.red,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showDebtOptions() {
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
                'Edit Debt',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _navigateToEditDebt();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Delete Debt',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Delete Debt', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete this debt? This action cannot be undone.',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () {
              _debtService.deleteDebt(_currentDebt.id);
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Close debt details page
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _navigateToEditDebt() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            AddDebtPage(initialType: _currentDebt.type, debt: _currentDebt),
      ),
    );
  }

  void _navigateToAddRecord() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddDebtRecordPage(debt: _currentDebt),
      ),
    );
  }

  Color _getStatusColor() {
    if (_currentDebt.isPaid) return Colors.green;
    if (_currentDebt.isOverdue) return Colors.red;
    return Colors.orange;
  }

  String _getStatusText() {
    if (_currentDebt.isPaid) return 'Paid';
    if (_currentDebt.isOverdue) return 'Overdue';
    return 'Active';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
