import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/payee_model.dart';

class PayeeDBHelper {
  static final PayeeDBHelper _instance = PayeeDBHelper._internal();
  factory PayeeDBHelper() => _instance;
  PayeeDBHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;

    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'payee.db');

    // DEBUG: print path
    print("Database path: $path");

    return openDatabase(
      path,
      version: 1, // fresh DB, version 1 is enough
      onCreate: (db, version) async {
        print("Creating tables...");

        // CREATE PAYEES TABLE
        await db.execute('''
          CREATE TABLE payees (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            type TEXT NOT NULL
          )
        ''');

        print("Tables created!");
      },
    );
  }

  /// Update an existing payee
  Future<void> updatePayee(PayeeModel payee) async {
    final db = await database;

    if (payee.id == null) {
      throw Exception("Cannot update payee without an ID");
    }

    await db.update(
      'payees',
      payee.toMap(),
      where: 'id = ?',
      whereArgs: [payee.id],
    );
  }

  /// Delete a payee
  Future<void> deletePayee(int id) async {
    final db = await database;
    await db.delete('payees', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> addPayee(PayeeModel payee) async {
    final db = await database;
    await db.insert('payees', payee.toMap());
  }

  Future<List<PayeeModel>> getPayees({String? type}) async {
    final db = await database;

    final result =
        type == null || type == 'All'
            ? await db.query('payees', orderBy: 'name')
            : await db.query(
              'payees',
              where: 'type = ?',
              whereArgs: [type],
              orderBy: 'name',
            );

    return result.map((e) => PayeeModel.fromMap(e)).toList();
  }

  Future<List<PayeeModel>> searchPayees(String query) async {
    final db = await database;
    final result = await db.query(
      'payees',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
    );
    return result.map((e) => PayeeModel.fromMap(e)).toList();
  }
}
