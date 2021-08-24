import 'dart:async';
import 'package:browserr/data/database/db.dart';
import 'package:browserr/domain/model/bookmark.dart';
import 'package:browserr/domain/model/history.dart';

class DaoOfDB {
  final dbProvider = DatabaseProvider.dbProvider;

  //Adds new Todo records
  Future<int> createHistoryItem(History item) async {
    final db = await dbProvider.database;
    var result = db!.insert(table, item.toJson());
    return result;
  }

  Future<int> createBookmarkItem(Bookmark item) async {
    final db = await dbProvider.database;
    var result = db!.insert(secondTable, item.toJson());
    return result;
  }

  //Get All Todo items
  //Searches if query string was passed
  Future<List<History>> getHistoryItems({List<String>? columns, String? query}) async {
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

  Future<List<Bookmark>> getBookmarksItems({List<String>? columns, String? query}) async {
    final db = await dbProvider.database;

    late List<Map<String, dynamic>> result;
    if (query != null) {
      if (query.isNotEmpty)
        result = await db!.query(secondTable,
            columns: columns,
            where: 'date LIKE ?',
            whereArgs: ["%$query%"]);
    } else {
      result = await db!.query(secondTable, columns: columns);
    }

    List<Bookmark> items = result.isNotEmpty
        ? result.map((item) => Bookmark.fromJson(item)).toList()
        : [];
    return items;
  }

  Future<int> queryHistoryRowCount(int rowID) async {
    final db = await dbProvider.database;
    //return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $table WHERE id LIKE %?%') [rowID]);
    var res = await db!
        .rawQuery("SELECT * FROM $table WHERE id LIKE '%$rowID%'");
    return res.isNotEmpty ? 1 : 0;
  }

  Future<int> queryBookmarksRowCount(String url) async {
    final db = await dbProvider.database;
    //return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $table WHERE id LIKE %?%') [rowID]);
    var res = await db!.rawQuery("SELECT * FROM $secondTable WHERE url LIKE '%$url%'");
    return res.isNotEmpty ? 1 : 0;
  }

  //Delete Todo records
  Future<int> deleteHistoryItem(int id) async {
    final db = await dbProvider.database;
    var result = await db!.delete(table, where: 'id = ?', whereArgs: [id]);

    return result;
  }

  Future<int> deleteBookmarksItem(String url) async {
    final db = await dbProvider.database;
    var result = await db!.delete(secondTable, where: 'url = ?', whereArgs: [url]);
    return result;
  }

  Future deleteAllBookmarksItems() async {
    final db = await dbProvider.database;
    var result = await db!.delete(
      secondTable,
    );
    //DELETE FROM SQLITE_SEQUENCE WHERE NAME = '" + TABLE_NAME + "'"
    await db.rawQuery("DELETE FROM SQLITE_SEQUENCE WHERE NAME = 'Bookmarks'");
    return result;
  }

  //We are not going to use this in the demo
  Future deleteAllHistoryItems() async {
    final db = await dbProvider.database;
    //final table = 'History';
    var result = await db!.delete(
      table,
    );
    //DELETE FROM SQLITE_SEQUENCE WHERE NAME = '" + TABLE_NAME + "'"
    await db.rawQuery("DELETE FROM SQLITE_SEQUENCE WHERE NAME = 'History'");
    return result;
  }
}
