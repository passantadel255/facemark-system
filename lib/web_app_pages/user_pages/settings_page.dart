import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:facemark/custom_widgets/custom_elevated_button.dart';
import 'package:facemark/custom_widgets/custom_snack_bar.dart';
import 'package:facemark/components/headers.dart';
import 'package:facemark/custom_widgets/hex_color.dart';
import 'package:facemark/custom_widgets/loading.dart';
import 'package:facemark/components/sidebar.dart';
import 'package:facemark/services/user_data_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> { final _formkey = GlobalKey<FormState>();
final _formkey2 = GlobalKey<FormState>();
bool isHidden = true;
bool isHidden2 = true;
bool isHidden3 = true;


var passState = "";

final TextEditingController _FNcontroller = TextEditingController();
final TextEditingController _LNcontroller = TextEditingController();


final TextEditingController _Econtroller = TextEditingController();
final TextEditingController _Pcontroller = TextEditingController();
final TextEditingController _CPcontroller = TextEditingController();
final TextEditingController _currentPcontroller = TextEditingController();

@override
void initState() {
  super.initState();
  _FNcontroller.text = userData.first_name;
  _LNcontroller.text = userData.last_name;
  _Econtroller.text = userData.email;

}
@override
void dispose() {
  _FNcontroller.dispose();
  _LNcontroller.dispose();
  _Econtroller.dispose();
  _Pcontroller.dispose();
  _CPcontroller.dispose();
  _currentPcontroller.dispose();
  super.dispose();
}

  void toggleMenu() {
    setState(() {
      isMenu = !isMenu;
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/app_components/setting-page-background.png',
              fit: BoxFit.cover,
            ),
          ),
          Row(
            children: [
              Sidebar(toggleMenu: toggleMenu),
              Expanded(
                child: Column(

                  children: [
                    const HeaderBar(title: "Settings", icon: Icons.settings),
                    SizedBox(height: width >= 1190 ? 150 : 30),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                          child: Wrap(
                            spacing: 120,
                            runSpacing: 60,
                            alignment: WrapAlignment.spaceAround,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            runAlignment: WrapAlignment.center,
                            children: [
                              // ---- Personal Info Column ----
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Personal Info:",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Montserrat',
                                      color: HexColor('#200B3B'),
                                    ),
                                  ),
                                  SizedBox(height: 20,),
                                  Container(
                                    constraints: BoxConstraints(maxWidth: 400),
                                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [HexColor('#FFFFFF'), HexColor('#EEEEEE')],
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: HexColor('#707070').withOpacity(.25),
                                          blurRadius: 15,
                                          spreadRadius: 6,
                                          offset: const Offset(3, 5),
                                        )
                                      ],
                                    ),
                                    child: Form(
                                      key: _formkey,
                                      child: Column(
                                        children: [
                                          textInput(AutofillHints.name, title: "First Name", hint: "enter your first name", Type: TextInputType.name, controller: _FNcontroller, enable: true),
                                          const SizedBox(height: 8),
                                          textInput(AutofillHints.familyName, title: "Last Name", hint: "enter your last name", Type: TextInputType.name, controller: _LNcontroller, enable: true),
                                          const SizedBox(height: 8),
                                          textInput(AutofillHints.email, title: "Email", hint: "enter your email", Type: TextInputType.emailAddress, controller: _Econtroller, enable: false),
                                          const SizedBox(height: 15),
                                          CustomElevatedButton(onPressed: () {_UpdateUserData();}, text: "Update", width: 200, height: 40,),
                                          const SizedBox(height: 10),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // ---- Change Password Column ----
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Change Password:",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Montserrat',
                                      color: HexColor('#200B3B'),
                                    ),
                                  ),
                                  SizedBox(height: 20,),

                                  Container(
                                    constraints: BoxConstraints(maxWidth: 400),
                                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [HexColor('#FFFFFF'), HexColor('#EEEEEE')],
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: HexColor('#707070').withOpacity(.25),
                                          blurRadius: 15,
                                          spreadRadius: 6,
                                          offset: const Offset(3, 5),
                                        )
                                      ],
                                    ),
                                    child: AutofillGroup(
                                      child: Form(
                                        key: _formkey2,
                                        child: Column(
                                          children: [
                                            currentPasswordInput(),
                                            const SizedBox(height: 8),
                                            newPasswordInput(),
                                            const SizedBox(height: 8),
                                            cNewPasswordInput(),
                                            const SizedBox(height: 20),
                                            CustomElevatedButton(onPressed: () {_ChangePassword();}, text: "Change Password",  width: 220, height: 40,),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget textInput(autofillHints, {title, hint, Type = TextInputType
    .name, maxLength = 40, maxLines = 1, controller, enable = true}) {

  return Container(
    margin: const EdgeInsets.symmetric(vertical: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$title:",
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: 'times'
          ),),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(
                  color: HexColor('#000000').withOpacity(.16),
                  blurRadius: 15, offset: const Offset(2, 5)
              )
              ]
          ),
          child: TextFormField(
            style: TextStyle(fontSize: 16,
              color: HexColor('#200B3B'),
            ),
            readOnly: !enable,
            autofillHints: [autofillHints],
            controller: controller,
            maxLength: maxLength,
            maxLines: maxLines,
            buildCounter: (BuildContext context,
                { int? currentLength, int? maxLength, bool? isFocused }) {
              return null;
            },
            keyboardType: Type,
            decoration: InputDecoration(
              filled: true,
              fillColor: enable ? Colors.white : HexColor("#EBEBEB"),
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
              hintText: '$hint',
              hintStyle: TextStyle(
                  fontSize: 14, color: HexColor("#828282")),
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 8.0, horizontal: 12.0),
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter your $title'; // Return an error message if the input is empty
              }
              return null; // Return null if the input is valid
            },

          ),
        )
      ],
    ),
  );
}


Widget currentPasswordInput() {

  return Container(
    margin: const EdgeInsets.symmetric(vertical: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Current Password:",
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: 'times'
          ),),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(
                  color: HexColor('#000000').withOpacity(.16),
                  blurRadius: 15, offset: const Offset(2, 5)
              )
              ]
          ),
          child: TextFormField(
            autofillHints: const [AutofillHints.password],
            controller: _currentPcontroller,
            maxLength: 50,
            buildCounter: (BuildContext context,
                { int? currentLength, int? maxLength, bool? isFocused }) {
              return null;
            },
            obscureText: isHidden,

            decoration: InputDecoration(
              prefixIcon: Icon(Icons.lock, color: HexColor("#496171")
                  .withOpacity(0.75),),
              suffixIcon: InkWell(
                onTap: () {
                  setState(() {
                    isHidden = !isHidden;
                  });
                },
                child: Icon(
                  isHidden ? Icons.visibility : Icons.visibility_off_rounded,
                  color: HexColor("#496171")
                      .withOpacity(0.5),
                ),
              ),
              filled: true,
              fillColor: HexColor("#ffffff"),
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
              hintText: 'enter your current password',
              hintStyle: TextStyle(
                  fontSize: 14,
                  color: HexColor("#828282")
              ),
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 12.0, horizontal: 16.0),
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter your Current Password'; // Return an error message if the input is empty
              }
              return null; // Return null if the input is valid
            },

          ),
        ),
        passState != "" ?
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(passState,
            style: const TextStyle(
                fontSize: 16,
                color: Colors.red
            ),
          ),
        ) :
        Container()
      ],
    ),
  );
}

Widget newPasswordInput() {

  return Container(
    margin: const EdgeInsets.symmetric(vertical: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("New Password:",
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: 'times'
          ),),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(
                  color: HexColor('#000000').withOpacity(.16),
                  blurRadius: 15, offset: const Offset(2, 5)
              )
              ]
          ),
          child: TextFormField(
            autofillHints: const [AutofillHints.newPassword],
            controller: _Pcontroller,
            maxLength: 50,
            buildCounter: (BuildContext context,
                { int? currentLength, int? maxLength, bool? isFocused }) {
              return null;
            },
            obscureText: isHidden2,

            decoration: InputDecoration(
              prefixIcon: Icon(Icons.lock, color: HexColor("#496171")
                  .withOpacity(0.75),),
              suffixIcon: InkWell(
                onTap: () {
                  setState(() {
                    isHidden2 = !isHidden2;
                  });
                },
                child: Icon(
                  isHidden2 ? Icons.visibility : Icons.visibility_off_rounded,
                  color: HexColor("#496171")
                      .withOpacity(0.5),
                ),
              ),
              filled: true,
              fillColor: HexColor("#ffffff"),
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
              hintText: 'enter your new password',
              hintStyle: TextStyle(
                  fontSize: 14,
                  color: HexColor("#828282")
              ),
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 12.0, horizontal: 16.0),
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter your New Password'; // Return an error message if the input is empty
              }
              return null; // Return null if the input is valid
            },

          ),
        ),
        passState != "" ?
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(passState,
            style: const TextStyle(
                fontSize: 16,
                color: Colors.red
            ),
          ),
        ) :
        Container()
      ],
    ),
  );
}

Widget cNewPasswordInput() {

  return Container(
    margin: const EdgeInsets.symmetric(vertical: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Confirm New Password:",
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: 'times'
          ),),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(
                  color: HexColor('#000000').withOpacity(.16),
                  blurRadius: 15, offset: const Offset(2, 5)
              )
              ]
          ),
          child: TextFormField(
              autofillHints: const [AutofillHints.newPassword],
              controller: _CPcontroller,
              maxLength: 50,
              buildCounter: (BuildContext context,
                  { int? currentLength, int? maxLength, bool? isFocused }) {
                return null;
              },
              obscureText: isHidden3,

              decoration: InputDecoration(
                prefixIcon: Icon(Icons.lock, color: HexColor("#496171")
                    .withOpacity(0.75),),
                suffixIcon: InkWell(
                  onTap: () {
                    setState(() {
                      isHidden3 = !isHidden3;
                    });
                  },
                  child: Icon(
                    isHidden3 ? Icons.visibility : Icons
                        .visibility_off_rounded,
                    color: HexColor("#496171")
                        .withOpacity(0.5),
                  ),
                ),
                filled: true,
                fillColor: HexColor("#ffffff"),
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
                hintText: 'Repeat your new password',
                hintStyle: TextStyle(
                    fontSize: 14,
                    color: HexColor("#828282")
                ),
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 12.0, horizontal: 16.0),
              ),

              validator: (value) {
                if (value!.trim().isEmpty) {
                  return 'Please Repeat Your New Password';
                } else {
                  return _Pcontroller.text == value.trim()
                      ? null
                      : "Please Validate Your Entered New Password";
                }
              }

          ),
        )
      ],
    ),
  );
}


Future<void> _UpdateUserData() async {
  if (_formkey.currentState!.validate()) {
    showLoading(context);
    try {
      var uid = FirebaseAuth.instance.currentUser!.uid;


      await FirebaseFirestore.instance.collection('users').doc(uid)
          .update({
        'first_name': _FNcontroller.text,
        'last_name': _LNcontroller.text,
      });

      setState(() {
        userData.first_name= _FNcontroller.text;
        userData.last_name= _LNcontroller.text;
      });

      Navigator.of(context).pop();
      showCustomSnackBar(context, "Data Has been Updated Successfully", isSuccess: true);


    } catch (e) {
      Navigator.of(context).pop();
      showCustomSnackBar(context, "Can't update Data now, try again later", isSuccess: false);
      print("error:$e");
    }
  }
}

Future<void> _ChangePassword() async {
  if (_formkey2.currentState!.validate()) {
    showLoading(context);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _Econtroller.text, password: _currentPcontroller.text);
      FirebaseAuth instance = FirebaseAuth.instance;
      await instance.currentUser
          ?.updatePassword(_Pcontroller.text)
          .then((_) {
        print("Successfully changed password");
        Navigator.of(context).pop();
        showCustomSnackBar(context, "Successfully changed password", isSuccess: true);


        //context.go("/profile");

      }).catchError((error) {
        print("Password can't be changed$error");
        var e = error.toString();
        if (e.contains('weak-password') ) {
          Navigator.of(context).pop();
          showCustomSnackBar(context, "Weak Password, Enter a New strong Password", isSuccess: false);

        }
      });
    } on FirebaseAuthException catch (e) {

      if (e.code == 'invalid-credential') {
        Navigator.of(context).pop();
        showCustomSnackBar(context, "your current password is wrong", isSuccess: false);

      }
    }
  }
}
}
