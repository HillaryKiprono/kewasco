// // import 'package:flutter/material.dart';
// //
// // class DashboardContent extends StatefulWidget {
// //   const DashboardContent({super.key});
// //
// //   @override
// //   State<DashboardContent> createState() => _DashboardContentState();
// // }
// //
// // class _DashboardContentState extends State<DashboardContent> {
// //   @override
// //   Widget build(BuildContext context) {
// //     return GridView(
// //
// //       gridDelegate:
// //           SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2,crossAxisSpacing: 20,mainAxisSpacing: 20),
// //       children: [
// //         CardViewContent(
// //             iconData: Icons.location_city_outlined,
// //           names: 'Total Location',
// //           number: '6',
// //           colour: Colors.blue,
// //         ),
// //
// //         CardViewContent(
// //           iconData: Icons.people,
// //           names: 'Total Supervisors',
// //           number: '6',
// //           colour: Colors.green,
// //         ),
// //
// //         CardViewContent(
// //           iconData: Icons.task,
// //           names: 'Total tasks',
// //           number: '24',
// //           colour: Colors.deepOrange,
// //         ),
// //
// //         CardViewContent(
// //           iconData: Icons.work_history,
// //           names: 'Total Workers',
// //           number: '17',
// //           colour: Colors.pink,
// //         ),
// //       ],
// //     );
// //   }
// // }
// //
// // class CardViewContent extends StatelessWidget {
// //   final Color colour;
// //   final String number;
// //   final String names;
// //   final IconData iconData;
// //   const CardViewContent({super.key, required this.colour, required this.number, required this.names, required this.iconData});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       decoration: BoxDecoration(
// //         borderRadius: BorderRadius.circular(20),
// //         color: colour
// //       ),
// //       height: 700,
// //       width: 400,
// //       child: Center(child: Column(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           Icon(iconData,color: Colors.white,size: 30,),
// //           Text(number,style: TextStyle(color: Colors.white,fontSize: 18),),
// //           Text(names,style: TextStyle(color: Colors.white,fontSize: 18),),
// //
// //
// //         ],
// //       )),
// //     );
// //   }
// // }
//
// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
//
// import '../admin/api_endpoints/api_connections.dart';
//
// class DashboardContent extends StatefulWidget {
//   const DashboardContent({super.key});
//
//   @override
//   State<DashboardContent> createState() => _DashboardContentState();
// }
//
// class _DashboardContentState extends State<DashboardContent> {
//   int totalLocations = 0;
//   int totalTeamLeaders = 0;
//   int totalTasks = 0;
//   int totalWorkers = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     fetchAllWorkers(); // Call your method to fetch data here
//     fetchAllTask();
//     fetchAllLocation();
//     fetchAllTeamLeaders();
//   }
//
//   Future<void> fetchAllWorkers() async {
//     try {
//       final response = await http.get(Uri.parse(API.fetchAllWorkers)); // Change API endpoint as needed
//
//       if (response.statusCode == 200) {
//         final dynamic jsonData = json.decode(response.body);
//
//         setState(() {
//           // Update the numbers based on the fetched data
//           // Assuming the length of the 'data' array represents the total number of workers
//           totalWorkers = jsonData['data']?.length ?? 0;
//         });
//       } else {
//         print('Failed to fetch data. Status Code: ${response.statusCode}');
//       }
//
//
//     } catch (e) {
//       print('Error: $e');
//     }
//   }
//
//   Future<void> fetchAllTask() async {
//     try {
//       final response = await http.get(Uri.parse(API.fetchAllTask)); // Change API endpoint as needed
//
//       if (response.statusCode == 200) {
//         final dynamic jsonData = json.decode(response.body);
//
//         setState(() {
//           // Update the numbers based on the fetched data
//           // Assuming the length of the 'data' array represents the total number of workers
//           totalTasks = jsonData['data']?.length ?? 0;
//         });
//       } else {
//         print('Failed to fetch data. Status Code: ${response.statusCode}');
//       }
//
//
//     } catch (e) {
//       print('Error: $e');
//     }
//   }
//
//   Future<void> fetchAllLocation() async {
//     try {
//       final response = await http.get(Uri.parse(API.fetchAllAreaLocation)); // Change API endpoint as needed
//
//       if (response.statusCode == 200) {
//         final dynamic jsonData = json.decode(response.body);
//
//         setState(() {
//           // Update the numbers based on the fetched data
//           // Assuming the length of the 'data' array represents the total number of workers
//           totalLocations = jsonData['data']?.length ?? 0;
//         });
//       } else {
//         print('Failed to fetch data. Status Code: ${response.statusCode}');
//       }
//
//
//     } catch (e) {
//       print('Error: $e');
//     }
//   }
//
//   Future<void> fetchAllTeamLeaders() async {
//     try {
//       final response = await http.get(Uri.parse(API.fetchAllTeamLeaders)); // Change API endpoint as needed
//
//       if (response.statusCode == 200) {
//         final dynamic jsonData = json.decode(response.body);
//
//         setState(() {
//           // Update the numbers based on the fetched data
//           // Assuming the length of the 'data' array represents the total number of workers
//           totalTeamLeaders = jsonData['data']?.length ?? 0;
//         });
//       } else {
//         print('Failed to fetch data. Status Code: ${response.statusCode}');
//       }
//
//
//     } catch (e) {
//       print('Error: $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GridView(
//       gridDelegate:
//       const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 20, mainAxisSpacing: 20),
//       children: [
//         CardViewContent(
//           iconData: Icons.location_city_outlined,
//           names: 'Total Location',
//           number: totalLocations.toString(),
//           colour: Colors.blue,
//         ),
//         CardViewContent(
//           iconData: Icons.people,
//           names: 'Total Supervisors',
//           number: totalTeamLeaders.toString(),
//           colour: Colors.green,
//         ),
//         CardViewContent(
//           iconData: Icons.task,
//           names: 'Total tasks',
//           number: totalTasks.toString(),
//           colour: Colors.deepOrange,
//         ),
//         CardViewContent(
//           iconData: Icons.work_history,
//           names: 'Total Workers',
//           number: totalWorkers.toString(),
//           colour: Colors.pink,
//         ),
//       ],
//     );
//   }
// }
//
// class CardViewContent extends StatelessWidget {
//   final Color colour;
//   final String number;
//   final String names;
//   final IconData iconData;
//
//   const CardViewContent(
//       {super.key, required this.colour, required this.number, required this.names, required this.iconData});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: MediaQuery.of(context).size.width * 0.1, // 10% of screen width
//       height: MediaQuery.of(context).size.height * 0.1, // 10% of screen width
//
//
//       decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: colour),
//       // height: 700,
//       // width: 400,
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               iconData,
//               color: Colors.white,
//               size: 30,
//             ),
//             Text(
//               number,
//               style: TextStyle(color: Colors.white, fontSize: 18),
//             ),
//             Text(
//               names,
//               style: TextStyle(color: Colors.white, fontSize: 18),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
