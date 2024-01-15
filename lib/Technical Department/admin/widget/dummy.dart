// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:kewasco_main_app/admin/api_endpoints/api_connections.dart';
// import 'package:http/http.dart' as http;
// import 'package:kewasco_main_app/admin/model/assignLocationModel.dart';
// import '../admin/components/footer.dart';
//
// class AssignAreaLocation extends StatefulWidget {
//   const AssignAreaLocation({Key? key}) : super(key: key);
//
//   @override
//   State<AssignAreaLocation> createState() => _AssignAreaLocationState();
// }
//
// class _AssignAreaLocationState extends State<AssignAreaLocation> {
//   String? selectedTeamLeaderName;
//   String? selectedAreaLocationName;
//
//   TextEditingController areaLocationCodeController = TextEditingController();
//   TextEditingController areaLocationNameController = TextEditingController();
//
//   List<String> teamLeadersList = [];
//   List<String> areaLocationList = [];
//
//   @override
//   void initState() {
//     super.initState();
//     fetchTeamLeaders();
//     fetchLocationName();
//
//     // Initialize with null values
//     selectedTeamLeaderName = null;
//     selectedAreaLocationName = null;
//   }
//
//
//   void showSuccessDialogResponse(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text("Success"),
//           content: const Text("New Area Location Added Successfully"),
//           actions: [
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text("OK"),
//             )
//           ],
//         );
//       },
//     );
//   }
//   void showFailureDialogResponse(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text("Failed"),
//           content: const Text("Failed to add New Area Location "),
//           actions: [
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text("Close"),
//             )
//           ],
//         );
//       },
//     );
//   }
//   Future<void> fetchTeamLeaders() async {
//     try {
//       var response = await http.get(Uri.parse(API.fetchAllTeamLeaders));
//
//       if (response.statusCode == 200) {
//         var data = jsonDecode(response.body);
//         List<String> teamLeaderNames = [];
//
//         if (data['success'] == true) {
//           for (var item in data['data']) {
//             // Assuming your API response has a 'teamLeaderName' field
//             String teamLeaderName = item['teamLeaderName'];
//             teamLeaderNames.add(teamLeaderName);
//           }
//
//           setState(() {
//             teamLeadersList = teamLeaderNames;
//             // Do not set selectedTeamLeaderName here, let it remain as it is
//           });
//         } else {
//           // Handle error from the API
//           print('Error from API: ${data['message']}');
//         }
//       } else {
//         // Handle HTTP error
//         print('Failed to fetch team leaders. Status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       // Handle error
//       print('Error fetching team leaders: $e');
//     }
//   }
//   Future<void> fetchLocationName() async {
//     try {
//       var response = await http.get(Uri.parse(API.fetchAllAreaLocation));
//
//       if (response.statusCode == 200) {
//         var data = jsonDecode(response.body);
//         List<String> areaLocationNames = [];
//
//         if (data['success'] == true) {
//           for (var item in data['data']) {
//             String areaLocationName = item['areaLocationName'];
//             areaLocationNames.add(areaLocationName);
//           }
//
//           setState(() {
//             areaLocationList = areaLocationNames;
//           });
//         } else {
//           // Handle error from the API
//           print('Error from API: ${data['message']}');
//         }
//       } else {
//         // Handle HTTP error
//         print('Failed to fetch area locations. Status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       // Handle error
//       print('Error fetching area locations: $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     selectedTeamLeaderName = teamLeadersList.isNotEmpty ? teamLeadersList[0] : '';
//     selectedAreaLocationName=areaLocationList.isNotEmpty ? areaLocationList[0] : '';
//     return Scaffold(
//       bottomNavigationBar: const footer(),
//       body: Column(
//         children: [
//           const CustomAppBar(),
//           const SizedBox(
//             height: 100,
//           ),
//           Container(
//             width: MediaQuery.of(context).size.width * 0.5,
//             child:
//             DropdownButtonFormField<String>(
//               focusColor: Colors.white,
//               decoration: InputDecoration(
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(20)
//                   )
//               ),
//               value: selectedTeamLeaderName,
//               hint: const Text('Select Team Leader Name'),
//               onChanged: (String? newValue) {
//                 setState(() {
//                   selectedTeamLeaderName = newValue;
//                 });
//               },
//               items: teamLeadersList.map((String value) {
//                 return DropdownMenuItem<String>(
//                   value: value,
//                   child: Text(value),
//                 );
//               }).toList(),
//             ),
//           ),
//           const SizedBox(
//             height: 30,
//           ),
//           Container(
//             width: MediaQuery.of(context).size.width * 0.5,
//             child: DropdownButtonFormField<String>(
//               focusColor: Colors.white,
//               decoration: InputDecoration(
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(20)
//                   )
//               ),
//
//               hint: const Text('Select Area Location Name'),
//               value: selectedAreaLocationName,
//               onChanged: (String? newValue) {
//                 setState(() {
//                   selectedAreaLocationName = newValue ?? '';
//                 });
//               },
//               items: areaLocationList.map((String value) {
//                 return DropdownMenuItem<String>(
//                   value: value,
//                   child: Text(value),
//                 );
//               }).toList(),
//             ),
//           ),
//           const SizedBox(
//             height: 30,
//           ),
//           RawMaterialButton(
//             onPressed: (){},
//             fillColor: Colors.blue,
//             constraints: const BoxConstraints.tightFor(height: 40, width: 150),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Text(
//               "Submit",
//               style: GoogleFonts.abel(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w900,
//                 fontSize: 24,
//               ),
//             ),
//           ),
//         ],
//       ),
//
//     );
//   }
// }
//
// class CustomAppBar extends StatelessWidget {
//   const CustomAppBar({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 80,
//       width: MediaQuery.of(context).size.width,
//       decoration: const BoxDecoration(
//         color: Colors.blueGrey,
//         borderRadius: BorderRadius.only(
//             bottomRight: Radius.circular(50), topLeft: Radius.circular(100)),
//       ),
//       child: const Column(
//         children: [
//           ListTile(
//             title: Center(
//               child: Text(
//                 "Assign Area Location",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 24,
//                 ),
//               ),
//             ),
//             trailing: Padding(
//               padding: EdgeInsets.only(top: 8.0),
//               child: CircleAvatar(
//                 backgroundColor: Colors.white,
//                 radius: 40,
//                 backgroundImage: AssetImage("assets/images/logo.png"),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
