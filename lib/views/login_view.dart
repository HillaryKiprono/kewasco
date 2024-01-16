import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../Technical Department/admin/admin_dashboard.dart';
import '../constants.dart';
import '../controller/simple_ui_controller.dart';
import '../user/models/dbHelper.dart';
import '../user/userPage.dart';


class LoginView extends StatefulWidget {
   LoginView({Key? key}) : super(key: key);
  SimpleUIController simpleUIController = Get.put(SimpleUIController());

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final dbHelper = DatabaseHelper();
  SimpleUIController simpleUIController=Get.put(SimpleUIController());

  TextEditingController nameController = TextEditingController();
  // TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();


  // Future<void> authenticateUser() async {
  //   final String username = nameController.text;
  //   final String password = passwordController.text;
  //
  //   try {
  //     bool isAuthenticated = await dbHelper.authenticateUser(username, password);
  //
  //     if (isAuthenticated) {
  //       // Store the authenticated username in a variable
  //       simpleUIController.setAuthenticatedUsername(username);
  //
  //       // Navigate to home page or perform any desired action
  //       print('User authenticated successfully!');
  //       Get.to(NRWPage());
  //     } else {
  //       // Show an error message or handle invalid credentials
  //       print('Invalid credentials. Authentication failed.');
  //     }
  //   } catch (e) {
  //     // Handle any potential errors during authentication
  //     print('Error during authentication: $e');
  //   }
  // }


  Future<void> authenticateUser() async {
    final String username = nameController.text;
    final String password = passwordController.text;

    try {
      bool isAuthenticated = await dbHelper.authenticateUser(username, password);

      if (isAuthenticated) {
        String? userRole = await dbHelper.getUserRole(username);

        if (userRole != null) {
          if (userRole == 'admin') {
            Get.to(AdminDashboard(username: '',));
          } else if (userRole == 'user') {
            Get.to(NRWPage());
          } else {
            print('Unknown user role: $userRole');
          }
        } else {
          print('User role not found for username: $username');
        }
      } else {
        print('Invalid credentials. Authentication failed.');
      }

      // Store the authenticated username in SimpleUIController
      simpleUIController.setAuthenticatedUsername(username);
    } catch (e) {
      print('Error during authentication: $e');
    }

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
              flex: 4,
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
              flex: 4,
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
                        return 'Please enter some text';
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
            authenticateUser();
          }
        },
        child: const Text('Login',style: TextStyle(color: Colors.white,fontSize: 30),),
      ),
    );
  }
}
