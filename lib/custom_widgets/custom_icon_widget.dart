import 'package:flutter/material.dart';


class CustomIconWidget extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color iconColor;
  final Color shadowColor;
  final Offset shadowOffset;
  final double blurRadius;

  const CustomIconWidget({super.key, 
    required this.icon,
    this.size = 25.0,
    this.iconColor = const Color(0xFF192A51),
    this.shadowColor = Colors.black,
    this.shadowOffset = const Offset(0, 4),
    this.blurRadius = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Shadow layer
        Text(
          String.fromCharCode(icon.codePoint),
          style: TextStyle(
            height: 1,
            fontSize: size,
            fontFamily: icon.fontFamily,
            color: Colors.transparent,
            shadows: [
              Shadow(
                offset: shadowOffset,
                blurRadius: blurRadius,
                color: shadowColor.withAlpha(64),
              ),
            ],
          ),
        ),
        // Actual icon layer
        Icon(
          icon,
          size: size,
          color: iconColor,
        ),
      ],
    );
  }
}
