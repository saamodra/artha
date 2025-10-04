import 'package:flutter/material.dart';
import 'main.dart';
import 'services/wallet_service.dart';
import 'pages/wallet_list_page.dart';
import 'pages/records_filter_page.dart';
import 'pages/add_record_page.dart';
import 'pages/debts_page.dart';
import 'profile_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  late PageController _pageController;
  final WalletService walletService = WalletService();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  void _showAddRecordPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            AddRecordPage(wallets: walletService.getWalletsInLegacyFormat()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [
          const WalletHomePage(), // Home - index 0
          const WalletListPage(), // Wallet - index 1
          const RecordsFilterPage(), // Records - index 2
          const DebtsPage(), // Debts - index 3
          const ProfilePage(), // Profile - index 4
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddRecordPage,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Flexible(
                child: _buildNavItem(icon: Icons.home, label: 'Home', index: 0),
              ),
              Flexible(
                child: _buildNavItem(
                  icon: Icons.account_balance_wallet,
                  label: 'Wallet',
                  index: 1,
                ),
              ),
              Flexible(
                child: _buildNavItem(
                  icon: Icons.receipt_long,
                  label: 'Records',
                  index: 2,
                ),
              ),
              Flexible(
                child: _buildNavItem(
                  icon: Icons.credit_card,
                  label: 'Debts',
                  index: 3,
                ),
              ),
              Flexible(
                child: _buildNavItem(
                  icon: Icons.person,
                  label: 'Profile',
                  index: 4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.blue.withValues(alpha: 0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.blue : Colors.white70,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.white70,
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
