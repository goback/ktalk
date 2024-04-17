import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ktalk/common/enum/theme_mode_enum.dart';
import 'package:ktalk/common/models/dark_theme_color.dart';
import 'package:ktalk/common/models/light_theme_color.dart';
import 'package:ktalk/common/providers/custom_theme_state.dart';

final customThemeProvider =
    NotifierProvider<CustomThemeNotifier, CustomThemeState>(
  () => CustomThemeNotifier(),
);

class CustomThemeNotifier extends Notifier<CustomThemeState> {
  @override
  CustomThemeState build() {
    return CustomThemeState.init();
  }

  void toggleThemeMode() {
    final themeModeEnum = state.themeModeEnum == ThemeModeEnum.dark
        ? ThemeModeEnum.light
        : ThemeModeEnum.dark;

    final themeColor = state.themeModeEnum == ThemeModeEnum.dark
        ? LightThemeColor()
        : DarkThemeColor();

    state = state.copyWith(
      themeColor: themeColor,
      themeModeEnum: themeModeEnum,
    );
  }
}
