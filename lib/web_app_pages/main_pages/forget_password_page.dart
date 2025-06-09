import 'package:facemark/custom_widgets/custom_elevated_button.dart';
import 'package:facemark/custom_widgets/hex_color.dart';
import 'package:flutter/material.dart';
import 'package:facemark/services/authntcation-service.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({super.key});

  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  final TextEditingController _emailController = TextEditingController();




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            'assets/images/app_components/splash-page-background.png', // Replace with your background image path
            fit: BoxFit.cover,
          ),
          // Form
          Center(
            child: SizedBox(
              width: 680,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  elevation: 8.0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 45.0,vertical: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: 15.0),
                        Text(
                          'Forgotten your password?',
                          style: TextStyle(
                            fontSize: 35.0,
                            fontWeight: FontWeight.w700,
                            fontFamily: "Roboto",
                            height: 1.1,
                            color: const Color(0xFF192A51),
                            shadows: [
                              Shadow(
                                offset: Offset(0, 2),
                                blurRadius: 4,
                                color: Colors.black.withAlpha(64),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 15.0),
                        Text(
                          "There is nothing to worry about, we'll send you a message to help you reset your password.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18.0,
                            fontFamily: "Roboto",
                            color: const Color(0xFF967AA1),
                          ),
                        ),
                        SizedBox(height: 35.0),
                        emailInput(),
                        SizedBox(height: 40.0),
                        CustomElevatedButton(
                          onPressed: () {
                            resetPassword(context, _emailController);
                          },
                          text: 'Send Reset Link',
                        ),
                        SizedBox(height: 20.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget emailInput(){
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Email Address:",
            style: TextStyle(
              fontFamily: 'Roboto', // Font family
              fontWeight: FontWeight.w500, // Regular weight
              fontSize: 14, // Font size
              height: 1.4, // Line height (140%)
              color: HexColor("#21272A"), // Text color
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(
                    color: HexColor('#858585').withOpacity(.3),
                    blurRadius: 4,offset: const Offset(0,4)
                )]
            ),
            child: TextFormField(

              autofillHints: const [AutofillHints.email, AutofillHints.username, AutofillHints.newUsername],
              controller: _emailController,
              maxLength: 90,
              maxLines: 1,
              buildCounter: (BuildContext context, { int? currentLength, int? maxLength, bool? isFocused }) {
                return null;
              },
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                filled: true,
                fillColor: HexColor("#F2F4F8"),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                hintText: 'Please enter your email address',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email address';
                } else if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
                return null;
              },

            ),
          )
        ],
      ),
    );
  }

}
