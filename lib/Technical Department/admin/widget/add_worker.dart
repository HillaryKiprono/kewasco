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
    FetchWorkerModel workerModel = FetchWorkerModel(
      workerNameController.text.trim(),);
    try {
      var response = await http.post(
          Uri.parse(API.submitWorker),
          body: workerModel.tojson()
      );

      if (response.statusCode == 200) {
        var submitResponseBody = jsonDecode(response.body);
        if (submitResponseBody['success'] == true) {
          workerNameController.clear();
          buttonClickMsg(context,QuickAlertType.success);
          if (kDebugMode) {
            print("Submitted successfully");
          }
          else {
            buttonClickMsg(context, QuickAlertType.error);
            if (kDebugMode) {
              print("Failed to submit data");
            }
          }
        }
      }
    }
    catch (e) {
      buttonClickMsg(context, QuickAlertType.error);
      print(e.toString());
    }
  }

  void buttonClickMsg(BuildContext context, QuickAlertType quickAlertType) {
    QuickAlert.show(
      context: context,
      type: quickAlertType,

    );
  }
  void showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Success"),
          content: const Text("New Worker Added successfully"),
          actions: [
            ElevatedButton(onPressed: () {
              Navigator.of(context).pop();
            }, child: const Text('ok'))
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
                          color: Colors.white
                          ,
                          borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Text(
                            "ADD NEW WORKER",
                            style: TextStyle(color: Colors.black),
                          ),

                          TextFormField(

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
                                return "Please enter Worker Name";
                              }
                            },
                          ),
                          RawMaterialButton(
                              fillColor: Colors.blue,
                              splashColor: Colors.blueAccent,
                              shape: StadiumBorder(),
                              onPressed: () {
                                saveWorker(context);
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
                                    Text("Submit Worker",style: TextStyle(color: Colors.white),),
                                  ],
                                ),
                              ))
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
