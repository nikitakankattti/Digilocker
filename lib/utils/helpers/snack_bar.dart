import 'package:flutter/material.dart';

class SnackBarHelper {
  static showSuccessMessage(
      {required BuildContext context, required String? message}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        shape: const StadiumBorder(),
        behavior: SnackBarBehavior.floating,
        content: Center(
          child: Text(message!),
        ),
        backgroundColor: Colors.green[400],
      ),
    );
  }

  static showErrorMessage(
      {required BuildContext context, required String? message}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        shape: const StadiumBorder(),
        behavior: SnackBarBehavior.floating,
        content: Center(
          child: Text(message!),
        ),
        backgroundColor: Colors.red[400],
      ),
    );
  }
}
