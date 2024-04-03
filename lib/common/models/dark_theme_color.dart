import 'dart:ui';

import 'package:ktalk/common/models/theme_color.dart';

class DarkThemeColor extends ThemeColor {
  DarkThemeColor() : super(
    background1Color: const Color.fromRGBO(18, 18, 18, 1),
    background2Color: const Color.fromRGBO(42, 42, 42, 1),
    background3Color: const Color.fromRGBO(18, 18, 18, 1),
    text1Color: const Color.fromRGBO(232, 232, 232, 1),
    text2Color: const Color.fromRGBO(146, 146, 146, 1),
  );
}