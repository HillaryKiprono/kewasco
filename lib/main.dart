import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:kewasco/user/models/dbHelper.dart';
import 'package:kewasco/views/loginDesktop.dart';
import 'package:kewasco/views/login_view.dart';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import 'dart:io' as io;

import 'Technical Department/api_endpoints/api_connections.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> checkOperating() async {
    if (io.Platform.isAndroid) {
      checkDataInDatabase();
      print('Operating System: Android');
    } else if (io.Platform.isIOS) {
      // Code to execute if the operating system is iOS
      print('Operating System: iOS');
    } else if (io.Platform.isWindows) {
      LoginDesktop();
      // Code to execute if the operating system is Windows
      print('Operating System: Windows');
    } else if (io.Platform.isLinux) {
      LoginDesktop();
      // Code to execute if the operating system is Linux
      print('Operating System: Linux');
    } else if (io.Platform.isMacOS) {
      // Code to execute if the operating system is macOS
      print('Operating System: macOS');
    } else {
      // Code to execute for other or unknown operating systems
      print('Operating System: Unknown');
    }
  }

  final dbHelper = DatabaseHelper();

  Future<void> fetchTaskFromServer() async {
    try {
      final response1 = await http.get(Uri.parse(API.fetchAllTask));

      if (response1.statusCode == 200) {
        print("Communicating to server correctly");

        final dynamic responseData1 = jsonDecode(response1.body);
        print("Response Data from server: $responseData1");

        if (responseData1 is Map<String, dynamic> &&
            responseData1.containsKey('data')) {
          final dynamic data1 = responseData1['data'];

          await dbHelper.clearTables();

          if (data1 is List) {
            for (var item1 in data1) {
              if (item1 is Map<String, dynamic> &&
                  item1.containsKey('taskName')) {
                final row1 = {
                  'taskName': item1['taskName'],
                };
                await dbHelper.insertTask(row1);
                final List<Map<String, dynamic>> storedTask =
                await dbHelper.queryAllTask();
                print(
                    "***************************** storedTask $storedTask");
              }
            }
          } else {
            print("Invalid data structure for 'data' field: $data1");
          }
        } else {
          print("Invalid data structure: $responseData1");
        }
      } else {
        print("Failed to connect");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> fetchWorkersFromServer() async {
    try {
      final response2 = await http.get(Uri.parse(API.fetchAllWorkers));

      if (response2.statusCode == 200) {
        print("Communicating to server correctly");

        final dynamic responseData2 = jsonDecode(response2.body);
        print("Response Data from server: $responseData2");

        if (responseData2 is Map<String, dynamic> &&
            responseData2.containsKey('data')) {
          final dynamic data2 = responseData2['data'];
          print("Worker data *********************$data2****************");

          await dbHelper.clearTables();

          if (data2 is List) {
            for (var item2 in data2) {
              if (item2 is Map<String, dynamic> &&
                  item2.containsKey('workerName')) {
                final row1 = {
                  'workerName': item2['workerName'],
                };
                await dbHelper.insertWorker(row1);
                final List<Map<String, dynamic>> storedWorker =
                await dbHelper.queryAllWorkers();
                print(
                    "***************************** storedWorker $storedWorker");
              }
            }
          } else {
            print("Invalid data structure for 'data' field: $data2");
          }
        } else {
          print("Invalid data structure: $responseData2");
        }
      } else {
        print("Failed to connect");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> fetchTeamLeadersFromServer() async {
    try {
      final response2 = await http.get(Uri.parse(API.fetchAllTeamLeaders));

      if (response2.statusCode == 200) {
        print("Communicating to server correctly");

        final dynamic responseData2 = jsonDecode(response2.body);
        print("Team Leaders Response  from server: $responseData2");

        if (responseData2 is Map<String, dynamic> &&
            responseData2.containsKey('data')) {
          final dynamic data2 = responseData2['data'];

          await dbHelper.clearTables();

          if (data2 is List) {
            for (var item2 in data2) {
              if (item2 is Map<String, dynamic> &&
                  item2.containsKey('teamLeaderName') &&
                  item2.containsKey("password") &&
                  item2.containsKey("userRole")) {
                final row1 = {
                  'teamLeaderName': item2['teamLeaderName'],
                  'userRole': item2['userRole'],
                  'password': item2['password'],
                };
                await dbHelper.insertTeamLeader(row1);
                final List<Map<String, dynamic>> storedTeamLeader =
                await dbHelper.queryAllTeamLeaders();
                print(
                    "*****************************StoredLeaders $storedTeamLeader");
              }
            }
          } else {
            print("Invalid data structure for 'data' field: $data2");
          }
        } else {
          print("Invalid data structure: $responseData2");
        }
      } else {
        print("Failed to connect");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  bool hasData = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      checkOperating();
      checkDataInDatabase();
    });
  }


  Future<bool> tableExists(Database database, String tableName) async {
    var result = await database.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='$tableName'");
    return result.isNotEmpty;
  }

  Future<void> checkDataInDatabase() async {
    // Open the database
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'kewasco.db');

    // Check if the database file exists
    bool databaseExists = await databaseFactory.databaseExists(path);

    // Declare tableExists variable
    bool tableExists = false;

    // Check if the database file exists
    if (databaseExists) {
      Database database = await openDatabase(path);

      // Check if the 'teamLeadersTbl' table exists
      tableExists = await this.tableExists(database, 'teamLeadersTbl');

      if (tableExists) {
        // Check if data exists in the database
        int? count = Sqflite.firstIntValue(
            await database.rawQuery('SELECT COUNT(*) FROM teamLeadersTbl'));

        // Update the state based on whether data exists
        setState(() {
          hasData = count! > 0;
        });

        // Close the database
        await database.close();
      } else {
        print("Table 'teamLeadersTbl' does not exist.");
        setState(() {
          hasData = false;
        });
      }
    } else {
      print("Database file does not exist.");
      setState(() {
        hasData = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        centerTitle: true,
      ),
      body: Center(
        child: (io.Platform.isAndroid)
            ? buildAndroidBody(context)
            : LoginView(),
      ),
    );
  }

  Widget buildAndroidBody(BuildContext context) {
    return hasData
        ? ElevatedButton(
      onPressed: () {
        // Navigate to the login view
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginView()),
        );
      },
      child: const Text('Get Started'),
    )
        : ElevatedButton(
      onPressed: () async {
        try {
          // Show loading spinner
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 8),
                    Text('Downloading Data...'),
                  ],
                ),
              );
            },
          );

          // Fetch data from the server
          await fetchTaskFromServer();
          await fetchWorkersFromServer();
          await fetchTeamLeadersFromServer();

          // Close loading spinner
          Navigator.pop(context);

          setState(() {
            hasData = true;
          });
        } catch (e) {
          // Handle errors and close loading spinner
          print('Error fetching data: $e');
          Navigator.pop(context);
        }
      },
      child: const Text('Download Data'),
    );
  }


}
