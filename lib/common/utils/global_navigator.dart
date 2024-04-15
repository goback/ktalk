import 'package:flutter/material.dart';
import 'package:ktalk/main.dart';

class GlobalNavigator {
  static Future<void> showAlertDialog({
    required String text,
  }) async {
    await showDialog(
      barrierDismissible: false,
      context: navigatorKey.currentContext!,
      builder: (context) {
        return AlertDialog(
          content: Text(text),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
