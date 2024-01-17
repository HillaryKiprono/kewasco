import 'package:flutter/material.dart';
import 'package:kewasco/Technical%20Department/admin/widget/addActivity.dart';
import 'package:kewasco/Technical%20Department/admin/widget/addTeamLeader.dart';
import 'package:kewasco/Technical%20Department/admin/widget/add_task.dart';
import 'package:kewasco/Technical%20Department/admin/widget/assignAreaLocation.dart';
import '../resource/app_colors.dart';
import '../resource/app_padding.dart';
import '../widget/add_worker.dart';
import '../widget/responsive_layout.dart';

class Todo {
  String name;
  bool enable;
  Todo({this.enable = true, required this.name});
}

class PanelLeftScreen extends StatefulWidget {
  const PanelLeftScreen({super.key});

  @override
  State<PanelLeftScreen> createState() => _PanelLeftScreenState();
}

class _PanelLeftScreenState extends State<PanelLeftScreen> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.purpleDark,

      body: Stack(
        children: [

          if (ResponsiveLayout.isComputer(context))
            Container(
              color: AppColors.purpleLight,
              width: 50,
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.purpleDark,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                  ),
                ),
              ),
            ),
          SingleChildScrollView(
            child:
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      left: AppPadding.P10 / 2,
                      top: AppPadding.P10 / 2,
                      right: AppPadding.P10 / 2),
                  child: Card(
                      color: Colors.blue.withOpacity(.7),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Container(
                        width: double.infinity,
                        child: const ListTile(
                          title: Center(
                            child: Text(
                              "Registration Panel",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          // subtitle: Text(
                          //   "",
                          //   style: TextStyle(color: Colors.white),
                          // ),

                        ),
                      )),
                ),
                const AddTask(),
                const AddWorker(),
                 AddNewTeamLeader(),
                const AssignAreaLocation(),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: AppPadding.P10 / 2,
                        top: AppPadding.P10 / 2,
                        right: AppPadding.P10 / 2,
                        bottom: AppPadding.P10),
                    child: Card(
                      color: AppColors.purpleLight,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),

                    ))
              ],
            ),
          )
        ],
      ),
    );
  }
}
