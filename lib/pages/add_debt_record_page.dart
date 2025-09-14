import 'package:flutter/material.dart';
import '../models/debt.dart';
import '../services/debt_service.dart';

class AddDebtRecordPage extends StatefulWidget {
  final Debt debt;

  const AddDebtRecordPage({super.key, required this.debt});

  @override
  State<AddDebtRecordPage> createState() => _AddDebtRecordPageState();
}

class _AddDebtRecordPageState extends State<AddDebtRecordPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  DebtAction _selectedAction = DebtAction.repay;
  String _selectedAccount = 'Cash';
  DateTime _selectedDateTime = DateTime.now();

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
    _selectedAccount = widget.debt.account;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        title: Text(
          'Add ${_getActionText()}',
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: _saveDebtRecord,
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.blue, fontSize: 16),
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
              // Debt Info Card
              Card(
                color: const Color(0xFF1A1A1A),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.grey[700],
                        radius: 20,
                        child: Text(
                          widget.debt.name.isNotEmpty
                              ? widget.debt.name[0].toUpperCase()
                              : '?',
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
                              widget.debt.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Current: IDR ${widget.debt.currentAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              (widget.debt.type == DebtType.iLent
                                      ? Colors.green
                                      : Colors.red)
                                  .withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.debt.type == DebtType.iLent
                              ? 'I Lent'
                              : 'I Owe',
                          style: TextStyle(
                            color: widget.debt.type == DebtType.iLent
                                ? Colors.green
                                : Colors.red,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Action Selection
              Card(
                color: const Color(0xFF1A1A1A),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Action',
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
                                () => _selectedAction = DebtAction.repay,
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: _selectedAction == DebtAction.repay
                                      ? Colors.green.withValues(alpha: 0.2)
                                      : Colors.grey.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _selectedAction == DebtAction.repay
                                        ? Colors.green
                                        : Colors.grey.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.payments,
                                      color: _selectedAction == DebtAction.repay
                                          ? Colors.green
                                          : Colors.white70,
                                      size: 32,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _getRepayText(),
                                      style: TextStyle(
                                        color:
                                            _selectedAction == DebtAction.repay
                                            ? Colors.green
                                            : Colors.white70,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(
                                () => _selectedAction = DebtAction.increaseDebt,
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color:
                                      _selectedAction == DebtAction.increaseDebt
                                      ? Colors.orange.withValues(alpha: 0.2)
                                      : Colors.grey.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color:
                                        _selectedAction ==
                                            DebtAction.increaseDebt
                                        ? Colors.orange
                                        : Colors.grey.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.add_circle,
                                      color:
                                          _selectedAction ==
                                              DebtAction.increaseDebt
                                          ? Colors.orange
                                          : Colors.white70,
                                      size: 32,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Increase\nDebt',
                                      style: TextStyle(
                                        color:
                                            _selectedAction ==
                                                DebtAction.increaseDebt
                                            ? Colors.orange
                                            : Colors.white70,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                      textAlign: TextAlign.center,
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
                          if (_selectedAction == DebtAction.repay &&
                              amount > widget.debt.currentAmount) {
                            return 'Amount cannot exceed current debt';
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

              // Date and Note
              Card(
                color: const Color(0xFF1A1A1A),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Date & Note',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Date Selection
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Date & Time',
                          style: TextStyle(color: Colors.white70),
                        ),
                        subtitle: Text(
                          _formatDisplayDateTime(_selectedDateTime),
                          style: const TextStyle(color: Colors.white),
                        ),
                        trailing: const Icon(
                          Icons.calendar_today,
                          color: Colors.blue,
                        ),
                        onTap: _selectDateTime,
                      ),
                      const SizedBox(height: 16),

                      // Note Field
                      TextFormField(
                        controller: _noteController,
                        style: const TextStyle(color: Colors.white),
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Note (Optional)',
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
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
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

    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
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

      if (pickedTime != null && mounted) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  String _formatDisplayDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getActionText() {
    if (_selectedAction == DebtAction.repay) {
      return _getRepayText();
    } else {
      return 'Debt Increase';
    }
  }

  String _getRepayText() {
    if (widget.debt.type == DebtType.iLent) {
      return 'Repayment';
    } else {
      return 'Payment';
    }
  }

  void _saveDebtRecord() {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text.trim());

      final debtRecord = DebtRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        debtId: widget.debt.id,
        action: _selectedAction,
        account: _selectedAccount,
        amount: amount,
        dateTime: _selectedDateTime,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      );

      _debtService.addDebtRecord(debtRecord);
      Navigator.of(context).pop();
    }
  }
}
