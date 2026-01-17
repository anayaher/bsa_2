import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/transaction_model.dart';

class TransactionDBHelper {
  static final TransactionDBHelper _instance = TransactionDBHelper._internal();
  factory TransactionDBHelper() => _instance;
  TransactionDBHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'transaction.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            amount REAL NOT NULL,
            type TEXT NOT NULL,
            payee TEXT NOT NULL,
            head TEXT NOT NULL,
            date TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> addTransaction(TransactionModel tx) async {
    final db = await database;
    await db.insert('transactions', tx.toMap());
  }

  Future<void> updateTransaction(TransactionModel tx) async {
    final db = await database;
    await db.update('transactions', tx.toMap(),
        where: 'id = ?', whereArgs: [tx.id]);
  }

  Future<void> deleteTransaction(int id) async {
    final db = await database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<TransactionModel>> getTransactions({
    String? type,
    String? payee,
    String? head,
    DateTime? from,
    DateTime? to,
    String? search,
  }) async {
    final db = await database;

    final whereClauses = <String>[];
    final args = <dynamic>[];

    if (type != null && type != 'All') {
      whereClauses.add('type = ?');
      args.add(type);
    }

    if (payee != null && payee != 'All') {
      whereClauses.add('payee = ?');
      args.add(payee);
    }

    if (head != null && head != 'All') {
      whereClauses.add('head = ?');
      args.add(head);
    }

    if (from != null) {
      whereClauses.add('date >= ?');
      args.add(from.toIso8601String());
    }

    if (to != null) {
      whereClauses.add('date <= ?');
      args.add(to.toIso8601String());
    }

    if (search != null && search.isNotEmpty) {
      whereClauses.add('(payee LIKE ? OR head LIKE ?)');
      args.add('%$search%');
      args.add('%$search%');
    }

    final whereString =
        whereClauses.isEmpty ? null : whereClauses.join(' AND ');

    final result = await db.query(
      'transactions',
      where: whereString,
      whereArgs: args,
      orderBy: 'date DESC',
    );

    return result.map((e) => TransactionModel.fromMap(e)).toList();
  }
}
