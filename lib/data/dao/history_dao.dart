import 'dart:async';
import 'package:browserr/data/database/historydb.dart';
import 'package:browserr/domain/model/history.dart';

class HistoryDao {
  final dbProvider = DatabaseProvider.dbProvider;

  //Adds new Todo records
  Future<int> createItem(History item) async {
    final db = await dbProvider.database;
    var result = db!.insert(table, item.toJson());
    return result;
  }

  //Get All Todo items
  //Searches if query string was passed
  Future<List<History>> getItems({List<String>? columns, String? query}) async {
    final db = await dbProvider.database;

    late List<Map<String, dynamic>> result;
    if (query != null) {
      if (query.isNotEmpty)
        result = await db!.query(table,
            columns: columns,
            where: 'date LIKE ?',
            whereArgs: ["%$query%"]);
    } else {
      result = await db!.query(table, columns: columns);
    }

    List<History> items = result.isNotEmpty
        ? result.map((item) => History.fromJson(item)).toList()
        : [];
    return items;
  }

  Future<int> queryRowCount(int rowID) async {
    final db = await dbProvider.database;
    //return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $table WHERE id LIKE %?%') [rowID]);
    var res = await db!
        .rawQuery("SELECT * FROM $table WHERE id LIKE '%$rowID%'");
    return res.isNotEmpty ? 1 : 0;
  }

  //Delete Todo records
  Future<int> deleteItem(int id) async {
    final db = await dbProvider.database;
    var result =
    await db!.delete(table, where: 'id = ?', whereArgs: [id]);

    return result;
  }

  //We are not going to use this in the demo
  Future deleteAllItems() async {
    final db = await dbProvider.database;
    var result = await db!.delete(
      table,
    );

    return result;
  }
}
