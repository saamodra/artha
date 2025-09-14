import 'package:flutter/material.dart';
import '../models/debt.dart';
import '../services/debt_service.dart';

class AddDebtPage extends StatefulWidget {
  final DebtType initialType;
  final Debt? debt; // For editing existing debt

  const AddDebtPage({super.key, required this.initialType, this.debt});

  @override
  State<AddDebtPage> createState() => _AddDebtPageState();
}

class _AddDebtPageState extends State<AddDebtPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  late DebtType _selectedType;
  String _selectedAccount = 'Cash';
  DateTime _selectedDate = DateTime.now();
  DateTime _selectedDueDate = DateTime.now().add(const Duration(days: 30));

  final DebtService _debtService = DebtService();

  final List<String> _accounts = [
    'Cash',
    'BRI',
    'BCA',
    'Cashfile',
    'SeaBank',
    'Ajaib Stocks',
    'Bibit',
    'Gopay',
    'DANA',
    'OVO',
    'Shopeepay',
  ];

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;

    if (widget.debt != null) {
      // Editing existing debt
      _nameController.text = widget.debt!.name;
      _descriptionController.text = widget.debt!.description;
      _amountController.text = widget.debt!.originalAmount.toStringAsFixed(0);
      _selectedType = widget.debt!.type;
      _selectedAccount = widget.debt!.account;
      _selectedDate = widget.debt!.dateCreated;
      _selectedDueDate = widget.debt!.dueDate;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.debt != null;

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        title: Text(
          isEditing ? 'Edit Debt' : 'Add Debt',
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: _saveDebt,
            child: Text(
              isEditing ? 'Update' : 'Save',
              style: const TextStyle(color: Colors.blue, fontSize: 16),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Debt Type Selection
              Card(
                color: const Color(0xFF1A1A1A),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Debt Type',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(
                                () => _selectedType = DebtType.iLent,
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: _selectedType == DebtType.iLent
                                      ? Colors.green.withValues(alpha: 0.2)
                                      : Colors.grey.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _selectedType == DebtType.iLent
                                        ? Colors.green
                                        : Colors.grey.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.trending_up,
                                      color: _selectedType == DebtType.iLent
                                          ? Colors.green
                                          : Colors.white70,
                                      size: 32,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'I Lent',
                                      style: TextStyle(
                                        color: _selectedType == DebtType.iLent
                                            ? Colors.green
                                            : Colors.white70,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedType = DebtType.iOwe),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: _selectedType == DebtType.iOwe
                                      ? Colors.red.withValues(alpha: 0.2)
                                      : Colors.grey.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _selectedType == DebtType.iOwe
                                        ? Colors.red
                                        : Colors.grey.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.trending_down,
                                      color: _selectedType == DebtType.iOwe
                                          ? Colors.red
                                          : Colors.white70,
                                      size: 32,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'I Owe',
                                      style: TextStyle(
                                        color: _selectedType == DebtType.iOwe
                                            ? Colors.red
                                            : Colors.white70,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Basic Information
              Card(
                color: const Color(0xFF1A1A1A),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Basic Information',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Name Field
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: _selectedType == DebtType.iLent
                              ? 'Person who owes me'
                              : 'Person I owe to',
                          labelStyle: const TextStyle(color: Colors.white70),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey.withValues(alpha: 0.3),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          errorBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          focusedErrorBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Description Field
                      TextFormField(
                        controller: _descriptionController,
                        style: const TextStyle(color: Colors.white),
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Description (Optional)',
                          labelStyle: const TextStyle(color: Colors.white70),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey.withValues(alpha: 0.3),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Amount and Account
              Card(
                color: const Color(0xFF1A1A1A),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Amount & Account',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Amount Field
                      TextFormField(
                        controller: _amountController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Amount (IDR)',
                          labelStyle: const TextStyle(color: Colors.white70),
                          prefixText: 'IDR ',
                          prefixStyle: const TextStyle(color: Colors.white70),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey.withValues(alpha: 0.3),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          errorBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          focusedErrorBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter an amount';
                          }
                          final amount = double.tryParse(value.trim());
                          if (amount == null || amount <= 0) {
                            return 'Please enter a valid amount';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Account Dropdown
                      DropdownButtonFormField<String>(
                        initialValue: _selectedAccount,
                        style: const TextStyle(color: Colors.white),
                        dropdownColor: const Color(0xFF1A1A1A),
                        decoration: InputDecoration(
                          labelText: 'Account',
                          labelStyle: const TextStyle(color: Colors.white70),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey.withValues(alpha: 0.3),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                        ),
                        items: _accounts.map((account) {
                          return DropdownMenuItem(
                            value: account,
                            child: Text(account),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedAccount = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Dates
              Card(
                color: const Color(0xFF1A1A1A),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Dates',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Date Created
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Date Created',
                          style: TextStyle(color: Colors.white70),
                        ),
                        subtitle: Text(
                          _formatDisplayDate(_selectedDate),
                          style: const TextStyle(color: Colors.white),
                        ),
                        trailing: const Icon(
                          Icons.calendar_today,
                          color: Colors.blue,
                        ),
                        onTap: () => _selectDate(isCreatedDate: true),
                      ),
                      const Divider(color: Colors.grey),

                      // Due Date
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Due Date',
                          style: TextStyle(color: Colors.white70),
                        ),
                        subtitle: Text(
                          _formatDisplayDate(_selectedDueDate),
                          style: const TextStyle(color: Colors.white),
                        ),
                        trailing: const Icon(Icons.event, color: Colors.blue),
                        onTap: () => _selectDate(isCreatedDate: false),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate({required bool isCreatedDate}) async {
    final currentDate = isCreatedDate ? _selectedDate : _selectedDueDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Color(0xFF1A1A1A),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isCreatedDate) {
          _selectedDate = picked;
        } else {
          _selectedDueDate = picked;
        }
      });
    }
  }

  String _formatDisplayDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _saveDebt() {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text.trim());

      if (widget.debt != null) {
        // Update existing debt
        final updatedDebt = widget.debt!.copyWith(
          type: _selectedType,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          account: _selectedAccount,
          originalAmount: amount,
          currentAmount: amount, // Reset current amount when editing
          dateCreated: _selectedDate,
          dueDate: _selectedDueDate,
        );
        _debtService.updateDebt(updatedDebt);
      } else {
        // Create new debt
        final debt = Debt(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: _selectedType,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          account: _selectedAccount,
          originalAmount: amount,
          currentAmount: amount,
          dateCreated: _selectedDate,
          dueDate: _selectedDueDate,
        );
        _debtService.addDebt(debt);
      }

      Navigator.of(context).pop();
    }
  }
}
