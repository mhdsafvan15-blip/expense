import 'package:flutter/foundation.dart';
import 'package:nenn/model/expense_model.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class DatabaseHelper {
  DatabaseHelper._internal();

  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    }

    final path = kIsWeb
        ? 'expense_manager_web.db'
        : p.join(await getDatabasesPath(), 'expense_manager.db');

    return openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE expenses (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            amount REAL NOT NULL,
            category TEXT NOT NULL,
            date TEXT NOT NULL,
            description TEXT,
            type TEXT NOT NULL DEFAULT 'expense'
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            "ALTER TABLE expenses ADD COLUMN type TEXT NOT NULL DEFAULT 'expense'",
          );
        }
      },
    );
  }

  Future<int> insertExpense(ExpenseModel expense) async {
    final db = await database;
    return db.insert('expenses', expense.toMap());
  }

  Future<List<ExpenseModel>> getExpenses({String? type}) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      where: type == null ? null : 'type = ?',
      whereArgs: type == null ? null : [type],
      orderBy: 'date DESC, id DESC',
    );

    return maps.map(ExpenseModel.fromMap).toList();
  }

  Future<ExpenseModel?> getExpenseById(int id) async {
    final db = await database;

    final result = await db.query(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return ExpenseModel.fromMap(result.first);
  }

  Future<int> updateExpense(ExpenseModel expense) async {
    final db = await database;

    if (expense.id == null) {
      throw ArgumentError('Expense ID is required for update');
    }

    return db.update(
      'expenses',
      expense.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> deleteExpense(int id) async {
    final db = await database;

    return db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  Future<double> getTotalExpense() async {
    return _getTotalByType('expense');
  }

  Future<double> getTotalIncome() async {
    return _getTotalByType('income');
  }

  Future<double> _getTotalByType(String type) async {
    final db = await database;

    final result = await db.rawQuery(
      'SELECT SUM(amount) AS total FROM expenses WHERE type = ?',
      [type],
    );

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
