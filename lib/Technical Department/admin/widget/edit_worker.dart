import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../config.dart';

class EditWorkerModal extends StatefulWidget {
  final int workerId;
  final String workerName;

  const EditWorkerModal({super.key, required this.workerId, required this.workerName});

  @override
  _EditWorkerModalState createState() => _EditWorkerModalState();
}

class _EditWorkerModalState extends State<EditWorkerModal> {
  TextEditingController workerNameController = TextEditingController();

  Future<bool> updateWorker(BuildContext context, int workerId, String updatedWorkerName) async {
    try {
      var response = await http.post(
        Uri.parse('http://${Config.ipAddress}/kewasco_api/modules/update_worker.php'),
        body: {
          'id': workerId.toString(),
          'updatedWorkerName': updatedWorkerName,
        },
      );

      if (response.statusCode == 200) {
        var updateResponseBody = jsonDecode(response.body);
        if (updateResponseBody['success'] == true) {
          // Worker updated successfully
          workerNameController.clear();
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
    workerNameController.text = widget.workerName;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Worker'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Current Worker Name: ${widget.workerName}'),
          const SizedBox(height: 16.0),
          TextFormField(
            controller: workerNameController,
            decoration: const InputDecoration(labelText: 'New Worker Name'),
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
            updateWorker(context, widget.workerId, workerNameController.text.trim()).then((success) {
              if (success) {
                // Data was successfully updated, set the result to true
                Navigator.of(context).pop(true);
              }
            });
          },
          child: const Text('Update Worker'),
        ),

      ],
    );
  }
}
