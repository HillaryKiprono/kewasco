import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:kewasco/Technical%20Department/user/showInsertedActivity.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;
import '../api_endpoints/api_connections.dart';
import '../dbHelperClass/databaseHelper.dart';

class UserDashboard extends StatefulWidget {
  @override
  _UserDashboardState createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  // bool showHiddenInput = false; // Add this line
  TextEditingController reasons = TextEditingController();
  bool syncing = false;
  double syncProgress = 0.0;
  String? selectedCategory;
  String? selectedAsset;
  String? selectedActivity;
  String? selectedWorker;
  String? selectedStatus;
  String? selectedComments;



  final List<String> statusSelection = ['Done', 'Incomplete'];
  final List<String> commentsSelection = [
    "Completed",
    "No Materials",
    "Climatic factors",
    "Other"
  ];
  List<Map<String, dynamic>> data = [];
  List<Map<String, dynamic>> workerData = [];
  List<String> categories = [];
  List<String> assets = [];
  List<String> activities = [];
  List<String> workers = [];
  List<String> savedActivities = [];
  List<String> selectedActivities = [];
  List<String> showInsertedActivity = [];

  Future<void> fetchData() async {
    if (categories.isEmpty) {
      final dbHelper = DatabaseHelper.instance;

      final List<Map<String, dynamic>> categoryData =
          await dbHelper.queryData();
      final List<String> fetchedCategories = categoryData
          .map((record) => record['CategoryName'] as String)
          .toSet()
          .toList(); // Using a Set to remove duplicates

      setState(() {
        categories = fetchedCategories;
      });
    }
  }

  Future<void> fetchAssets() async {
    final dbHelper = DatabaseHelper.instance;

    if (selectedCategory != null) {
      final List<Map<String, dynamic>> assetData =
          await dbHelper.queryAssets(selectedCategory!);
      final Set<String> fetchedAssets = Set<String>.from(
          assetData.map((record) => record['AssetName'] as String));

      setState(() {
        assets = fetchedAssets.toList();
      });
    }
  }

  // Future<void> fetchAssets() async {
  //   final dbHelper = DatabaseHelper.instance;
  //   if (selectedCategory != null) {
  //     final List<Map<String, dynamic>> assetData =
  //     await dbHelper.queryAssets(selectedCategory!);
  //     final List<String> fetchedAssets =
  //     assetData.map((record) => record['AssetName'] as String).toList();
  //
  //     setState(() {
  //       assets = fetchedAssets;
  //     });
  //   }
  // }

  // Future<void> fetchActivities() async {
  //   final dbHelper = DatabaseHelper.instance;
  //
  //   if (selectedAsset != null) {
  //     final List<Map<String, dynamic>> activityData =
  //     await dbHelper.queryActivities(selectedAsset!);
  //     final List<String> fetchedActivities =
  //     activityData.map((record) => record['ActivityName'] as String).toList();
  //
  //     setState(() {
  //       activities = fetchedActivities;
  //     });
  //   }
  // }

  Future<void> fetchActivities() async {
    final dbHelper = DatabaseHelper.instance;

    if (selectedAsset != null) {
      final List<Map<String, dynamic>> activityData =
          await dbHelper.queryActivities(selectedAsset!);
      final Set<String> fetchedActivities = Set<String>.from(
          activityData.map((record) => record['ActivityName'] as String));

      setState(() {
        activities = fetchedActivities.toList();
      });
    }
  }

  Future<void> fetchWorkerName() async {
    final dbHelper = DatabaseHelper.instance;
    final List<Map<String, dynamic>> workerData = await dbHelper.queryWorkers();
    final List<String> fetchedWorkers =
        workerData.map((record) => record['workerName'] as String).toList();

    setState(() {
      workers = fetchedWorkers;
    });
  }

  Future<void> saveActivity(BuildContext context) async {
    // Check if any of the fields is empty
    if (selectedCategory == null ||
        selectedAsset == null ||
        selectedActivity == null ||
        selectedWorker == null ||
        selectedComments == null ||
        selectedStatus == null) {
      Fluttertoast.showToast(msg: "Please fill in all fields.");
      return;
    }

    // Show an alert dialog to confirm the submission
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Submit Activity"),
          content: Text("Do you want to submit the activity?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                // Close the dialog
                Navigator.of(context).pop();
                // Save the data to the fieldActivities_tbl
                final dbPath = await getDatabasesPath();
                final db = await openDatabase(
                  join(dbPath, 'maintenance.db'),
                  version: 1,
                );
                try {
                  await db.transaction((txn) async {
                    await txn.rawInsert(
                      'INSERT INTO fieldActivities_tbl(CategoryName, AssetName, ActivityName, WorkerName, Status, Date, Time,Comments) VALUES (?, ?, ?, ?, ?, ?, ?,?)',
                      [
                        selectedCategory,
                        selectedAsset,
                        selectedActivity,
                        selectedWorker,
                        selectedStatus,
                        DateFormat('yyyy-MM-dd').format(DateTime.now()),
                        DateFormat('HH:mm:ss').format(DateTime.now()),
                        selectedComments
                      ],
                    );
                  });
                  // Show a success message or perform any other actions
                  Fluttertoast.showToast(msg: "Activity saved successfully");
                } catch (e) {
                  print("Error saving activity: $e");
                  Fluttertoast.showToast(
                      msg: "Failed to save activity. Please try again.");
                }
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<bool> checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      print("Connected to mobile data or Wi-Fi");
      // uploadDataToDatabase();
      syncDataToMySQL();
      // Connected to mobile data or Wi-Fi
      return true;
    } else {
      // Not connected to mobile data or Wi-Fi
      Fluttertoast.showToast(msg: "Please connect to WIFI network");
      return false;
    }
  }

  void syncDataToMySQL() async {
    Database database = await openDatabase(
      join(await getDatabasesPath(), 'maintenance.db'),
    );

    List<Map<String, dynamic>> data = await database.query('_fieldActivity');

    int totalRows = data.length;
    int uploadedRows = 0;

    for (var row in data) {
      http.post(Uri.parse(API.uploadActivity), body: {
        'CategoryName': row['CategoryName'],
        'AssetName': row['AssetName'],
        'ActivityName': row['ActivityName'],
        'WorkerName': row['WorkerName'],
        'Status': row['Status'],
        'Date': row['Date'],
        'Time': row['Time'],
        'Comments': row['Comments'],
      });
      uploadedRows++;
      double percentage = (uploadedRows / totalRows) * 100;
      Fluttertoast.showToast(
          msg:
              "Please be Patient While Uploading data to the Server and ensure you have strong Internet connections Uploading: ${percentage.toStringAsFixed(2)}%");
    }
    // Clear data after successful upload
    await database.delete('fieldActivities_tbl');
  }

  @override
  void initState() {
    super.initState();
    fetchData();
    fetchWorkerName();
  }

  TextEditingController timeController = TextEditingController(
    text: DateFormat('HH:mm:ss').format(DateTime.now()),
  );
  TextEditingController dateController = TextEditingController(
    text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('User Dashboard'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.cloud_upload),
              onPressed: () {
                // uploadDataToDatabase();
                checkConnectivity();
              },
            ),
          ],

        ),
        body: Container(
          margin: const EdgeInsets.only(top: 30.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(width: 2, color: Colors.grey),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedCategory,
                        hint: const Text('Select Category'),
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value;
                            selectedAsset = null;
                            selectedActivity = null;
                            assets = []; // Clear assets when category changes
                          });
                          fetchAssets();
                        },
                        items: categories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                      ),


                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(width: 2, color: Colors.grey),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedAsset,
                        hint: const Text('Select Asset'),
                        onChanged: (value) {
                          setState(() {
                            selectedAsset = value;
                            selectedActivity = null;
                            activities = [];
                          });
                          fetchActivities();
                        },
                        items: assets.map((asset) {
                          return DropdownMenuItem<String>(
                            value: asset,
                            child: Text(asset),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(width: 2, color: Colors.grey),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedActivity,
                        hint: const Text('Select Activity'),
                        onChanged: (value) {
                          setState(() {
                            // Update selected activity
                            selectedActivity = value;
                          });
                        },
                        items: activities.map((activity) {
                          return DropdownMenuItem<String>(
                            value: activity,
                            child: Text(activity),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(width: 2, color: Colors.grey),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedWorker,
                        hint: const Text('Select Worker'),
                        onChanged: (value) {
                          setState(() {
                            // Update selected activity
                            selectedWorker = value;
                          });
                        },
                        items: workers.map((worker) {
                          return DropdownMenuItem<String>(
                            value: worker,
                            child: Text(worker),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(width: 2, color: Colors.grey),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: selectedStatus,
                          hint: const Text('Select Status'),
                          onChanged: (value) {
                            setState(() {
                              selectedStatus = value;
                            });
                          },
                          items: statusSelection.map((status) {
                            return DropdownMenuItem<String>(
                              value: status,
                              child: Text(status),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(width: 2, color: Colors.grey),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: selectedComments,
                          hint: const Text('Select Comments'),
                          onChanged: (value) {
                            setState(() {
                              selectedComments = value;
                            });
                          },
                          items: commentsSelection.map((comments) {
                            return DropdownMenuItem<String>(
                              value: comments,
                              child: Text(comments),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),

                const Divider(
                  height: 4,
                  thickness: 4,
                  color: Colors.blue,
                ),
                const SizedBox(
                  height: 20,
                ),

                //************Date by default***************//
                Padding(
                  padding: const EdgeInsets.only(left: 40.0, right: 40.0),
                  child: TextFormField(
                    controller: dateController,
                    decoration: InputDecoration(
                      labelText: 'Date Done',
                      enabled: false,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15.0,
                ),
                //*****************Time Default**********************//
                Padding(
                  padding: const EdgeInsets.only(left: 40.0, right: 40.0),
                  child: TextFormField(
                    controller: timeController,
                    decoration: InputDecoration(
                      labelText: 'Time of the day',
                      enabled: false,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),

                //****************Submit Button*****************
                const SizedBox(
                  height: 20,
                ),

                ElevatedButton(
                  onPressed: () {
                    saveActivity(context);
                  },
                  child: const Text("Save the Activity"),
                ),
                const SizedBox(
                  height: 20,
                ),

                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FieldActivityTableScreen()),
                    );
                  },
                  child: const Text("Display Stored Field Activities"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
