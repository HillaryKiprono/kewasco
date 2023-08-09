import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../api_endpoints/api_connections.dart';
import '../../model/workerModel.dart';
import '../resource/app_colors.dart';

class AddWorker extends StatefulWidget {
  AddWorker({super.key});
  final Color leftBarColor = const Color(0xff53fdd7);
  final Color rightBarColor = const Color(0xffff5182);
  @override
  State<StatefulWidget> createState() => AddWorkerState();
}

class AddWorkerState extends State<AddWorker> {
  final double width = 7;
  int touchedGroupIndex = -1;

  //declaring  variables

  final formKey = GlobalKey<FormState>();
  // TextEditingController CategoryIdController = TextEditingController();
  TextEditingController workerNameController = TextEditingController();

  void showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('Congratulations! You have successfully added a new worker.'),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void showFailureDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Failure'),
          content: const Text('An error occurred. Please try again.'),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> saveWorker() async {
    WorkerModel workerModel = WorkerModel(
      workerNameController.text.trim(),
    );

    try {
      var res = await http.post(
        Uri.parse(API.submitWorker),
        body: workerModel.toJson(),
      );

      if (res.statusCode == 200) {
        var resBodyOfSubmitCategory = jsonDecode(res.body);

        if (resBodyOfSubmitCategory['success'] == true) {
          workerNameController.clear();
          showSuccessDialog(context);
        }
        else {
          print("falses");
          //showFailureDialog(context);
        }
      } else {
        Fluttertoast.showToast(
          msg: "Failed to connect! Please check your network connectivity",
        );
        print("checked newtork");
        // showFailureDialog(context);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Check connection");
      Fluttertoast.showToast(msg: e.toString());
      print("catch error");
      //showFailureDialog(context);
    }
  }


  @override
  void initState() {
    super.initState();



  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Card(
          color: AppColors.purpleLight,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 3,
          child:  AspectRatio(
            aspectRatio: 1.1,
            child: Padding(
              padding: EdgeInsets.all(16),
              child:
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      //makeTransactionsIcon(),
                      Text(
                        'Add New Worker',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                     
                    ],
                  ),
              
                  const SizedBox(
                    height: 38,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 0),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            const Text(
                              "Adding new Worker",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                          
                            const SizedBox(
                              height: 20,
                            ),
                            TextField(
                               controller: workerNameController,
                              decoration: InputDecoration(
                                  labelText: "Enter Worker Name",
                                  border: OutlineInputBorder(
                                      borderRadius:
                                      BorderRadius.circular(10))),
                            ),
                            const SizedBox(
                              height: 15,
                            ),

                            ElevatedButton(
                                onPressed: () {
                                   saveWorker();
                                },
                                child: const Text("Save Worker"))
                          ],
                        ),
                      ),
                    ),
                  ),


                  SizedBox(
                    height: 12,
                  ),
                ],
              ),
            ),
          ),
        ),

      ],
    );
  }

}

