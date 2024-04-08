import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ktalk/common/utils/logger.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(auth: FirebaseAuth.instance),
);

class AuthRepository {
  final FirebaseAuth auth;
  String? _verificationId;

  AuthRepository({
    required this.auth,
  });

  Future<void> sendOTP({
    required String phoneNumber,
  }) async {
    await auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      codeSent: (verificationId, _) {
        _verificationId = verificationId;
      },
      verificationCompleted: (_) {},
      verificationFailed: (error) {
        logger.d(error.message);
        logger.d(error.stackTrace);
      },
      codeAutoRetrievalTimeout: (_) {},
    );
  }
}
