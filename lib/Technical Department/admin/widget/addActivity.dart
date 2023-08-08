import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../config.dart';
import '../../api_endpoints/api_connections.dart';
import '../resource/app_colors.dart';
import '../resource/app_padding.dart';

class AddActivity extends StatefulWidget {
  const AddActivity({super.key});

  @override
  State<StatefulWidget> createState() => AddActivityState();
}

class AddActivityState extends State {
  int touchedIndex = -1;
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController assetController = TextEditingController();
  final TextEditingController activityNameController = TextEditingController();
  final formKeyactivity = GlobalKey<FormState>();

  List<String> _categories = [];
  List<String> _assets = [];
  String? _selectedCategory;
  String? _selectedAsset;

  Future<void> fetchCategories() async {
    final response = await http.get(Uri.parse(
        'http://${Config.ipAddress}/Maintenance_Activity_API/modules/fetchCategoryName.php'));
    if (response.statusCode == 200) {
      List<String> categories = List<String>.from(json.decode(response.body));

      setState(() {
        _categories = categories;
        _selectedCategory = categories.isNotEmpty ? categories[0] : null;
      });

      if (_selectedCategory != null) {
        fetchAssets(_selectedCategory!);
      }
    }
  }

  Future<void> fetchAssets(String category) async {
    final response = await http.get(Uri.parse(
        'http://${Config.ipAddress}/Maintenance_Activity_API/modules/fetchCategoryAsset.php?CategoryName=$category'));
    if (response.statusCode == 200) {
      List<String> assets = List<String>.from(json.decode(response.body));

      setState(() {
        _assets = assets;
        _selectedAsset = assets.isNotEmpty ? assets[0] : null;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCategories();
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
              'Operation completion failed. Please check your internet or inputs.'),
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

  // Submit Activities
  Future<void> saveActivity() async {
    // Get the values from the form fields
    String categoryName = _selectedCategory ?? categoryController.text.trim();
    String assetName = _selectedAsset ?? assetController.text.trim();
    String activityName = activityNameController.text.trim();

    // Validate the form fields
    // if (!formKeyactivity.currentState!.validate()) {
    //   return;
    // }

    // Create a map of the data to be sent in the post request
    Map<String, String> data = {
      'CategoryName': categoryName,
      'AssetName': assetName,
      'ActivityName': activityName,
    };

    // Send the post request to the PHP script on your server that will handle the database insert
    try {
      var response = await http.post(
        Uri.parse(API.submitActivity),
        body: data,
      );

      if (response.statusCode == 200) {
        // If the request was successful, show a toast message
        // Fluttertoast.showToast(
        //     msg: "Congratulations, activity saved successfully");
        showSuccessDialog(context);
        categoryController.clear();
        assetController.clear();
        activityNameController.clear();
      } else {
        // If the request failed, show an error message
        // Fluttertoast.showToast(msg: "Failed to submit activity details");
        showFailureDialog(context);
      }
    } catch (e) {
      // Fluttertoast.showToast(
      //     msg:
      //     "Oops! Sorry, activity submission failed. Please check your network.");
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Text(
                          "Add New Activity",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        DropdownButtonFormField<String>(
                          style: const TextStyle(
                              color: Colors.white,
                              backgroundColor: Color(0XFF0d193e)),
                          hint: const Text("Select category",
                              style: TextStyle(color: Colors.white)),
                          value: _selectedCategory,
                          isExpanded: true,
                          items: _categories.map((data) {
                            return DropdownMenuItem<String>(
                              value: data,
                              child: Text(data),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value;
                            });
                            fetchAssets(value!);
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a category';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                          ),
                        ),
                        DropdownButtonFormField<String>(
                          style: TextStyle(color: Colors.red),
                          value: _selectedAsset,
                          hint: const Text('Select an asset'),
                          onChanged: (newValue) {
                            setState(() {
                              _selectedAsset = newValue!;
                            });
                          },
                          items: _assets
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select an asset';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                          ),
                        ),
                        TextFormField(
                          style: TextStyle(color: Colors.white),
                          controller: activityNameController,
                          decoration: InputDecoration(
                              labelText: "Enter Activity Name",
                              labelStyle: TextStyle(color: Colors.white),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(color: Colors.red))),
                        ),
                        RawMaterialButton(
                          shape: StadiumBorder(),
                            fillColor: Colors.blue,
                            splashColor: Colors.blueAccent,
                            onPressed: () {
                              saveActivity();
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0,horizontal: 20),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.data_saver_on,color: Colors.white,),
                                  SizedBox(width: 10,),
                                  Text("Submit Activity",style: TextStyle(color: Colors.white),),
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
