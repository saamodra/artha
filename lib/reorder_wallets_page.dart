import 'package:flutter/material.dart';

class ReorderWalletsPage extends StatefulWidget {
  final List<Map<String, dynamic>> initialWallets;
  final Function(List<Map<String, dynamic>>) onReorder;

  const ReorderWalletsPage({
    super.key,
    required this.initialWallets,
    required this.onReorder,
  });

  @override
  State<ReorderWalletsPage> createState() => _ReorderWalletsPageState();
}

class _ReorderWalletsPageState extends State<ReorderWalletsPage> {
  late List<Map<String, dynamic>> wallets;

  @override
  void initState() {
    super.initState();
    // Create a copy of the wallets list to avoid modifying the original
    wallets = List<Map<String, dynamic>>.from(widget.initialWallets);
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = wallets.removeAt(oldIndex);
      wallets.insert(newIndex, item);
    });
  }

  void _saveOrder() {
    widget.onReorder(wallets);
    Navigator.of(context).pop();
  }

  void _resetOrder() {
    setState(() {
      wallets = List<Map<String, dynamic>>.from(widget.initialWallets);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Reorder Wallets',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: _resetOrder,
            child: const Text('Reset', style: TextStyle(color: Colors.blue)),
          ),
          TextButton(
            onPressed: _saveOrder,
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Long press and drag to reorder your wallets. The order will be reflected in the main screen.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Reorderable List
            Expanded(
              child: ReorderableListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: wallets.length,
                onReorder: _onReorder,
                itemBuilder: (context, index) {
                  final wallet = wallets[index];
                  return _buildReorderableWalletCard(wallet, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReorderableWalletCard(Map<String, dynamic> wallet, int index) {
    return Container(
      key: ValueKey(wallet['name']),
      margin: const EdgeInsets.only(bottom: 8),
      child: Card(
        color: const Color(0xFF1A1A1A),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: wallet['color'] as Color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: wallet['hasIcon'] == true
                ? const Icon(Icons.trending_up, color: Colors.white, size: 24)
                : Center(
                    child: Text(
                      wallet['name'].toString().substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
          ),
          title: Text(
            wallet['name'] as String,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            wallet['balance'] as String,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '#${index + 1}',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.drag_handle, color: Colors.white54, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
