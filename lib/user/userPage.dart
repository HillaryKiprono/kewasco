import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:kewasco/user/storeditems.dart';
import 'package:kewasco/user/viewJobCardFieldData.dart';
import '../Technical Department/api_endpoints/api_connections.dart';
import '../controller/simple_ui_controller.dart';
import 'components/singleTextArea.dart';
import 'components/singleTextField.dart';
import 'models/dbHelper.dart';
import 'models/jobcard.dart';
class NRWPage extends StatefulWidget {
  NRWPage({super.key});

  @override
  State<NRWPage> createState() => _NRWPageState();
}

class _NRWPageState extends State<NRWPage> {
  final dbHelper = DatabaseHelper();
  // final SimpleUIController simpleUIController = Get.find<SimpleUIController>();
  SimpleUIController simpleUIController = Get.put(SimpleUIController());


  TextEditingController latitudeController = TextEditingController();
  TextEditingController longitudeController = TextEditingController();
  TextEditingController departmentController = TextEditingController(text: "Technical Department");
  TextEditingController sectionController = TextEditingController(text: "NRW");
  TextEditingController accountNumberController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController workDescriptionController = TextEditingController();
  TextEditingController materialsUsedController = TextEditingController();
  String formattedStartDate = "";
  String formattedStartTime = "";
  String formattedEndDate = "";
  String initialLatitudes = "0";
  String initialLongtitudes = "0";
  String? selectedWorkStatus;
  String? selectedWorker;
  DateTime selectedStartDate = DateTime.now();
  DateTime selectedEndDate = DateTime.now();
  final myTextController = TextEditingController();
  var reasonValidation = true;
  String? selectedTaskName;
  List<String> task = [];
  List<String> workers = [];
  List<Map<String, dynamic>> _insertedTaskNames = [];
  List<Map<String, dynamic>> _insertedWorkerNames = [];

  void _getLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        latitudeController.text = position.latitude.toString();
        longitudeController.text = position.longitude.toString();
        initialLatitudes = latitudeController.text;
        initialLongtitudes = longitudeController.text.toString();
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _selectStartDate(
      BuildContext context, DateTime initialDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2024),
    );

    if (picked != null && picked != selectedStartDate) {
      setState(() {
        selectedStartDate = picked;
        formattedStartDate = DateFormat('yyyy-MM-dd').format(selectedStartDate);
        if (kDebugMode) {
          print("Formatted Start Date: $formattedStartDate");
        }
      });
    }
  }

  Future<void> _selectedEndDate(
      BuildContext context, DateTime initialDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2024),
    );

    if (picked != null && picked != selectedEndDate) {
      setState(() {
        selectedEndDate = picked;
        formattedEndDate = DateFormat('yyyy-MM-dd').format(selectedEndDate);
      });
    }
  }

  String formattedCompletionTime = "";
  DateTime selectedCompletionTime = DateTime.now();

  Future<void> _selectedCompletionTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedCompletionTime),
    );

    if (pickedTime != null) {
      final DateTime combinedDateTime = DateTime(
        selectedCompletionTime.year,
        selectedCompletionTime.month,
        selectedCompletionTime.day,
        pickedTime.hour,
        pickedTime.minute,
      );

      setState(() {
        selectedCompletionTime = combinedDateTime;
        formattedCompletionTime =
            "${selectedCompletionTime.hour}:${selectedCompletionTime.minute}";
      });
    }
  }

  String formattedStartedTime = "";
  DateTime selectedStartTime = DateTime.now();

  Future<void> _selectedStartTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedStartTime),
    );

    if (pickedTime != null) {
      final DateTime combinedDateTime = DateTime(
        selectedStartTime.year,
        selectedStartTime.month,
        selectedStartTime.day,
        pickedTime.hour,
        pickedTime.minute,
      );

      setState(() {
        selectedStartTime = combinedDateTime;
        formattedStartedTime =
            "${selectedStartTime.hour}:${selectedStartTime.minute}";
      });
    }
  }

  Future<void> fetchTaskFromServer() async {
    try {
      final response1 = await http.get(Uri.parse(API.fetchAllTask));

      if (response1.statusCode == 200 ) {
        print("Communicating to server correctly");

        final dynamic responseData1 = jsonDecode(response1.body);
        print("Response Data from server: $responseData1");

        if (responseData1 is Map<String, dynamic> &&
            responseData1.containsKey('data')) {
          final dynamic data1 = responseData1['data'];

          await dbHelper.clearTables();

          if (data1 is List) {
            for (var item1 in data1) {
              if (item1 is Map<String, dynamic> &&
                  item1.containsKey('taskName')) {
                final row1 = {
                  'taskName': item1['taskName'],
                };
                await dbHelper.insertTask(row1);
                final List<Map<String, dynamic>> storedTask = await dbHelper.queryAllTask();
              }
            }
          }  else {
            print("Invalid data structure for 'data' field: $data1");
          }
        } else {
          print("Invalid data structure: $responseData1");
        }
      } else {
        print("Failed to connect");
      }
    } catch (e) {
      print(e.toString());
    }
  }


  Future<void> fetchWorkersFromServer() async {
    try {
      final response2 = await http.get(Uri.parse(API.fetchAllWorkers));

      if (response2.statusCode == 200 ) {
        print("Communicating to server correctly");

        final dynamic responseData2 = jsonDecode(response2.body);
        print("Response Data from server: $responseData2");

        if (responseData2 is Map<String, dynamic> &&
            responseData2.containsKey('data')) {
          final dynamic data2 = responseData2['data'];

          await dbHelper.clearTables();

          if (data2 is List) {
            for (var item2 in data2) {
              if (item2 is Map<String, dynamic> &&
                  item2.containsKey('workerName')) {
                final row1 = {
                  'workerName': item2['workerName'],
                };
                await dbHelper.insertWorker(row1);
                final List<Map<String, dynamic>> storedWorker = await dbHelper.queryAllWorkers();
              }
            }
          }  else {
            print("Invalid data structure for 'data' field: $data2");
          }
        } else {
          print("Invalid data structure: $responseData2");
        }
      } else {
        print("Failed to connect");
      }
    } catch (e) {
      print(e.toString());
    }
  }
  Future<void> fetchTeamLeadersFromServer() async {
    try {
      final response2 = await http.get(Uri.parse(API.fetchAllTeamLeaders));

      if (response2.statusCode == 200 ) {
        print("Communicating to server correctly");

        final dynamic responseData2 = jsonDecode(response2.body);
        print("Team Leaders Response  from server: $responseData2");

        if (responseData2 is Map<String, dynamic> &&
            responseData2.containsKey('data')) {
          final dynamic data2 = responseData2['data'];

          await dbHelper.clearTables();

          if (data2 is List) {
            for (var item2 in data2) {
              if (item2 is Map<String, dynamic> &&
                  item2.containsKey('teamLeaderName') && item2.containsKey("password")) {
                final row1 = {
                  'teamLeaderName': item2['teamLeaderName'],
                  'password': item2['password'],
                };
                await dbHelper.insertTeamLeader(row1);
                final List<Map<String, dynamic>> storedTeamLeader = await dbHelper.queryAllTeamLeaders();
                print("*****************************StoredLeaders $storedTeamLeader");
              }
            }
          }  else {
            print("Invalid data structure for 'data' field: $data2");
          }
        } else {
          print("Invalid data structure: $responseData2");
        }
      } else {
        print("Failed to connect");
      }
    } catch (e) {
      print(e.toString());
    }
  }
  Future<List<Map<String, dynamic>>> fetchStoredTaskFromDatabase() async {
    // Call the queryAllTask function to get all tasks from the database
    final List<Map<String, dynamic>> storedTask = await dbHelper.queryAllTask();

     _insertedTaskNames=storedTask;
     print(_insertedTaskNames[0]);

    return storedTask;
  }
  Future<List<Map<String, dynamic>>> fetchStoredWorkersFromSqflite() async {
    // Call the queryAllTask function to get all tasks from the database
    final List<Map<String, dynamic>> storedWorkers = await dbHelper.queryAllWorkers();

    _insertedWorkerNames=storedWorkers;

    return storedWorkers;
  }
  Future<void> saveDetailsToLocalStorage() async {
    // Check if a work status was selected
    if (selectedWorkStatus != null) {
      // Create a JobCard instance to store the details
      JobCard jobCard = JobCard(
        accountNo: accountNumberController.text,
        dateStarted: formattedStartDate,
        timeStarted: formattedStartedTime,
        department: departmentController.text,
        section: sectionController.text,
        selectedTaskName: selectedTaskName.toString(),
        workLocation: locationController.text,
        northings: longitudeController.text,
        eastings: latitudeController.text,
        workStatus: selectedWorkStatus.toString(),
        dateCompleted: formattedEndDate,
        timeCompleted: formattedCompletionTime,
        workDescription: workDescriptionController.text,
        material: materialsUsedController.text,
        assignedWorker: selectedWorker.toString(),
        username: simpleUIController.authenticatedUsername.toString(),
      );

      // Insert jobCard into the database
      await dbHelper.insertJobCard(jobCard);
      print('Details saved to SQLite database: $jobCard');
      accountNumberController.clear();
      locationController.clear();
      longitudeController.clear();
      latitudeController.clear();
      selectedWorkStatus = "";
      workDescriptionController.clear();
      materialsUsedController.clear();
      selectedWorker="";
      selectedTaskName="";
    } else {
      // Handle the case where no work status is selected
      print('Please select a work status');
    }
  }
  Future<void> fetchTask() async {
 //   final db = await dbHelper.database;
    final List<Map<String, dynamic>> taskData = await dbHelper.queryAllTask();
    final List<String> fetchTask =
    taskData.map((record) => record['taskName'] as String).toList();

    setState(() {
      task = fetchTask;
      print(task);
    });
  }
  Future<void> fetchWorkers() async {
  //  final db = await dbHelper.database;
    final List<Map<String, dynamic>> workerData = await dbHelper.queryAllWorkers();
    final List<String> fetchWorker =
    workerData.map((record) => record['workerName'] as String).toList();

    setState(() {
      workers = fetchWorker;
      print(workers);
    });
  }

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    fetchTask();
    fetchWorkers();
    fetchStoredTaskFromDatabase();
    fetchStoredTaskFromDatabase();

    // Format initial dates and times
    formattedStartDate = DateFormat('yyyy-MM-dd').format(selectedStartDate);
    formattedStartedTime =
        "${selectedStartTime.hour}:${selectedStartTime.minute}";
    formattedEndDate = DateFormat('yyyy-MM-dd').format(selectedEndDate);
    formattedCompletionTime =
        "${selectedCompletionTime.hour}:${selectedCompletionTime.minute}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: CustomViewAppBar(),
      // PreferredSize(
      //   preferredSize: const Size(150, 130),
      //   child: Container(
      //     margin: const EdgeInsets.only(top: 30),
      //     child: AppBar(
      //       backgroundColor: Colors.white,
      //       elevation: 0.000001,
      //       title: Row(
      //
      //         children: [
      //           Image.asset(
      //             "assets/images/logo.png",
      //             width: 80,
      //             height: 100,
      //           ),
      //           const Expanded(
      //             child: Padding(
      //               padding: EdgeInsets.only(top: 14.0),
      //               child: Column(
      //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //                 children: [
      //                   Text(
      //                     "Kericho Water & Sanitation Company",
      //                     maxLines: 2,
      //                     textAlign: TextAlign.center,
      //                     style: TextStyle(color: Colors.black),
      //                   ),
      //                 ],
      //               ),
      //             ),
      //           ),
      //         ],
      //       ),
      //
      //     ),
      //   ),
      // ),
      body: SafeArea(
        child:
        SingleChildScrollView(
          child: Column(
            children: [
            Container(
                margin: const EdgeInsets.only(top: 10),
                child: ListTile(
                  title: Row(
                      children: [
                        Image.asset(
                          "assets/images/kewasco.jpeg",
                          width: 120,
                          height: 120,
                        ),
                        const Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(top: 0.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  "Kericho Water & Sanitation Company",
                                   textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                ),

                ),


              const Text(
                "JOB CARD",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.w400),
              ),
              const IntrinsicHeight(
                child: Divider(
                  height: 8,
                  color: Colors.black,
                  endIndent: 0,
                  indent: 0,
                  thickness: 8,
                ),
              ),
              const SizedBox(
                height: 4,
              ),
              const IntrinsicHeight(
                child: Divider(
                  height: 4,
                  color: Colors.black,
                  endIndent: 0,
                  indent: 0,
                  thickness: 4,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // SingleTextField(
                      //   title: "Job Card No",
                      // ),
                      Center(
                        child: GetBuilder<SimpleUIController>(
                          builder: (controller) {
                            return Row(
                              children: [
                                ElevatedButton(onPressed: () {
                              // Navigate to the stored data screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => StoredDataScreen()),
                              );
                            }, child: Text("View ")),
                                Text(
                                  'Welcome, ${controller.authenticatedUsername}',
                                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                                ),
                              ],
                            );
                          },
                        ),
                      ),

                      const SizedBox(
                        height: 8,
                      ),
                      
                      SingleTextField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Account No or Phone Number Required';
                          }
                          return null; // Return null if the validation succeeds
                        },

                        title: "Account No / Phone No",
                        controller: accountNumberController,
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Text("Start Date"),
                        const SizedBox(
                          height: 8,
                        ),
                        Container(
                          height: 40,
                          width: 150,
                          decoration: BoxDecoration(
                              color: const Color(0xFFE9EFF0),
                              borderRadius: BorderRadius.circular(20)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                "${selectedStartDate.day}/${selectedStartDate.month}/${selectedStartDate.year}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  _selectStartDate(context,
                                      selectedStartDate.add(Duration(days: 0)));
                                },
                                child: const Icon(
                                  Icons.calendar_today_outlined,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: Container(
                      child: Column(
                        children: [
                          const Text("Start Time"),
                          const SizedBox(
                            height: 8,
                          ),
                          Container(
                            height: 40,
                            width: 150,
                            decoration: BoxDecoration(
                                color: const Color(0xFFE9EFF0),
                                borderRadius: BorderRadius.circular(20)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  formattedStartedTime,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    _selectedStartTime(context);
                                  },
                                  child: const Icon(
                                    Icons.access_time,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              SingleTextField(
                title: "Department",
                controller: departmentController,
                readOnly: true,
              ),
              const SizedBox(
                height: 8,
              ),
              SingleTextField(
                title: "Section",
                readOnly: true,
                controller: sectionController,
              ),
              const SizedBox(
                height: 8,
              ),
              const Text("Select Task"),

              Padding(
                padding: const EdgeInsets.all(10),
                child: Container(

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(width: 2, color: Colors.grey),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedTaskName,
                      hint: const Text('Select Task'),
                      onChanged: (value) {
                        setState(() {
                          // Update selected activity
                          selectedTaskName = value;
                        });
                      },
                      items: task.map((newTask) {
                        return DropdownMenuItem<String>(
                          value: newTask,
                          child: Text(newTask),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),


              const SizedBox(
                height: 8,
              ),
              SingleTextField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Location Required';
                  }
                  return null; // Return null if the validation succeeds
                },
                title: "Location",
                controller: locationController,
              ),
              const SizedBox(
                height: 8,
              ),
              Row(
                children: [
                  Expanded(
                      child: SingleTextField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Northings Required';
                          }
                          return null; // Return null if the validation succeeds
                        },
                    title: "Northings",
                    controller: longitudeController,
                  )),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                      child: SingleTextField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Eastings Required';
                          }
                          return null; // Return null if the validation succeeds
                        },
                    title: "Eastings",
                    controller: latitudeController,
                  )),
                  const SizedBox(
                    width: 8,
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: RawMaterialButton(
                  onPressed: () {
                    _getLocation();
                  },
                  fillColor: Colors.orangeAccent,
                  // shape:  RoundedRectangleBorder(borderRadius: Radius.circular(20),),
                  shape: StadiumBorder(),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Click here to get Location",
                      style: GoogleFonts.aleo(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              SingleTextArea(
                title: 'Work Description',
                controller: workDescriptionController,
              ),
              const Text("Work Status"),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: DropdownButtonFormField<String>(
                  value: selectedWorkStatus,
                  items: const [
                    DropdownMenuItem<String>(
                      value: "Yes",
                      child: Text("Yes"),
                    ),
                    DropdownMenuItem<String>(
                      value: "No",
                      child: Text("No"),
                    ),
                    DropdownMenuItem<String>(
                      value: "Pending",
                      child: Text("Pending"),
                    ),
                  ],
                  onChanged: (String? selected) {
                    setState(() {
                      selectedWorkStatus = selected!;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: "Work Status",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(20),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Text("Completion Date"),
                        const SizedBox(
                          height: 8,
                        ),
                        Container(
                          height: 40,
                          width: 150,
                          decoration: BoxDecoration(
                              color: const Color(0xFFE9EFF0),
                              borderRadius: BorderRadius.circular(20)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                "${selectedEndDate.day}/${selectedEndDate.month}/${selectedEndDate.year}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  _selectedEndDate(context,
                                      selectedEndDate.add(Duration(days: 0)));
                                },
                                child: const Icon(
                                  Icons.calendar_today_outlined,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: Container(
                      child: Column(
                        children: [
                          const Text("Completion Time"),
                          const SizedBox(
                            height: 8,
                          ),
                          Container(
                            height: 40,
                            width: 150,
                            decoration: BoxDecoration(
                                color: const Color(0xFFE9EFF0),
                                borderRadius: BorderRadius.circular(20)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  "${formattedCompletionTime}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    _selectedCompletionTime(context);
                                  },
                                  child: const Icon(
                                    Icons.access_time,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              SingleTextArea(
                title: 'Material Used/Further Recommendation',
                controller: materialsUsedController,
              ),
              const SizedBox(
                height: 8,
              ),
              const Row(
                children: [

                  SizedBox(
                    width: 20,
                  ),
                  // Expanded(
                  //   child: SingleTextField(
                  //     title: "Supervisor Signature",
                  //   ),
                  // ),
                ],
              ),

              Text("Select Worker"),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(width: 2, color: Colors.grey),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedWorker,
                      hint: const Text('Please select worker name'),
                      onChanged: (value) {
                        setState(() {
                          // Update selected activity
                          selectedWorker = value;
                        });
                      },
                      items: workers.map((newWorker) {
                        return DropdownMenuItem<String>(
                          value: newWorker,
                          child: Text(newWorker),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),



              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  RawMaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    fillColor: Colors.orangeAccent,
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    onPressed: () {
                      if(_formKey.currentState!.validate() ?? false){
                        saveDetailsToLocalStorage();
                      }

                    },
                    child: Text(
                      "Submit Data",
                      style: GoogleFonts.abel(fontSize: 20, color: Colors.white),
                    ),
                  ),
                  RawMaterialButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    fillColor: Colors.orangeAccent,
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const ViewJobCardFieldData()));
                    },
                    child: const Text(
                      "View Data",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
