import 'package:flutter/material.dart';
import 'package:nenn/model/expense_model.dart';
import '../services/expense_service.dart';
import '../utils/app_colors.dart';
import 'add_expense_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ExpenseService _service = ExpenseService();

  List<ExpenseModel> _expenses = [];
  double _totalExpense = 0;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    try {
      final expenses = await _service.fetchExpenses();
      final total = await _service.fetchTotalExpense();

      if (!mounted) return;

      setState(() {
        _expenses = expenses;
        _totalExpense = total;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = 'Could not load expenses. Please try again.';
      });
    }
  }

  Future<void> _openAddExpense() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AddExpenseScreen()),
    );

    if (result == true && mounted) {
      await _loadExpenses();
    }
  }

  Future<void> _deleteExpense(ExpenseModel expense) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Delete Expense?'),
        content: Text('Delete "${expense.title}" permanently?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text('Delete', style: TextStyle(color: AppColors.expense)),
          ),
        ],
      ),
    );

    if (confirmed != true || expense.id == null) return;

    try {
      await _service.removeExpense(expense.id!);
      await _loadExpenses();

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Expense deleted')));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not delete expense')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Expence', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: RefreshIndicator(
        onRefresh: _loadExpenses,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            Text(
              'Welcome back!',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Track your expenses smartly.',
              style: TextStyle(color: AppColors.grey),
            ),
            SizedBox(height: 20),

            Container(
              padding: EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Expenses',
                    style: TextStyle(color: Colors.white70),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '₹ ${_totalExpense.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 29,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${_expenses.length} transactions recorded',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            Text(
              'Recent Transactions',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),

            if (_isLoading)
              Padding(
                padding: EdgeInsets.all(30),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              Column(
                children: [
                  Text(_error!),
                  TextButton(onPressed: _loadExpenses, child: Text('Retry')),
                ],
              )
            else if (_expenses.isEmpty)
              Padding(
                padding: EdgeInsets.all(28),
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 55,
                      color: AppColors.grey,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No expenses yet',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Tap + to add your first expense.',
                      style: TextStyle(color: AppColors.grey),
                    ),
                  ],
                ),
              )
            else
              ..._expenses.map(
                (expense) => Card(
                  color: Colors.white,
                  elevation: 0,
                  margin: EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withValues(
                        alpha: 0.12,
                      ),
                      child: Icon(Icons.receipt_long, color: AppColors.primary),
                    ),
                    title: Text(
                      expense.title,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${expense.category} • '
                      '${expense.date.day}/'
                      '${expense.date.month}/'
                      '${expense.date.year}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '₹${expense.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: AppColors.expense,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'delete') {
                              _deleteExpense(expense);
                            }
                          },
                          itemBuilder: (_) => [
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: _openAddExpense,
        child: Icon(Icons.add, size: 30),
      ),
    );
  }
}
