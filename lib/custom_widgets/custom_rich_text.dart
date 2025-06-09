import 'package:flutter/material.dart';

class CustomRichText extends StatelessWidget {
  final String title;
  final String value;
  final double size;

  const CustomRichText({super.key, required this.title, required this.value, this.size = 16.0});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(fontSize: size, color: Color(0xFF192A51)), // Default text style for the entire RichText
        children: <TextSpan>[
          TextSpan(text: '$title: ', style: TextStyle(fontWeight: FontWeight.normal)),
          TextSpan(text: value, style: TextStyle(fontWeight: FontWeight.w600)), // Semi-bold for value
        ],
      ),
    );
  }
}
