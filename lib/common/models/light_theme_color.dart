import 'dart:ui';

import 'package:ktalk/common/models/theme_color.dart';

class LightThemeColor extends ThemeColor {
  LightThemeColor() : super(
    background1Color: const Color.fromRGBO(232, 232, 232, 1),
    background2Color: const Color.fromRGBO(232, 232, 232, 1),
    background3Color: const Color.fromRGBO(186, 186, 186, 1),
    text1Color: const Color.fromRGBO(18, 18, 18, 1),
    text2Color: const Color.fromRGBO(120, 120, 120, 1),
  );
}