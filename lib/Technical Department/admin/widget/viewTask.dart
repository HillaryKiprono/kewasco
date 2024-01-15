import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../config.dart';
import '../../api_endpoints/api_connections.dart';
import '../../model/fetchTaskModel.dart';
import '../resource/app_colors.dart';
import 'editTask.dart';
import 'edit_worker.dart';

class ViewAllTask extends StatefulWidget {
  const ViewAllTask({Key? key}) : super(key: key);

  @override
  State<ViewAllTask> createState() => _ViewAllWorkersState();
}

class _ViewAllWorkersState extends State<ViewAllTask> {

  List<FetchTaskModel> taskData = [];

  int currentPage = 1;
  int itemsPerPage = 5;

  List<FetchTaskModel> getPaginatedData() {
    int startIndex = (currentPage - 1) * itemsPerPage;
    int endIndex = startIndex + itemsPerPage;

    // Ensure endIndex is within the valid range
    endIndex = endIndex.clamp(0, taskData.length);

    return taskData.sublist(startIndex, endIndex);
  }

  Future<void> fetchDataFromDatabase() async {
    final response = await http.get(Uri.parse(API.fetchAllTask));
    if (response.statusCode == 200) {
      final dynamic jsonResponse = json.decode(response.body);
      print(jsonResponse); // Add this line to print the response

      if (jsonResponse is Map<String, dynamic> && jsonResponse.containsKey('data')) {
        List<FetchTaskModel> newData = (jsonResponse['data'] as List<dynamic>)
            .map((item) => FetchTaskModel.fromJson(item))
            .toList();

        setState(() {
          taskData = newData;
        });
      } else {
        print('Error: Unexpected JSON format.');
      }
    } else {
      print('Error: Failed to load data. Status code: ${response.statusCode}');
    }
  }

  Future<void> confirmDeleteTask(BuildContext context, String taskId) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete Task?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                int? parsedTaskId = int.tryParse(taskId);
                if (parsedTaskId != null) {
                  try {
                    final response = await http.delete(
                      Uri.parse('http://${Config.ipAddress}/kewasco_api/modules/delete_task.php?id=$parsedTaskId'),
                    );

                    if (response.statusCode == 200) {
                      final Map<String, dynamic> responseData = json.decode(response.body);

                      if (responseData['success'] == true) {
                        // Worker deleted successfully
                        print('Task deleted successfully');
                        fetchDataFromDatabase();
                      } else {
                        // Error in deletion
                        if (kDebugMode) {
                          print('Error deleting Task: ${responseData['message']}');
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error deleting Task: ${responseData['message']}'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    } else {
                      // Handle non-200 status code
                      print('Error deleting Task. Status code: ${response.statusCode}');
                    }
                  } catch (error) {
                    print('Error deleting Task: $error');
                    // Handle other errors
                  }
                } else {
                  print("Invalid Task ID. Please try again.");
                  // Provide a meaningful error message to the user
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Invalid Task ID. Please try again.'),
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

  Future<void> confirmEditTask(BuildContext context, int taskId, String taskName) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditTaskModal(taskId: taskId, taskName: taskName);
      },
    ).then((result) {
      if (result == true) {
        // Data was successfully updated, fetch new data
        fetchDataFromDatabase();
      }
    });
  }

  // Future<void> confirmEditTask(BuildContext context, int workerId, String workerName) async {
  //   return showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return EditWorkerModal(workerId: workerId, workerName: workerName);
  //     },
  //   );
  // }
  @override
  void initState() {
    super.initState();
    fetchDataFromDatabase();
  }

  @override
  Widget build(BuildContext context) {
    List<FetchTaskModel> paginatedData = getPaginatedData();


    return Container(
      height: 400,
      width: double.infinity,
      padding: const EdgeInsets.only(
        // left: AppPadding.P10 / 2,
        // right: AppPadding.P10 / 2,
        // top: AppPadding.P10,
        // bottom: AppPadding.P10
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



                    SingleChildScrollView(
                      child: Column(
                        // crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text("View All Task"),
                          const SizedBox(height: 6.0),
                          FractionallySizedBox(

                            widthFactor: 0.9,
                            child: DataTable(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                              ),
                              columns: [
                                DataColumn(
                                  label: Container(
                                    // padding: const EdgeInsets.all(8.0),
                                    child: Expanded(child: const Text('ID')),
                                  ),
                                ),
                                const DataColumn(
                                  label: Text('Name'),
                                ),
                                const DataColumn(
                                  label: Text('Action'),
                                ),
                              ],
                              rows: List.generate(
                                paginatedData.length,
                                    (index) => DataRow(
                                  cells: [
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          paginatedData[index].id?.toString() ?? 'N/A',
                                          style: const TextStyle(color: Colors.blue),

                                        ),
                                      ),
                                    ),



                                    DataCell(
                                      Text(paginatedData[index].taskName),
                                    ),
                                    DataCell(
                                      Container(
                                        padding: EdgeInsets.all(0.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            IconButton(onPressed: () => confirmDeleteTask(
                                                context, paginatedData[index].id?.toString() ?? 'N/A'
                                            ), icon: Icon(Icons.delete,color: Colors.red,)),
                                            IconButton(onPressed: (){

                                              confirmEditTask(
                                                context,
                                                paginatedData[index].id ?? 0,
                                                paginatedData[index].taskName,

                                              );
                                              fetchDataFromDatabase();
                                            }, icon: Icon(Icons.edit,color: Colors.green,)),
                                            // ElevatedButton(
                                            //   onPressed: () => confirmDeleteTask(
                                            //       context, paginatedData[index].id?.toString() ?? 'N/A'
                                            //   ),
                                            //   style: ElevatedButton.styleFrom(
                                            //     backgroundColor: Colors.red,
                                            //   ),
                                            //   child: const Icon(Icons.delete),
                                            // ),

                                            // ElevatedButton(
                                            //   onPressed: (){
                                            //
                                            //     confirmEditTask(
                                            //         context,
                                            //         paginatedData[index].id ?? 0,
                                            //         paginatedData[index].workerName,
                                            //
                                            //     );
                                            //     fetchDataFromDatabase();
                                            //   },
                                            //   child: const Text('Edit'),
                                            // ),


                                          ],
                                        ),
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
                                    int totalPage =
                                    (taskData.length / itemsPerPage).ceil();
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



                  ),
                ),)
            ],
          ),
        ),
      ),
    );

  }

}
