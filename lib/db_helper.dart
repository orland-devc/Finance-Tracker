import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'budget_tracker.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Create table
        await db.execute('''
          CREATE TABLE expenses (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            amount REAL NOT NULL,
            category TEXT NOT NULL,
            date TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // Insert a new expense
  Future<int> addExpense(Map<String, dynamic> expense) async {
    final db = await database;
    return db.insert('expenses', expense);
  }

  // Retrieve all expenses
  Future<List<Map<String, dynamic>>> getExpenses() async {
    final db = await database;
    return db.query('expenses', orderBy: 'date DESC');
  }

  // Delete an expense
  Future<int> deleteExpense(int id) async {
    final db = await database;
    return db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  // Update an expense
  Future<int> updateExpense(int id, Map<String, dynamic> expense) async {
    final db = await database;
    return db.update('expenses', expense, where: 'id = ?', whereArgs: [id]);
  }
}
