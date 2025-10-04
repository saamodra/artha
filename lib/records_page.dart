import 'package:flutter/material.dart';
import 'pages/add_record_page.dart';
import 'models/wallet_record.dart';
import 'services/record_service.dart';
import 'widgets/record_item.dart';

class RecordsPage extends StatefulWidget {
  final List<String> selectedWallets;

  const RecordsPage({super.key, this.selectedWallets = const []});

  @override
  State<RecordsPage> createState() => _RecordsPageState();
}

class _RecordsPageState extends State<RecordsPage> {
  String selectedPeriod = 'This year';
  final RecordService recordService = RecordService();

  bool get isShowingAllWallets => widget.selectedWallets.isEmpty;

  List<WalletRecord> get filteredRecords {
    final allRecords = recordService.records;
    if (isShowingAllWallets) {
      return allRecords;
    }

    // Filter records for selected wallets
    return allRecords.where((record) {
      // Show record if it involves any of the selected wallets
      bool isFromSelectedWallet = widget.selectedWallets.contains(
        record.account,
      );
      bool isToSelectedWallet =
          record.transferToAccount != null &&
          widget.selectedWallets.contains(record.transferToAccount!);

      return isFromSelectedWallet || isToSelectedWallet;
    }).toList();
  }

  String get pageTitle {
    if (isShowingAllWallets) {
      return 'Records';
    } else if (widget.selectedWallets.length == 1) {
      return '${widget.selectedWallets.first} Records';
    } else {
      return 'Selected Wallets Records';
    }
  }

  String get totalAmountLabel {
    if (isShowingAllWallets) {
      return 'THIS YEAR';
    } else if (widget.selectedWallets.length == 1) {
      return '${widget.selectedWallets.first.toUpperCase()} - THIS YEAR';
    } else {
      return 'SELECTED WALLETS - THIS YEAR';
    }
  }

  String get filteredTotalAmount {
    double total = 0;

    if (isShowingAllWallets) {
      // Calculate total from all wallets
      final allWalletNames = _getAllAccounts()
          .map((account) => account['name'] as String)
          .toList();
      total = recordService.getTotalBalanceForAccounts(allWalletNames);
    } else {
      // Calculate total from selected wallets only
      total = recordService.getTotalBalanceForAccounts(widget.selectedWallets);
    }

    return '∑ IDR ${total.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        title: Text(
          pageTitle,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Total amount section
          AnimatedBuilder(
            animation: recordService,
            builder: (context, child) {
              return Container(
                width: double.infinity,
                color: const Color(0xFF111111),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      totalAmountLabel,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      filteredTotalAmount,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Transactions list
          Expanded(
            child: Container(
              color: const Color(0xFF111111),
              child: AnimatedBuilder(
                animation: recordService,
                builder: (context, child) {
                  final records = filteredRecords;
                  if (records.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.receipt_long,
                            size: 64,
                            color: Colors.white54,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            isShowingAllWallets
                                ? 'No records yet'
                                : 'No records for selected wallet${widget.selectedWallets.length > 1 ? 's' : ''}',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isShowingAllWallets
                                ? 'Tap the + button to add your first record'
                                : 'No transactions found for the selected wallet${widget.selectedWallets.length > 1 ? 's' : ''}',
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 16,
                    ),
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      final record = records[index];
                      return RecordItem(
                        record: record,
                        wallets: _getAllAccounts(),
                        recordService: recordService,
                        onRecordChanged: () => setState(() {}),
                      );
                    },
                  );
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
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddRecordPage(wallets: _getAllAccounts()),
            ),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  List<Map<String, dynamic>> _getAllAccounts() {
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
