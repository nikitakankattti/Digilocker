import 'package:document_saver_app/routes/routes.dart';
import 'package:document_saver_app/utils/helpers/snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  static bool isLoggedIn = false;

  setIsLoggedIn() {
    isLoggedIn = !isLoggedIn;
    notifyListeners();
  }

  bool isEmailValid(String email) {
    final emailRegex = RegExp(
        r'^[\w-]+(\.[\w-]+)*@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*(\.[a-zA-Z]{2,})$');
    return emailRegex.hasMatch(email);
  }

  bool isPasswordValid(String password) {
    final passwordRegex = RegExp(
        r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{6,}$');
    return passwordRegex.hasMatch(password);
  }

  bool isGoogleEmail(String email) {
    final googleDomains = ['gmail.com', 'googlemail.com'];

    final domain = email.split('@')[1].toLowerCase();
    return googleDomains.contains(domain);
  }

  signUp({
    required BuildContext context,
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      if (!isEmailValid(email)) {
        SnackBarHelper.showErrorMessage(
          context: context,
          message: "Invalid email address.",
        );
        return;
      }

      if (!isPasswordValid(password)) {
        SnackBarHelper.showErrorMessage(
          context: context,
          message:
              "Password must be at least 8 characters long and contain at least one letter and one number.",
        );
        return;
      }

      if (!isGoogleEmail(email)) {
        SnackBarHelper.showErrorMessage(
          context: context,
          message: "Invalid email address",
        );
        return;
      }

      // Check if the email is already registered
      var methods =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      if (methods.isNotEmpty) {
        SnackBarHelper.showErrorMessage(
          context: context,
          message: "This email is already registered.",
        );
        return;
      }

      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      String uid = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'username': username,
        'email': email,
      });

      await userCredential.user!.sendEmailVerification();

      SnackBarHelper.showSuccessMessage(
        context: context,
        message:
            "Registration successful. Please check your email for verification.",
      );
      Navigator.pushReplacementNamed(context, loginPageRoute);
    } on FirebaseAuthException catch (e) {
      SnackBarHelper.showErrorMessage(context: context, message: e.message);
    }
  }

  signIn({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      if (!isEmailValid(email)) {
        SnackBarHelper.showErrorMessage(
          context: context,
          message: "Invalid email address.",
        );
        return;
      }

      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      if (userCredential.user!.emailVerified) {
        Navigator.pushReplacementNamed(context, homePageRoute);
      } else {
        SnackBarHelper.showErrorMessage(
          context: context,
          message: "Please verify your email before signing in.",
        );
      }
    } on FirebaseAuthException catch (e) {
      SnackBarHelper.showErrorMessage(context: context, message: e.message);
    }
  }

  forgotPassword({required BuildContext context, required String email}) async {
    try {
      if (!isEmailValid(email)) {
        SnackBarHelper.showErrorMessage(
          context: context,
          message: "Invalid email address.",
        );
        return;
      }

      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: email)
          .then((value) {
        SnackBarHelper.showSuccessMessage(
          context: context,
          message: "Password recovery email sent. Please check your inbox.",
        );
        Navigator.pushReplacementNamed(context, loginPageRoute);
      });
    } on FirebaseAuthException catch (e) {
      SnackBarHelper.showErrorMessage(context: context, message: e.message);
    }
  }

  signOut({required context}) async {
    try {
      await FirebaseAuth.instance.signOut().then((value) {
        Navigator.pushReplacementNamed(context, loginPageRoute);
      });
    } on FirebaseAuthException catch (e) {
      SnackBarHelper.showErrorMessage(context: context, message: e.message);
    }
  }
}
