import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  () => LocaleNotifier(),
);

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    final languageCode = Platform.localeName.split('_')[0];
    return Locale(languageCode);
  }

  void changeLocale({required Locale locale}) {
    state = locale;
  }
}
