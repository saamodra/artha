import 'package:flutter/material.dart';
import '../services/record_service.dart';
import '../widgets/filterable_records_page.dart';

class RecordsFilterPage extends StatefulWidget {
  const RecordsFilterPage({super.key});

  @override
  State<RecordsFilterPage> createState() => _RecordsFilterPageState();
}

class _RecordsFilterPageState extends State<RecordsFilterPage> {
  final RecordService recordService = RecordService();

  @override
  Widget build(BuildContext context) {
    return FilterableRecordsPage(
      title: 'Records',
      recordService: recordService,
      wallets: _getAllAccounts(),
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
