import 'package:nenn/model/expense_model.dart';

import '../database/database_helper.dart';

class ExpenseService {
  final DatabaseHelper _database = DatabaseHelper.instance;

  Future<int> addExpense(ExpenseModel expense) {
    return _database.insertExpense(expense);
  }

  Future<List<ExpenseModel>> fetchExpenses() {
    return _database.getExpenses();
  }

  Future<int> editExpense(ExpenseModel expense) {
    return _database.updateExpense(expense);
  }

  Future<int> removeExpense(int id) {
    return _database.deleteExpense(id);
  }

  Future<double> fetchTotalExpense() {
    return _database.getTotalExpense();
  }
}
