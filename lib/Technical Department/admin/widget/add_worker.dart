import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:kewasco/Technical%20Department/model/assetModel.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import '../../api_endpoints/api_connections.dart';
import '../../model/workerModel.dart';
import '../resource/app_colors.dart';
import '../resource/app_padding.dart';

class AddWorker extends StatefulWidget {
  const AddWorker({super.key});

  @override
  State<StatefulWidget> createState() => AddWorkerState();
}

class AddWorkerState extends State {
  int touchedIndex = -1;
  TextEditingController workerNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();



  Future<void> saveWorker(BuildContext context) async {
    AddWorkerModel workerModel = AddWorkerModel(
      workerNameController.text.trim(),
    );
    try {
      var res = await http.post(
        Uri.parse(API.submitWorker),
        body: workerModel.toJson(),
      );

      // Print raw server response
      print("Server Response: ${res.body}");

      if (res.statusCode == 200) {
        try {
          var resBodyOfSaveCategory = jsonDecode(res.body);

          if (resBodyOfSaveCategory['success'] == true) {
            // Show success message
            showSuccessDialog(context);

            // Reset text controllers to clear the entered data
            workerNameController.clear();
          } else {
            // Show failure message
            showFailureDialog(context);
          }
        } catch (e) {
          // Handle JSON decoding error
          print("Error decoding JSON: $e");
          showFailureDialog(context);
        }
      } else {
        // Show failure message for non-200 status codes
        print("Failed to connect. Status Code: ${res.statusCode}");
        showFailureDialog(context);
      }
    } catch (e) {
      // Handle general exception
      print("Check your connection");
      print(e.toString());
      showFailureDialog(context);
    }
  }
  // Show dialog for successful insertion of activity
  void showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('Operation completed successfully.'),
          actions: <Widget>[
            ElevatedButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Show dialog for failure insertion message
  void showFailureDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Failed to save Activity'),
          content: const Text(
              'Operation #### completion failed. Please check your internet or inputs.'),
          actions: <Widget>[
            ElevatedButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [

                          const Text(
                            "ADD NEW WORKER",
                            style: TextStyle(color: Colors.black),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: workerNameController,
                              style: TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                  // fillColor: Colors.white,
                                  //  filled: true,
                                  labelText: "Enter Worker Name",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  )),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Please enter Team Worker Name";
                                }
                                return null;
                              },
                            ),
                          ),
                          RawMaterialButton(
                            fillColor: Colors.blue,
                            splashColor: Colors.blueAccent,
                            shape: StadiumBorder(),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                saveWorker(context);
                              }
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 20,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.save_rounded, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text("Submit Worker",
                                      style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
