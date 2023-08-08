import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const _databaseName = "maintenance.db";
  static const _tblLogin = "tblLogin";
  static const tblWorker = "tblWorker";
  static const _tblData = 'tblData';
  static const _fieldActivity = "fieldActivities_tbl";
  static const _databaseVersion = 1;

  DatabaseHelper._privateConstructor();

  DatabaseHelper();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    final dbOpen = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
    return dbOpen;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tblLogin (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT,
        password TEXT,
        role TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE $tblWorker (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        workerName TEXT
      )
    ''');

    await db.execute('''
    CREATE TABLE $_tblData(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    CategoryName TEXT,
    AssetName TEXT,
    ActivityName TEXT
    )''');
    await db.execute('''
    CREATE TABLE fieldActivities_tbl (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      CategoryName TEXT,
      AssetName TEXT,
      ActivityName TEXT,
      WorkerName TEXT,
      Date TEXT,
      Time TEXT,
      Status TEXT,
      Comments TEXT
    )
  ''');
  }

  Future<void> clearTables() async {
    Database db = await instance.database;
    await db.delete(_tblLogin);
    await db.delete(tblWorker);
    await db.delete(_tblData);
  }

  Future<int> insertLogins(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(_tblLogin, row);
  }

  Future<int> insertWorkers(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(tblWorker, row);
  }

  Future<int> insertData(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(_tblData, row);
  }

  Future<int> insertFieldActivities(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(_fieldActivity, row);
  }

  Future<List<Map<String, dynamic>>> queryWorkers() async {
    Database db = await instance.database;
    return await db.query(tblWorker);
  }

  Future<List<Map<String, dynamic>>> queryLoginsData() async {
    Database db = await instance.database;
    return await db.query(_tblLogin);
  }

  Future<List<Map<String, dynamic>>> queryData() async {
    Database db = await instance.database;
    return await db.query(_tblData);
  }

  Future<List<Map<String, dynamic>>> queryActivities(String assetName) async {
    final db = await instance.database;
    return await db.query(
        'tblData', where: 'AssetName = ?', whereArgs: [assetName]);
  }

  // Future<List<Map<String, dynamic>>> queryAssets(String categoryName) async {
  //   final db = await database;
  //   return await db.query(
  //       'tblData', where: 'CategoryName = ?', whereArgs: [categoryName]);
  // }

  Future<List<Map<String, dynamic>>> queryAssets(String categoryName) async {
    final db = await database;
    return await db.query(
        'tblData', where: 'CategoryName = ?', whereArgs: [categoryName]);
  }


  Future<List<Map<String, dynamic>>> queryWorkersName() async {
    final db = await instance.database;
    return await db.query(tblWorker);
  }

  // Method to fetch stored field activity data from the database
  Future<List<Map<String, dynamic>>> queryFieldActivities() async {
    final db = await instance.database;
    return await db.query(_fieldActivity);
  }

  //Method to delete the fieldActivity in the table  using an id

  Future<int> deleteFieldActivity(int id) async {
    final db = await instance.database;
    return await db.delete(
      _fieldActivity,
      where: 'id = ?',
      whereArgs: [id],
    );
  }




}