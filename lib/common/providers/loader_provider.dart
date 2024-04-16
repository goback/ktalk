import 'package:flutter_riverpod/flutter_riverpod.dart';

final loaderProvider = NotifierProvider<LoaderNotifier, bool>(
  () => LoaderNotifier(),
);

class LoaderNotifier extends Notifier<bool> {
  @override
  bool build() {
    return false;
  }

  void show() {
    state = true;
  }

  void hide() {
    state = false;
  }
}
