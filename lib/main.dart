import 'package:flutter/material.dart';
import 'package:kewasco/Technical%20Department/admin/widget/testpdf.dart';
import 'package:kewasco/Technical%20Department/admin/widget/uploadDataToSqflite.dart';
import 'package:kewasco/Technical%20Department/user/userDashboard.dart';
import 'package:kewasco/login_screen.dart';
import 'package:kewasco/sign_in.dart';

import 'Technical Department/Meter Store/meter_records.dart';
import 'Technical Department/admin/admin_dashboard.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // theme: ThemeData(primarySwatch: Colors.teal),
      theme: ThemeData().copyWith(
        brightness: Brightness.dark,
            scaffoldBackgroundColor: Colors.black
      ),
      // home:  UploadDataToSqflite(),
     home:  LoginScreen(),
   //  home: AdminDashboard(username: "Hillary"),

    );
  }
}