import 'dart:convert';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'Technical Department/admin/admin_dashboard.dart';
import 'Technical Department/api_endpoints/api_connections.dart';
import 'Technical Department/dbHelperClass/databaseHelper.dart';
import 'Technical Department/user/userDashboard.dart';
import 'config.dart';


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

  void _login(BuildContext context) async {
    final String username = _usernameController.text;
    final String password = _passwordController.text;

    try {
      List<Map<String, dynamic>> result = await DatabaseHelper.instance.queryLoginData(
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
    } catch (e) {
      print('Error fetching items from local storage: $e');
      // Handle the error here
      _showErrorDialog(context);
    }
  }

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



  void handleLogin(BuildContext context, String role) {
    if (role == 'Admin') {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                AdminDashboard(username: _usernameController.text)),
      );
      _showSuccessDialog(context); // Show success dialogue for admin login
    } else if (role == 'User') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UserDashboard()),
      );
      _showSuccessDialog(context); // Show success dialogue for user login
    } else {
      _showErrorDialog(
          context); // Show error dialogue for unknown role or error
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
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AdminDashboard(username: username)));
        _showSuccessDialog(context); // Show success dialogue for admin login
      } else if (role == 'User') {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => UserDashboard()));
        _showSuccessDialog(context); // Show success dialogue for user login
      } else {
        _showErrorDialog(
            context); // Show error dialogue for unknown role or error
      }
    }).catchError((error) {
      _showErrorDialog(context); // Show error dialogue for failed login
    });
  }

  void checkedOperatingSystem(BuildContext context) {
    if (Platform.isAndroid) {
      _login(context);
    } else {
      _handleLoginDesktop(context);
    }
  }

   _openDownloadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Download Data'),
          content: Text('Would you like to download the data?'),
          actions: [
            TextButton(
              onPressed: () {

                _downloadData(context); // Close the dialog
                // Perform download logic here
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }

  // method to fetched data from server
  Future<void> fetchDataStoreInDatabase() async {
    const url1 =
        'http://${Config.ipAddress}/Maintenance_Activity_API/modules/fetchData.php';
    const url2 =
        'http://${Config.ipAddress}/Maintenance_Activity_API/modules/fetchWorker.php';
    const url3 =
        'http://${Config.ipAddress}/Maintenance_Activity_API/modules/fetchLogins.php';

    try {
      final response1 = await http.get(Uri.parse(url1));
      final response2 = await http.get(Uri.parse(url2));
      final response3 = await http.get(Uri.parse(url3));
      if (response1.statusCode == 200 &&
          response2.statusCode == 200 &&
          response3.statusCode == 200) {
        final data1 = jsonDecode(response1.body);
        final data2 = jsonDecode(response2.body);
        final data3 = jsonDecode(response3.body);

        await DatabaseHelper.instance.clearTables();

        for (var item in data3) {
          final row3 = {
            'id': item['id'],
            'username': item['username'],
            'password': item['password'],
            'role': item['role']
          };
          await DatabaseHelper.instance.insertLogins(row3);
        }

        for (var item2 in data2) {
          final row2 = {
            'id': item2['id'],
            'workerName': item2['workerName']
          };
          await DatabaseHelper.instance.insertWorkers(row2);
        }

        for(var item1 in data1){
          final row1={
            'id': item1['id'],
            'CategoryName':item1['CategoryName'],
            'AssetName':item1['AssetName'],
            'ActivityName':item1['ActivityName'],
          };
          await DatabaseHelper.instance.insertData(row1);
        }

        // Fluttertoast.showToast(msg: "Uploaded successfully");

      } else {
        Fluttertoast.showToast(msg: "Failed to connect");
      }
    } catch (e) {
      print(e.toString());
    }
  }



  void _downloadData(BuildContext context) async {
    Navigator.pop(context);

     _openDownloadDialog(context);

    bool wifiConnected = await checkWifiConnectivity();

    if (wifiConnected) {
      await downloadAndStoreData(context);
      Fluttertoast.showToast(msg: "Data downloaded successfully");
      Navigator.pop(context);
    } else {
      Fluttertoast.showToast(msg: "Please connect to Wi-Fi before downloading");

    }
  }

  Future<bool> checkWifiConnectivity() async {
    // Implement your logic to check Wi-Fi connectivity here
    // Return true if connected, false if not connected
    return true; // Placeholder value for demonstration
  }

  Future<void> downloadAndStoreData(BuildContext context) async {
    // Implement your logic to download and store data here
    // You can use the fetchDataStoreInDatabase method as before
    Navigator.pop(context);
    await fetchDataStoreInDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white54,

          actions: [
            IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () {
                _openDownloadDialog(context);
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 300,
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/images/water.jpg'),
                        fit: BoxFit.fill)),
                child: Stack(
                  children: [
                    Positioned(
                      left: 30,
                      width: 80,
                      height: 200,
                      child: Container(
                        decoration: const BoxDecoration(
                            image: DecorationImage(
                                image:
                                    AssetImage('assets/images/light-1.png'))),
                      ),
                    ),
                    Positioned(
                      left: 140,
                      width: 80,
                      height: 150,
                      child: Container(
                        decoration: const BoxDecoration(
                            image: DecorationImage(
                                image:
                                    AssetImage('assets/images/light-2.png'))),
                      ),
                    ),
                    Positioned(
                      right: 40,
                      top: 40,
                      width: 80,
                      height: 150,
                      child: Container(
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                image: AssetImage('assets/images/logo.jpeg'))),
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
                            child: TextFormField(

                              controller: _usernameController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                hintText: "Username",
                                hintStyle: TextStyle(color: Colors.grey[400]),
                              ),

                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter your username";
                                }
                                return null;
                              },
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                  hintText: "Password",
                                  hintStyle:
                                      TextStyle(color: Colors.grey[400])),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                return null;
                              },
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
                          borderRadius: BorderRadius.circular(80),
                          gradient: const LinearGradient(colors: [
                            Color.fromRGBO(143, 148, 251, 1),
                            Color.fromRGBO(143, 148, 251, .6),
                          ])),
                      child: SizedBox(
                        width: 100,
                        child:
                        ElevatedButton(
                          onPressed: () {


                                checkedOperatingSystem(context);

                          },
                          style: ElevatedButton.styleFrom(
                              primary: Colors.green,
                              onPrimary: Colors.white,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              textStyle: TextStyle()),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
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
        ));
  }
}
