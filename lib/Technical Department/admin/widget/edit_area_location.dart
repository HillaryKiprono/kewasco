import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../config.dart';


class EditAreaLocationModal extends StatefulWidget {
  final int areaLocationId;
  final String areaLocationCode;
  final String areaLocationName;


  EditAreaLocationModal(
      this.areaLocationId, this.areaLocationCode, this.areaLocationName);

  @override
  _EditAreaLocationModalState createState() => _EditAreaLocationModalState();
}

class _EditAreaLocationModalState extends State<EditAreaLocationModal> {
  TextEditingController areaLocationCodeController = TextEditingController();
  TextEditingController areaLocationNameController = TextEditingController();

  Future<bool> updateWorker(BuildContext context, int areaLocationId, String updatedAreaLocationCode,String updatedAreaLocationName) async {
    try {
      var response = await http.post(
        Uri.parse('http://${Config.ipAddress}/kewasco_api/modules/update_area_location.php'),
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
    areaLocationCodeController.text = widget.areaLocationCode;
    areaLocationNameController.text = widget.areaLocationName;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update Area Location'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Current Area Location Code: ${widget.areaLocationCode}'),
          const SizedBox(height: 16.0),
          Text('Current  Area Location Name: ${widget.areaLocationName}'),
          const SizedBox(height: 16.0),
          TextFormField(
            controller: areaLocationCodeController,
            decoration: const InputDecoration(labelText: 'New Area Location Code'),
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            controller: areaLocationNameController,
            decoration: const InputDecoration(labelText: 'New Area Location Name'),
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
            updateWorker(context, widget.areaLocationId,areaLocationCodeController.text.trim(),areaLocationNameController.text.trim()).then((success) {
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
