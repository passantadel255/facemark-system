import 'package:facemark/custom_widgets/hex_color.dart';
import 'package:flutter/material.dart';

Future<bool> showLogoutDialog(BuildContext context) async {
  var wid = MediaQuery.of(context).size.width;



  return await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        'Logout',
        style: TextStyle(
            fontSize:  wid < 550 ? 18 : 24,
            fontWeight: FontWeight.bold,
            color: HexColor('#200B3B'),
            fontFamily: 'roboto'),
        textAlign: TextAlign.start,
      ),
      content: Container(
          constraints: BoxConstraints(minWidth: wid < 550 ? 300 : 400,
              minHeight: 50),
          child: Text('Are you sure you want to logout?',
            style: TextStyle(
                fontSize:  wid < 550 ? 14 : 18,
                fontFamily: 'roboto'),)),
      actions: <Widget>[
        TextButton(

          style: ElevatedButton.styleFrom(
            backgroundColor: HexColor('#192A51'), // Set background color to blue
            elevation: 6, // Add shadow
            shadowColor: Colors.black.withOpacity(0.5), // Shadow color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // Rounded corners
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.white,
                fontSize: wid < 550 ? 14 : 16,
              ),
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop(false); // Dismiss the dialog but don't logout
          },
        ),
        SizedBox(width: 5,),
        ElevatedButton(

          onPressed: ()  {
            Navigator.of(context).pop(true); // Dismiss the dialog and proceed with logout
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white, // Set background color to red
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
            child: Text('Logout', style: TextStyle(color: Colors.red, fontSize: wid < 550 ? 14 : 16),),
          ),
        )
      ],
    ),
  ) ?? false; // If the dialog is dismissed by clicking outside, it returns null, so we convert it to 'false'.
}