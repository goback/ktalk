import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ktalk/auth/providers/auth_state.dart';
import 'package:ktalk/auth/repositories/auth_repository.dart';
import 'package:ktalk/common/providers/loader_provider.dart';

final authStateProvider = StreamProvider<User?>(
  (ref) => FirebaseAuth.instance.authStateChanges(),
);

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  () => AuthNotifier(),
);

class AuthNotifier extends Notifier<AuthState> {
  late AuthRepository authRepository;
  late LoaderNotifier loaderNotifier;

  @override
  AuthState build() {
    authRepository = ref.watch(authRepositoryProvider);
    loaderNotifier = ref.watch(loaderProvider.notifier);
    return AuthState.init();
  }

  Future<void> sendOTP({
    required String phoneNumber,
  }) async {
    try {
      loaderNotifier.show();
      await authRepository.sendOTP(phoneNumber: phoneNumber);
    } catch (_) {
      rethrow;
    } finally {
      loaderNotifier.hide();
    }
  }

  Future<void> verifyOTP({
    required String userOTP,
  }) async {
    try {
      loaderNotifier.show();
      await authRepository.verifyOTP(userOTP: userOTP);
    } catch (_) {
      rethrow;
    } finally {
      loaderNotifier.hide();
    }
  }

  Future<void> saveUserData({
    required String name,
    required File? profileImage,
  }) async {
    try {
      loaderNotifier.show();
      final userModel = await authRepository.saveUserData(
        name: name,
        profileImage: profileImage,
      );

      state = state.copyWith(
        userModel: userModel,
      );
    } catch (_) {
      rethrow;
    } finally {
      loaderNotifier.hide();
    }
  }

  Future<void> getCurrentUserData() async {
    try {
      final userModel = await authRepository.getCurrentUserData();
      state = state.copyWith(
        userModel: userModel,
      );
    } catch (_) {
      rethrow;
    }
  }
}
