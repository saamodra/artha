import 'package:flutter/material.dart';
import '../models/wallet_record.dart';
import '../pages/edit_record_page.dart';
import '../services/record_service.dart';

class RecordItem extends StatelessWidget {
  final WalletRecord record;
  final List<Map<String, dynamic>> wallets;
  final RecordService recordService;
  final VoidCallback? onRecordChanged;
  final String? contextWalletName; // For wallet-specific display logic

  const RecordItem({
    super.key,
    required this.record,
    required this.wallets,
    required this.recordService,
    this.onRecordChanged,
    this.contextWalletName,
  });

  @override
  Widget build(BuildContext context) {
    return _buildRecordItem(context);
  }

  Widget _buildRecordItem(BuildContext context) {
    final isPositive = record.type == RecordType.income;
    final isTransfer = record.type == RecordType.transfer;

    Color amountColor;
    String amountPrefix;

    if (isTransfer) {
      if (contextWalletName != null) {
        // Wallet-specific context: show incoming/outgoing
        if (record.transferToAccount == contextWalletName) {
          // Incoming transfer
          amountColor = Colors.green;
          amountPrefix = '+';
        } else {
          // Outgoing transfer
          amountColor = Colors.red;
          amountPrefix = '-';
        }
      } else {
        // General context: show as blue transfer
        amountColor = Colors.blue;
        amountPrefix = '';
      }
    } else if (isPositive) {
      amountColor = Colors.green;
      amountPrefix = '+';
    } else {
      amountColor = Colors.red;
      amountPrefix = '-';
    }

    return Dismissible(
      key: Key(record.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red.withValues(alpha: 0.1),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete, color: Colors.red, size: 28),
            SizedBox(height: 4),
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmation(context);
      },
      onDismissed: (direction) {
        _performDelete(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: InkWell(
          onTap: () => _editRecord(context),
          child: Row(
            children: [
              // Category icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getIconColorForCategory(record.category, record.type),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getIconForCategory(record.category, record.type),
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),

              // Record details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            record.category,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (record.label != null &&
                            record.label!.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              record.label!,
                              style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 1),
                    Text(
                      isTransfer
                          ? '${record.account} → ${record.transferToAccount}'
                          : record.account,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (record.note != null && record.note!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        '"${record.note}"',
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Amount and date
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$amountPrefix IDR ${_formatAmount(record.amount)}',
                    style: TextStyle(
                      color: amountColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _formatDateRelative(record.dateTime),
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editRecord(BuildContext context) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) =>
                EditRecordPage(record: record, wallets: wallets),
          ),
        )
        .then((_) {
          // Notify parent widget that record might have changed
          onRecordChanged?.call();
        });
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Text(
            'Delete Record',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Are you sure you want to delete this ${record.type.name} record? This action cannot be undone.',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _performDelete(BuildContext context) {
    recordService.deleteRecord(record.id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Record deleted successfully'),
        backgroundColor: Colors.red,
      ),
    );
    // Notify parent widget that record was deleted
    onRecordChanged?.call();
  }

  String _formatAmount(double amount) {
    return amount
        .toStringAsFixed(2)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
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
