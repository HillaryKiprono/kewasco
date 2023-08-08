// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:intl/intl.dart';
// import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';
//
// class EditFieldActivityScreen extends StatefulWidget {
//   final Map<String, dynamic> activity;
//
//   EditFieldActivityScreen({required this.activity});
//
//   @override
//   _EditFieldActivityScreenState createState() => _EditFieldActivityScreenState();
// }
//
// class _EditFieldActivityScreenState extends State<EditFieldActivityScreen> {
//   TextEditingController categoryController = TextEditingController();
//   TextEditingController assetController = TextEditingController();
//   TextEditingController activityController = TextEditingController();
//   TextEditingController workerController = TextEditingController();
//   TextEditingController statusController = TextEditingController();
//   TextEditingController timeController = TextEditingController(
//     text: DateFormat('HH:mm:ss').format(DateTime.now()),
//   );
//   TextEditingController dateController = TextEditingController(
//     text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
//   );
//
//
//   String? selectedCategory;
//   String? selectedAsset;
//   String? selectedActivity;
//   String? selectedWorker;
//   String? selectedStatus;
//
//
//   // @override
//   // void initState() {
//   //   super.initState();
//   //   // Set the initial values of the text fields based on the selected field activity
//   //   categoryController.text = widget.activity['CategoryName'];
//   //   assetController.text = widget.activity['AssetName'];
//   //   activityController.text = widget.activity['ActivityName'];
//   //   workerController.text = widget.activity['WorkerName'];
//   //   statusController.text = widget.activity['Status'];
//   // }
//
//
//   @override
//   void initState() {
//     super.initState();
//     // Initialize the selected values based on the selected field activity
//       // Set the initial values of the text fields based on the selected field activity
//       categoryController.text = widget.activity['CategoryName'];
//       assetController.text = widget.activity['AssetName'];
//       activityController.text = widget.activity['ActivityName'];
//       workerController.text = widget.activity['WorkerName'];
//       statusController.text = widget.activity['Status'];
//
//     // Set the initial values of Date and Time fields
//     // dateController.text = widget.activity['Date'];
//     // timeController.text = widget.activity['Time'];
//
//     // Fetch the default values from the database based on the activity ID
//     _fetchDefaultValues();
//   }
//
//   // Fetch default values from the database and update the dropdown menus
//   Future<void> _fetchDefaultValues() async {
//     final dbHelper = DatabaseHelper.instance;
//
//     // Fetch the default values from the database using the activity ID
//     final Map<String, dynamic> fieldActivity =
//     await dbHelper.queryFieldActivityById(widget.activity['id']);
//
//     // Update the selected values of the dropdown menus based on the fetched values
//     setState(() {
//       selectedCategory = fieldActivity['CategoryName'];
//       selectedAsset = fieldActivity['AssetName'];
//       selectedActivity = fieldActivity['ActivityName'];
//       selectedWorker = fieldActivity['WorkerName'];
//       selectedStatus = fieldActivity['Status'];
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Edit Field Activity"),
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             TextField(
//               controller: categoryController,
//               decoration: InputDecoration(labelText: 'Category Name'),
//             ),
//             TextField(
//               controller: assetController,
//               decoration: InputDecoration(labelText: 'Asset Name'),
//             ),
//             TextField(
//               controller: activityController,
//               decoration: InputDecoration(labelText: 'Activity Name'),
//             ),
//             TextField(
//               controller: workerController,
//               decoration: InputDecoration(labelText: 'Worker Name'),
//             ),
//             TextField(
//               controller: statusController,
//               decoration: InputDecoration(labelText: 'Status'),
//             ),
//             //************Date by default***************//
//             TextField(
//               controller: dateController,
//               decoration: InputDecoration(labelText: 'Status'),
//             ),
//             TextField(
//               controller: timeController,
//               decoration: InputDecoration(labelText: 'Status'),
//             ),
//
//
//             // Padding(
//             //   padding: const EdgeInsets.only(left: 40.0, right: 40.0),
//             //   child: TextFormField(
//             //     controller: dateController,
//             //     decoration: InputDecoration(
//             //       labelText: 'Date Done',
//             //       enabled: false,
//             //       border: OutlineInputBorder(
//             //         borderRadius: BorderRadius.circular(20),
//             //       ),
//             //     ),
//             //   ),
//             // ),
//             // const SizedBox(height: 15.0,),
//             // //*****************Time Default**********************//
//             // Padding(
//             //   padding: const EdgeInsets.only(left: 40.0, right: 40.0),
//             //   child: TextFormField(
//             //     controller: timeController,
//             //     decoration: InputDecoration(
//             //       labelText: 'Time of the day',
//             //       enabled: false,
//             //       border: OutlineInputBorder(
//             //         borderRadius: BorderRadius.circular(20),
//             //       ),
//             //     ),
//             //   ),
//             // ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () {
//                 // Save the edited field activity
//                 _saveEditedActivity();
//               },
//               child: Text('Update Now'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _saveEditedActivity() async {
//     // Get the updated values from the text fields
//     String updatedCategory = categoryController.text;
//     String updatedAsset = assetController.text;
//     String updatedActivity = activityController.text;
//     String updatedWorker = workerController.text;
//     String updatedStatus = statusController.text;
//
//     // Check if any of the fields is empty
//     if (updatedCategory.isEmpty ||
//         updatedAsset.isEmpty ||
//         updatedActivity.isEmpty ||
//         updatedWorker.isEmpty ||
//         updatedStatus.isEmpty) {
//       Fluttertoast.showToast(msg: "Please fill in all fields.");
//       return;
//     }
//
//     // Update the field activity in the database
//     final dbHelper = DatabaseHelper.instance;
//     await dbHelper.updateFieldActivity(
//       widget.activity['id'],
//       updatedCategory,
//       updatedAsset,
//       updatedActivity,
//       updatedWorker,
//       updatedStatus,
//     );
//
//     // Show a success message or perform any other actions after saving the edited activity
//     Fluttertoast.showToast(msg: "Activity updated successfully");
//
//     // Close the edit screen and go back to the previous screen
//     Navigator.pop(context as BuildContext);
//   }
// }
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
//   DatabaseHelper();
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
//     CREATE TABLE $_tblData(
//     id INTEGER PRIMARY KEY AUTOINCREMENT,
//     CategoryName TEXT,
//     AssetName TEXT,
//     ActivityName TEXT
//     )''');
//     await db.execute('''
//     CREATE TABLE $_fieldActivity (
//       id INTEGER PRIMARY KEY AUTOINCREMENT,
//       CategoryName TEXT,
//       AssetName TEXT,
//       ActivityName TEXT,
//       WorkerName TEXT,
//       Date TEXT,
//       Time TEXT,
//       Status TEXT
//     )
//   ''');
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
//     return await db.query(
//         'tblData', where: 'AssetName = ?', whereArgs: [assetName]);
//   }
//
//   Future<List<Map<String, dynamic>>> queryAssets(String categoryName) async {
//     final db = await database;
//     return await db.query(
//         'tblData', where: 'CategoryName = ?', whereArgs: [categoryName]);
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
//
//   // Method to fetch a specific field activity by its ID from the database
//   Future<Map<String, dynamic>> queryFieldActivityById(int id) async {
//     final db = await instance.database;
//     final List<Map<String, dynamic>> results = await db.query(
//       _fieldActivity,
//       where: 'id = ?',
//       whereArgs: [id],
//       limit: 1,
//     );
//
//     if (results.isNotEmpty) {
//       return results.first;
//     } else {
//       return Map<String, dynamic>();
//     }
//   }
//
//   // Method to update the field activity in the table using an id
//   Future<int> updateFieldActivity(int id,
//       String updatedCategory,
//       String updatedAsset,
//       String updatedActivity,
//       String updatedWorker,
//       String updatedStatus,) async {
//     final db = await instance.database;
//     return await db.update(
//       _fieldActivity,
//       {
//         'CategoryName': updatedCategory,
//         'AssetName': updatedAsset,
//         'ActivityName': updatedActivity,
//         'WorkerName': updatedWorker,
//         'Status': updatedStatus,
//       },
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//   }
// }
