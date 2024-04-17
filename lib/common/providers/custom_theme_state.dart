import 'package:flutter/material.dart';
import 'package:ktalk/common/enum/theme_mode_enum.dart';
import 'package:ktalk/common/models/dark_theme_color.dart';
import 'package:ktalk/common/models/light_theme_color.dart';
import 'package:ktalk/common/models/theme_color.dart';

class CustomThemeState {
  final ThemeColor themeColor;
  final ThemeModeEnum themeModeEnum;

  const CustomThemeState({
    required this.themeColor,
    required this.themeModeEnum,
  });

  factory CustomThemeState.init() {
    // Brightness.dark;
    // Brightness.light;
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    return CustomThemeState(
      themeColor:
          brightness == Brightness.dark ? DarkThemeColor() : LightThemeColor(),
      themeModeEnum: brightness == Brightness.dark
          ? ThemeModeEnum.dark
          : ThemeModeEnum.light,
    );
  }

  CustomThemeState copyWith({
    ThemeColor? themeColor,
    ThemeModeEnum? themeModeEnum,
  }) {
    return CustomThemeState(
      themeColor: themeColor ?? this.themeColor,
      themeModeEnum: themeModeEnum ?? this.themeModeEnum,
    );
  }
}
