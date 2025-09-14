import 'package:flutter/material.dart';
import '../models/debt.dart';

class DebtItem extends StatelessWidget {
  final Debt debt;
  final VoidCallback? onTap;

  const DebtItem({super.key, required this.debt, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1A1A1A),
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.grey[700],
                    radius: 20,
                    child: Text(
                      debt.name.isNotEmpty ? debt.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          debt.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (debt.description.isNotEmpty)
                          Text(
                            debt.description,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'IDR ${debt.currentAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                        style: TextStyle(
                          color: debt.type == DebtType.iLent
                              ? Colors.green
                              : Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _formatDate(debt.dueDate),
                        style: TextStyle(
                          color: debt.isOverdue ? Colors.red : Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (!debt.isPaid && debt.paidAmount > 0) ...[
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: debt.paidPercentage / 100,
                  backgroundColor: Colors.grey[800],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    debt.type == DebtType.iLent ? Colors.green : Colors.blue,
                  ),
                  minHeight: 4,
                ),
                const SizedBox(height: 4),
                Text(
                  '${debt.paidPercentage.toStringAsFixed(1)}% paid',
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference == 0) {
      return 'Due today';
    } else if (difference == 1) {
      return 'Due tomorrow';
    } else if (difference > 0) {
      return 'Due in $difference days';
    } else {
      return '${difference.abs()} days overdue';
    }
  }
}
