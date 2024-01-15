import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../../api_endpoints/api_connections.dart';
import '../../model/areaLocationModel.dart';


class AddAreaLocation extends StatefulWidget {
  const AddAreaLocation({super.key});

  @override
  State<AddAreaLocation> createState() => _AddAreaLocationState();
}

class _AddAreaLocationState extends State<AddAreaLocation> {

  

  TextEditingController areaLocationNameController = TextEditingController();
  TextEditingController areaLocationCodeController = TextEditingController();

  Future<void> saveAreaLocation() async {
    String areaLocationCode = areaLocationCodeController.text.trim();
    String areaLocationName = areaLocationNameController.text.trim();

    if (areaLocationCode.isEmpty || areaLocationName.isEmpty) {
      // Show an error message when fields are empty
      showEmptyFieldsDialog(context);
      return;
    }

    AreaLocationModel areaLocationModel =
    AreaLocationModel(areaLocationCode, areaLocationName);

    try {
      var serverResponse = await http.post(
        Uri.parse(API.submitAreaLocation),
        body: areaLocationModel.toJson(),
      );
      if (serverResponse.statusCode == 200) {
        var decodeAreaLocation = jsonDecode(serverResponse.body);
        if (decodeAreaLocation["success"] == true) {
          areaLocationCodeController.clear();
          areaLocationNameController.clear();
          showSuccessDialogResponse(context);
        } else {
          showFailureDialogResponse(context);
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }

  void showEmptyFieldsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
          content: const Text("Please fill in all the fields."),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            )
          ],
        );
      },
    );
  }

  //
  // TextEditingController areaLocationNameController = TextEditingController();
  // TextEditingController areaLocationCodeController = TextEditingController();
  //
  // Future<void> saveAreaLocation() async {
  //   AreaLocationModel areaLocationModel = AreaLocationModel(
  //       areaLocationCodeController.text.trim(),
  //       areaLocationNameController.text.trim());
  //   try {
  //     var serverResponse = await http.post(
  //       Uri.parse(
  //         API.submitAreaLocation,
  //       ),
  //       body: areaLocationModel.toJson()
  //     );
  //     if(serverResponse.statusCode==200){
  //       var decodeAreaLocation=jsonDecode(serverResponse.body);
  //       if(decodeAreaLocation["success"]==true){
  //         areaLocationCodeController.clear();
  //         areaLocationNameController.clear();
  //        showSuccessDialogResponse(context);
  //       }
  //       else{
  //         showFailureDialogResponse(context);
  //       }
  //     }
  //   } catch (e) {
  //     print(e.toString());
  //   }
  // }
  void showSuccessDialogResponse(BuildContext context){
    showDialog(
      context: context,
      builder: (BuildContext context){
        return  AlertDialog(
          title: const Text("Success"),
          content: const Text("New Area Location Added Successfully"),
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
          content: const Text("Failed to add New Area Location "),
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
    return Scaffold(
      // bottomNavigationBar: const footer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const CustomAppBar(),
            const SizedBox(
              height: 60,
            ),
            Column(
              children: [
                TextFormField(
                  controller: areaLocationCodeController,
                  cursorColor: Colors.greenAccent,
                  decoration: InputDecoration(
                      labelText: "Enter Area Location Code",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20))),
                ),
                const SizedBox(
                  height: 30,
                ),
                TextFormField(
                  controller: areaLocationNameController,
                  cursorColor: Colors.greenAccent,
                  decoration: InputDecoration(
                      labelText: "Enter Area Location Name",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20))),
                ),
                const SizedBox(
                  height: 30,
                ),
                RawMaterialButton(
                  onPressed: () {
                    saveAreaLocation();
                  },
                  fillColor: Colors.blue,
                  constraints:
                      const BoxConstraints.tightFor(height: 40, width: 150),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Submit",
                    style: GoogleFonts.abel(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 24),
                  ),
                ),
              ],
            )
          ],
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
              "Add Area Location",
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
