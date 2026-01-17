import 'package:BSA/Features/Salary/models/salary_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SalaryDBHelper {
  static final SalaryDBHelper _instance = SalaryDBHelper._internal();
  factory SalaryDBHelper() => _instance;
  SalaryDBHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<int> getTotalSalary() async {
    final db = await database;

    final result = await db.rawQuery('''
    SELECT 
      (basic + daAmount + hraAmount + ta + arrears) as total 
    FROM salary 
    LIMIT 1
  ''');

    return (result.first['total'] ?? 0) as int;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'salary.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
  CREATE TABLE salary (
    id INTEGER PRIMARY KEY,
    basic INTEGER,
    daPercent INTEGER,
    hraPercent INTEGER,
    daAmount INTEGER,
    hraAmount INTEGER,
    ta INTEGER,
    arrears INTEGER
  )
''');
      },
    );
  }

  Future<void> saveSalary(SalaryModel salary) async {
    final db = await database;

    await db.insert(
      'salary',
      salary.toMap()..['arrears'] = salary.arrears,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<SalaryModel?> getSalary() async {
    final db = await database;

    final result = await db.query('salary', limit: 1);

    if (result.isNotEmpty) {
      return SalaryModel.fromMap(result.first);
    }
    return null;
  }

  Future<void> clearSalary() async {
    final db = await database;
    await db.delete('salary');
  }
}
