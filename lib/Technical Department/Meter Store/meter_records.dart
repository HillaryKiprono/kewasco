import 'package:flutter/material.dart';

class MeterRecords extends StatefulWidget {
  const MeterRecords({super.key});

  @override
  State<MeterRecords> createState() => _MeterRecordsState();
}

class _MeterRecordsState extends State<MeterRecords> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          margin: EdgeInsets.only(top: 20),
          width: double.infinity,
          // color: Colors.blueAccent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                child: const Text(
                  "BIN CARD",
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
              ),
              // SizedBox(height: 10,),
              Container(
                margin: const EdgeInsets.only(
                  left: 100,
                ),
                child:
                    const Text("KERICHO WATER AND SANITATION COMPANY LIMITED"),
              ),

              Container(
                margin: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(

                    children: [
                      Text("Maximum"),
                      Text("_________________________"),
                      Text("Minimum"),
                      Text("_________________________"),
                      Text("Re-order Level"),
                      Text("_______")
                    ],
                  ),
                ),
              ),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  child: const Row(
                    children: [
                      Text("Description"),
                      Text("_________________________"),
                      Text("_________________________"),
                      Text("Part No"),
                      Text("_______________________")
                    ],

                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
