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
    try {
      await authRepository.sendOTP(phoneNumber: phoneNumber);
    } catch (_) {
      rethrow;
    }
  }

  Future<void> verifyOTP({
    required String userOTP,
  }) async {
    try {
      await authRepository.verifyOTP(userOTP: userOTP);
    } catch (_) {
      rethrow;
    }
  }

  Future<void> saveUserData({
    required String name,
    required File? profileImage,
  }) async {
    try {
      final userModel = await authRepository.saveUserData(
        name: name,
        profileImage: profileImage,
      );

      state = state.copyWith(
        userModel: userModel,
      );
    } catch (_) {
      rethrow;
    }
  }
}
