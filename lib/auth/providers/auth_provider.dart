import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ktalk/auth/providers/auth_state.dart';
import 'package:ktalk/auth/repositories/auth_repository.dart';

final authStateProvider = StreamProvider<User?>(
  (ref) => FirebaseAuth.instance.authStateChanges(),
);

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  () => AuthNotifier(),
);

class AuthNotifier extends Notifier<AuthState> {
  late AuthRepository authRepository;

  @override
  AuthState build() {
    authRepository = ref.watch(authRepositoryProvider);
    return AuthState.init();
  }

  Future<void> sendOTP({
    required String phoneNumber,
  }) async {
    await authRepository.sendOTP(phoneNumber: phoneNumber);
  }

  Future<void> verifyOTP({
    required String userOTP,
  }) async {
    await authRepository.verifyOTP(userOTP: userOTP);
  }

  Future<void> saveUserData({
    required String name,
    required File? profileImage,
  }) async {
    await authRepository.saveUserData(
      name: name,
      profileImage: profileImage,
    );
  }
}
