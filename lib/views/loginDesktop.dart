import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:lottie/lottie.dart';
import '../Technical Department/admin/admin_dashboard.dart';
import '../Technical Department/api_endpoints/api_connections.dart';
import '../constants.dart';
import '../controller/simple_ui_controller.dart';
import '../user/models/dbHelper.dart';
import 'package:http/http.dart' as http;

import '../user/models/userModel.dart';
import '../user/userPage.dart';

class LoginDesktop extends StatefulWidget {
  LoginDesktop({Key? key}) : super(key: key);
  SimpleUIController simpleUIController = Get.put(SimpleUIController());

  @override
  State<LoginDesktop> createState() => _LoginDesktopState();
}

class _LoginDesktopState extends State<LoginDesktop> {
  SimpleUIController simpleUIController=Get.put(SimpleUIController());
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> fetchTeamLeadersFromServer() async {
    try {
      final response2 = await http.get(Uri.parse(API.fetchAllTeamLeaders));

      if (response2.statusCode == 200) {
        print("Communicating to the server correctly");

        final dynamic responseData2 = jsonDecode(response2.body);
        print("Team Leaders Response from the server: $responseData2");

        if (responseData2 is Map<String, dynamic> &&
            responseData2.containsKey('data')) {
          final dynamic data2 = responseData2['data'];

          if (data2 is List) {
            bool loginSuccessful = false; // Flag to check if any valid login occurs

            for (var item2 in data2) {
              if (item2 is Map<String, dynamic> &&
                  item2.containsKey('teamLeaderName') &&
                  item2.containsKey("password") &&
                  item2.containsKey("userRole")) {
                final row1 = {
                  'teamLeaderName': item2['teamLeaderName'],
                  'userRole': item2['userRole'],
                  'password': item2['password'],
                };

                // Assuming that you have a User model class
                User user = User.fromJson(row1);

                // Check login credentials
                if (user.teamLeaderName == nameController.text &&
                    user.password == passwordController.text &&
                    ["admin", "user"].contains(user.userRole)) {
                  // Set authenticated user information
                  _handleSuccessfulLogin(user);

                  // Show success alert if not shown before
                  if (!loginSuccessful) {
                    // _showAlertDialog('Login Successful', 'Welcome, ${user.teamLeaderName}!');
                    loginSuccessful = true; // Set the flag to true
                  }
                  else
                    {
                      _showAlertDialog("Login Fails", "Invalid Credentials");
                    }

                  // // Navigate to the appropriate screen
                  // if (user.userRole == "admin") {
                  //   Get.off(() => AdminDashboard(username: '${user.teamLeaderName}'));
                  // } else {
                  //   Get.to(() => NRWPage());
                  // }

                  // Break out of the loop once a valid user is found
                  break;
                }
              }
            }
          } else {
            _showAlertDialog("Login Fails", "Invalid Credentials");
          }
        } else {
          _showAlertDialog("Login Fails", "Invalid Credentials");
        }
      } else {
        _showAlertDialog("Login Fails", "Invalid Credentials");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  void _handleSuccessfulLogin(User user) {
    simpleUIController.setAuthenticatedUsername(user.teamLeaderName);

    // Navigate to the appropriate screen
    if (user.userRole == 'admin') {
       _showAlertDialog('Login Successful', 'Welcome, ${user.teamLeaderName}!');
      Get.off(() => AdminDashboard(username: '',));
    } else if (user.userRole == 'user') {
      _showAlertDialog('Login Successful', 'Welcome, ${user.teamLeaderName}!');
      Get.to(() => NRWPage());
    } else if(!(user.userRole == 'admin') && (!(user.userRole == 'user'))) {
      _showAlertDialog('Invalid Credentials', 'Please check your username and password.');
    }
    else
      {
        _showAlertDialog('Invalid Credentials', 'Please check your username and password.');
      }
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the AlertDialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }



  @override
  void initState() {
   // fetchTeamLeadersFromServer();
     super.initState();

  }


  @override
  void dispose() {
    nameController.dispose();
    passwordController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    SimpleUIController simpleUIController = Get.find<SimpleUIController>();
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        body: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              return _buildLargeScreen(size, simpleUIController);
            } else {
              return _buildSmallScreen(size, simpleUIController);
            }
          },
        ),
      ),
    );
  }

  /// For large screens
  Widget _buildLargeScreen(
      Size size,
      SimpleUIController simpleUIController,
      ) {
    return Column(
      children: [
        RotatedBox(
            quarterTurns: 0,
            child: Image.asset("assets/images/kewasco.jpeg")
          //   Lottie.asset(
          //   'assets/coin.json',
          //   height: size.height * 0.3,
          //   width: double.infinity,
          //   fit: BoxFit.fill,
          // ),
        ),
        Row(
          children: [
            const Expanded(
              flex: 2,
              child: RotatedBox(
                  quarterTurns: 3,
                  child: Text("")
                //   Lottie.asset(
                //   'assets/coin.json',
                //   height: size.height * 0.3,
                //   width: double.infinity,
                //   fit: BoxFit.fill,
                // ),
              ),
            ),
            SizedBox(width: size.width * 0.06),
            Expanded(
              flex: 5,
              child: _buildMainBody(
                size,
                simpleUIController,
              ),
            ),
            const Expanded(
              flex: 2,
              child: RotatedBox(
                  quarterTurns: 0,
                  child: Text("")
                //   Lottie.asset(
                //   'assets/coin.json',
                //   height: size.height * 0.3,
                //   width: double.infinity,
                //   fit: BoxFit.fill,
                // ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// For Small screens
  Widget _buildSmallScreen(
      Size size,
      SimpleUIController simpleUIController,
      ) {
    return Center(
      child: _buildMainBody(
        size,
        simpleUIController,
      ),
    );
  }

  /// Main Body
  Widget _buildMainBody(
      Size size,
      SimpleUIController simpleUIController,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment:
      size.width > 600 ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        size.width > 600
            ? Container()
            : Lottie.asset(
          'assets/wave.json',
          height: size.height * 0.2,
          width: size.width,
          fit: BoxFit.fill,
        ),
        SizedBox(
          height: size.height * 0.03,
        ),
        Center(
          child: Text(
            'Login',
            style: kLoginTitleStyle(size),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Center(
            child: Text(
              'Welcome Back ',
              style: kLoginSubtitleStyle(size),
            ),
          ),
        ),
        SizedBox(
          height: size.height * 0.03,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  style: kTextFormFieldStyle(),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.person),
                    hintText: 'Username',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                  ),
                  controller: nameController,
                  // The validator receives the text that the user has entered.
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter username';
                    } else if (value.length < 4) {
                      return 'at least enter 4 characters';
                    } else if (value.length > 13) {
                      return 'maximum character is 13';
                    }
                    return null;
                  },
                ),

                SizedBox(
                  height: size.height * 0.02,
                ),

                /// password
                Obx(
                      () => TextFormField(
                    style: kTextFormFieldStyle(),
                    controller: passwordController,
                    obscureText: simpleUIController.isObscure.value,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_open),
                      suffixIcon: IconButton(
                        icon: Icon(
                          simpleUIController.isObscure.value
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          simpleUIController.isObscureActive();
                        },
                      ),
                      hintText: 'Password',
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                    ),
                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some Password';
                      } else if (value.length < 7) {
                        return 'at least enter 6 characters';
                      } else if (value.length > 13) {
                        return 'maximum character is 13';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(
                  height: size.height * 0.01,
                ),

                SizedBox(
                  height: size.height * 0.02,
                ),

                /// Login Button
                loginButton(),
                SizedBox(
                  height: size.height * 0.03,
                ),

              ],
            ),
          ),
        ),
      ],
    );
  }

  // Login Button
  Widget loginButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.deepOrange),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
        onPressed: () {
          // Validate returns true if the form is valid, or false otherwise.
          if (_formKey.currentState!.validate()) {
            fetchTeamLeadersFromServer();
          }
        },
        child: const Text('Login',style: TextStyle(color: Colors.white,fontSize: 30),),
      ),
    );
  }
}
