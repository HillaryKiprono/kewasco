import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kewasco/Technical%20Department/admin/resource/app_colors.dart';
import 'package:kewasco/Technical%20Department/dbHelperClass/databaseHelper.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;

import '../api_endpoints/api_connections2.dart';



class FieldActivityTableScreen extends StatefulWidget {
  @override
  _FieldActivityTableScreenState createState() =>
      _FieldActivityTableScreenState();
}

class _FieldActivityTableScreenState extends State<FieldActivityTableScreen> {
  List<Map<String, dynamic>> storedFieldActivity = [];
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

  Future<void> syncDataToMySQL() async {
    Database database = await openDatabase(
      join(await getDatabasesPath(), 'maintenance.db'),
    );

    List<Map<String, dynamic>> data = await database.query('fieldActivities_tbl');

    int totalRows = data.length;
    int uploadedRows = 0;

    for (var row in data) {
      try {
        var response = await http.post(
          Uri.parse(API.uploadActivity),
            body: {
              'CategoryName': row['CategoryName'],
              'AssetName': row['AssetName'],
              'ActivityName': row['ActivityName'],
              'WorkerName': row['WorkerName'],
              'Status': row['Status'],
              'Date': row['Date'],
              'Time': row['Time'],
              'Comments': row['Comments'],

            }
        );
       // var url="http://${Config.ipAddress}/Maintenance_Activity_API/modules/upload_activity.php";
       //  var response = await http.post(
       //      Uri.parse(url),
       //      body: {
       //        'CategoryName': row['CategoryName'],
       //        'AssetName': row['AssetName'],
       //        'ActivityName': row['ActivityName'],
       //        'WorkerName': row['WorkerName'],
       //        'Status': row['Status'],
       //        'Date': row['Date'],
       //        'Time': row['Time'],
       //        'Comments': row['Comments'],
       //
       //
       //      });
        print('Response: ${response.body}');


        if (response.statusCode == 200) {
          // Data uploaded successfully
          print('Data synced successfully');

        } else {
          print("***********************************************failed to sync Data************************************************************");
          // Error occurred while uploading data
          print('Error: ${response.body}');
        }
      } catch (e) {
        print('Error while uploading data: $e');
      }

      uploadedRows++;
      double percentage = (uploadedRows / totalRows) * 100;
      Fluttertoast.showToast(
        msg: "Please be Patient While Uploading data to the Server and ensure you have a strong Internet connection. Uploading: ${percentage.toStringAsFixed(2)}%",
      );

    }

    // Clear data after successful upload
    await database.delete('fieldActivities_tbl');
  }


  @override
  void initState() {
    super.initState();
    fetchStoredFieldActivities();
  }

  Future<void> fetchStoredFieldActivities() async {
    final dbHelper = DatabaseHelper.instance;
    storedFieldActivity = await dbHelper.queryFieldActivities();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Stored Field Activities"),
        actions: [
          IconButton(
            iconSize: 32,
            onPressed: () {
              syncDataToMySQL();
            },
            icon: Icon(Icons.cloud_upload),

          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('#')),
            DataColumn(label: Text('Category Name')),
            DataColumn(label: Text('Asset Name')),
            DataColumn(label: Text('Activity Name')),
            DataColumn(label: Text('Worker Name')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Comments')),
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Time')),
            DataColumn(label: Text('Action')),
          ],
          rows: storedFieldActivity.map((activity) {
            final id = activity['id'];
            return DataRow(cells: [
              DataCell(Text(activity['id'].toString())),
              DataCell(Text(activity['CategoryName'])),
              DataCell(Text(activity['AssetName'])),
              DataCell(Text(activity['ActivityName'])),
              DataCell(Text(activity['WorkerName'])),
              DataCell(Text(activity['Status'])),
              DataCell(Text(activity['Comments'])),
              DataCell(Text(activity['Date'])),
              DataCell(Text(activity['Time'])),
              DataCell(Row(
                children: [
                  // IconButton(
                  //   onPressed: () {
                  //     // Add your edit logic here
                  //     // Open the edit activity screen when the edit button is clicked
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (context) => EditFieldActivityScreen(activity: activity),
                  //       ),
                  //     );
                  //   },
                  //   icon: Icon(Icons.edit,color: Colors.blue,),
                  // ),
                  IconButton(
                    onPressed: () {
                      // Show an alert dialog before deleting the field activity
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Confirm Delete"),
                            content:
                            Text("Do you want to delete this activity?"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); // Close the dialog
                                },
                                child: Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () {
                                  // Delete the field activity and fetch the updated list
                                  DatabaseHelper.instance
                                      .deleteFieldActivity(id);
                                  fetchStoredFieldActivities();
                                  Navigator.of(context)
                                      .pop(); // Close the dialog
                                },
                                child: Text("OK"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                  ),
                ],
              )),

            ]);
          }).toList(),
        ),
      ),

floatingActionButton: RawMaterialButton(
  shape: StadiumBorder(),
  onPressed: checkConnectivity,
  fillColor: AppColors.bg1,
  child: Padding(
    padding:  EdgeInsets.symmetric(vertical: 8.0,horizontal: 20),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.sync,color: Colors.white,),
        SizedBox(width: 20,),
        Text("Upload to Server",style: TextStyle(color: Colors.white),),
      ],
    ),
  ),

),
      // floatingActionButton: Container(
      //   width: 150, // Set the width of the container as needed
      //   child: FloatingActionButton(
      //     onPressed: () {
      //       checkConnectivity();
      //     },
      //     child: Text("Upload to Server"),
      //     backgroundColor: Colors.blue, // Change the background color as needed
      //   ),
      // ),
    );
  }
}


