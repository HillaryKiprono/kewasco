import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../config.dart';
import '../../api_endpoints/api_connections.dart';
import '../../model/fetchAreaLocationModel.dart';
import '../resource/app_colors.dart';
import '../resource/app_padding.dart';
import 'edit_area_location.dart';

class ViewAllAreaLocation extends StatefulWidget {
  const ViewAllAreaLocation({Key? key}) : super(key: key);

  @override
  State<ViewAllAreaLocation> createState() => _ViewAllAreaLocationState();
}

class _ViewAllAreaLocationState extends State<ViewAllAreaLocation> {
  List<FetchAreaLocationModel> workerData = [];

  int currentPage = 1;
  int itemsPerPage = 5;

  List<FetchAreaLocationModel> getPaginatedData() {
    int startIndex = (currentPage - 1) * itemsPerPage;
    int endIndex = startIndex + itemsPerPage;

    // Ensure endIndex is within the valid range
    endIndex = endIndex.clamp(0, workerData.length);

    return workerData.sublist(startIndex, endIndex);
  }

  Future<void> fetchDataFromDatabase() async {
    final response = await http.get(Uri.parse(API.fetchAllAreaLocation));
    if (response.statusCode == 200) {
      final dynamic jsonResponse = json.decode(response.body);
      print(jsonResponse); // Add this line to print the response

      if (jsonResponse is Map<String, dynamic> &&
          jsonResponse.containsKey('data')) {
        List<FetchAreaLocationModel> newData =
        (jsonResponse['data'] as List<dynamic>)
            .map((item) => FetchAreaLocationModel.fromJson(item))
            .toList();


        setState(() {
          workerData = newData;
        });
      } else {
        print('Error: Unexpected JSON format.');
      }
    } else {
      print('Error: Failed to load data. Status code: ${response.statusCode}');
    }
  }

  Future<void> confirmDeleteTask(BuildContext context, String workerId) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete worker?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                int? parsedAreaLocationId = int.tryParse(workerId);
                if (parsedAreaLocationId != null) {
                  try {
                    final response = await http.delete(
                      Uri.parse(
                          'http://${Config.ipAddress}/kewasco_api/modules/deleteAreaLocation.php?id=$parsedAreaLocationId'),
                    );

                    if (response.statusCode == 200) {
                      final Map<String, dynamic> responseData =
                          json.decode(response.body);

                      if (responseData['success'] == true) {
                        // Worker deleted successfully
                        print('Area Location deleted successfully');
                        fetchDataFromDatabase();
                      } else {
                        // Error in deletion
                        if (kDebugMode) {
                          print(
                              'Error deleting Area Location: ${responseData['message']}');
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Error deleting Area Location: ${responseData['message']}'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    } else {
                      // Handle non-200 status code
                      print(
                          'Error deleting Area Location. Status code: ${response.statusCode}');
                    }
                  } catch (error) {
                    print('Error deleting Area Location: $error');
                    // Handle other errors
                  }
                } else {
                  print("Invalid worker ID. Please try again.");
                  // Provide a meaningful error message to the user
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Invalid Area Location ID. Please try again.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }

                // Close the dialog
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> confirmEditTask(
      BuildContext context, int areaLocationId, String areaLocationCode,String areaLocationName) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditAreaLocationModal(
            areaLocationId,
            areaLocationCode,
            areaLocationName
        );
      },
    ).then((result) {
      if (result == true) {
        // Data was successfully updated, fetch new data
        fetchDataFromDatabase();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    fetchDataFromDatabase();
  }

  @override
  Widget build(BuildContext context) {
    List<FetchAreaLocationModel> paginatedData = getPaginatedData();


    return Container(
      height: 400,
      width: double.infinity,
      padding: const EdgeInsets.only(
          left: AppPadding.P10 / 2,
          right: AppPadding.P10 / 2,
          top: AppPadding.P10,
          bottom: AppPadding.P10
      ),
      child: Card(
        color: AppColors.purpleLight,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: AspectRatio(
          aspectRatio: 1.5,
          child: Row(
            children: <Widget>[
              const SizedBox(
                height: 18,
              ),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white
                        ,
                        borderRadius: BorderRadius.circular(20)),
                    child:



                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 6.0),
                        Text("All Area Location"),
                        const SizedBox(height: 6.0),

                        FractionallySizedBox(
                          widthFactor: 0.9,
                          child: DataTable(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                            ),
                            columns: const [
                              // DataColumn(
                              //   label: Text('ID'),
                              // ),
                              DataColumn(
                                label: Text('Code'),
                              ),
                              DataColumn(
                                label: Text(
                                  "Location",
                                ),
                              ),
                              DataColumn(
                                label: Text('Action'),
                              ),
                            ],
                            rows: List.generate(
                              paginatedData.length,
                                  (index) => DataRow(
                                cells: [
                                  // DataCell(
                                  //   Text(
                                  //     paginatedData[index].id?.toString() ?? 'N/A',
                                  //     style: const TextStyle(color: Colors.blue),
                                  //   ),
                                  // ),
                                  DataCell(
                                    Text(paginatedData[index].areaLocationCode),
                                  ),
                                  DataCell(
                                    Text(paginatedData[index].areaLocationName),
                                  ),
                                  DataCell(
                                    Row(

                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        IconButton(onPressed: () => confirmDeleteTask(
                                            context,
                                            paginatedData[index].id?.toString() ??
                                                'N/A'),
                                            icon: Icon(Icons.delete_forever,color: Colors.red,)),

                                        IconButton(
                                            onPressed: () {
                                              confirmEditTask(
                                                  context,
                                                  paginatedData[index].id ?? 0,
                                                  paginatedData[index].areaLocationCode,
                                                  paginatedData[index].areaLocationName
                                              );
                                              fetchDataFromDatabase();
                                            },
                                            icon: Icon(Icons.edit,color: Colors.blue,)),
                                        // ElevatedButton(
                                        //   onPressed: () => confirmDeleteTask(
                                        //       context,
                                        //       paginatedData[index].id?.toString() ??
                                        //           'N/A'),
                                        //   style: ElevatedButton.styleFrom(
                                        //     backgroundColor: Colors.red,
                                        //   ),
                                        //   child: const Text('Delete'),
                                        // ),
                                        // ElevatedButton(
                                        //   onPressed: () {
                                        //     confirmEditTask(
                                        //       context,
                                        //       paginatedData[index].id ?? 0,
                                        //       paginatedData[index].areaLocationCode,
                                        //       paginatedData[index].areaLocationName
                                        //     );
                                        //     fetchDataFromDatabase();
                                        //   },
                                        //   child: const Text('Edit'),
                                        // ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        // Pagination
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed: () {
                                setState(() {
                                  currentPage = currentPage > 1 ? currentPage - 1 : 1;
                                });
                              },
                            ),
                            Text(currentPage.toString(), style: TextStyle(fontSize: 18.0)),
                            IconButton(
                              icon: const Icon(Icons.arrow_forward),
                              onPressed: () {
                                setState(() {
                                  int totalPage = (workerData.length / itemsPerPage).ceil();
                                  currentPage =
                                  currentPage < totalPage ? currentPage + 1 : totalPage;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),



                  ),
                ),)
            ],
          ),
        ),
      ),
    );


    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.withOpacity(0.9),
        title: const Text('View All Area Location'),
        centerTitle: true,
      ),
      // bottomNavigationBar: const footer(),
      body: Container(
        margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1),
        // padding: const EdgeInsets.all(16.0),
        child:
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 6.0),
            FractionallySizedBox(
              widthFactor: 0.9,
              child: DataTable(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                ),
                columns: const [
                  // DataColumn(
                  //   label: Text('ID'),
                  // ),
                  DataColumn(
                    label: Text('Code'),
                  ),
                  DataColumn(
                    label: Text(
                      "Location",
                    ),
                  ),
                  DataColumn(
                    label: Text('Action'),
                  ),
                ],
                rows: List.generate(
                  paginatedData.length,
                  (index) => DataRow(
                    cells: [
                      // DataCell(
                      //   Text(
                      //     paginatedData[index].id?.toString() ?? 'N/A',
                      //     style: const TextStyle(color: Colors.blue),
                      //   ),
                      // ),
                      DataCell(
                        Text(paginatedData[index].areaLocationCode),
                      ),
                      DataCell(
                        Text(paginatedData[index].areaLocationName),
                      ),
                      DataCell(
                        Row(

                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(onPressed: () => confirmDeleteTask(
                                context,
                                paginatedData[index].id?.toString() ??
                                    'N/A'),
                                icon: Icon(Icons.delete_forever,color: Colors.red,)),

                            IconButton(
                                onPressed: () {
                                  confirmEditTask(
                                    context,
                                    paginatedData[index].id ?? 0,
                                    paginatedData[index].areaLocationCode,
                                    paginatedData[index].areaLocationName
                                  );
                                  fetchDataFromDatabase();
                                },
                            icon: Icon(Icons.edit,color: Colors.blue,)),
                            // ElevatedButton(
                            //   onPressed: () => confirmDeleteTask(
                            //       context,
                            //       paginatedData[index].id?.toString() ??
                            //           'N/A'),
                            //   style: ElevatedButton.styleFrom(
                            //     backgroundColor: Colors.red,
                            //   ),
                            //   child: const Text('Delete'),
                            // ),
                            // ElevatedButton(
                            //   onPressed: () {
                            //     confirmEditTask(
                            //       context,
                            //       paginatedData[index].id ?? 0,
                            //       paginatedData[index].areaLocationCode,
                            //       paginatedData[index].areaLocationName
                            //     );
                            //     fetchDataFromDatabase();
                            //   },
                            //   child: const Text('Edit'),
                            // ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            // Pagination
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      currentPage = currentPage > 1 ? currentPage - 1 : 1;
                    });
                  },
                ),
                Text(currentPage.toString(), style: TextStyle(fontSize: 18.0)),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () {
                    setState(() {
                      int totalPage = (workerData.length / itemsPerPage).ceil();
                      currentPage =
                          currentPage < totalPage ? currentPage + 1 : totalPage;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
