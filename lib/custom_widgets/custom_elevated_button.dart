import 'package:flutter/material.dart';

class CustomElevatedButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final double? width;
  final double? height;

  const CustomElevatedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width, // Optional width
    this.height, // Optional height
  });

  @override
  _CustomElevatedButtonState createState() => _CustomElevatedButtonState();
}

class _CustomElevatedButtonState extends State<CustomElevatedButton> {
  bool isHovered = false; // Track hover state

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          isHovered = false;
        });
      },
      child: ElevatedButton(
        onPressed: widget.onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // Rounded corners
          ),
          elevation: 0, // Shadow depth
          shadowColor: Colors.black.withAlpha(64), // Shadow color with 25% opacity
          backgroundColor: Colors.transparent, // Required for gradient
          padding: const EdgeInsets.symmetric(vertical: 10), // Vertical padding
        ),
        child: Container(
          height: widget.height ?? 48, // Default height if not provided
          width: widget.width ?? double.infinity, // Default to full width if not provided
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20), // Match the button's rounded corners
            gradient: LinearGradient(
              colors: [
                const Color(0xFF967AA1), // Muted Purple
                const Color(0xFF192A51), // Dark Blue
              ],
              begin: isHovered ? Alignment.bottomCenter : Alignment.topCenter,
              end: isHovered ? Alignment.topCenter : Alignment.bottomCenter,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(64), // Shadow color
                offset: const Offset(0, 4), // Position of shadow
                blurRadius: 4, // Blur effect
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            widget.text,
            style: const TextStyle(
              fontFamily: 'Roboto', // Font family
              fontWeight: FontWeight.w500, // Regular weight
              fontSize: 18, // Font size
              height: 1.4, // Line height (140%)
              color: Colors.white, // Text color
            ),
          ),
        ),
      ),
    );
  }
}
