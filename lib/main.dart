import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ktalk/common/enum/theme_mode_enum.dart';
import 'package:ktalk/common/providers/custom_theme_provider.dart';
import 'package:ktalk/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(
    child: MyApp(),
  ));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customTheme = ref.watch(customThemeProvider);
    final themeData = customTheme.themeModeEnum == ThemeModeEnum.dark
        ? ThemeData.dark()
        : ThemeData.light();

    return MaterialApp(
      theme: themeData.copyWith(
        scaffoldBackgroundColor: customTheme.themeColor.background1Color,
        appBarTheme: AppBarTheme(
          backgroundColor: customTheme.themeColor.background1Color,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: customTheme.themeColor.text1Color,
          ),
        ),
        tabBarTheme: TabBarTheme(
          indicatorColor: Colors.transparent,
          labelColor: customTheme.themeColor.text1Color,
          unselectedLabelColor: Colors.grey.withOpacity(0.7),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: customTheme.themeColor.text1Color,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.yellow,
          foregroundColor: Colors.black,
        ),
        dividerTheme: DividerThemeData(
          color: Colors.grey.withOpacity(0.2),
          indent: 15,
          endIndent: 15,
        ),
      ),
      home: const Scaffold(
        body: Center(
          child: Text('메인 화면'),
        ),
      ),
    );
  }
}
