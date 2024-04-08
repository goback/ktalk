import 'package:flutter/material.dart';
import 'package:ktalk/auth/screens/otp_screen.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case OTPScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => const OTPScreen(),
      );
    default:
      return MaterialPageRoute(
        builder: (context) => Container(),
      );
  }
}
