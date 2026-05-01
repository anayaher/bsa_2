// lib/Features/Insurance/db/insurance_db.dart

import 'package:BSA/Models/puc_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class PucDb {
  static final PucDb instance = PucDb._init();
  static Database? _database;

  PucDb._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('puc.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE puc(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehicleId INTEGER NOT NULL,
        validFrom TEXT NOT NULL,
        validUpto TEXT NOT NULL,
        photoPath TEXT NOT NULL,
        FOREIGN KEY(vehicleId) REFERENCES vehicle(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<int> insertPuc(PucModel insurance) async {
    final db = await instance.database;
    return await db.insert('puc', insurance.toMap());
  }

  Future<List<PucModel>> fetchPucForVehicle(int vehicleId) async {
    final db = await instance.database;
    final maps = await db.query(
      'puc',
      where: 'vehicleId = ?',
      whereArgs: [vehicleId],
    );
    return maps.map((e) => PucModel.fromMap(e)).toList();
  }

  Future<List<PucModel>> fetchAllPucs() async {
    final db = await instance.database;
    final maps = await db.query('puc');
    return maps.map((e) => PucModel.fromMap(e)).toList();
  }

  Future<int> updatePuc(PucModel insurance) async {
    final db = await instance.database;
    return await db.update(
      'puc',
      insurance.toMap(),
      where: 'id = ?',
      whereArgs: [insurance.id],
    );
  }

  Future<int> deletePuc(int id) async {
    final db = await instance.database;
    return await db.delete('puc', where: 'id = ?', whereArgs: [id]);
  }
}
