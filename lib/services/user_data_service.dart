

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class UserData {
  String first_name;
  String last_name;
  String image_url;
  String email;
  String role;
  String id;
  var uid;
  bool isAuth;

  List attendance_rates;

  UserData({
    required this.first_name,
    required this.last_name,
    required this.image_url,
    required this.email,
    required this.role,
    required this.id,
    required this.uid,
    required this.isAuth,

    required this.attendance_rates,
  });

  void clear() {
    first_name = "N/A";
    last_name = "N/A";
    image_url = "N/A";
    email = "N/A";
    role = "N/A";
    id = "N/A";
    uid = "N/A";
    isAuth = false;

    attendance_rates = [];

  }

}

var userData = UserData(
  first_name: "N/A",
  last_name: "N/A",
  image_url: "N/A",
  email: "N/A",
  role: "N/A",
  id: "N/A",
  uid: "N/A",
  isAuth: false,

  attendance_rates: [],
);


Future<bool> isAuth() async {

  final User? user = FirebaseAuth.instance.currentUser;

  if (user != null) {

    if(!userData.isAuth){
      await getUserData();
    }

    if(userData.isAuth){
      return true;
    }else{
      userData.clear();
      return false;
    }
  }
  else {
    userData.clear();
    return false;
  }
}


Future<void> getUserData() async {
  print("getUserData Fun start");
  final User? user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  if (user != null) {
    try {
      // Fetch the user document from Firestore
      final userDoc = await firestore.collection('users').doc(user.uid).get();

      // Check if the document exists
      if (userDoc.exists) {

        final data = userDoc.data();
        if (data != null) {
          userData.first_name = data['first_name'] ?? "N/A";
          userData.last_name = data['last_name'] ?? "N/A";
          userData.image_url = data['image_url'] ?? "N/A";
          userData.email = data['email'] ?? "N/A";
          userData.role = data['role'] ?? "N/A";
          userData.id = data['id'] ?? "N/A";
          userData.uid = user.uid;
          userData.isAuth = true; // Mark user as authenticated
          if(userData.role == 'student'){
            userData.attendance_rates = data['attendance_rates'] ?? {};
          }
          //print("UserData successfully loaded");
        }
      } else {
        print("No user document found in Firestore for UID: ${user.uid}");
        userData.clear(); // Clear user data if no document found
      }
    } catch (e) {
      print("Error in getUserData: $e");
      userData.clear(); // Clear user data if an error occurs
    }
  } else {
    print("No authenticated user found.");
    userData.clear();
  }
}



