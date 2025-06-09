import 'package:flutter/material.dart';

void showCustomSnackBar(BuildContext context, String message, {bool isSuccess = true}) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();

  final snackBar = SnackBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    behavior: SnackBarBehavior.floating,
    padding: EdgeInsets.zero,
    duration: const Duration(seconds: 9),
    content: Builder(
      builder: (snackContext) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 500),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, (1 - value) * 20), // Smooth slide up
              child: Opacity(
                opacity: value, // Smooth fade in
                child: child,
              ),
            );
          },
          child: Center(
            child: Container(
              constraints: const BoxConstraints(minHeight: 55, maxWidth: 900),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSuccess ? const Color(0xFFeaf6ec) : const Color(0xFFffe5e5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  // Left colored bar
                  Container(
                    width: 5,
                    height: 55,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        bottomLeft: Radius.circular(8),
                      ),
                      color: isSuccess ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Icon
                  Icon(
                    isSuccess ? Icons.check : Icons.close,
                    color: isSuccess ? Colors.green : Colors.red,
                    size: 25,
                  ),
                  const SizedBox(width: 8),
                  // Text
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                  // Close Button
                  InkWell(
                    onTap: () {
                      ScaffoldMessenger.maybeOf(snackContext)?.hideCurrentSnackBar();
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(right: 15.0),
                      child: Icon(Icons.close, color: Colors.black, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
