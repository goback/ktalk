import 'package:flutter/material.dart';
import 'package:ktalk/common/utils/logger.dart';

void main() {
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
