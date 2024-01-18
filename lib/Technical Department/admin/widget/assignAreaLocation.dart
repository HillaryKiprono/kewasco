import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../../api_endpoints/api_connections.dart';
import '../../model/assignLocationModel.dart';
import '../resource/app_colors.dart';
import '../resource/app_padding.dart';

class AssignAreaLocation extends StatefulWidget {
  const AssignAreaLocation({Key? key}) : super(key: key);

  @override
  State<AssignAreaLocation> createState() => _AssignAreaLocationState();
}

class _AssignAreaLocationState extends State<AssignAreaLocation> {
  final _formKey = GlobalKey<FormState>();

  String? selectedTeamLeaderName;
  String? selectedAreaLocationName;

  TextEditingController areaLocationCodeController = TextEditingController();
  TextEditingController areaLocationNameController = TextEditingController();

  List<String> teamLeadersList = [];
  List<String> areaLocationList = [];

  @override
  void initState() {
    super.initState();
    fetchTeamLeaders();
    fetchLocationName();

    // Initialize with null values
    selectedTeamLeaderName = null;
    selectedAreaLocationName = null;
  }


  void showSuccessDialogResponse(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Success"),
          content: const Text("New Area Location Added Successfully"),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            )
          ],
        );
      },
    );
  }
  void showFailureDialogResponse(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Failed"),
          content: const Text("Failed to add New Area Location "),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Close"),
            )
          ],
        );
      },
    );
  }

  Future<void> fetchTeamLeaders() async {
    try {
      var response = await http.get(Uri.parse(API.fetchAllTeamLeaders));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        List<String> teamLeaderNames = [];

        if (data['success'] == true) {
          for (var item in data['data']) {
            // Assuming your API response has a 'teamLeaderName' field
            String teamLeaderName = item['teamLeaderName'];
            teamLeaderNames.add(teamLeaderName);
          }

          setState(() {
            teamLeadersList = teamLeaderNames;
            // Do not set selectedTeamLeaderName here, let it remain as it is
          });
        } else {
          // Handle error from the API
          print('Error from API: ${data['message']}');
        }
      } else {
        // Handle HTTP error
        print('Failed to fetch team leaders. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle error
      print('Error fetching team leaders: $e');
    }
  }
  Future<void> fetchLocationName() async {
    try {
      var response = await http.get(Uri.parse(API.fetchAllAreaLocation));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        List<String> areaLocationNames = [];

        if (data['success'] == true) {
          for (var item in data['data']) {
            String areaLocationName = item['areaLocationName'];
            areaLocationNames.add(areaLocationName);
          }

          setState(() {
            areaLocationList = areaLocationNames;
          });
        } else {
          // Handle error from the API
          print('Error from API: ${data['message']}');
        }
      } else {
        // Handle HTTP error
        print('Failed to fetch area locations. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle error
      print('Error fetching area locations: $e');
    }
  }

  Future<void> saveAssignedAreaLocation(String selectedTeamLeader, String selectedAreaLocation) async {
    AssignAreaLocationModel assignAreaLocationModel = AssignAreaLocationModel(
      selectedTeamLeader,
      selectedAreaLocation,
    );

    try {
      var serverResponse = await http.post(
        Uri.parse(API.submitAssignAreaLocation),
        body: assignAreaLocationModel.toJson(),
      );

      if (serverResponse.statusCode == 200) {
        var decodeAreaLocation = jsonDecode(serverResponse.body);

        if (decodeAreaLocation["success"] == true) {
          areaLocationCodeController.clear();
          areaLocationNameController.clear();
          showSuccessDialogResponse(context);
        } else {
          showFailureDialogResponse(context);
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }
  @override
  Widget build(BuildContext context) {

    return Container(
      height: 400,
      width: double.infinity,
      padding: const EdgeInsets.only(
          left: AppPadding.P10 / 2,
          right: AppPadding.P10 / 2,
          top: AppPadding.P10,
          bottom: AppPadding.P10),
      child: Card(
        // color: AppColors.purpleLight,
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
                  child:
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white
                        ,
                        borderRadius: BorderRadius.circular(20)),
                    child:
                    Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Text(
                            "ASSIGN AREA LOCATION",
                            style: TextStyle(color: Colors.black),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: DropdownButtonFormField(
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)
                                  )
                              ),

                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Please Select Team Leader";
                                }
                                return null;
                              },
                              value: selectedTeamLeaderName,
                              hint: const Text('Select Team Leader'),
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedTeamLeaderName = newValue;
                                });
                              },
                              items: teamLeadersList.map((String teamLeader) {
                                return DropdownMenuItem<String>(
                                  value: teamLeader,
                                  child: Text(teamLeader),
                                );
                              }).toList(),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: DropdownButtonFormField(
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)
                                  )
                              ),
                              value: selectedAreaLocationName,

                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Please Select Area Location Task Name";
                                }
                                return null;
                              },
                              hint: const Text('Select Area Location'),
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedAreaLocationName = newValue;
                                });
                              },
                              items: areaLocationList.map((String areaLocation) {
                                return DropdownMenuItem<String>(
                                  value: areaLocation,
                                  child: Text(areaLocation),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          RawMaterialButton(
                            onPressed: () {
                              // Handle submit button click
                              if (selectedTeamLeaderName != null &&
                                  selectedAreaLocationName != null) {
                                // Perform the desired action
                                // For example, you can call a function to submit data
                                saveAssignedAreaLocation(
                                  selectedTeamLeaderName!,
                                  selectedAreaLocationName!,
                                );
                              } else {
                                // Show an error dialog or handle validation
                                showFailureDialogResponse(context);
                              }
                            },
                            fillColor: Colors.blue,
                            constraints: const BoxConstraints.tightFor(height: 40, width: 150),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "Submit Location",
                              style: GoogleFonts.abel(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 28,
              ),
            ],
          ),
        ),
      ),
    );


    return Scaffold(
      // bottomNavigationBar: const footer(),
      body: Column(
        children: [
          const CustomAppBar(),
          const SizedBox(
            height: 20,
          ),
          DropdownButtonFormField(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10)
              )
            ),
            value: selectedTeamLeaderName,
            hint: const Text('Select Team Leader'),
            onChanged: (String? newValue) {
              setState(() {
                selectedTeamLeaderName = newValue;
              });
            },
            items: teamLeadersList.map((String teamLeader) {
              return DropdownMenuItem<String>(
                value: teamLeader,
                child: Text(teamLeader),
              );
            }).toList(),
          ),
          const SizedBox(
            height: 20,
          ),
          DropdownButtonFormField(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10)
                )
              ),
            value: selectedAreaLocationName,
            hint: const Text('Select Area Location'),
            onChanged: (String? newValue) {
              setState(() {
                selectedAreaLocationName = newValue;
              });
            },
            items: areaLocationList.map((String areaLocation) {
              return DropdownMenuItem<String>(
                value: areaLocation,
                child: Text(areaLocation),
              );
            }).toList(),
          ),
          const SizedBox(
            height: 30,
          ),
          RawMaterialButton(
            onPressed: () {
              // Handle submit button click
              if (selectedTeamLeaderName != null &&
                  selectedAreaLocationName != null) {
                // Perform the desired action
                // For example, you can call a function to submit data
                saveAssignedAreaLocation(
                  selectedTeamLeaderName!,
                  selectedAreaLocationName!,
                );
              } else {
                // Show an error dialog or handle validation
                showFailureDialogResponse(context);
              }
            },
            fillColor: Colors.blue,
            constraints: const BoxConstraints.tightFor(height: 40, width: 150),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "Submit",
              style: GoogleFonts.abel(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      width: MediaQuery.of(context).size.width,
      decoration:  BoxDecoration(
        color: Colors.blue.withOpacity(.9),
        borderRadius: const BorderRadius.only(
            bottomRight: Radius.circular(50), topLeft: Radius.circular(100)),
      ),
      child: const Column(
        children: [
          ListTile(
            title: Center(
              child: Padding(
                padding: EdgeInsets.only(left: 8.0,top: 16),
                child: Text(
                  "Assign Area Location",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            trailing: Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 40,
                backgroundImage: AssetImage("assets/images/logo.png"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


