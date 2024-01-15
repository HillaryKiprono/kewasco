// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:http/http.dart' as http;
// import '../api_endpoints/api_connections2.dart';
//
// class AddSupervisor extends StatefulWidget {
//   const AddSupervisor({super.key});
//
//   @override
//   State<AddSupervisor> createState() => _AddSupervisorState();
// }
//
// class _AddSupervisorState extends State<AddSupervisor> {
//   final TextEditingController usernameController = TextEditingController();
//   final TextEditingController roleController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   //validation methods
//   String? validateUsername(String? value){
//     if(value==null || value.isEmpty) {
//       return "Please enter a username.";
//     }
//     return null;
//   }
//
//   String? validateRole(String? value){
//     if(value==null || value.isEmpty){
//       return "Please enter a role";
//     }
//     return null;
//   }
//   String? validatePassword(String? value){
//     if(value==null || value.isEmpty){
//       return "Please enter Password";
//     }
//   }
//
//   Future<void> insertUser() async {
//     final url = Uri.parse(API.addSupervisor);
//     final response = await http.post(
//       url,
//       body: {
//         'username': usernameController.text,
//         'role': roleController.text,
//         'password': passwordController.text,
//       },
//     );
//
//     if (response.statusCode == 200) {
//       // User inserted successfully
//
//       usernameController.clear();
//       passwordController.clear();
//       roleController.clear();
//
//       showDialog(
//         context: context,
//         builder: (_) => AlertDialog(
//           title: Text('Success'),
//           content: const Text('User inserted successfully.'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text('OK'),
//             ),
//           ],
//         ),
//       );
//     } else {
//       usernameController.clear();
//       passwordController.clear();
//       roleController.clear();
//       // Failed to insert user
//       showDialog(
//         context: context,
//         builder: (_) => AlertDialog(
//           title: Text('Error'),
//           content: const Text('Failed to insert user.'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('OK'),
//             ),
//           ],
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey,
//       appBar: AppBar(
//         title: const Text('Adding New Supervisor'),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Container(
//                   padding: EdgeInsets.all(30),
//                   width: MediaQuery.of(context).size.width*0.8,
//                   height: MediaQuery.of(context).size.height*0.8,
//                   decoration: const BoxDecoration(
//
//                       borderRadius: BorderRadius.all(Radius.circular(20)),
//                       color: Colors.white
//
//                   ),
//
//                   child:
//                   SingleChildScrollView(
//                     child:
//                     Form(
//                       key: _formKey,
//                       child:
//                       Column(
//
//                         children: [
//                           Image.asset('assets/images/logo.png'),
//                           TextFormField(
//                             controller: usernameController,
//                             decoration: const InputDecoration(
//                               border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.all(Radius.circular(20))
//                               ),
//                               labelText: 'Username',
//                             ),
//                             validator: validateUsername,
//                           ),
//                           const SizedBox(height: 20,),
//                           TextFormField(
//                             controller: roleController,
//                             decoration: const InputDecoration(
//                                 border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.all(Radius.circular(20))
//                                 ),
//                                 labelText: 'Role',
//                                 hintText: "The role should be (Admin) or (User) follow this format"
//                             ),
//                             validator: validateRole,
//                           ),
//                           const SizedBox(height: 20,),
//                           TextFormField(
//                             controller: passwordController,
//                             decoration: const InputDecoration(
//                               border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.all(Radius.circular(20))
//                               ),
//                               labelText: 'Password',
//                             ),
//                             obscureText: true,
//                             validator: validatePassword,
//                           ),
//                           const SizedBox(height: 16.0),
//                           ElevatedButton(
//                             onPressed: () {
//                               if (_formKey.currentState!.validate()) {
//                                 insertUser();
//                               }
//                             },
//                             child: const Text('Register'),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }