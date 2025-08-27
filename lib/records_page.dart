import 'package:flutter/material.dart';

class RecordsPage extends StatefulWidget {
  const RecordsPage({super.key});

  @override
  State<RecordsPage> createState() => _RecordsPageState();
}

class _RecordsPageState extends State<RecordsPage> {
  String selectedPeriod = 'This year';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {},
        ),
        title: const Text(
          'Records',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Total amount section
          Container(
            width: double.infinity,
            color: const Color(0xFF111111),
            padding: const EdgeInsets.all(16.0),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'THIS YEAR',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '∑ IDR 228,472,818.00',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Transactions list
          Expanded(
            child: Container(
              color: const Color(0xFF111111),
              child: ListView.builder(
                itemCount: getTransactionRecords().length,
                itemBuilder: (context, index) {
                  final transaction = getTransactionRecords()[index];
                  return _buildTransactionItem(transaction);
                },
              ),
            ),
          ),

          // Time period selector
          Container(
            color: const Color(0xFF111111),
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.chevron_left, color: Colors.white70),
                ),
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          selectedPeriod,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_drop_down, color: Colors.white),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.chevron_right, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    final isPositive =
        (transaction['amount'] as String).startsWith('+') ||
        !(transaction['amount'] as String).startsWith('-');
    final amountColor = isPositive ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Category icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: transaction['iconColor'] as Color,
              shape: BoxShape.circle,
            ),
            child: Icon(
              transaction['icon'] as IconData,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // Transaction details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction['category'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  transaction['account'] as String,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                if (transaction['description'] != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    '"${transaction['description']}"',
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
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
                transaction['amount'] as String,
                style: TextStyle(
                  color: amountColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                transaction['date'] as String,
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
    );
  }

  List<Map<String, dynamic>> getTransactionRecords() {
    return [
      {
        'category': 'Financial investments',
        'account': 'Bibit',
        'amount': 'IDR 263,732.00',
        'date': 'Today',
        'icon': Icons.trending_up,
        'iconColor': Colors.pink,
      },
      {
        'category': 'Communication, PC',
        'account': 'SeaBank',
        'amount': '-IDR 10,900.00',
        'date': 'Today',
        'description': 'Phone Cleaner',
        'icon': Icons.computer,
        'iconColor': Colors.blue,
      },
      {
        'category': 'Income',
        'account': 'BCA',
        'amount': 'IDR 11,035,000.00',
        'date': 'Aug 25',
        'description': 'Gaji',
        'icon': Icons.monetization_on,
        'iconColor': Colors.orange,
      },
      {
        'category': 'Food & Drinks',
        'account': 'Cash',
        'amount': '-IDR 14,000.00',
        'date': 'Aug 25',
        'icon': Icons.restaurant,
        'iconColor': Colors.red,
      },
      {
        'category': 'Loan, interests',
        'account': 'BCA',
        'amount': '-IDR 10,000,000.00',
        'date': 'Aug 25',
        'description': 'Me → Mas Sabrang : Rumah - Mas Sabrang',
        'icon': Icons.account_balance,
        'iconColor': Colors.teal,
      },
      {
        'category': 'Active sport, fitness',
        'account': 'Cash',
        'amount': '-IDR 30,000.00',
        'date': 'Aug 24',
        'description': 'Master Gym Ponorogo',
        'icon': Icons.fitness_center,
        'iconColor': Colors.green,
      },
      {
        'category': 'Groceries',
        'account': 'Gopay',
        'amount': '-IDR 28,800.00',
        'date': 'Aug 24',
        'description': 'Hydrococo',
        'icon': Icons.shopping_cart,
        'iconColor': Colors.orange,
      },
      {
        'category': 'Loan, interests',
        'account': 'BCA',
        'amount': '-IDR 10,000,000.00',
        'date': 'Aug 24',
        'description': 'Me → Mas Sabrang : Rumah - Mas Sabrang',
        'icon': Icons.account_balance,
        'iconColor': Colors.teal,
      },
      {
        'category': 'Clothes & shoes',
        'account': 'SeaBank',
        'amount': '-IDR 77,500.00',
        'date': 'Aug 23',
        'description': 'Kale Arion Kaos',
        'icon': Icons.checkroom,
        'iconColor': Colors.lightBlue,
      },
    ];
  }
}
