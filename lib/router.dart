import 'package:flutter/material.dart';
import 'package:ktalk/auth/screens/otp_screen.dart';
import 'package:ktalk/chat/screens/chat_screen.dart';
import 'package:ktalk/group/screens/create_group_screen.dart';
import 'package:ktalk/group/screens/group_screen.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case OTPScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => const OTPScreen(),
      );
    case ChatScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => const ChatScreen(),
      );
    case GroupScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => const GroupScreen(),
      );
    case CreateGroupScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => const CreateGroupScreen(),
      );
    default:
      return MaterialPageRoute(
        builder: (context) => Container(),
      );
  }
}
