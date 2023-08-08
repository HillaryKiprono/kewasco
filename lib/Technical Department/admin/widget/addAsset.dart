import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:kewasco/Technical%20Department/model/assetModel.dart';
import '../../api_endpoints/api_connections.dart';
import '../resource/app_colors.dart';
import '../resource/app_padding.dart';

class AddAssets extends StatefulWidget {
  const AddAssets({super.key});

  @override
  State<StatefulWidget> createState() => AddAssetsState();
}

class AddAssetsState extends State {
  int touchedIndex = -1;
  final TextEditingController categoryNameController = TextEditingController();
  // final TextEditingController assetIdController = TextEditingController();
  final TextEditingController assetNameController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  String? _selectedCategoryName;

  List<String> _categoryDropdownData = [];

  Future<List<String>> fetchData() async {
    final response = await http.get(Uri.parse(API.fetchCategory));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      final List<String> dataList = jsonData.cast<String>().toList();
      return dataList;
    } else {
      throw Exception('Failed to fetch data');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final data = await fetchData();
    setState(() {
      _categoryDropdownData = data;
    });
  }

  void showSuccessDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Success"),
            content: Text("Congratulations! Asset details saved successfully."),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"))
            ],
          );
        });
  }

  void showFailureDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Failure"),
            content: Text(
                "Oops! Asset details submission failed. Please check your network."),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"))
            ],
          );
        });
  }

  //method to save Asset Details
//   Future<void> saveAssetDetails()async{
//     if (!formKey.currentState!.validate()) {
//       return;
//     }
// //use AssetModel
//   AssetModel assetModel=AssetModel(
//       // assetIdController.text.trim(),
//       assetNameController.text.trim(),
//       categoryNameController.text.trim()
//   );
//     try{
//       var response =await http.post(Uri.parse(API.submitAsset),
//       body: assetModel.toJson());
//
//       if(response.statusCode==200){
//         showSuccessDialog(context);
//         assetIdController.clear();
//         assetNameController.clear();
//         categoryNameController.clear();
//         showSuccessDialog(context);
//       }
//       else
//         {
//           showFailureDialog(context);
//         }
//     }
//     catch(e){
//       print(e.toString());
//       showFailureDialog(context);
//     }
//   }

  Future<void> saveAssetDetails() async {
    // if (!formKey.currentState!.validate()) {
    //   return;
    // }

    // String assetId = assetIdController.text.trim();
    String AssetName = assetNameController.text.trim();
    String CategoryName =
        _selectedCategoryName ?? categoryNameController.text.trim();

    Map<String, String> data = {
      'AssetName': AssetName,
      'CategoryName': CategoryName,
    };

    try {
      var response = await http.post(Uri.parse(API.submitAsset),
          body: data);

      if (response.statusCode == 200) {
        // assetIdController.clear();
        assetNameController.clear();
      //  categoryNameController.clear();
        showSuccessDialog(context);
      } else {
        Fluttertoast.showToast(
            msg: 'Failed to submit asset details. Please try again.');
        showFailureDialog(context);
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg:
              'Oops! Asset details submission failed. Please check your network.');
      showFailureDialog(context);
    }
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Text(
                          "Add New Assets",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        DropdownButtonFormField<String>(
                          style: const TextStyle(
                              color: Colors.white,
                              backgroundColor: Color(0XFF0d193e)),
                          hint: const Text(
                            "Select category",
                            style: TextStyle(color: Colors.white),
                          ),
                          value: _selectedCategoryName,
                          isExpanded: true,
                          items: _categoryDropdownData.map((data) {
                            return DropdownMenuItem<String>(
                              value: data,
                              child: Text(data),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategoryName = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a category';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ),
                            ),
                          ),
                        ),
                        // TextFormField(
                        //   style: TextStyle(color: Colors.white),
                        //   decoration: InputDecoration(
                        //       labelText: "Enter Asset ID",
                        //       labelStyle: TextStyle(color: Colors.white),
                        //       border: OutlineInputBorder(
                        //           borderRadius: BorderRadius.circular(20),
                        //           borderSide: BorderSide(color: Colors.red))),
                        // ),
                        TextFormField(
                          controller: assetNameController,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                              labelText: "Enter Asset Name",
                              labelStyle: TextStyle(color: Colors.white),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(color: Colors.red))),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter Asset Name';
                            }
                            return null;
                          },
                        ),
                        RawMaterialButton(
                            fillColor: Colors.blue,
                            splashColor: Colors.blueAccent,
                            shape: StadiumBorder(),
                            onPressed: () {
                              saveAssetDetails();
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 20
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.add_circle,color: Colors.white,),
                                  SizedBox(width: 8,),
                                  Text("Submit Asset",style: TextStyle(color: Colors.white),),
                                ],
                              ),
                            ))
                      ],
                    )),
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
