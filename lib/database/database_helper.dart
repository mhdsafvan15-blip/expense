import 'package:flutter/foundation.dart';
import 'package:nenn/model/expense_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null && _database!.isOpen) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Select the correct database factory for Chrome or native.
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    }

    final String dbPath;

    if (kIsWeb) {
      // Web database is persisted using IndexedDB.
      dbPath = 'expense_manager_web.db';
    } else {
      final directory = await getDatabasesPath();
      dbPath = join(directory, 'expense_manager.db');
    }

    return openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE expenses (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            amount REAL NOT NULL,
            category TEXT NOT NULL,
            date TEXT NOT NULL,
            description TEXT
          )
        ''');
      },
    );
  }

  // CREATE
  Future<int> insertExpense(ExpenseModel expense) async {
    final db = await database;

    final data = expense.toMap()..remove('id');

    return db.insert(
      'expenses',
      data,
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  // READ ALL
  Future<List<ExpenseModel>> getExpenses() async {
    final db = await database;

    final rows = await db.query('expenses', orderBy: 'date DESC, id DESC');

    return rows.map(ExpenseModel.fromMap).toList();
  }

  // READ ONE
  Future<ExpenseModel?> getExpenseById(int id) async {
    final db = await database;

    final rows = await db.query(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (rows.isEmpty) return null;

    return ExpenseModel.fromMap(rows.first);
  }

  // UPDATE
  Future<int> updateExpense(ExpenseModel expense) async {
    final id = expense.id;

    if (id == null) {
      throw ArgumentError('Expense ID is required.');
    }

    final db = await database;
    final data = expense.toMap()..remove('id');

    return db.update('expenses', data, where: 'id = ?', whereArgs: [id]);
  }

  // DELETE
  Future<int> deleteExpense(int id) async {
    final db = await database;

    return db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  // TOTAL
  Future<double> getTotalExpense() async {
    final db = await database;

    final result = await db.rawQuery(
      'SELECT SUM(amount) AS total FROM expenses',
    );

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // CLOSE
  Future<void> closeDatabase() async {
    final db = _database;

    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
