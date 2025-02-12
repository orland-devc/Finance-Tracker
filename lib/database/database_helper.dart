import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
// import '../models/transaction.dart';
import '../models/transaction.dart' as custom; // Alias your custom model

import '../models/category.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'expense_tracker.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create transactions table (combines expenses and income)
    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        description TEXT,
        category TEXT NOT NULL,
        type TEXT NOT NULL,
        date TEXT NOT NULL
      )
    ''');
    
    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        type TEXT NOT NULL
      )
    ''');

    // Insert default categories
    await _insertDefaultCategories(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add type column and convert expenses table to transactions
      await db.execute('ALTER TABLE expenses RENAME TO transactions');
      await db.execute('ALTER TABLE transactions ADD COLUMN type TEXT NOT NULL DEFAULT "expense"');
      await db.execute('ALTER TABLE categories ADD COLUMN type TEXT NOT NULL DEFAULT "expense"');
    }
  }

  Future<void> _insertDefaultCategories(Database db) async {
    // Expense categories
    final expenseCategories = [
      'Food',
      'Transportation',
      'Entertainment',
      'Bills',
      'Shopping'
    ];

    // Income categories
    final incomeCategories = [
      'Salary',
      'Business',
      'Freelance',
      'Gifts',
      'Other Income'
    ];

    for (var category in expenseCategories) {
      await db.insert('categories', {
        'name': category,
        'type': 'expense'
      });
    }

    for (var category in incomeCategories) {
      await db.insert('categories', {
        'name': category,
        'type': 'income'
      });
    }
  }

  // Get today's transactions
  Future<double> getTodayTotal(String type) async {
    Database db = await database;
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();

    final result = await db.rawQuery('''
      SELECT SUM(amount) as total
      FROM transactions
      WHERE type = ? AND date BETWEEN ? AND ?
    ''', [type, startOfDay, endOfDay]);
    
    return result.first['total'] as double? ?? 0.0;
  }

  // Get transactions for a specific period
  Future<List<custom.Transaction>> getTransactionsByPeriod(
    DateTime startDate,
    DateTime endDate,
    {String? type}
  ) async {
    Database db = await database;
    String whereClause = 'date BETWEEN ? AND ?';
    List<dynamic> whereArgs = [startDate.toIso8601String(), endDate.toIso8601String()];
    
    if (type != null) {
      whereClause += ' AND type = ?';
      whereArgs.add(type);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) => custom.Transaction.fromMap(maps[i]));
  }

  // Get daily totals for bar chart
  Future<List<Map<String, dynamic>>> getDailyTotals(
    DateTime startDate,
    DateTime endDate,
    String type
  ) async {
    Database db = await database;
    final result = await db.rawQuery('''
      SELECT date, SUM(amount) as total
      FROM transactions
      WHERE type = ? AND date BETWEEN ? AND ?
      GROUP BY date(date)
      ORDER BY date
    ''', [type, startDate.toIso8601String(), endDate.toIso8601String()]);
    
    return result;
  }

  // Basic CRUD operations
  Future<int> insertTransaction(custom.Transaction newTransaction) async {
    Database db = await database;
    return await db.insert('transactions', newTransaction.toMap());
  }

  Future<List<Category>> getCategoriesByType(String type) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'name',
    );
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  Future<double> getTotalBalance() async {
    final db = await database;
    
    // Get total income
    final List<Map<String, dynamic>> incomeResult = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE type = ?',
      ['income']
    );
    
    // Get total expenses
    final List<Map<String, dynamic>> expenseResult = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE type = ?',
      ['expense']
    );
    
    final double totalIncome = incomeResult.first['total'] ?? 0.0;
    final double totalExpenses = expenseResult.first['total'] ?? 0.0;
    
    return totalIncome - totalExpenses;
  }
}