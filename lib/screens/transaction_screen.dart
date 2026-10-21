import 'package:flutter/material.dart';
import 'package:nenn/model/expense_model.dart';
import '../services/expense_service.dart';
import '../utils/app_colors.dart';
import 'edit_transaction_screen.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final ExpenseService _service = ExpenseService();

  List<ExpenseModel> _expenses = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    try {
      final result = await _service.fetchExpenses();

      if (!mounted) return;

      setState(() {
        _expenses = result;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = 'Unable to load transactions.';
      });
    }
  }

  Future<void> _editExpense(ExpenseModel expense) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditTransactionScreen(expense: expense),
      ),
    );

    if (result == true && mounted) {
      await _loadExpenses();
    }
  }

  Future<void> _deleteExpense(ExpenseModel expense) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Expense?'),
        content: Text('Delete "${expense.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: AppColors.expense)),
          ),
        ],
      ),
    );

    if (confirm != true || expense.id == null) return;

    try {
      await _service.removeExpense(expense.id!);
      await _loadExpenses();

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Expense deleted')));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Transactions'),
        actions: [
          IconButton(onPressed: _loadExpenses, icon: Icon(Icons.refresh)),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_error!),
                  TextButton(onPressed: _loadExpenses, child: Text('Retry')),
                ],
              ),
            )
          : _expenses.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 60,
                    color: AppColors.grey,
                  ),
                  SizedBox(height: 12),
                  Text('No transactions yet'),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadExpenses,
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: _expenses.length,
                itemBuilder: (context, index) {
                  final expense = _expenses[index];

                  return Card(
                    color: Colors.white,
                    elevation: 0,
                    margin: EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Color(0xFFE2F2ED),
                        child: Icon(
                          Icons.receipt_long,
                          color: AppColors.primary,
                        ),
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
                          IconButton(
                            tooltip: 'Edit expense',
                            icon: Icon(
                              Icons.edit_outlined,
                              color: AppColors.primary,
                            ),
                            onPressed: () => _editExpense(expense),
                          ),
                          IconButton(
                            tooltip: 'Delete expense',
                            icon: Icon(
                              Icons.delete_outline,
                              color: AppColors.expense,
                            ),
                            onPressed: () => _deleteExpense(expense),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
