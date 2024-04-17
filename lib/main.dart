import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ktalk/auth/providers/auth_provider.dart';
import 'package:ktalk/auth/screens/phone_number_input_screen.dart';
import 'package:ktalk/auth/screens/user_information_screen.dart';
import 'package:ktalk/common/enum/theme_mode_enum.dart';
import 'package:ktalk/common/providers/custom_theme_provider.dart';
import 'package:ktalk/common/providers/loader_provider.dart';
import 'package:ktalk/common/providers/locale_provider.dart';
import 'package:ktalk/common/screens/main_layout_screen.dart';
import 'package:ktalk/common/utils/global_navigator.dart';
import 'package:ktalk/common/utils/locale/generated/l10n.dart';
import 'package:ktalk/common/utils/logger.dart';
import 'package:ktalk/firebase_options.dart';
import 'package:ktalk/router.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:permission_handler/permission_handler.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> requestPermission() async {
  final contactPermissionStatus = await Permission.contacts.request();

  if (contactPermissionStatus.isDenied ||
      contactPermissionStatus.isPermanentlyDenied) {
    await openAppSettings();
    SystemNavigator.pop();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await requestPermission();
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
    final locale = ref.watch(localeProvider);

    ref.listen(loaderProvider, (previous, next) {
      next ? context.loaderOverlay.show() : context.loaderOverlay.hide();
    });

    return GlobalLoaderOverlay(
      useDefaultLoading: false,
      overlayColor: const Color.fromRGBO(0, 0, 0, 0.4),
      overlayWidgetBuilder: (_) => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        navigatorKey: navigatorKey,
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
          context.loaderOverlay.hide();
          if (user == null) {
            return const PhoneNumberInputScreen();
          }

          if (user.displayName == null || user.displayName!.isEmpty) {
            return const UserInformationScreen();
          }

          return const MainLayoutScreen();
        },
        error: (error, stackTrace) {
          context.loaderOverlay.hide();
          GlobalNavigator.showAlertDialog(text: error.toString());
          logger.d(error);
          logger.d(stackTrace);
          return null;
        },
        loading: () {
          context.loaderOverlay.show();
          return null;
        },
      ),
    );
  }
}
