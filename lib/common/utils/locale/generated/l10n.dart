// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Enter your phone number`
  String get loginScreenText1 {
    return Intl.message(
      'Enter your phone number',
      name: 'loginScreenText1',
      desc: '',
      args: [],
    );
  }

  /// `KTalk will need to verify your account.`
  String get loginScreenText2 {
    return Intl.message(
      'KTalk will need to verify your account.',
      name: 'loginScreenText2',
      desc: '',
      args: [],
    );
  }

  /// `Next`
  String get next {
    return Intl.message(
      'Next',
      name: 'next',
      desc: '',
      args: [],
    );
  }

  /// `Verifying your number`
  String get optScreenText1 {
    return Intl.message(
      'Verifying your number',
      name: 'optScreenText1',
      desc: '',
      args: [],
    );
  }

  /// `We have sent an SMS with a code`
  String get optScreenText2 {
    return Intl.message(
      'We have sent an SMS with a code',
      name: 'optScreenText2',
      desc: '',
      args: [],
    );
  }

  /// `Profile info`
  String get userInformationScreenText1 {
    return Intl.message(
      'Profile info',
      name: 'userInformationScreenText1',
      desc: '',
      args: [],
    );
  }

  /// `Please provide your name and an optional profile photo`
  String get userInformationScreenText2 {
    return Intl.message(
      'Please provide your name and an optional profile photo',
      name: 'userInformationScreenText2',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a name`
  String get userInformationScreenText3 {
    return Intl.message(
      'Please enter a name',
      name: 'userInformationScreenText3',
      desc: '',
      args: [],
    );
  }

  /// `Exit`
  String get exit {
    return Intl.message(
      'Exit',
      name: 'exit',
      desc: '',
      args: [],
    );
  }

  /// `Welcome to KTalk`
  String get landingScreenText1 {
    return Intl.message(
      'Welcome to KTalk',
      name: 'landingScreenText1',
      desc: '',
      args: [],
    );
  }

  /// `Read our Privacy Policy. Tap "Agree and continue" to accept the Terms of Service.`
  String get landingScreenText2 {
    return Intl.message(
      'Read our Privacy Policy. Tap "Agree and continue" to accept the Terms of Service.',
      name: 'landingScreenText2',
      desc: '',
      args: [],
    );
  }

  /// `Agree and continue`
  String get landingScreenText3 {
    return Intl.message(
      'Agree and continue',
      name: 'landingScreenText3',
      desc: '',
      args: [],
    );
  }

  /// `KTalk`
  String get mainLayoutScreenText1 {
    return Intl.message(
      'KTalk',
      name: 'mainLayoutScreenText1',
      desc: '',
      args: [],
    );
  }

  /// `Friends`
  String get mainLayoutScreenText2 {
    return Intl.message(
      'Friends',
      name: 'mainLayoutScreenText2',
      desc: '',
      args: [],
    );
  }

  /// `Chats`
  String get mainLayoutScreenText3 {
    return Intl.message(
      'Chats',
      name: 'mainLayoutScreenText3',
      desc: '',
      args: [],
    );
  }

  /// `Groups`
  String get mainLayoutScreenText4 {
    return Intl.message(
      'Groups',
      name: 'mainLayoutScreenText4',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get mainLayoutScreenText5 {
    return Intl.message(
      'Settings',
      name: 'mainLayoutScreenText5',
      desc: '',
      args: [],
    );
  }

  /// `Logout`
  String get mainLayoutScreenText6 {
    return Intl.message(
      'Logout',
      name: 'mainLayoutScreenText6',
      desc: '',
      args: [],
    );
  }

  /// `Theme`
  String get mainLayoutScreenText7 {
    return Intl.message(
      'Theme',
      name: 'mainLayoutScreenText7',
      desc: '',
      args: [],
    );
  }

  /// `Create group`
  String get createGroupScreenText1 {
    return Intl.message(
      'Create group',
      name: 'createGroupScreenText1',
      desc: '',
      args: [],
    );
  }

  /// `Enter group name`
  String get createGroupScreenText2 {
    return Intl.message(
      'Enter group name',
      name: 'createGroupScreenText2',
      desc: '',
      args: [],
    );
  }

  /// `Select Friends`
  String get createGroupScreenText3 {
    return Intl.message(
      'Select Friends',
      name: 'createGroupScreenText3',
      desc: '',
      args: [],
    );
  }

  /// `People`
  String get groupScreenText1 {
    return Intl.message(
      'People',
      name: 'groupScreenText1',
      desc: '',
      args: [],
    );
  }

  /// `Me`
  String get receiver {
    return Intl.message(
      'Me',
      name: 'receiver',
      desc: '',
      args: [],
    );
  }

  /// `Reply to {userName}`
  String replyTo(Object userName) {
    return Intl.message(
      'Reply to $userName',
      name: 'replyTo',
      desc: '',
      args: [userName],
    );
  }

  /// `Image`
  String get image {
    return Intl.message(
      'Image',
      name: 'image',
      desc: '',
      args: [],
    );
  }

  /// `Video`
  String get video {
    return Intl.message(
      'Video',
      name: 'video',
      desc: '',
      args: [],
    );
  }

  /// `Enter a message...`
  String get messageInputFieldWidgetText1 {
    return Intl.message(
      'Enter a message...',
      name: 'messageInputFieldWidgetText1',
      desc: '',
      args: [],
    );
  }

  /// `Write a reply...`
  String get messageInputFieldWidgetText2 {
    return Intl.message(
      'Write a reply...',
      name: 'messageInputFieldWidgetText2',
      desc: '',
      args: [],
    );
  }

  /// `The file has been saved`
  String get videoDownloadWidgetText1 {
    return Intl.message(
      'The file has been saved',
      name: 'videoDownloadWidgetText1',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get language {
    return Intl.message(
      'Language',
      name: 'language',
      desc: '',
      args: [],
    );
  }

  /// `Unknown`
  String get unknown {
    return Intl.message(
      'Unknown',
      name: 'unknown',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ja'),
      Locale.fromSubtags(languageCode: 'ko'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
