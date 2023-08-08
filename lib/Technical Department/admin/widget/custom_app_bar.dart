import 'package:flutter/material.dart';

import '../resource/app_colors.dart';
import '../resource/app_padding.dart';
import 'responsive_layout.dart';

//List<String> _buttonNames = ["Overview", "Revenue", "Sales", "Control"];
int _currentSelectedButton = 0;

class CustomAppBar extends StatefulWidget {
  const CustomAppBar({super.key});

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.purpleLight,
      child: Row(children: [
        if (ResponsiveLayout.isComputer(context))
          Container(
            margin:  EdgeInsets.all(AppPadding.P10),
            height: double.infinity,
            decoration: const BoxDecoration(boxShadow: [
              BoxShadow(
                color: Colors.black45,
                offset: Offset(0, 0),
                spreadRadius: 1,
                blurRadius: 10,
              )
            ], shape: BoxShape.circle),
            child: CircleAvatar(
              backgroundColor: Colors.deepPurple,
              radius: 30,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.asset(
                  "assets/images/logo.jpeg",
                ),
              ),
            ),
          )
        else
          IconButton(
            color: Colors.white,
            iconSize: 30,
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            icon: const Icon(Icons.menu),
          ),
        const SizedBox(width: AppPadding.P10),

          Padding(
           padding: EdgeInsets.all(0),
            child:Text("TECHNICAL",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),

          ),
        const Spacer(),
        // IconButton(
        //   color: Colors.white,
        //   iconSize: 30,
        //   onPressed: () {},
        //   icon: const Icon(Icons.search),
        // ),
        Stack(
          children: [
            IconButton(
              color: Colors.white,
              iconSize: 30,
              onPressed: () {},
              icon: const Icon(Icons.notifications_none_outlined),
            ),
            const Positioned(
              right: 6,
              top: 6,
              child: CircleAvatar(
                backgroundColor: Colors.pink,
                radius: 8,
                child: Text(
                  "3",
                  style: TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        if (!ResponsiveLayout.isPhoneLimit(context))
          Container(
            margin: const EdgeInsets.all(AppPadding.P10),
            height: double.infinity,
            decoration: const BoxDecoration(boxShadow: [
              BoxShadow(
                color: Colors.black45,
                offset: Offset(0, 0),
                spreadRadius: 1,
                blurRadius: 10,
              )
            ], shape: BoxShape.circle),
            child: const CircleAvatar(
              backgroundColor: AppColors.orange,
              radius: 35,
              backgroundImage: AssetImage(
                "assets/images/profile.png",
              ),
            ),
          ),
      ]),
    );
  }
}
