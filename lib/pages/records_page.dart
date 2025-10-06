import 'package:flutter/material.dart';
import '../services/record_service.dart';
import '../widgets/filterable_records.dart';
import '../services/wallet_service.dart';

class RecordsPage extends StatefulWidget {
  const RecordsPage({super.key});

  @override
  State<RecordsPage> createState() => _RecordsPageState();
}

class _RecordsPageState extends State<RecordsPage> {
  final RecordService recordService = RecordService();
  final WalletService walletService = WalletService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRecords();
    });
  }

  Future<void> _loadRecords() async {
    await recordService.loadRecords();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: walletService,
      builder: (context, _) {
        return FilterableRecords(
          title: 'Records',
          recordService: recordService,
          wallets: walletService.getWalletsInLegacyFormat(),
          showBackButton:
              false, // No back button when accessed from bottom navbar
        );
      },
    );
  }
}
