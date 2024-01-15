import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'fetchTaskModel.dart';
import 'jobcard.dart';

class DatabaseHelper {
  Database? _database;
  final String _tblJobCard = 'job_cards';
  static const _tblTask = "tblTask";
  static const _databaseName = "kewasco.db";
  static const _tblWorker = "tblWorker";
  static const teamLeadersTbl = "teamLeadersTbl";

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    final path = await getDatabasesPath();
    return openDatabase(
      join(path, _databaseName),
      onCreate: (db, version) async {
        print('Creating tables: $_tblTask');
        print('Creating tables: $_tblWorker');
        print('Creating tables: $_tblJobCard');
        await db.execute(
          'CREATE TABLE $_tblTask(id INTEGER PRIMARY KEY AUTOINCREMENT, taskName TEXT)',
        );
        await db.execute('''
  CREATE TABLE job_cards(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    accountNo TEXT,
    dateStarted TEXT,
    timeStarted TEXT,
    department TEXT,
    section TEXT,
    selectedTaskName TEXT,
    workLocation TEXT,
    northings TEXT,
    eastings TEXT,
    workStatus TEXT,
    dateCompleted TEXT,
    timeCompleted TEXT,
    workDescription TEXT,
    material TEXT,
    username TEXT,
    assignedWorker TEXT
  )
''');

        await db.execute('''
      CREATE TABLE $_tblWorker (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        workerName TEXT
      )
    ''');

        await db.execute('''
      CREATE TABLE ${teamLeadersTbl} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        teamLeaderName TEXT,
        userRole TEXT,
        password TEXT
      )
    ''');
      },
      version: 1,
    );
  }

  Future<void> insertJobCard(JobCard jobCard) async {
    final db = await database;
    try {
      await db.insert(
        'job_cards',
        jobCard.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      // print('Job card inserted successfully with ID: ${jobCard.id}');
      print('Inserted data:');
      print('Account Number: ${jobCard.accountNo}');
      print('Start Date: ${jobCard.dateStarted}');
      print('Task: ${jobCard.selectedTaskName}');
      print('Worker: ${jobCard.assignedWorker}');
      print('timeStarted: ${jobCard.timeStarted}');
      print('dateCompleted: ${jobCard.dateCompleted}');
      print('timeCompleted: ${jobCard.timeCompleted}');

      print('username: ${jobCard.username}');
    } catch (e) {
      print('Error inserting job card: $e');
      print('Data being inserted: ${jobCard.toMap()}');
    }
  }

  Future<int> insertTask(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert(_tblTask, row);
  }

  Future<int> insertTeamLeader(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert(teamLeadersTbl, row);
  }

  Future<List<Map<String, dynamic>>> queryAllTeamLeaders() async {
    Database db = await database;
    return await db.query(teamLeadersTbl);
  }

  Future<bool> authenticateUser(String username, String password) async {
    final db = await database;

    List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT * FROM $teamLeadersTbl
      WHERE teamLeaderName = ? AND password = ?
    ''', [username, password]);

    return results.isNotEmpty;
  }

  Future<int> insertWorker(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert(_tblWorker, row);
  }

  Future<List<Map<String, dynamic>>> queryAllWorkers() async {
    Database db = await database;
    return await db.query(_tblWorker);
  }

  Future<List<Map<String, dynamic>>> queryAllTask() async {
    Database db = await database;
    return await db.query(_tblTask);
  }

  Future<List<Map<String, dynamic>>> queryAllJobCard() async {
    final db = await database;
    return await db.query('job_cards');
  }

  Future<void> clearTables() async {
    Database db = await database;
    await db.delete('job_cards');
    await db.delete(_tblTask);
    await db.delete(_tblWorker);
    await db.delete(teamLeadersTbl);
  }

  Future<String?> getUserRole(String username) async {
    try {
      Database db = await database;
      List<Map<String, dynamic>> result = await db.query(
        teamLeadersTbl,
        columns: ['userRole'],
        where: 'teamLeaderName = ?',
        whereArgs: [username],
      );

      if (result.isNotEmpty) {
        return result[0]['userRole'] as String?;
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching user role: $e');
      return null;
    }
  }
}
