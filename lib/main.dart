import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
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
    print('sdfrsdfsd');
    logger.d('tesfedfsdfsd');
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('메인 화면'),
        ),
      ),
    );
  }
}
