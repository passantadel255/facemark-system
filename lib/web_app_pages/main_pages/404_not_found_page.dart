import 'package:facemark/custom_widgets/custom_elevated_button.dart';
import 'package:facemark/components/headers.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';




class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar:  PreferredSize(
          preferredSize: width > 400 ? const Size.fromHeight(70):const Size.fromHeight(55),
          child:  BasicHeader()
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(
              'assets/images/app_components/404_not_found.webp', // Replace with your image path
              fit: BoxFit.cover,
              width: width >= 800 ? width -width * .6 : width,
            ),
            const SizedBox(height: 50),
            Center(
              child: Text(
                '404 Error - Page Not Found',
                style: TextStyle(fontSize: width >= 800 ? 35:25,
                    fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 20),
            CustomElevatedButton(
              text: "Go Home",
              onPressed: () {
                context.go('/');
              },
              width: 200, // Optional width
              height: 50, // Optional height
            ),
          ],
        ),
      ),
    );
  }
}
