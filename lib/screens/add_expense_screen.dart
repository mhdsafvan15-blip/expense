import 'package:flutter/material.dart';
import 'package:nenn/model/expense_model.dart';

import '../database/database_helper.dart';
import '../utils/app_colors.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final DatabaseHelper _database = DatabaseHelper.instance;

  String selectedType = 'expense';
  String selectedCategory = 'Personal';
  DateTime selectedDate = DateTime.now();
  bool _isSaving = false;

  final List<String> expenseCategories = [
    'Personal',
    'Food',
    'Travel',
    'Shopping',
    'Bills',
    'Health',
    'Education',
    'Other',
  ];

  final List<String> incomeCategories = [
    'Salary',
    'Freelance',
    'Business',
    'Gift',
    'Investment',
    'Other',
  ];

  List<String> get currentCategories {
    return selectedType == 'income' ? incomeCategories : expenseCategories;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && mounted) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final transaction = ExpenseModel(
        title: titleController.text.trim(),
        amount: double.parse(amountController.text.trim()),
        category: selectedCategory,
        date: selectedDate,
        description: descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim(),
        type: selectedType,
      );

      await _database.insertExpense(transaction);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            selectedType == 'income'
                ? 'Income added successfully'
                : 'Expense added successfully',
          ),
          backgroundColor: selectedType == 'income'
              ? Colors.green
              : AppColors.expense,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save transaction: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = selectedType == 'income';
    final accentColor = isIncome ? Colors.green : AppColors.expense;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isIncome ? 'Add Income' : 'Add Expense'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Transaction Type',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Expense / Income selector
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment<String>(
                    value: 'expense',
                    label: Text('Expense'),
                    icon: Icon(Icons.arrow_upward),
                  ),
                  ButtonSegment<String>(
                    value: 'income',
                    label: Text('Income'),
                    icon: Icon(Icons.arrow_downward),
                  ),
                ],
                selected: {selectedType},
                onSelectionChanged: (values) {
                  setState(() {
                    selectedType = values.first;

                    if (!currentCategories.contains(selectedCategory)) {
                      selectedCategory = currentCategories.first;
                    }
                  });
                },
                showSelectedIcon: false,
                style: ButtonStyle(
                  foregroundColor: WidgetStateProperty.resolveWith<Color?>((
                    states,
                  ) {
                    if (states.contains(WidgetState.selected)) {
                      return Colors.white;
                    }
                    return AppColors.text;
                  }),
                  backgroundColor: WidgetStateProperty.resolveWith<Color?>((
                    states,
                  ) {
                    if (states.contains(WidgetState.selected)) {
                      return selectedType == 'income'
                          ? Colors.green
                          : AppColors.expense;
                    }
                    return Colors.white;
                  }),
                ),
              ),

              const SizedBox(height: 24),

              // Title
              TextFormField(
                controller: titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: isIncome ? 'Income title' : 'Expense title',
                  hintText: isIncome
                      ? 'e.g. Monthly salary'
                      : 'e.g. Grocery shopping',
                  prefixIcon: const Icon(Icons.title),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 18),

              // Amount
              TextFormField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '₹ ',
                  prefixIcon: Icon(Icons.currency_rupee),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final amount = double.tryParse(value?.trim() ?? '');

                  if (amount == null || !amount.isFinite || amount <= 0) {
                    return 'Enter a valid amount greater than zero';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 18),

              // Category
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category_outlined),
                  border: OutlineInputBorder(),
                ),
                items: currentCategories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedCategory = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 18),

              // Date
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(8),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    prefixIcon: Icon(Icons.calendar_month),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    '${selectedDate.day.toString().padLeft(2, '0')}/'
                    '${selectedDate.month.toString().padLeft(2, '0')}/'
                    '${selectedDate.year}',
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Optional description
              TextFormField(
                controller: descriptionController,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'Add some details',
                  prefixIcon: Icon(Icons.notes),
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 28),

              // Save
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveTransaction,
                  icon: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(
                    _isSaving
                        ? 'Saving...'
                        : isIncome
                        ? 'Save Income'
                        : 'Save Expense',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isIncome
                        ? Colors.green
                        : AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
