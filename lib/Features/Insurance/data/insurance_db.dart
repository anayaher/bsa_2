// lib/Features/Insurance/db/insurance_db.dart
import 'package:BSA/Models/insurance_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class InsuranceDB {
  static final InsuranceDB instance = InsuranceDB._init();
  static Database? _database;

  InsuranceDB._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('insurance.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE insurance(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehicleId INTEGER NOT NULL,
        buyDate TEXT NOT NULL,
        validUpto TEXT NOT NULL,
        photoPath TEXT NOT NULL,
        FOREIGN KEY(vehicleId) REFERENCES vehicle(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<int> insertInsurance(InsuranceModel insurance) async {
    final db = await instance.database;
    return await db.insert('insurance', insurance.toMap());
  }

  Future<List<InsuranceModel>> fetchInsurances(int vehicleId) async {
    final db = await instance.database;
    final maps = await db.query(
      'insurance',
      where: 'vehicleId = ?',
      whereArgs: [vehicleId],
      orderBy: 'buyDate DESC',
    );
    return maps.map((e) => InsuranceModel.fromMap(e)).toList();
  }

  Future<List<InsuranceModel>> fetchAllInsurances() async {
    final db = await instance.database;
    final maps = await db.query('insurance', orderBy: 'buyDate DESC');
    return maps.map((e) => InsuranceModel.fromMap(e)).toList();
  }

  Future<int> updateInsurance(InsuranceModel insurance) async {
    final db = await instance.database;
    return await db.update(
      'insurance',
      insurance.toMap(),
      where: 'id = ?',
      whereArgs: [insurance.id],
    );
  }

  Future<int> deleteInsurance(int id) async {
    final db = await instance.database;
    return await db.delete('insurance', where: 'id = ?', whereArgs: [id]);
  }
}
