// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:kewasco_activity_maintenance/AdminModule/adminDashboard.dart';
// import 'package:kewasco_activity_maintenance/userDashboard/userdashboard.dart';
// import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';
// import 'api_connection/api_connection.dart';
// import 'dart:io';
//
// class LoginScreen extends StatefulWidget {
//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   final TextEditingController _usernameController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final formKey = GlobalKey<FormState>();
//   List<dynamic> loginData = []; // Variable to store fetched login data
//   List<dynamic>? storedData;
//
//   void _showSuccessDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Login Successful'),
//           content: const Text('You have successfully logged in.'),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 // Perform any other desired action after successful login
//               },
//               child: const Text('OK'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _showErrorDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Login Error'),
//           content: const Text('Wrong username or password.'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('OK'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void loginInAndroid(BuildContext context) async {
//     final String username = _usernameController.text;
//     final String password = _passwordController.text;
//
//     try {
//       var databasesPath = await getDatabasesPath();
//       var path = join(databasesPath, 'kewasco.db');
//
//       var database = await openDatabase(
//         path,
//         version: 1,
//         onCreate: (db, version) async {
//           // Database creation code...
//         },
//       );
//
//       var result = await database.query(
//         'tblLogins',
//         where: 'username = ? AND password = ?',
//         whereArgs: [username, password],
//       );
//
//       if (result.isNotEmpty) {
//         final role = result.first['role'].toString();
//
//         if (role == 'Admin') {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => AdminDashboard(username: username)),
//           );
//           _showSuccessDialog(context); // Show success dialogue for admin login
//         } else if (role == 'User') {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => UserDashboard()),
//           );
//           _showSuccessDialog(context); // Show success dialogue for user login
//         } else {
//           _showErrorDialog(context); // Show error dialogue for unknown role or error
//         }
//       } else {
//         _showErrorDialog(context); // Show error dialogue for incorrect username or password
//       }
//
//       await database.close();
//     } catch (e) {
//       print('Error fetching items from local storage: $e');
//       // showFailureDialog(context);
//     }
//   }
//
//   Future<String> loginInDesktop(String username, String password) async {
//     final response = await http.post(
//       Uri.parse(API.submitLogin),
//       body: {'username': username, 'password': password},
//     );
//
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//
//       return data['role'];
//     } else if (response.statusCode == 401) {
//       throw Exception('Incorrect username or password');
//     } else {
//       throw Exception('Failed to login');
//     }
//   }
//
//   void _handleLoginDesktop(BuildContext context) {
//     final String username = _usernameController.text;
//     final String password = _passwordController.text;
//
//     loginInDesktop(username, password).then((role) {
//       if (role == 'Admin') {
//         Navigator.push(context, MaterialPageRoute(builder: (context) => AdminDashboard(username: username)));
//         _showSuccessDialog(context); // Show success dialogue for admin login
//       } else if (role == 'User') {
//         Navigator.push(context, MaterialPageRoute(builder: (context) => UserDashboard()));
//         _showSuccessDialog(context); // Show success dialogue for user login
//       } else {
//         _showErrorDialog(context); // Show error dialogue for unknown role or error
//       }
//     }).catchError((error) {
//       _showErrorDialog(context); // Show error dialogue for failed login
//     });
//   }
//
//   void checkedOperatingSystem(BuildContext context) {
//     if (Platform.isAndroid) {
//       loginInAndroid(context);
//     } else {
//       _handleLoginDesktop(context);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white70,
//       body: Center(
//         child: Container(
//           width: MediaQuery.of(context).size.width * 0.8,
//           height: MediaQuery.of(context).size.height * 0.6,
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Form(
//             key: formKey,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Container(
//                   child: Image.asset('assets/images/logo.png'),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 15),
//                   child: Container(
//                     width: MediaQuery.of(context).size.width * 0.8,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(20.0),
//                       border: Border.all(width: 2, color: Colors.grey),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 15),
//                       child: TextFormField(
//                         controller: _usernameController,
//                         decoration: const InputDecoration(
//                           labelText: 'Enter Username',
//                         ),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return "Please enter your username";
//                           }
//                           return null;
//                         },
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 20,
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 15),
//                   child: Container(
//                     width: MediaQuery.of(context).size.width * 0.8,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(20.0),
//                       border: Border.all(width: 2, color: Colors.grey),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 15),
//                       child: TextFormField(
//                         controller: _passwordController,
//                         obscureText: true,
//                         decoration: const InputDecoration(
//                           labelText: 'Enter Password',
//                         ),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter your password';
//                           }
//                           return null;
//                         },
//                       ),
//                     ),
//                   ),
//                 ),
//                 ElevatedButton(
//
//                   onPressed: () {
//                     if (formKey.currentState!.validate()) {
//                       checkedOperatingSystem(context);
//                     }
//                   },
//                   style: ElevatedButton.styleFrom(
//                     primary: Colors.blue,
//                     onPrimary: Colors.white,
//                     padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 8),
//                     shape: const RoundedRectangleBorder(
//
//                     )
//                   ),
//                   child: const Text('Login'),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'Technical Department/admin/admin_dashboard.dart';
import 'Technical Department/api_endpoints/api_connections2.dart';
import 'Technical Department/user/userDashboard.dart';

import 'dart:io';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  List<dynamic> loginData = []; // Variable to store fetched login data

  List<dynamic>? storedData;

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Login Successful'),
          content: const Text('You have successfully logged in.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Perform any other desired action after successful login
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Login Error'),
          content: const Text('Wrong username or password.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void loginInAndroid(BuildContext context) async {
    final String username = _usernameController.text;
    final String password = _passwordController.text;

    try {
      var databasesPath = await getDatabasesPath();
      var path = join(databasesPath, 'maintenance.db');

      var database = await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          // Database creation code...
        },
      );

      var result = await database.query(
        'tblLogins',
        where: 'username = ? AND password = ?',
        whereArgs: [username, password],
      );

      if (result.isNotEmpty) {
        final role = result.first['role'].toString();

        if (role == 'Admin') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AdminDashboard(username: username)),
          );
          _showSuccessDialog(context); // Show success dialogue for admin login
        } else if (role == 'User') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UserDashboard()),
          );
          _showSuccessDialog(context); // Show success dialogue for user login
        } else {
          _showErrorDialog(context); // Show error dialogue for unknown role or error
        }
      } else {
        _showErrorDialog(context); // Show error dialogue for incorrect username or password
      }

      await database.close();
    } catch (e) {
      print('Error fetching items from local storage: $e');
      // showFailureDialog(context);
    }
  }

  // void loginInAndroid(BuildContext context) async {
  //   final String username = _usernameController.text;
  //   final String password = _passwordController.text;
  //
  //   if (storedData == null || storedData!.isEmpty) {
  //     try {
  //       final role = await loginInDesktop(username, password);
  //       handleLogin(context, role);
  //     } catch (e) {
  //       print('Error fetching items from backend API: $e');
  //       _showErrorDialog(context);
  //     }
  //   } else {
  //     try {
  //       var databasesPath = await getDatabasesPath();
  //       var path = join(databasesPath, 'kewasco.db');
  //
  //       var database = await openDatabase(
  //         path,
  //         version: 1,
  //         onCreate: (db, version) async {
  //           // Database creation code...
  //         },
  //       );
  //
  //       var result = await database.query(
  //         'tblLogins',
  //         where: 'username = ? AND password = ?',
  //         whereArgs: [username, password],
  //       );
  //
  //       if (result.isNotEmpty) {
  //         final role = result.first['role'].toString();
  //         handleLogin(context, role);
  //       } else {
  //         _showErrorDialog(context); // Show error dialogue for incorrect username or password
  //       }
  //
  //       await database.close();
  //     } catch (e) {
  //       print('Error fetching items from local storage: $e');
  //       _showErrorDialog(context);
  //     }
  //   }
  // }

  void handleLogin(BuildContext context, String role) {
    if (role == 'Admin') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AdminDashboard(username: _usernameController.text)),
      );
      _showSuccessDialog(context); // Show success dialogue for admin login
    } else if (role == 'User') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UserDashboard()),
      );
      _showSuccessDialog(context); // Show success dialogue for user login
    } else {
      _showErrorDialog(context); // Show error dialogue for unknown role or error
    }
  }


  Future<String> loginInDesktop(String username, String password) async {
    final response = await http.post(
      Uri.parse(API.submitLogin),
      body: {'username': username, 'password': password},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      return data['role'];
    } else if (response.statusCode == 401) {
      throw Exception('Incorrect username or password');
    } else {
      throw Exception('Failed to login');
    }
  }

  void _handleLoginDesktop(BuildContext context) {
    final String username = _usernameController.text;
    final String password = _passwordController.text;

    loginInDesktop(username, password).then((role) {
      if (role == 'Admin') {
        Navigator.push(context, MaterialPageRoute(builder: (context) => AdminDashboard(username: username)));
        _showSuccessDialog(context); // Show success dialogue for admin login
      } else if (role == 'User') {
        Navigator.push(context, MaterialPageRoute(builder: (context) => UserDashboard()));
        _showSuccessDialog(context); // Show success dialogue for user login
      } else {
        _showErrorDialog(context); // Show error dialogue for unknown role or error
      }
    }).catchError((error) {
      _showErrorDialog(context); // Show error dialogue for failed login
    });
  }

  void checkedOperatingSystem(BuildContext context) {
    if (Platform.isAndroid) {
      loginInAndroid(context);
    } else {
      _handleLoginDesktop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: Image.asset('assets/images/logo.png'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(width: 2, color: Colors.grey),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                            labelText: 'Enter Username',
                            icon: Icon(Icons.person)
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your username";
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(width: 2, color: Colors.grey),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: TextFormField(

                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          icon: Icon(Icons.vpn_key),
                          // hintText: "Enter Password",
                          labelText: 'Enter Password',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20,),
                SizedBox(
                  width: 100,
                  child: ElevatedButton(

                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        checkedOperatingSystem(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(

                        primary: Colors.green,
                        onPrimary: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 16,vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),

                        ),
                        textStyle: TextStyle(

                        )
                    ),
                    child: const Text('Login',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}