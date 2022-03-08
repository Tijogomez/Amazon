import 'package:amazon/db/Tasks.dart';
import 'package:amazon/db/log.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AmazonDatabase {
  static final AmazonDatabase instance = AmazonDatabase._init();

  AmazonDatabase._init();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDb("amazon.db");
    return _database!;
  }

  Future<Database> _initDb(String dbName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbName);

    return await openDatabase(path, version: 1, onCreate: _createDb);
  }

  Future _createDb(Database db, int version) async {
    await db.execute('''
    CREATE TABLE USERS(
            username TEXT NOT NULL PRIMARY KEY,
            password TEXT NOT NULL,
            email TEXT)
            ''');

    await db.execute('''
    CREATE TABLE $TasksTableName(
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      status TEXT NOT NULL,
      createdDate INTEGER NOT NULL,
      completeBeforeDate INTEGER NOT NULL,
      images TEXT,
      pin INTEGER NOT NULL,
      description TEXT,
      latitude REAL,
      longitude REAL )
    ''');

    await db.execute('''
    CREATE TABLE $LogTableName(
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      username TEXT NOT NULL,
      event TEXT NOT NULL,
      date INTEGER NOT NULL,
      name TEXT NOT NULL )
    ''');
  }

  Future closeDb() async {
    final db = await instance.database;
    db.close();
  }
}
