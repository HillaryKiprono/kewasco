import 'package:flutter/material.dart';
class CustomAppbar extends StatelessWidget {
  const CustomAppbar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 30),
      child: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.000001,
        title: Row(
          children: [
            Image.asset(
              "assets/images/logo.png",
              width: 80,
              height: 100,
            ),
            const Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 14.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      "Kericho Water & Sanitation Company",
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}