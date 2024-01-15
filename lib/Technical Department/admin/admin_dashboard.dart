import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:kewasco/Technical%20Department/admin/resource/app_colors.dart';
import 'package:kewasco/Technical%20Department/admin/screen/panel_center_screen.dart';
import 'package:kewasco/Technical%20Department/admin/widget/custom_app_bar.dart';
import 'package:kewasco/Technical%20Department/admin/widget/responsive_layout.dart';
import 'screen/panel_left_screen.dart';

class AdminDashboard extends StatefulWidget {
  AdminDashboard({super.key, required this.username});
  final String username;

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int currentIndex = 1;

  final List<Widget> _icons = const [
    Icon(Icons.add, size: 30),
    Icon(Icons.list, size: 30),
    Icon(Icons.compare_arrows, size: 30),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size(double.infinity, 100),
          child: (ResponsiveLayout.isTinyLimit(context) ||
              ResponsiveLayout.isTinyHeightLimit(context))
              ? Container()
              : const CustomAppBar(),
        ),
        body: ResponsiveLayout(
          tiny: Container(),
          phone: currentIndex == 0
              ? const PanelLeftScreen()
              : currentIndex == 1
              ? const PanelCenterScreen()
              : Container(), // Adjust if needed
          tablet: const Row(
            children: [
              Expanded(child: PanelLeftScreen()),
            ],
          ),
          largeTablet: const Row(
            children: [
              Expanded(child: PanelLeftScreen()),
              Expanded(child: PanelCenterScreen()),
            ],
          ),
          computer: const Row(
            children: [
              Expanded(flex: 4, child: PanelLeftScreen()),
              Expanded(flex: 6, child: PanelCenterScreen()),
            ],
          ),
        ),
        bottomNavigationBar: ResponsiveLayout.isPhoneLimit(context)
            ? CurvedNavigationBar(
          backgroundColor: AppColors.purpleDark,
          color: AppColors.bg,
          index: currentIndex,
          items: _icons,
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },
        )
            : const SizedBox(),
      ),
    );
  }
}
