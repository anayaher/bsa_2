import 'package:BSA/Features/Savings/gold_item.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class GoldDB {
  static final GoldDB instance = GoldDB._init();
  static Database? _database;

  GoldDB._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('gold_items.db');
    return _database!;
  }
  

  Future<double> fetchTotalGoldValue() async {
    final db = await instance.database;

    final result = await db.rawQuery(
      'SELECT SUM(CAST(totalCost AS REAL)) as total FROM gold_items',
    );

    final value = result.first['total'];
    if (value == null) return 0.0;

    return (value as num).toDouble();
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE gold_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT,
        item TEXT,
        weight TEXT,
        jewellerName TEXT,
        userName TEXT,
        rate TEXT,
        gst TEXT,
        making TEXT,
        totalCost TEXT,
        photoPath TEXT
      )
    ''');
  }

  Future<int> insertGold(GoldItem item) async {
    final db = await instance.database;
    return await db.insert('gold_items', item.toMap());
  }

  Future<List<GoldItem>> fetchGold() async {
    final db = await instance.database;
    final result = await db.query('gold_items', orderBy: 'id DESC');
    return result.map((e) => GoldItem.fromMap(e)).toList();
  }

  Future<int> updateGold(GoldItem item) async {
    final db = await instance.database;
    return await db.update(
      'gold_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteGold(int id) async {
    final db = await instance.database;
    return await db.delete('gold_items', where: 'id = ?', whereArgs: [id]);
  }
}
