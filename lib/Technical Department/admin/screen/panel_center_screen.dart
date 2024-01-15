import 'package:flutter/material.dart';
import 'package:kewasco/Technical%20Department/admin/widget/viewAllTeamLeaders.dart';
import 'package:kewasco/Technical%20Department/admin/widget/viewAllWorkers.dart';
import 'package:kewasco/Technical%20Department/admin/widget/viewAssignAreaLocation.dart';
import '../resource/app_colors.dart';
import '../resource/app_padding.dart';
import '../widget/addSupervisor.dart';
import '../widget/add_worker.dart';
import '../widget/viewTask.dart';

class PanelCenterScreen extends StatefulWidget {
  const PanelCenterScreen({super.key});

  @override
  State<PanelCenterScreen> createState() => _PanelCenterScreenState();
}

class _PanelCenterScreenState extends State<PanelCenterScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
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
                          "View  ALL",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      // subtitle: Text(
                      //   "82% of Products Avail.",
                      //   style: TextStyle(color: Colors.white),
                      // ),
                    ),
                  )),
            ),

            ViewAllTask(),
             ViewAllWorkers(),
            ViewAllTeamLeaders(),
            ViewAllAssignAreaLocation()
            // AddSupervisor(),
          ],
        ),
      ),
    );
  }
}
