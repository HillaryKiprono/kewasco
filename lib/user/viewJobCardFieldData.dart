import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../Technical Department/api_endpoints/api_connections.dart';
import 'models/dbHelper.dart';

class ViewJobCardFieldData extends StatefulWidget {
  const ViewJobCardFieldData({super.key});

  @override
  State<ViewJobCardFieldData> createState() => _ViewJobCardFieldDataState();
}

class _ViewJobCardFieldDataState extends State<ViewJobCardFieldData> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Map<String, dynamic>> fetchJobCardList = [];
  bool isLoading = true;

  void _refreshJobCard() async {
    final data = await databaseHelper.queryAllJobCard();
    setState(() {
      fetchJobCardList = data;
      isLoading = false;
    });
  }


  Future<void> syncDataToMySQL() async {
    // Database database = await openDatabase(
    //   join(await getDatabasesPath(), 'kewasco.db'),
    // );

    List<Map<String, dynamic>> data = await databaseHelper.queryAllJobCard();
    databaseHelper.clearTables();

    int totalRows = data.length;
    int uploadedRows = 0;

    for (var row in data) {
      try {
        var response = await http.post(
          Uri.parse(API.uploadJobCard),
          headers: {"Content-Type": "application/x-www-form-urlencoded"},
          body: {
            'accountNo': row['accountNo'].toString(),
            'dateStarted': row['dateStarted'] != null
                ? DateFormat('yyyy/MM/dd').format(DateTime.parse(row['dateStarted']))
                : "",
            'timeStarted': row['timeStarted'] != null
                ? row['timeStarted'].toString()
                : "",
            'department': row['department'].toString(),
            'section': row['section'].toString(),
            'selectedTaskName': row['selectedTaskName'].toString(),
            'workLocation': row['workLocation'].toString(),
            'northings': row['northings'].toString(),
            'eastings': row['eastings'].toString(),
            'workStatus': row['workStatus'].toString(),
            'dateCompleted': row['dateCompleted'] != null
                ? DateFormat('yyyy/MM/dd').format(DateTime.parse(row['dateCompleted']))
                : "",
            'timeCompleted': row['timeCompleted'] != null
                ? row['timeCompleted'].toString()
                : "",
            'workDescription': row['workDescription'].toString(),
            'material': row['material'].toString(),
            'assignedWorker': row['assignedWorker'].toString(),
            'username': row['username'].toString(),
          },
        );

        print('Response: ${response.body}');

        if (response.statusCode == 200) {
          // Data uploaded successfully
          print('Data synced successfully');
        } else {
          print("***********************************************failed to sync Data************************************************************");
          // Print the formatted date for debugging purposes
          print('Formatted Date: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(row['dateStarted']))}');
          print('Server Response: ${response.body}');
        }
      } catch (e) {
        print('Error during data synchronization: $e');
      }

      uploadedRows++;
      double percentage = (uploadedRows / totalRows) * 100;
      print("Please be Patient While Uploading data to the Server and ensure you have a strong Internet connection. Uploading: ${percentage.toStringAsFixed(2)}%");
    }

    // Clear data after successful upload
    //await database.delete('job_cards');
  }





  @override
  void initState() {
    super.initState();
    _refreshJobCard();
    print(("Number of items in the jobcard: ${fetchJobCardList.length}"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("View JobCard."),
      ),
      body: ListView.builder(
        itemCount: fetchJobCardList.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 5,
            child: ListTile(
              title: Text(
                "Account No: ${fetchJobCardList[index]["accountNo"]}",
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "dateStarted: ${fetchJobCardList[index]["dateStarted"]}",
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    "timeStarted: ${fetchJobCardList[index]["timeStarted"]}",
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    "department: ${fetchJobCardList[index]["department"]}",
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    "section: ${fetchJobCardList[index]["section"]}",
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    "Task: ${fetchJobCardList[index]["selectedTaskName"]}",
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    "workLocation: ${fetchJobCardList[index]["workLocation"]}",
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    "northings: ${fetchJobCardList[index]["northings"]}",
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    "eastings: ${fetchJobCardList[index]["eastings"]}",
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    "workStatus: ${fetchJobCardList[index]["workStatus"]}",
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    "dateCompleted: ${fetchJobCardList[index]["dateCompleted"]}",
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    "timeCompleted: ${fetchJobCardList[index]["timeCompleted"]}",
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    "workDescription: ${fetchJobCardList[index]["workDescription"]}",
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    "material: ${fetchJobCardList[index]["material"]}",
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    "assignedWorker: ${fetchJobCardList[index]["assignedWorker"]}",
                  ),
                  const SizedBox(
                    height: 10,
                  ),

                  Text(
                    "username: ${fetchJobCardList[index]["username"]}",
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: RawMaterialButton(
        onPressed: () => syncDataToMySQL(),
        fillColor: Colors.deepOrangeAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            " Clicked here to Upload",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
