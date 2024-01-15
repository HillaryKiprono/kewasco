import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../config.dart';
import '../../api_endpoints/api_connections.dart';
import '../../model/fetchTeamLeadersModel.dart';
import '../resource/app_colors.dart';
import '../resource/app_padding.dart';
import 'editTeamLeaders.dart';

class ViewAllTeamLeaders extends StatefulWidget {
  const ViewAllTeamLeaders({Key? key}) : super(key: key);

  @override
  State<ViewAllTeamLeaders> createState() => _ViewAllTeamLeadersState();
}

class _ViewAllTeamLeadersState extends State<ViewAllTeamLeaders> {
  List<FetchTeamLeadersModel> teamLeaders = [];

  int currentPage = 1;
  int itemsPerPage = 5;

  List<FetchTeamLeadersModel> getPaginatedData() {
    int startIndex = (currentPage - 1) * itemsPerPage;
    int endIndex = startIndex + itemsPerPage;

    // Ensure endIndex is within the valid range
    endIndex = endIndex.clamp(0, teamLeaders.length);

    return teamLeaders.sublist(startIndex, endIndex);
  }

  Future<void> fetchTeamLeadersFromDatabase() async {
    final response = await http.get(Uri.parse(API.fetchAllTeamLeaders));
    if (response.statusCode == 200) {
      final dynamic jsonResponse = json.decode(response.body);
      print(jsonResponse);

      if (jsonResponse is Map<String, dynamic> && jsonResponse.containsKey('data')) {
        List<FetchTeamLeadersModel> newData = (jsonResponse['data'] as List<dynamic>)
            .map((item) => FetchTeamLeadersModel.fromJson(item))
            .toList();

        setState(() {
          teamLeaders = newData;
        });
      } else {
        print('Error: Unexpected JSON format.');
      }
    } else {
      print('Error: Failed to load data. Status code: ${response.statusCode}');
    }
  }


  Future<void> confirmDeleteTeamLeader(BuildContext context, String teamLeaderId) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete Team Leader?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Ensure that workerId is a valid integer
                int? parsedteamLeaderId = int.tryParse(teamLeaderId);
                if (parsedteamLeaderId != null) {
                  try {
                    final response = await http.delete(
                      Uri.parse('http://${Config.ipAddress}/kewasco_api/modules/deleteTeamLeader.php?id=$parsedteamLeaderId'),
                    );

                    if (response.statusCode == 200) {
                      final Map<String, dynamic> responseData = json.decode(response.body);

                      if (responseData['success'] == true) {
                        // Worker deleted successfully
                        print('Worker deleted successfully');
                        fetchTeamLeadersFromDatabase();
                      } else {
                        // Error in deletion
                        if (kDebugMode) {
                          print('Error deleting worker: ${responseData['message']}');
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error deleting worker: ${responseData['message']}'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    } else {
                      // Handle non-200 status code
                      print('Error deleting worker. Status code: ${response.statusCode}');
                    }
                  } catch (error) {
                    print('Error deleting worker: $error');
                    // Handle other errors
                  }
                } else {
                  print("Invalid worker ID. Please try again.");
                  // Provide a meaningful error message to the user
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Invalid worker ID. Please try again.'),
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

  Future<void> confirmEditTeamLeader(BuildContext context, int teamLeaderId, String teamLeaderName) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditTeamLeadersModal(teamLeaderId: teamLeaderId, teamLeaderName: teamLeaderName);
      },
    ).then((result) {
      if (result == true) {
        // Data was successfully updated, fetch new data
        fetchTeamLeadersFromDatabase();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    fetchTeamLeadersFromDatabase();
  }

  @override
  Widget build(BuildContext context) {
    List<FetchTeamLeadersModel> paginatedData = getPaginatedData();
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
                        Text("All Team leaders"),
                        const SizedBox(height: 6.0),
                        FractionallySizedBox(
                          widthFactor: 0.9,
                          child: DataTable(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                            ),
                            columns: const [
                              DataColumn(
                                label: Text('#'),
                              ),
                              DataColumn(
                                label: Text('Name'),
                              ),
                              DataColumn(
                                label: Text('Action'),
                              ),
                            ],
                            rows: List.generate(
                              paginatedData.length,
                                  (index) => DataRow(
                                cells: [
                                  DataCell(
                                    Text(
                                      paginatedData[index].id?.toString() ?? 'N/A',
                                      style: const TextStyle(color: Colors.blue),

                                    ),
                                  ),



                                  DataCell(
                                    Text(paginatedData[index].teamLeaderName),
                                  ),
                                  DataCell(
                                    Container(
                                      padding: EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          IconButton(onPressed: () => confirmDeleteTeamLeader(
                                              context, paginatedData[index].id?.toString() ?? 'N/A'
                                          ), icon: Icon(Icons.delete,color: Colors.red,)),

                                          IconButton(onPressed: (){

                                            confirmEditTeamLeader(
                                              context,
                                              paginatedData[index].id ?? 0,
                                              paginatedData[index].teamLeaderName,

                                            );
                                            fetchTeamLeadersFromDatabase();
                                          }, icon: Icon(Icons.edit,color: Colors.blue,)),
                                          // ElevatedButton(
                                          //   onPressed: () => confirmDeleteTeamLeader(
                                          //       context, paginatedData[index].id?.toString() ?? 'N/A'
                                          //   ),
                                          //   style: ElevatedButton.styleFrom(
                                          //     backgroundColor: Colors.red,
                                          //   ),
                                          //   child: const Text('Delete'),
                                          // ),

                                          // ElevatedButton(
                                          //   onPressed: (){
                                          //
                                          //     confirmEditTeamLeader(
                                          //       context,
                                          //       paginatedData[index].id ?? 0,
                                          //       paginatedData[index].teamLeaderName,
                                          //
                                          //     );
                                          //     fetchTeamLeadersFromDatabase();
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
                                  (teamLeaders.length / itemsPerPage).ceil();
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

  }
}
