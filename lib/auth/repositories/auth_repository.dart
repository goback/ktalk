import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ktalk/common/utils/logger.dart';
import 'package:mime/mime.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(
    auth: FirebaseAuth.instance,
    firebaseStorage: FirebaseStorage.instance,
  ),
);

class AuthRepository {
  final FirebaseAuth auth;
  final FirebaseStorage firebaseStorage;
  String? _verificationId;

  AuthRepository({
    required this.auth,
    required this.firebaseStorage,
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

  Future<void> verifyOTP({
    required String userOTP,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: userOTP,
    );

    await auth.signInWithCredential(credential);
  }

  saveUserData({
    required String name,
    required File? profileImage,
  }) async {
    final uid = auth.currentUser!.uid;

    String? photoUrl;

    if (profileImage != null) {
      final mimeType = lookupMimeType(profileImage.path);
      final metadata = SettableMetadata(contentType: mimeType);
      final snapshot = await firebaseStorage
          .ref()
          .child('profile')
          .child(uid)
          .putFile(profileImage, metadata);
      photoUrl = await snapshot.ref.getDownloadURL();
    }
  }
}
