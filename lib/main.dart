import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ktalk/auth/providers/auth_provider.dart';
import 'package:ktalk/auth/screens/phone_number_input_screen.dart';
import 'package:ktalk/common/enum/theme_mode_enum.dart';
import 'package:ktalk/common/providers/custom_theme_provider.dart';
import 'package:ktalk/common/utils/logger.dart';
import 'package:ktalk/firebase_options.dart';
import 'package:ktalk/router.dart';

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
      onGenerateRoute: (settings) => generateRoute(settings),
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
        body: Main(),
      ),
    );
  }
}

class Main extends ConsumerWidget {
  const Main({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider);

    return Scaffold(
      body: auth.when(
        data: (user) {
          if (user == null) {
            return const PhoneNumberInputScreen();
          }

          return Center(
            child: ElevatedButton(
              onPressed: () => FirebaseAuth.instance.signOut(),
              child: Text('로그아웃 버튼'),
            ),
          );
        },
        error: (error, stackTrace) {
          logger.d(error);
          logger.d(stackTrace);
          return null;
        },
        loading: () {
          return const CircularProgressIndicator();
        },
      ),
    );
  }
}
