import 'dart:math';
import 'package:facemark/custom_widgets/custom_elevated_button.dart';
import 'package:facemark/components/headers.dart';
import 'package:facemark/services/authntcation-service.dart';
import 'package:flutter/material.dart';
import 'package:facemark/custom_widgets/hex_color.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isHidden = true; // To toggle password visibility
  bool isRemember = false; // To toggle Remember CheckBox
  bool _isHovered = false; // forget password


  final _formKey = GlobalKey<FormState>(); // Form key for validation

  final TextEditingController _emailcontroller = TextEditingController();
  final TextEditingController _passwordcontroller = TextEditingController();


  @override
  void dispose() {
    // TODO: implement dispose
    _emailcontroller.dispose();
    _passwordcontroller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {


    // Screen dimensions for responsiveness
    final screenWidth = MediaQuery.of(context).size.width;

    // Determine if the screen is mobile or desktop
    final isMobile = screenWidth < 882;

    final containerSize = max(screenWidth * 0.4, 400).toDouble(); // 30% of screen width or 300 (whichever is greater)

    return Scaffold(
      body: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // Scrollable Content
          SingleChildScrollView(
            child: Center(
              child: Padding(
                padding:  EdgeInsets.only(top: isMobile ? 70 : 150), // Space below the header
                child: Wrap(
                  spacing: 80, // Horizontal spacing
                  runSpacing: isMobile ? 10 : 50, // Vertical spacing
                  alignment: WrapAlignment.spaceAround,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  verticalDirection: isMobile ? VerticalDirection.up: VerticalDirection.down, // Reverse wrapping direction

                  children: [
                    // Login Form
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 16, horizontal: max(containerSize * .1, 10)),
                      constraints:  BoxConstraints(maxWidth: containerSize),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            "Log In",
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              fontSize: (screenWidth * 0.06).clamp(18.0, 36.0), // Min: 18, Max: 36
                            ),
                          ),
                          SizedBox(height: isMobile ? 20 : 60),

                          Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                // Email Address Field
                                emailInput(),
                                SizedBox(height: isMobile ? 20 : 35),

                                // Password Field
                                passwordInput(),
                                const SizedBox(height: 30),


                                // Remember Me and Forgot Password
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Checkbox(
                                          value: isRemember,
                                          onChanged: (value) {
                                            setState(() {
                                              isRemember = !isRemember;
                                            });
                                          },
                                        ),
                                        Text(
                                          "Remember me",
                                          style: TextStyle(
                                            fontFamily: 'Roboto', // Font family
                                            fontWeight: FontWeight.w400, // Regular weight
                                            fontSize: 14, // Font size
                                            height: 1.4, // Line height (140%)
                                            color: HexColor("#21272A"), // Text color
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Forgot passwordButton
                                    MouseRegion(
                                      onEnter: (_) => setState(() => _isHovered = true),
                                      onExit: (_) => setState(() => _isHovered = false),
                                      child: InkWell(
                                        onTap: () {
                                          context.go('/forget-password');
                                        },
                                        child: Text(
                                          "Forgotten account?",
                                          style: TextStyle(
                                            color: _isHovered ? HexColor('#01579B') : HexColor('#000000'),
                                            fontSize: 14, // Font size
                                            height: 1.4, // Line height (140%)
                                            fontFamily: 'Roboto', // Font family
                                            fontWeight: FontWeight.w400, // Regular weigh//
                                            decoration: _isHovered ? TextDecoration.underline : TextDecoration.none,
                                            decorationColor: HexColor('#01579B'),
                                          ),
                                        ),
                                      ),
                                    )

                                  ],
                                ),
                                const SizedBox(height: 15),

                                // Log In Button
                                CustomElevatedButton(
                                  text: "Log In",
                                  onPressed: () {
                                    // Call your login logic here
                                    signIn(context, _formKey, _emailcontroller.text, _passwordcontroller.text, isRemember);
                                  },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: isMobile ? 20 : 60),

                          // Social Logins
                          Wrap(

                            spacing: 20, // Horizontal spacing
                            runSpacing: 15, // Vertical spacing
                            alignment: WrapAlignment.spaceAround,
                            crossAxisAlignment: WrapCrossAlignment.center,

                            children: [
                              OutlinedButton.icon(
                                onPressed: () {
                                  // Logic for "Log in with Google"
                                },

                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(220, 48), // Full width with height 48
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), // Button padding
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10), // Rounded corners
                                  ),
                                  side: const BorderSide(
                                    color: Colors.black, // Border color (black)
                                    width: 1.5, // Border thickness
                                  ),
                                  backgroundColor: Colors.white, // Background color
                                ),
                                icon: Image.asset(
                                  'assets/images/app_components/google-icon.png',
                                  height: 20, // Icon size
                                ),
                                label: const Text(
                                  "Log in with Google",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500, // Medium weight text
                                    color: Colors.black, // Text color
                                  ),
                                ),
                              ),
                              OutlinedButton.icon(
                                onPressed: () {
                                  // Logic for "Log in with Apple"
                                },
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(220, 48), // Full width with height 48
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), // Button padding
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10), // Rounded corners
                                  ),
                                  side: const BorderSide(
                                    color: Colors.black, // Border color (black)
                                    width: 2, // Border thickness
                                  ),
                                  backgroundColor: Colors.white, // Background color
                                ),
                                icon: Image.asset(
                                  'assets/images/app_components/apple-icon.png',
                                  height: 20, // Icon size
                                ),
                                label: const Text(
                                  "Log in with Apple",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500, // Medium weight text
                                    color: Colors.black, // Text color
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Illustration
                    Container(
                      padding: const EdgeInsets.all(16),

                      constraints:  BoxConstraints(maxWidth: containerSize),
                      child: Image.asset(
                        'assets/images/app_components/login-Illustration.png', // Replace with your illustration image
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Fixed Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: BasicHeader(),
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
               fontFamily: 'Montserrat',
               fontWeight: FontWeight.bold,
               fontSize: 16,
               height: 1.4,
               color: HexColor("#21272A"),
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
              controller: _emailcontroller,
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
                hintText: 'example@email.com',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                ),
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
  Widget passwordInput(){

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Password:",
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
              fontSize: 16,
              height: 1.4,
              color: HexColor("#21272A"),
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
              autofillHints: const [AutofillHints.password],
              controller: _passwordcontroller,
              maxLength: 50,
              buildCounter: (BuildContext context, { int? currentLength, int? maxLength, bool? isFocused }) {
                return null;
              },
              obscureText: isHidden,

              decoration: InputDecoration(
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 15.0),
                  child: InkWell(
                    onTap: (){
                      setState(() {
                        isHidden = !isHidden;
                      });
                    },
                    child: Icon(
                      isHidden ? Icons.visibility : Icons.visibility_off_rounded,
                      color: HexColor("#697077"),
                    ),
                  ),
                ),
                filled: true,
                fillColor: HexColor("#F2F4F8"),
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
                hintText: 'Enter your password',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                } else if (value.length < 6) {
                  return 'Password must be at least 6 characters long';
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
