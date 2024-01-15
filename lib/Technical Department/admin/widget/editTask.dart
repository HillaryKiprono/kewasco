import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../config.dart';

class EditTaskModal extends StatefulWidget {
  final int taskId;
  final String taskName;

  const EditTaskModal({super.key, required this.taskId, required this.taskName});

  @override
  _EditTaskModalState createState() => _EditTaskModalState();
}

class _EditTaskModalState extends State<EditTaskModal> {
  TextEditingController taskNameController = TextEditingController();

  Future<bool> updateWorker(BuildContext context, int taskId, String updatedTaskName) async {
    try {
      var response = await http.post(
        Uri.parse('http://${Config.ipAddress}/kewasco_api/modules/updateTask.php'),
        body: {
          'id': taskId.toString(),
          'updatedTaskName': updatedTaskName,
        },
      );

      if (response.statusCode == 200) {
        var updateResponseBody = jsonDecode(response.body);
        if (updateResponseBody['success'] == true) {
          // Worker updated successfully
          taskNameController.clear();
          if (kDebugMode) {
            print("Updated successfully");
          }
          return true; // Return true to indicate success
        } else {
          // Error in update
          if (kDebugMode) {
            print("Failed to update Task: ${updateResponseBody['message']}");
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
    taskNameController.text = widget.taskName;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Task'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Current Task Name: ${widget.taskName}'),
          const SizedBox(height: 16.0),
          TextFormField(
            controller: taskNameController,
            decoration: const InputDecoration(labelText: 'New Task Name'),
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
            updateWorker(context, widget.taskId, taskNameController.text.trim()).then((success) {
              if (success) {
                // Data was successfully updated, set the result to true
                Navigator.of(context).pop(true);
              }
            });
          },
          child: const Text('Update Task'),
        ),

      ],
    );
  }
}
