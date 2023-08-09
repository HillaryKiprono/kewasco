import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'Technical Department/admin/admin_dashboard.dart';
import 'Technical Department/api_endpoints/api_connections.dart';
import 'Technical Department/user/userDashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
        'tblLogin',
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
    return  Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 400,
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        image:
                        AssetImage('assets/images/water.jpg'),
                        fit: BoxFit.fill)
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: 30,
                      width: 80,
                      height: 200,
                      child: Container(
                        decoration: const BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage(
                                    'assets/images/light-1.png'))),
                      ),
                    ),
                    Positioned(
                      left: 140,
                      width: 80,
                      height: 150,
                      child: Container(
                        decoration: const BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage(
                                    'assets/images/light-2.png'))),
                      ),
                    ),
                    Positioned(
                      right: 40,
                      top: 40,
                      width: 80,
                      height: 150,
                      child: Container(
                        decoration: const BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage(
                                    'assets/images/clock.png'))),
                      ),
                    ),
                    Positioned(
                      child: Container(
                        margin: const EdgeInsets.only(top: 50),
                        child: const Center(
                          child: Text(
                            "Login",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(
                                color: Color.fromRGBO(143, 148, 251, .2),
                                blurRadius: 20.0,
                                offset: Offset(0, 10))
                          ]),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: const BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(color: Colors.grey))),
                            child: TextField(
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20)
                                  ),
                                  hintText: "Username",
                                  hintStyle:
                                  TextStyle(color: Colors.grey[400])),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20)
                                  ),
                                  hintText: "Password",
                                  hintStyle:
                                  TextStyle(color: Colors.grey[400])),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: const LinearGradient(colors: [
                            Color.fromRGBO(143, 148, 251, 1),
                            Color.fromRGBO(143, 148, 251, .6),
                          ])),
                      child: const Center(
                        child: Text(
                          "Login",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 70,
                    ),
                    // const Text(
                    //   "Forgot Password?",
                    //   style: TextStyle(color: Color.fromRGBO(143, 148, 251, 1)),
                    // ),
                  ],
                ),
              )
            ],
          ),
        ));;
  }
}
