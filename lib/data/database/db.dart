import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

final table = 'History';
final secondTable = 'Bookmarks';
final columnId = 'id';
final columnUrl = 'url';
final columnTitle = 'title';
final columnDate = 'date';
final columnImage = 'image';

class DatabaseProvider {
  static final DatabaseProvider dbProvider = DatabaseProvider();
  Database? _database;
  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await createDatabase();
    return _database;
  }

  createDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    //"ReactiveTodo.db is our database instance name
    String path = join(documentsDirectory.path, "ReactiveDB.db");
    var database = await openDatabase(path,
        version: 1, onCreate: initDB, onUpgrade: onUpgrade);
    return database;
  }

  //This is optional, and only used for changing DB schema migrations
  void onUpgrade(Database database, int oldVersion, int newVersion) {
    if (newVersion > oldVersion) {}
  }

  void initDB(Database database, int version) async {
    await database.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnTitle TEXT NOT NULL,
            $columnUrl TEXT NOT NULL,
            $columnDate INTEGER NOT NULL,
            $columnImage BLOB
          )
          ''');
    await database.execute('''
          CREATE TABLE $secondTable (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnTitle TEXT NOT NULL,
            $columnUrl TEXT NOT NULL,
            $columnDate INTEGER NOT NULL,
            $columnImage BLOB
          )
          ''');
  }
}
