
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance =
  DatabaseHelper._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(
      databasePath,
      'expense_manager.db',
    );

    return openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(
      Database db,
      int version,
      ) async {
    // Bang danh muc
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL
          CHECK(type IN ('Chi tiêu', 'Thu nhập')),
        icon TEXT NOT NULL DEFAULT '',
        UNIQUE(name, type)
      )
    ''');

    // Bang giao dich
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER NOT NULL,
        amount INTEGER NOT NULL CHECK(amount > 0),
        type TEXT NOT NULL
          CHECK(type IN ('Chi tiêu', 'Thu nhập')),
        date TEXT NOT NULL,
        note TEXT DEFAULT '',
        FOREIGN KEY (category_id)
          REFERENCES categories(id)
      )
    ''');

    // Danh muc mac dinh
    final categories = [
      {
        'name': 'Ăn uống',
        'type': 'Chi tiêu',
        'icon': 'restaurant',
      },
      {
        'name': 'Mua sắm',
        'type': 'Chi tiêu',
        'icon': 'shopping_bag',
      },
      {
        'name': 'Di chuyển',
        'type': 'Chi tiêu',
        'icon': 'directions_car',
      },
      {
        'name': 'Giải trí',
        'type': 'Chi tiêu',
        'icon': 'movie',
      },
      {
        'name': 'Lương',
        'type': 'Thu nhập',
        'icon': 'payments',
      },
      {
        'name': 'Khác',
        'type': 'Chi tiêu',
        'icon': 'category',
      },
    ];

    for (final category in categories) {
      await db.insert('categories', category);
    }
  }

  // Lay danh sach danh muc
  Future<List<Map<String, Object?>>> getCategories({
    String? type,
  }) async {
    final db = await database;

    return db.query(
      'categories',
      where: type == null ? null : 'type = ?',
      whereArgs: type == null ? null : [type],
      orderBy: 'id ASC',
    );
  }

  // Them giao dich
  Future<int> insertTransaction({
    required int categoryId,
    required int amount,
    required String type,
    required DateTime date,
    String note = '',
  }) async {
    if (amount <= 0) {
      throw ArgumentError('Số tiền phải lớn hơn 0');
    }

    final db = await database;

    return db.insert('transactions', {
      'category_id': categoryId,
      'amount': amount,
      'type': type,
      'date': _formatDate(date),
      'note': note,
    });
  }

  // Lay tat ca giao dich
  Future<List<Map<String, Object?>>> getTransactions()
  async {
    final db = await database;

    return db.rawQuery('''
      SELECT
        t.id,
        t.category_id,
        t.amount,
        t.type,
        t.date,
        t.note,
        c.name AS category_name
      FROM transactions t
      INNER JOIN categories c
        ON t.category_id = c.id
      ORDER BY t.date DESC, t.id DESC
    ''');
  }

  // Tim mot giao dich theo ID
  Future<Map<String, Object?>?> getTransactionById(
      int id,
      ) async {
    final db = await database;

    final result = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    return result.isEmpty ? null : result.first;
  }

  // Sua giao dich
  Future<int> updateTransaction({
    required int id,
    required int categoryId,
    required int amount,
    required String type,
    required DateTime date,
    String note = '',
  }) async {
    if (amount <= 0) {
      throw ArgumentError('Số tiền phải lớn hơn 0');
    }

    final db = await database;

    return db.update(
      'transactions',
      {
        'category_id': categoryId,
        'amount': amount,
        'type': type,
        'date': _formatDate(date),
        'note': note,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Xoa giao dich
  Future<int> deleteTransaction(int id) async {
    final db = await database;

    return db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Tinh tong thu nhap
  Future<int> getTotalIncome() async {
    return _getTotal('Thu nhập');
  }

  // Tinh tong chi tieu
  Future<int> getTotalExpense() async {
    return _getTotal('Chi tiêu');
  }

  Future<int> _getTotal(String type) async {
    final db = await database;

    final result = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(amount), 0) AS total
      FROM transactions
      WHERE type = ?
      ''',
      [type],
    );

    return (result.first['total'] as num).toInt();
  }

  // Tinh so du
  Future<int> getBalance() async {
    final income = await getTotalIncome();
    final expense = await getTotalExpense();

    return income - expense;
  }

  // Dinh dang ngay theo ISO
  String _formatDate(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }
}
