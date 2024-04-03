import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ktalk/common/providers/custom_theme_state.dart';

final customThemeProvider = NotifierProvider<CustomThemeNotifier, CustomThemeState>(
    () => CustomThemeNotifier(),
);

class CustomThemeNotifier extends Notifier<CustomThemeState> {
  @override
  CustomThemeState build() {
    return CustomThemeState.init();
  }
}