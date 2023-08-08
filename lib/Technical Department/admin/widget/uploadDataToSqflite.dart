import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../../config.dart';
import '../../dbHelperClass/databaseHelper.dart';


class UploadDataToSqflite extends StatefulWidget {
  const UploadDataToSqflite({Key? key}) : super(key: key);

  @override
  State<UploadDataToSqflite> createState() => _UploadDataToSqfliteState();
}

class _UploadDataToSqfliteState extends State<UploadDataToSqflite> {

  Future<void> fetchDataStoreInDatabase() async {
    const url1 =
        'http://${Config.ipAddress}/Maintenance_Activity_API/modules/fetchData.php';
    const url2 =
        'http://${Config.ipAddress}/Maintenance_Activity_API/modules/fetchWorker.php';
    const url3 =
        'http://${Config.ipAddress}/Maintenance_Activity_API/modules/fetchLogins.php';

    try {
      final response1 = await http.get(Uri.parse(url1));
      final response2 = await http.get(Uri.parse(url2));
      final response3 = await http.get(Uri.parse(url3));
      if (response1.statusCode == 200 &&
          response2.statusCode == 200 &&
          response3.statusCode == 200) {
        final data1 = jsonDecode(response1.body);
        final data2 = jsonDecode(response2.body);
        final data3 = jsonDecode(response3.body);

        await DatabaseHelper.instance.clearTables();

        for (var item in data3) {
          final row3 = {
            'id': item['id'],
            'username': item['username'],
            'password': item['password'],
            'role': item['role']
          };
          await DatabaseHelper.instance.insertLogins(row3);
        }

        for (var item2 in data2) {
          final row2 = {
            'id': item2['id'],
            'workerName': item2['workerName']
          };
          await DatabaseHelper.instance.insertWorkers(row2);
        }

        for(var item1 in data1){
          final row1={
            'id': item1['id'],
            'CategoryName':item1['CategoryName'],
            'AssetName':item1['AssetName'],
            'ActivityName':item1['ActivityName'],
          };
          await DatabaseHelper.instance.insertData(row1);
        }

        Fluttertoast.showToast(msg: "Uploaded successfully");
      } else {
        Fluttertoast.showToast(msg: "Failed to connect");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<List<Map<String, dynamic>>> fetchStoredLoginsDataFromDatabase() async {
    final List<Map<String, dynamic>> storedLoginsData =
    await DatabaseHelper.instance.queryLoginsData();
    return storedLoginsData;
  }

  Future<List<Map<String, dynamic>>> fetchStoredWorkersFromDatabase() async {
    final List<Map<String, dynamic>> storedWorkerData =
    await DatabaseHelper.instance.queryWorkers();
    return storedWorkerData;
  }


  Future<List<Map<String, dynamic>>> fetchStoredDataFromDatabase() async {
    final List<Map<String, dynamic>> storedDataActivity =
    await DatabaseHelper.instance.queryData();
    return storedDataActivity;
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fetch and store data to phone"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: fetchDataStoreInDatabase,
              child: const Text("Upload login to phone"),
            ),
            ElevatedButton(
              onPressed: () async {
                final storedData = await fetchStoredLoginsDataFromDatabase();
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Stored Logins"),
                      content: SizedBox(
                        height: 200,
                        child: ListView.builder(
                          itemCount: storedData.length,
                          itemBuilder: (BuildContext context, int index) {
                            final data = storedData[index];
                            return ListTile(
                              title: Text("UserName: ${data['username']}"),
                              subtitle: Text("Password : ${data['password']}"),
                            );
                          },
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text("Close"),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text("Display Stored Logins"),
            ),


            ElevatedButton(
              onPressed: () async {
                final storedWorkerData = await fetchStoredWorkersFromDatabase();
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Stored Worker Data"),
                      content: SizedBox(
                        height: 200,
                        child: ListView.builder(
                          itemCount: storedWorkerData.length,
                          itemBuilder: (BuildContext context, int index) {
                            final data = storedWorkerData[index];
                            return ListTile(
                              title: Text("WorkerName: ${data['workerName']}"),
                            );
                          },
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text("Close"),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text("Display Workers Stored"),
            ),


            ElevatedButton(
              onPressed: () async {
                final storedActivityData = await fetchStoredDataFromDatabase();
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Stored Data Activity"),
                      content: SizedBox(
                        height: 200,
                        child: ListView.builder(
                          itemCount: storedActivityData.length,
                          itemBuilder: (BuildContext context, int index) {
                            final data = storedActivityData[index];
                            return ListTile(
                              title: Text("CategoryName: ${data['CategoryName']}"),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("AssetName: ${data['AssetName']}"),
                                  Text("ActivityName: ${data['ActivityName']}"),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text("Close"),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text("Display Activity Stored"),
            ),

          ],
        ),
      ),
    );
  }
}

// class DatabaseHelper {
//   static const _databaseName = "maintenance.db";
//   static const _tblLogin = "tblLogin";
//   static const tblWorker = "tblWorker";
//   static const _tblData = 'tblData';
//   static const _fieldActivity = "fieldActivities_tbl";
//   static const _databaseVersion = 1;
//
//   DatabaseHelper._privateConstructor();
//
//   static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
//
//   static Database? _database;
//
//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDatabase();
//     return _database!;
//   }
//
//   Future<Database> _initDatabase() async {
//     String path = join(await getDatabasesPath(), _databaseName);
//     final dbOpen = await openDatabase(
//       path,
//       version: _databaseVersion,
//       onCreate: _onCreate,
//     );
//     return dbOpen;
//   }
//
//   Future<void> _onCreate(Database db, int version) async {
//     await db.execute('''
//       CREATE TABLE $_tblLogin (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         username TEXT,
//         password TEXT,
//         role TEXT
//       )
//     ''');
//
//     await db.execute('''
//       CREATE TABLE $tblWorker (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         workerName TEXT
//       )
//     ''');
//
//     await db.execute('''
//       CREATE TABLE $_tblData (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         CategoryName TEXT,
//         AssetName TEXT,
//         ActivityName TEXT
//       )
//     ''');
//
//     await db.execute('''
//       CREATE TABLE $_fieldActivity (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         CategoryName TEXT,
//         AssetName TEXT,
//         ActivityName TEXT,
//         WorkerName TEXT,
//         Date TEXT,
//         Time TEXT,
//         Status TEXT
//       )
//     ''');
//   }
//
//   Future<void> clearTables() async {
//     Database db = await instance.database;
//     await db.delete(_tblLogin);
//     await db.delete(tblWorker);
//     await db.delete(_tblData);
//   }
//
//   Future<int> insertLogins(Map<String, dynamic> row) async {
//     Database db = await instance.database;
//     return await db.insert(_tblLogin, row);
//   }
//
//   Future<int> insertWorkers(Map<String, dynamic> row) async {
//     Database db = await instance.database;
//     return await db.insert(tblWorker, row);
//   }
//
//   Future<int> insertData(Map<String, dynamic> row) async {
//     Database db = await instance.database;
//     return await db.insert(_tblData, row);
//   }
//
//   Future<int> insertFieldActivities(Map<String, dynamic> row) async {
//     Database db = await instance.database;
//     return await db.insert(_fieldActivity, row);
//   }
//
//   Future<List<Map<String, dynamic>>> queryWorkers() async {
//     Database db = await instance.database;
//     return await db.query(tblWorker);
//   }
//
//   Future<List<Map<String, dynamic>>> queryLoginsData() async {
//     Database db = await instance.database;
//     return await db.query(_tblLogin);
//   }
//
//   Future<List<Map<String, dynamic>>> queryData() async {
//     Database db = await instance.database;
//     return await db.query(_tblData);
//   }
//
//   Future<List<Map<String, dynamic>>> queryActivities(String assetName) async {
//     final db = await instance.database;
//     return await db
//         .query('tblData', where: 'AssetName = ?', whereArgs: [assetName]);
//   }
//
//   Future<List<Map<String, dynamic>>> queryAssets(String categoryName) async {
//     final db = await database;
//     return await db
//         .query('tblData', where: 'CategoryName = ?', whereArgs: [categoryName]);
//   }
//
//   Future<List<Map<String, dynamic>>> queryWorkersName() async {
//     final db = await instance.database;
//     return await db.query(tblWorker);
//   }
//
//   // Method to fetch stored field activity data from the database
//   Future<List<Map<String, dynamic>>> queryFieldActivities() async {
//     final db = await instance.database;
//     return await db.query(_fieldActivity);
//   }
//
//   //Method to delete the fieldActivity in the table  using an id
//
//   Future<int> deleteFieldActivity(int id) async {
//     final db = await instance.database;
//     return await db.delete(
//       _fieldActivity,
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//   }
// }