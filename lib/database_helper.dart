import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final brewTable = 'Brew';
class DatabaseHelper {
  static final DatabaseHelper dbHelper = DatabaseHelper();
  final _dbName = "CoffeeJournal.db";
  final _dbVersion = 1;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await createDatabase();
    return _database!;
  }

  createDatabase() async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, _dbName);
    var database = await openDatabase(path,
        version: 1, onCreate: initDB);
    return database;
  }

  void initDB(Database database, int version) async {
    await database.execute("CREATE TABLE $brewTable ("
        "id INTEGER PRIMARY KEY, "
        "roaster TEXT, "
        "blend TEXT, "
        "roast_profile TEXT, "
        "method TEXT, "
        "grind_size TEXT, "
        "dose INTEGER, "
        "dose_measurement TEXT,"
        "water INTEGER, "
        "water_measurement TEXT, "
        "duration INTEGER, "
        "time INTEGER, "
        "rating INTEGER, "
        "notes TEXT"
        ")");
  }
}