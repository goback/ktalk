import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ktalk/auth/providers/auth_state.dart';
import 'package:ktalk/auth/repositories/auth_repository.dart';

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
}
