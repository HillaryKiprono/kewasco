import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../config.dart';
import '../../api_endpoints/api_connections.dart';


class EditAssignAreaLocationModal extends StatefulWidget {
  final int areaLocationId;
  final String teamLeaderName;
  final String areaLocationName;


  EditAssignAreaLocationModal(
      this.areaLocationId, this.teamLeaderName, this.areaLocationName);

  @override
  _EditAssignAreaLocationModalState createState() => _EditAssignAreaLocationModalState();
}

class _EditAssignAreaLocationModalState extends State<EditAssignAreaLocationModal> {
  TextEditingController areaLocationCodeController = TextEditingController();
  TextEditingController areaLocationNameController = TextEditingController();

  String? selectedTeamLeaderName;
  String? selectedAreaLocationName;

  List<String> teamLeadersList = [];
  List<String> areaLocationList = [];


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

  Future<bool> updateWorker(BuildContext context, int areaLocationId, String updatedAreaLocationCode,String updatedAreaLocationName) async {
    try {
      var response = await http.post(
        Uri.parse('http://${Config.ipAddress}/kewasco_api/modules/update_assign_area_location.php'),
        body: {
          'id': areaLocationId.toString(),
          'updatedAreaLocationCode': updatedAreaLocationCode,
          'updatedAreaLocationName': updatedAreaLocationName,
        },
      );

      if (response.statusCode == 200) {
        var updateResponseBody = jsonDecode(response.body);
        if (updateResponseBody['success'] == true) {

          areaLocationCodeController.clear();
          areaLocationNameController.clear();
          if (kDebugMode) {
            print("Updated successfully");
          }
          return true; // Return true to indicate success
        } else {
          // Error in update
          if (kDebugMode) {
            print("Failed to update areaLocation: ${updateResponseBody['message']}");
          }
        }
      }
    } catch (e) {
      print(e.toString());
    }
    return false; // Return false if there was an error during the update
  }



  @override
  void initState() {
    super.initState();
    areaLocationCodeController.text = widget.teamLeaderName;
    areaLocationNameController.text = widget.areaLocationName;
    fetchTeamLeaders();
    fetchLocationName();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update Area Location'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Current Area Location Code: ${widget.teamLeaderName}'),
          const SizedBox(height: 16.0),
          Text('Current Area Location Name: ${widget.areaLocationName}'),
          const SizedBox(height: 16.0),

          DropdownButton<String>(
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

          const SizedBox(height: 16.0),

          DropdownButton<String>(
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
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            await updateWorker(context, widget.areaLocationId,selectedTeamLeaderName!,selectedAreaLocationName!).then((success) {
              if (success) {
                // Data was successfully updated, set the result to true
                Navigator.of(context).pop(true);
              }
            });
          },
          child: const Text('Update Area Location '),
        ),
      ],
    );
  }


}
