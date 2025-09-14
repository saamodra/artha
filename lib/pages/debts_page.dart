import 'package:flutter/material.dart';
import '../models/debt.dart';
import '../services/debt_service.dart';
import 'add_debt_page.dart';
import 'debt_details_page.dart';

class DebtsPage extends StatefulWidget {
  const DebtsPage({super.key});

  @override
  State<DebtsPage> createState() => _DebtsPageState();
}

class _DebtsPageState extends State<DebtsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DebtService _debtService = DebtService();
  bool showClosed = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _debtService,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: const Color(0xFF111111),
          appBar: AppBar(
            backgroundColor: const Color(0xFF111111),
            title: const Text(
              'Debts',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            automaticallyImplyLeading: false,
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.blue,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
              tabs: const [
                Tab(text: 'I Lent'),
                Tab(text: 'I Owe'),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () => _showFilterOptions(),
                icon: Icon(
                  showClosed ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildDebtList(DebtType.iLent),
              _buildDebtList(DebtType.iOwe),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _navigateToAddDebt(),
            backgroundColor: Colors.blue,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildDebtList(DebtType type) {
    final debts = showClosed
        ? _debtService.getDebtsByType(type)
        : _debtService.getActiveDebts(type);

    final activeDebts = debts.where((d) => !d.isPaid).toList();
    final closedDebts = debts.where((d) => d.isPaid).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Card
          _buildSummaryCard(type),
          const SizedBox(height: 24),

          // Active Debts Section
          if (activeDebts.isNotEmpty) ...[
            _buildSectionHeader(
              title: type == DebtType.iLent
                  ? '${activeDebts.length} ${activeDebts.length == 1 ? 'person owes' : 'people owe'} me'
                  : 'I owe to ${activeDebts.length} ${activeDebts.length == 1 ? 'person' : 'people'}',
              color: type == DebtType.iLent ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 8),
            ...activeDebts.map((debt) => _buildDebtCard(debt)),
            const SizedBox(height: 24),
          ],

          // Closed Debts Section
          if (showClosed && closedDebts.isNotEmpty) ...[
            _buildSectionHeader(
              title: type == DebtType.iLent
                  ? '${closedDebts.length} ${closedDebts.length == 1 ? 'person has' : 'people have'} paid me back'
                  : 'I have paid back ${closedDebts.length} ${closedDebts.length == 1 ? 'person' : 'people'}',
              color: Colors.grey,
            ),
            const SizedBox(height: 8),
            ...closedDebts.map((debt) => _buildDebtCard(debt)),
            const SizedBox(height: 24),
          ],

          // Empty State
          if (activeDebts.isEmpty && (!showClosed || closedDebts.isEmpty))
            _buildEmptyState(type),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(DebtType type) {
    final activeCount = _debtService.getActiveDebtCount(type);
    final overdueCount = _debtService.getOverdueDebtCount(type);

    return Card(
      color: const Color(0xFF1A1A1A),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  type == DebtType.iLent ? 'Total Lent' : 'Total Owed',
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),
                if (overdueCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$overdueCount Overdue',
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _debtService.getFormattedTotalAmountByType(type),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: type == DebtType.iLent ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  type == DebtType.iLent
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                  color: type == DebtType.iLent ? Colors.green : Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  '$activeCount active ${activeCount == 1 ? 'debt' : 'debts'}',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({required String title, required Color color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDebtCard(Debt debt) {
    return Card(
      color: const Color(0xFF1A1A1A),
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _navigateToDebtDetails(debt),
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

  Widget _buildEmptyState(DebtType type) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(
              type == DebtType.iLent ? Icons.trending_up : Icons.trending_down,
              size: 64,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              type == DebtType.iLent ? 'No money lent' : 'No debts owed',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              type == DebtType.iLent
                  ? 'When you lend money to someone, it will appear here'
                  : 'When you owe money to someone, it will appear here',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.3),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _navigateToAddDebt(),
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                type == DebtType.iLent ? 'Add Lent Money' : 'Add Debt',
                style: const TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterOptions() {
    setState(() {
      showClosed = !showClosed;
    });
  }

  void _navigateToAddDebt() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddDebtPage(
          initialType: _tabController.index == 0
              ? DebtType.iLent
              : DebtType.iOwe,
        ),
      ),
    );
  }

  void _navigateToDebtDetails(Debt debt) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => DebtDetailsPage(debt: debt)),
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
