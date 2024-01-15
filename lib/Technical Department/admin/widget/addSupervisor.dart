import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../api_endpoints/api_connections2.dart';
import '../resource/app_colors.dart';

class AddSupervisor extends StatefulWidget {
  AddSupervisor({super.key});
  final Color leftBarColor = const Color(0xff53fdd7);
  final Color rightBarColor = const Color(0xffff5182);
  @override
  State<StatefulWidget> createState() => AddSupervisorState();
}

class AddSupervisorState extends State<AddSupervisor> {
  final double width = 7;
  int touchedGroupIndex = -1;

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  //validation methods
  String? validateUsername(String? value){
    if(value==null || value.isEmpty) {
      return "Please enter a username.";
    }
    return null;
  }

  String? validateRole(String? value){
    if(value==null || value.isEmpty){
      return "Please enter a role";
    }
    return null;
  }
  String? validatePassword(String? value){
    if(value==null || value.isEmpty){
      return "Please enter Password";
    }
  }

  Future<void> insertUser() async {
    final url = Uri.parse(API.addSupervisor);
    final response = await http.post(
      url,
      body: {
        'username': usernameController.text,
        'role': roleController.text,
        'password': passwordController.text,
      },
    );

    if (response.statusCode == 200) {
      // User inserted successfully

      usernameController.clear();
      passwordController.clear();
      roleController.clear();

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Success'),
          content: const Text('User inserted successfully.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    } else {
      usernameController.clear();
      passwordController.clear();
      roleController.clear();
      // Failed to insert user
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Error'),
          content: const Text('Failed to insert user.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }


  @override
  void initState() {
    super.initState();



  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Card(
          color: AppColors.purpleLight,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 3,
          child:  AspectRatio(
            aspectRatio: 1.1,
            child: Padding(
              padding: EdgeInsets.all(16),
              child:
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        //makeTransactionsIcon(),
                        Text(
                          'Add Supervisor',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        // Text(
                        //   r'$345,462',
                        //   style: TextStyle(
                        //     color: Colors.white,
                        //     fontSize: 18,
                        //     fontWeight: FontWeight.bold,
                        //   ),
                        // ),
                      ],
                    ),
                  
                    SizedBox(
                      height: 38,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 0),
                      child:
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              const Text(
                                "Adding  Supervisor",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              // TextField(
                              //   controller: CategoryIdController,
                              //   decoration: InputDecoration(
                              //       labelText: "Enter Category Id",
                              //       border: OutlineInputBorder(
                              //           borderRadius:
                              //           BorderRadius.circular(10))),
                              // ),
                              const SizedBox(
                                height: 20,
                              ),
                              Form(
                                key: _formKey,
                                child:
                                Column(

                                  children: [
                                    // Image.asset('assets/images/logo.png'),
                                    TextFormField(
                                      controller: usernameController,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(20))
                                        ),
                                        labelText: 'Username',
                                      ),
                                      validator: validateUsername,
                                    ),
                                    const SizedBox(height: 20,),
                                    TextFormField(
                                      controller: roleController,
                                      decoration: const InputDecoration(
                                          border: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(Radius.circular(20))
                                          ),
                                          labelText: 'Role',
                                          hintText: "The role should be (Admin) or (User) follow this format"
                                      ),
                                      validator: validateRole,
                                    ),
                                    const SizedBox(height: 20,),
                                    TextFormField(
                                      controller: passwordController,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(20))
                                        ),
                                        labelText: 'Password',
                                      ),
                                      obscureText: true,
                                      validator: validatePassword,
                                    ),
                                    const SizedBox(height: 16.0),
                                    ElevatedButton(
                                      onPressed: () {
                                        if (_formKey.currentState!.validate()) {
                                          insertUser();
                                        }
                                      },
                                      child: const Text('Submit'),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 15,
                              ),

                            ],
                          ),
                        ),
                      ),
                    ),


                    SizedBox(
                      height: 12,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

}

