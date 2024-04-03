import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ktalk/common/models/light_theme_color.dart';
import 'package:ktalk/common/utils/logger.dart';
import 'package:ktalk/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeData = ThemeData.light();
    final customTheme = LightThemeColor();

    print('sdfrsdfsd');
    logger.d('tesfedfsdfsd');
    return MaterialApp(
      theme: themeData.copyWith(
        scaffoldBackgroundColor: customTheme.background1Color,
      ),
      home: Scaffold(
        body: Center(
          child: Text('메인 화면'),
        ),
      ),
    );
  }
}
