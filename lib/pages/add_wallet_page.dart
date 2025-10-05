import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/wallet.dart';
import '../services/wallet_service.dart';

class AddWalletPage extends StatefulWidget {
  const AddWalletPage({super.key});

  @override
  State<AddWalletPage> createState() => _AddWalletPageState();
}

class _AddWalletPageState extends State<AddWalletPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _initialValueController = TextEditingController();

  WalletType _selectedWalletType = WalletType.manualInput;
  String? _selectedAccountType;
  AssetType? _selectedAssetType;
  Color _selectedColor = WalletService.walletColors[0];
  bool _isLoading = false;

  final WalletService _walletService = WalletService();

  @override
  void dispose() {
    _nameController.dispose();
    _accountNumberController.dispose();
    _initialValueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        title: const Text(
          'Add New Wallet',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveWallet,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Wallet Type Selection
                _buildWalletTypeSelector(),
                const SizedBox(height: 32),

                // Wallet Name
                _buildTextField(
                  controller: _nameController,
                  label: 'Wallet Name',
                  hint: 'Enter wallet name',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a wallet name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Conditional Fields based on wallet type
                if (_selectedWalletType == WalletType.manualInput) ...[
                  // Account Number (for manual input)
                  _buildTextField(
                    controller: _accountNumberController,
                    label: 'Account Number (Optional)',
                    hint: 'Enter account number',
                  ),
                  const SizedBox(height: 24),

                  // Account Type (for manual input)
                  _buildAccountTypeDropdown(),
                  const SizedBox(height: 24),

                  // Initial Value
                  _buildTextField(
                    controller: _initialValueController,
                    label: 'Initial Value',
                    hint: '0.00',
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}'),
                      ),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter initial value';
                      }
                      final amount = double.tryParse(value.trim());
                      if (amount == null || amount < 0) {
                        return 'Please enter a valid amount';
                      }
                      return null;
                    },
                  ),
                ] else ...[
                  // Asset Type (for investment)
                  _buildAssetTypeDropdown(),
                  const SizedBox(height: 24),
                ],

                const SizedBox(height: 24),

                // Color Selection
                _buildColorSelector(),
                const SizedBox(height: 32),

                // Preview Card
                _buildPreviewCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWalletTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Wallet Type',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: WalletType.values.map((type) {
            final isSelected = _selectedWalletType == type;
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(
                  right: type == WalletType.manualInput ? 8 : 0,
                  left: type == WalletType.investment ? 8 : 0,
                ),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedWalletType = type;
                      // Reset fields when changing type
                      if (type == WalletType.investment) {
                        _selectedAccountType = null;
                        _accountNumberController.clear();
                        _initialValueController.clear();
                      } else {
                        _selectedAssetType = null;
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.blue.withValues(alpha: 0.2)
                          : const Color(0xFF1A1A1A),
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.transparent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          type == WalletType.manualInput
                              ? Icons.account_balance_wallet
                              : Icons.trending_up,
                          color: isSelected ? Colors.blue : Colors.white70,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          type.displayName,
                          style: TextStyle(
                            color: isSelected ? Colors.blue : Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: const Color(0xFF1A1A1A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Account Type',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue:
              _selectedAccountType, // Using deprecated 'value' for compatibility
          style: const TextStyle(color: Colors.white),
          dropdownColor: const Color(0xFF1A1A1A),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF1A1A1A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select an account type';
            }
            return null;
          },
          items: AccountTypes.manualInputTypes.map((type) {
            return DropdownMenuItem<String>(
              value: type,
              child: Text(type, style: const TextStyle(color: Colors.white)),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedAccountType = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildAssetTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Asset Type',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<AssetType>(
          initialValue:
              _selectedAssetType, // Using deprecated 'value' for compatibility
          style: const TextStyle(color: Colors.white),
          dropdownColor: const Color(0xFF1A1A1A),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF1A1A1A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
          ),
          validator: (value) {
            if (value == null) {
              return 'Please select an asset type';
            }
            return null;
          },
          items: AssetType.values.map((type) {
            return DropdownMenuItem<AssetType>(
              value: type,
              child: Text(
                type.displayName,
                style: const TextStyle(color: Colors.white),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedAssetType = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Color',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: WalletService.walletColors.map((color) {
            final isSelected = _selectedColor == color;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedColor = color;
                });
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.transparent,
                    width: 3,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPreviewCard() {
    final walletName = _nameController.text.isNotEmpty
        ? _nameController.text
        : 'Wallet Name';
    final initialValue = _initialValueController.text.isNotEmpty
        ? double.tryParse(_initialValueController.text) ?? 0.0
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Preview',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          color: const Color(0xFF1A1A1A),
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _selectedColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: _selectedWalletType == WalletType.investment
                  ? const Icon(Icons.trending_up, color: Colors.white, size: 24)
                  : const SizedBox(),
            ),
            title: Text(
              walletName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              _selectedWalletType == WalletType.manualInput
                  ? 'IDR ${_formatCurrency(initialValue)}'
                  : _selectedAssetType?.displayName ?? 'Investment',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  String _formatCurrency(double amount) {
    return amount
        .toStringAsFixed(2)
        .replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  Future<void> _saveWallet() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Check if wallet name already exists
        final walletName = _nameController.text.trim();
        final nameExists = await _walletService.isWalletNameExists(walletName);
        if (nameExists) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('A wallet with this name already exists'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
        final initialValue = _selectedWalletType == WalletType.manualInput
            ? double.parse(_initialValueController.text.trim())
            : 0.0;

        final wallet = Wallet(
          id: '', // Empty ID - Supabase will generate it automatically
          name: _nameController.text.trim(),
          type: _selectedWalletType,
          color: _selectedColor,
          initialValue: initialValue,
          accountNumber: _selectedWalletType == WalletType.manualInput
              ? _accountNumberController.text.trim().isEmpty
                    ? null
                    : _accountNumberController.text.trim()
              : null,
          accountType: _selectedAccountType,
          assetType: _selectedAssetType,
        );

        await _walletService.addWallet(wallet);

        if (mounted) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Wallet "${wallet.name}" created successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          // Go back to wallet list
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error creating wallet: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}
