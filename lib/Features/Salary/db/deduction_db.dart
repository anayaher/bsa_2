import 'package:BSA/Features/Salary/models/deduction_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DeductionDBHelper {
  static final DeductionDBHelper _instance = DeductionDBHelper._internal();
  factory DeductionDBHelper() => _instance;

  DeductionDBHelper._internal();

  Database? _db;

  Future<int> getTotalDeductions() async {
  final db = await this.db;

  final result = await db.rawQuery(
    'SELECT SUM(amount) as total FROM deductions',
  );

  final total = result.first['total'];
  return total == null ? 0 : total as int;
}

  Future<Database> get db async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'bsa.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE deductions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            amount INTEGER
          )
        ''');
      },
    );
  }

  Future<void> addDeduction(DeductionModel d) async {
    final db = await this.db;
    await db.insert('deductions', d.toMap());
  }

  Future<List<DeductionModel>> getDeductions() async {
    final db = await this.db;
    final res = await db.query('deductions');
    return res.map((e) => DeductionModel.fromMap(e)).toList();
  }

  Future<void> deleteDeduction(int id) async {
    final db = await this.db;
    await db.delete('deductions', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAll() async {
    final db = await this.db;
    await db.delete('deductions');
  }
}
