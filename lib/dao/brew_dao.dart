import 'dart:async';
import 'dart:developer' as developer;

import 'package:coffee_journal/database_helper.dart';
import 'package:coffee_journal/model/brew.dart';

class BrewDao {
  final dbHelper = DatabaseHelper.dbHelper;

  Future<int> createBrew(Brew brew) async {
    developer.log("Creating brew");
    final db = await dbHelper.database;
    var result = db.insert(brewTable, brew.toDatabaseJson());
    return result;
  }

  Future<Brew> getBrewById(int id) async {
    developer.log("Get brew $id");
    final db = await dbHelper.database;
    var result = await db.query(brewTable, where: 'id = ?', whereArgs: [id]);

    return Brew.fromDatabaseJson(result.first);
  }

  Future<Brew> getBrewByRoasterAndBlend(String? roaster, String? blend) async {
    developer.log("Get brew $roaster, $blend");
    final db = await dbHelper.database;
    var result = await db.query(brewTable,
        where: 'roaster = ? AND blend = ?',
        whereArgs: [roaster, blend],
        orderBy: 'time desc'
    );

    return Brew.fromDatabaseJson(result.first);
  }

  //Get All Brew items
  //Searches if query string was passed
  Future<List<Brew>> getBrews({ List<String>? columns, String? query }) async {
    final db = await dbHelper.database;

    List<Map<String, dynamic>> result = List.empty();
    if (query != null) {
      if (query.isNotEmpty)
        result = await db.query(brewTable,
            columns: columns,
            where: 'description LIKE ?',
            whereArgs: ["%$query%"],
            orderBy: 'time desc');
    } else {
      result = await db.query(brewTable, columns: columns, orderBy: 'time desc');
    }

    List<Brew> brews = result.isNotEmpty
        ? result.map((item) => Brew.fromDatabaseJson(item)).toList()
        : [];
    return brews;
  }

  Future<int> updateBrew(Brew brew) async {
    final db = await dbHelper.database;

    var result = await db.update(brewTable, brew.toDatabaseJson(),
        where: "id = ?", whereArgs: [brew.id]);

    return result;
  }

  Future<int> deleteBrew(int id) async {
    developer.log("Deleting brew $id");
    final db = await dbHelper.database;
    var result = await db.delete(brewTable, where: 'id = ?', whereArgs: [id]);

    return result;
  }
}