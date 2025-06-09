import 'package:flutter/material.dart';


showLoading(context) {
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const AlertDialog(
          title: Text("Please Wait"),
          content: SizedBox(
              height: 50, child: Center(child: CircularProgressIndicator())),
        );
      });
}


