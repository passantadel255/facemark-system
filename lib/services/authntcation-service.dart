import 'package:facemark/custom_widgets/custom_snack_bar.dart';
import 'package:facemark/custom_widgets/loading.dart';
import 'package:facemark/services/user_data_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

////////////////////////////////////////////////////////////////////////
////////////////  Login with Email & Password function  ////////////////
////////////////////////////////////////////////////////////////////////

Future<void> signIn(BuildContext context, GlobalKey<FormState> formKey,
    String email, String password, bool isRemember)
async {
  if (formKey.currentState!.validate()) {
    // Show loading indicator
    showLoading(context);

    try {
      // Set persistence based on the 'isRemember' checkbox
      await FirebaseAuth.instance.setPersistence(
        isRemember ? Persistence.LOCAL : Persistence.NONE,
      );

      // Attempt to sign in
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      bool auth = await isAuth();

      // Navigate directly to the home page on successful authentication
      Navigator.of(context).pop(); // Close loading

      if (auth) {
        context.go("/Dashboard");
      }
    } on FirebaseAuthException catch (e) {
      Navigator.of(context).pop(); // Close loading
      String errorMessage;

      switch (e.code) {
        case 'invalid-email':
          errorMessage = 'Invalid email format';
          break;
        case 'user-disabled':
          errorMessage = 'This user account is disabled';
          break;
        case 'user-not-found':
          errorMessage = 'User not found';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password';
          break;
        case 'network-request-failed':
          errorMessage = 'Please check your internet connection';
          break;
        case 'invalid-credential':
          errorMessage =
              'Wrong Email or Password, Please check them and try again';
          break;
        default:
          errorMessage = 'Unexpected error: ${e.message}';
          break;
      }

      // Show custom SnackBar for error
      showCustomSnackBar(
        context,
        errorMessage,
        isSuccess: false,
      );
    } catch (e) {
      Navigator.of(context).pop(); // Close loading
      print("Error: $e");
    }
  }
}

////////////////////////////////////////////////////////////////////////
//////////////////////  Forget Password function  //////////////////////
////////////////////////////////////////////////////////////////////////

Future<void> resetPassword(
    BuildContext context, TextEditingController emailController)
async {
  final String email = emailController.text.trim();
  final FirebaseAuth auth = FirebaseAuth.instance;

  if (email.isEmpty) {
    showCustomSnackBar(
      context,
      "Please enter an email address.",
      isSuccess: false,
    );
    return;
  }

  try {
    showLoading(context);
    await auth.sendPasswordResetEmail(email: email);

    showCustomSnackBar(
      context,
      "A password reset link has been sent to your registered email. Please check your inbox or spam folder.",
      isSuccess: true,
    );
    Navigator.of(context).pop(); // Close loading
    context.go('/login');
  } on FirebaseAuthException catch (e) {
    Navigator.of(context).pop(); // Close loading
    String errorMessage;

    switch (e.code) {
      case 'invalid-email':
        errorMessage =
            "Invalid email format. Please enter a valid email address.";
        break;
      case 'network-request-failed':
        errorMessage = "Network error. Please check your internet connection.";
        break;
      case 'too-many-requests':
        errorMessage = "Too many password reset requests. Try again later.";
        break;
      default:
        errorMessage = "An unexpected error occurred: ${e.message}";
        break;
    }

    showCustomSnackBar(
      context,
      errorMessage,
      isSuccess: false,
    );
  } catch (e) {
    Navigator.of(context).pop(); // Close loading
    showCustomSnackBar(
      context,
      "An unknown error occurred. Please try again later.",
      isSuccess: false,
    );
  }
}
