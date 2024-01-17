import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:http/http.dart' as http;

import '../../api_endpoints/api_connections.dart';
import '../../model/teamLeaderModel.dart';
import '../resource/app_colors.dart';
import '../resource/app_padding.dart';


class AddNewTeamLeader extends StatefulWidget {
  AddNewTeamLeader({super.key});

  @override
  State<AddNewTeamLeader> createState() => _AddNewTeamLeaderState();
}

class _AddNewTeamLeaderState extends State<AddNewTeamLeader> {
  TextEditingController teamLeaderNameController = TextEditingController();
  TextEditingController teamLeaderPasswordController=TextEditingController();

  Future<void> saveTeamLeader() async {
    TeamLeaderModel teamLeaderModel = TeamLeaderModel(
      teamLeaderNameController.text.trim(),
      teamLeaderPasswordController.text.trim()
    );
    try {
      var response = await http.post(
        Uri.parse(API.submitTeamLeader),
        body: teamLeaderModel.toJson(),
      );
      if (response.statusCode == 200) {
        var submitTeamLeader = jsonDecode(response.body);
        if (submitTeamLeader['success']==true) {
          teamLeaderNameController.clear();
          teamLeaderPasswordController.clear();
            showSuccessDialogResponse(context);

        }
        else
          {
            showFailureDialogResponse(context);
          }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  void showSuccessDialogResponse(BuildContext context){
    showDialog(
      context: context,
      builder: (BuildContext context){
        return  AlertDialog(
          title: const Text("Success"),
          content: const Text("New Team Leader Added Successfully"),
          actions: [
            ElevatedButton(onPressed: (){
              Navigator.of(context).pop();
            }, child: Text("OK"))
          ],
        );
      },
    );
  }

  void showFailureDialogResponse(BuildContext context){
    showDialog(
      context: context,
      builder: (BuildContext context){
        return  AlertDialog(
          title: const Text("Failed"),
          content: const Text("Failed to add New Team Leader "),
          actions: [
            ElevatedButton(onPressed: (){
              Navigator.of(context).pop();
            }, child: const Text("close"))
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Text(
                          "ADD TEAM LEADER",
                          style: TextStyle(color: Colors.black),
                        ),


                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: teamLeaderNameController,
                            cursorColor: Colors.greenAccent,
                            maxLines: 2,
                            decoration: InputDecoration(
                                labelText: "Enter Team Leader Name",
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20))),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            obscureText: true,
                            controller: teamLeaderPasswordController,
                            cursorColor: Colors.greenAccent,
                            decoration: InputDecoration(
                                labelText: "Enter Team Leader Password",
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20))),
                          ),
                        ),
                        RawMaterialButton(
                            fillColor: Colors.blue,
                            splashColor: Colors.blueAccent,
                            shape: StadiumBorder(),
                            onPressed: () {
                              saveTeamLeader();
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
                                  Text("Submit Team leader",style: TextStyle(color: Colors.white),),
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

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: MediaQuery
          .of(context)
          .size
          .width,
      decoration:  BoxDecoration(
        color: Colors.blue.withOpacity(.9),
        borderRadius: const BorderRadius.only(
            bottomRight: Radius.circular(50), topLeft: Radius.circular(100)),
      ),
      child: const ListTile(
        title: Center(
          child: Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Text(
              "Register Team Leader",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
        ),
        trailing: Padding(
          padding: EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            radius: 40,
            backgroundImage: AssetImage("assets/images/logo.png"),
          ),
        ),
      ),
    );
  }
}
