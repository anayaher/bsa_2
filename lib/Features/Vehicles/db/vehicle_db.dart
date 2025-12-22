import 'package:BSA/Models/vehicle_model.dart';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class VehicleDB {
  static final VehicleDB instance = VehicleDB._init();
  static Database? _database;

  VehicleDB._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB("vehicles.db");
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE vehicles(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehicleName TEXT NOT NULL,
        regNumber TEXT NOT NULL,
        registrationDate TEXT NOT NULL,
        purchaseDate TEXT NOT NULL,
        purchasePrice REAL NOT NULL,
        vehiclePhoto TEXT NOT NULL,
        rcFront TEXT NOT NULL,
        rcBack TEXT NOT NULL,
        pucDate TEXT NOT NULL,
        pucValidUpto TEXT NOT NULL,
        pucPhoto TEXT NOT NULL,
        chassis TEXT,
        engine TEXT
      )
    ''');
  }

  Future<int> insertVehicle(VehicleModel model) async {
    final db = await instance.database;
    return await db.insert("vehicles", model.toMap());
  }

  Future<List<VehicleModel>> fetchVehicles() async {
    final db = await instance.database;
    final data = await db.query("vehicles");
    return data.map((e) => VehicleModel.fromMap(e)).toList();
  }

  Future<int> deleteVehicle(int id) async {
    final db = await instance.database;
    return await db.delete("vehicles", where: "id = ?", whereArgs: [id]);
  }

  Future<int> updateVehicle(VehicleModel model) async {
    final db = await instance.database;
    return await db.update(
      "vehicles",
      model.toMap(),
      where: "id = ?",
      whereArgs: [model.id],
    );
  }
}
