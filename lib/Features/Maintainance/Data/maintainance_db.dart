import 'package:BSA/Models/maintainance_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


class MaintenanceDB {
  static final MaintenanceDB instance = MaintenanceDB._init();
  static Database? _database;

  MaintenanceDB._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('maintenance.db');
    return _database!;
  }

  Future<Database> _initDB(String file) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, file);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE maintenance(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehicleId INTEGER NOT NULL,
        date TEXT NOT NULL,
        maintenanceType TEXT NOT NULL,
        price REAL NOT NULL,
        garage TEXT NOT NULL,
        kms INTEGER
      )
    ''');
  }

  // INSERT
  Future<int> addMaintenance(MaintenanceModel model) async {
    final db = await instance.database;
    return await db.insert('maintenance', model.toMap());
  }

  // GET by Vehicle ID
  Future<List<MaintenanceModel>> fetchMaintenanceByVehicle(int vehicleId) async {
    final db = await instance.database;

    final result = await db.query(
      'maintenance',
      where: 'vehicleId = ?',
      whereArgs: [vehicleId],
      orderBy: 'date DESC',
    );

    return result.map((e) => MaintenanceModel.fromMap(e)).toList();
  }

  // DELETE one item
  Future<int> deleteMaintenance(int id) async {
    final db = await instance.database;
    return await db.delete(
      'maintenance',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // DELETE all when vehicle deleted (optional helper)
  Future<int> deleteByVehicle(int vehicleId) async {
    final db = await instance.database;
    return await db.delete(
      'maintenance',
      where: 'vehicleId = ?',
      whereArgs: [vehicleId],
    );
  }
}
