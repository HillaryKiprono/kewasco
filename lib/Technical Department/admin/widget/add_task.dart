import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:kewasco/Technical%20Department/model/categoryModel.dart';
import '../../api_endpoints/api_connections.dart';
import '../../model/TaskData.dart';
import '../resource/app_colors.dart';
import '../resource/app_padding.dart';
import 'package:http/http.dart' as http;


class AddTask extends StatefulWidget {
  const AddTask({super.key});

  @override
  State<StatefulWidget> createState() => AddTaskState();
}

class AddTaskState extends State {
  int touchedIndex = -1;

  TextEditingController taskNameController = TextEditingController();


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

  //create a method to  save Category
  Future<void> saveTask(BuildContext context) async {
    TaskModel taskModel = TaskModel(
      taskNameController.text.trim(),

    );
    try {
      var res = await http.post(
        Uri.parse(API.submitTask),
        body: taskModel.toJson(),
      );
      if (res.statusCode == 200) {
        var resBodyOfSaveCategory = jsonDecode(res.body);

        if (resBodyOfSaveCategory['success'] == true) {
          //show success message
          showSuccessDialog(context);

          // Reset text controllers to clear the entered data
          taskNameController.clear();
        } else {
          showFailureDialog(context);
        }
        print("Connected successfully");
      } else {
        showFailureDialog(context);
        print("Failed to connect. Check your network connectivity.");
        print("failed to connect");
      }
    } catch (e) {
      print("Check your connection");
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
                  child:
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white
,
                    borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Text(
                          "ADD NEW TASK",
                          style: TextStyle(color: Colors.black),
                        ),

                        TextFormField(

                          controller: taskNameController,
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                           // fillColor: Colors.white,
                            //  filled: true,
                              labelText: "Enter Task Name",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              )),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please enter TaskName";
                            }
                          },
                        ),
                        RawMaterialButton(
                            fillColor: Colors.blue,
                            splashColor: Colors.blueAccent,
                            shape: StadiumBorder(),
                            onPressed: () {
                              saveTask(context);
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 20
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.save_rounded,color: Colors.white,),
                                  SizedBox(width: 8,),
                                  Text("Submit Task",style: TextStyle(color: Colors.white),),
                                ],
                              ),
                            ))
                      ],
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
  }
}
