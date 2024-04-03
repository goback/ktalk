import 'dart:ui';

abstract class ThemeColor {
  final Color background1Color;
  final Color background2Color;
  final Color background3Color;

  final Color text1Color;
  final Color text2Color;

  const ThemeColor({
    required this.background1Color,
    required this.background2Color,
    required this.background3Color,
    required this.text1Color,
    required this.text2Color,
  });
}