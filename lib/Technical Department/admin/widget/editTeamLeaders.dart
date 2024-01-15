import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../config.dart';

class EditTeamLeadersModal extends StatefulWidget {
  final int teamLeaderId;
  final String teamLeaderName;

  const EditTeamLeadersModal({super.key, required this.teamLeaderId, required this.teamLeaderName});

  @override
  _EditTeamLeadersModalState createState() => _EditTeamLeadersModalState();
}

class _EditTeamLeadersModalState extends State<EditTeamLeadersModal> {
  TextEditingController teamLeaderNameController = TextEditingController();

  Future<bool> updateWorker(BuildContext context, int workerId, String updatedTeamLeaderName) async {
    try {
      var response = await http.post(
        Uri.parse('http://${Config.ipAddress}/kewasco_api/modules/update_team_leader.php'),
        body: {
          'id': workerId.toString(),
          'updatedTeamLeaderName': updatedTeamLeaderName,
        },
      );

      if (response.statusCode == 200) {
        var updateResponseBody = jsonDecode(response.body);
        if (updateResponseBody['success'] == true) {
          // Worker updated successfully
          teamLeaderNameController.clear();
          if (kDebugMode) {
            print("Updated successfully");
          }
          return true; // Return true to indicate success
        } else {
          // Error in update
          if (kDebugMode) {
            print("Failed to update worker: ${updateResponseBody['message']}");
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
    teamLeaderNameController.text = widget.teamLeaderName;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update Team Leader'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Current Team Leader Name: ${widget.teamLeaderName}'),
          const SizedBox(height: 16.0),
          TextFormField(
            controller: teamLeaderNameController,
            decoration: const InputDecoration(labelText: 'New Team Leader Name'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            updateWorker(context, widget.teamLeaderId,teamLeaderNameController.text.trim()).then((success) {
              if (success) {
                // Data was successfully updated, set the result to true
                Navigator.of(context).pop(true);
              }
            });
          },
          child: const Text('Update Team Leader'),
        ),

      ],
    );
  }
}
