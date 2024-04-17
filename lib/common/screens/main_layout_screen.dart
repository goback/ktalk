import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ktalk/common/enum/theme_mode_enum.dart';
import 'package:ktalk/common/providers/custom_theme_provider.dart';
import 'package:ktalk/common/providers/locale_provider.dart';
import 'package:ktalk/common/utils/locale/generated/l10n.dart';

class MainLayoutScreen extends ConsumerStatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  ConsumerState<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends ConsumerState<MainLayoutScreen> {
  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final themeModeEnum = ref.watch(customThemeProvider).themeModeEnum;

    return DefaultTabController(
      animationDuration: Duration.zero,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(S.current.mainLayoutScreenText1),
          bottom: TabBar(
            tabs: [
              Tab(
                icon: const Icon(Icons.person, size: 30),
                iconMargin: const EdgeInsets.only(bottom: 1),
                text: S.current.mainLayoutScreenText2,
              ),
              Tab(
                icon: const Icon(Icons.chat_bubble_rounded, size: 30),
                iconMargin: const EdgeInsets.only(bottom: 1),
                text: S.current.mainLayoutScreenText3,
              ),
              Tab(
                icon: const Icon(Icons.wechat_outlined, size: 30),
                iconMargin: const EdgeInsets.only(bottom: 1),
                text: S.current.mainLayoutScreenText4,
              )
            ],
          ),
        ),
        endDrawer: Drawer(
          child: Column(
            children: [
              SizedBox(
                height: 100,
                child: DrawerHeader(
                  child: Text(
                    S.current.mainLayoutScreenText5,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SwitchListTile(
                secondary: const Icon(Icons.brightness_6),
                title: Text(S.current.mainLayoutScreenText7),
                activeColor: Colors.grey,
                value: themeModeEnum == ThemeModeEnum.light,
                onChanged: (value) {
                  ref.read(customThemeProvider.notifier).toggleThemeMode();
                },
              ),
              const ListTile(
                leading: Icon(Icons.language),
                title: Text('언어'),
              ),
              RadioListTile(
                title: const Text('한국어'),
                value: const Locale('ko'),
                groupValue: locale,
                onChanged: (value) {
                  ref
                      .read(localeProvider.notifier)
                      .changeLocale(locale: value!);
                },
              ),
              RadioListTile(
                title: const Text('English'),
                value: const Locale('en'),
                groupValue: locale,
                onChanged: (value) {
                  ref
                      .read(localeProvider.notifier)
                      .changeLocale(locale: value!);
                },
              ),
              RadioListTile(
                title: const Text('日本語'),
                value: const Locale('ja'),
                groupValue: locale,
                onChanged: (value) {
                  ref
                      .read(localeProvider.notifier)
                      .changeLocale(locale: value!);
                },
              ),
            ],
          ),
        ),
        body: const TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            Center(
              child: Text('1번'),
            ),
            Center(
              child: Text('2번'),
            ),
            Center(
              child: Text('3번'),
            ),
          ],
        ),
      ),
    );
  }
}
