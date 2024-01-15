import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SingleTextField extends StatelessWidget {
  SingleTextField({
    Key? key,
    required this.title,
    this.iconData,
    this.controller,
    this.readOnly = false,
    this.validator,
  }) : super(key: key);

  final String title;
  final Icon? iconData;
  final bool readOnly;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      child: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.lato(fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 10,
          ),
          TextFormField(
            readOnly: readOnly, // Set readOnly property based on the parameter
            validator: validator,
            controller: controller, // Use the provided controller here
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
