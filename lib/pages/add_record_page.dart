import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/wallet_record.dart';
import '../services/record_service.dart';
import '../services/category_service.dart';

class AddRecordPage extends StatefulWidget {
  final List<Map<String, dynamic>> wallets;
  final String? preSelectedWallet;

  const AddRecordPage({
    super.key,
    required this.wallets,
    this.preSelectedWallet,
  });

  @override
  State<AddRecordPage> createState() => _AddRecordPageState();
}

class _AddRecordPageState extends State<AddRecordPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _labelController = TextEditingController();
  final _categoryService = CategoryService();

  RecordType _selectedType = RecordType.expense;
  String? _selectedCategory;
  String? _selectedAccount;
  String? _selectedTransferToAccount;
  DateTime _selectedDateTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Initialize category service
    _categoryService.initialize();
    _categoryService.addListener(_onCategoryServiceChanged);

    // Set default account to pre-selected wallet or first wallet if available
    if (widget.preSelectedWallet != null) {
      // Verify that the pre-selected wallet exists in the wallet list
      final walletExists = widget.wallets.any(
        (wallet) => wallet['name'] as String == widget.preSelectedWallet,
      );
      if (walletExists) {
        _selectedAccount = widget.preSelectedWallet;
      } else {
        // Debug: Log when pre-selected wallet is not found
        debugPrint(
          'AddRecordPage: Pre-selected wallet "${widget.preSelectedWallet}" not found in wallet list',
        );
        debugPrint(
          'Available wallets: ${widget.wallets.map((w) => w['name']).join(', ')}',
        );
        if (widget.wallets.isNotEmpty) {
          _selectedAccount = widget.wallets.first['name'] as String;
        }
      }
    } else if (widget.wallets.isNotEmpty) {
      _selectedAccount = widget.wallets.first['name'] as String;
    }
    // Set default category based on type
    _updateCategoryForType();
  }

  void _onCategoryServiceChanged() {
    if (mounted) {
      setState(() {
        // Update category selection when categories are loaded
        _updateCategoryForType();
      });
    }
  }

  @override
  void dispose() {
    _categoryService.removeListener(_onCategoryServiceChanged);
    _amountController.dispose();
    _noteController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  void _updateCategoryForType() {
    final categories = _categoryService.getCategoryNamesForType(_selectedType);
    if (categories.isNotEmpty) {
      _selectedCategory = categories.first;
    }
  }

  void _onTypeChanged(RecordType? type) {
    if (type != null) {
      setState(() {
        _selectedType = type;
        _updateCategoryForType();
        // Reset transfer account when not transfer type
        if (type != RecordType.transfer) {
          _selectedTransferToAccount = null;
        }
      });
    }
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: const Color(0xFF1A1A1A),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      if (!mounted) return;
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: Colors.blue,
                onPrimary: Colors.white,
                surface: const Color(0xFF1A1A1A),
                onSurface: Colors.white,
              ),
            ),
            child: child!,
          );
        },
      );

      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _saveRecord() {
    if (_formKey.currentState!.validate()) {
      if (_selectedType == RecordType.transfer &&
          _selectedTransferToAccount == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a transfer destination account'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_selectedType == RecordType.transfer &&
          _selectedAccount == _selectedTransferToAccount) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot transfer to the same account'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final record = WalletRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: _selectedType,
        category: _selectedCategory!,
        account: _selectedAccount!,
        transferToAccount: _selectedTransferToAccount,
        amount: double.parse(_amountController.text),
        dateTime: _selectedDateTime,
        note: _noteController.text.isEmpty ? null : _noteController.text,
        label: _labelController.text.isEmpty ? null : _labelController.text,
      );

      RecordService().addRecord(record);

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_selectedType.name.toUpperCase()} record added successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Add Record',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: _saveRecord,
            child: const Text(
              'SAVE',
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF111111),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Form Card
              Card(
                color: const Color(0xFF1A1A1A),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Record Type Section
                      const Text(
                        'Record Type',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: RecordType.values.map((type) {
                          final isSelected = _selectedType == type;
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: type == RecordType.values.last ? 0 : 8,
                              ),
                              child: ElevatedButton(
                                onPressed: () => _onTypeChanged(type),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isSelected
                                      ? Colors.blue
                                      : const Color(0xFF2A2A2A),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: BorderSide(
                                      color: isSelected
                                          ? Colors.blue
                                          : Colors.transparent,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  type.name.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white70,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 20),

                      // Category Section
                      const Text(
                        'Category',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _categoryService.isLoading
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white54),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Row(
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.blue,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Loading categories...',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ],
                              ),
                            )
                          : _categoryService.error != null
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.red),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.error,
                                    color: Colors.red,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Error: ${_categoryService.error}',
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : DropdownButtonFormField<String>(
                              initialValue: _selectedCategory,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              dropdownColor: const Color(0xFF1A1A1A),
                              style: const TextStyle(color: Colors.white),
                              items: _categoryService
                                  .getCategoryNamesForType(_selectedType)
                                  .map(
                                    (category) => DropdownMenuItem(
                                      value: category,
                                      child: Text(category),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedCategory = value;
                                });
                              },
                              validator: (value) => value == null
                                  ? 'Please select a category'
                                  : null,
                            ),

                      const SizedBox(height: 20),

                      // Account Section
                      Text(
                        _selectedType == RecordType.transfer
                            ? 'From Account'
                            : 'Account',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedAccount,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        dropdownColor: const Color(0xFF1A1A1A),
                        style: const TextStyle(color: Colors.white),
                        items: widget.wallets
                            .map(
                              (wallet) => DropdownMenuItem(
                                value: wallet['name'] as String,
                                child: Text(wallet['name'] as String),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedAccount = value;
                          });
                        },
                        validator: (value) =>
                            value == null ? 'Please select an account' : null,
                      ),

                      // Transfer To Account Section (only for transfers)
                      if (_selectedType == RecordType.transfer) ...[
                        const SizedBox(height: 20),
                        const Text(
                          'To Account',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedTransferToAccount,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          dropdownColor: const Color(0xFF1A1A1A),
                          style: const TextStyle(color: Colors.white),
                          items: widget.wallets
                              .where(
                                (wallet) => wallet['name'] != _selectedAccount,
                              )
                              .map(
                                (wallet) => DropdownMenuItem(
                                  value: wallet['name'] as String,
                                  child: Text(wallet['name'] as String),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedTransferToAccount = value;
                            });
                          },
                        ),
                      ],

                      const SizedBox(height: 20),

                      // Amount Section
                      const Text(
                        'Amount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _amountController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: '0.00',
                          hintStyle: TextStyle(color: Colors.white54),
                          prefixText: 'IDR ',
                          prefixStyle: TextStyle(color: Colors.white),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}'),
                          ),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an amount';
                          }
                          final amount = double.tryParse(value);
                          if (amount == null || amount <= 0) {
                            return 'Please enter a valid amount';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Date & Time Section
                      const Text(
                        'Date & Time',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: _selectDateTime,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white54),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                color: Colors.white70,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${_selectedDateTime.day}/${_selectedDateTime.month}/${_selectedDateTime.year} ${_selectedDateTime.hour.toString().padLeft(2, '0')}:${_selectedDateTime.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(color: Colors.white),
                              ),
                              const Spacer(),
                              const Icon(
                                Icons.arrow_drop_down,
                                color: Colors.white70,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Note Section
                      const Text(
                        'Note (Optional)',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _noteController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Add a note...',
                          hintStyle: TextStyle(color: Colors.white54),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        maxLines: 3,
                      ),

                      const SizedBox(height: 20),

                      // Label Section
                      const Text(
                        'Label (Optional)',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _labelController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Add a label...',
                          hintStyle: TextStyle(color: Colors.white54),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveRecord,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'SAVE ${_selectedType.name.toUpperCase()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
