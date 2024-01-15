import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:text_area/text_area.dart';

class SingleTextArea extends StatelessWidget {
  SingleTextArea({Key? key, required this.title, this.controller})
      : super(key: key);

  final TextEditingController? controller;
  var reasonValidation = true;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.lato(fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 10,
          ),
          TextArea(
            borderRadius: 10,
            borderColor: const Color(0xFFCFD6FF),
            textEditingController: controller,
            suffixIcon: Icons.attach_file_rounded,
            onSuffixIconPressed: () => {},
            validation: reasonValidation,
            errorText: reasonValidation ? null : 'Please type a work description!',
          ),
        ],
      ),
    );
  }
}
