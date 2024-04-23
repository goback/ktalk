import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ktalk/auth/models/user_model.dart';
import 'package:ktalk/common/utils/logger.dart';
import 'package:mime/mime.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(
    auth: FirebaseAuth.instance,
    firebaseStorage: FirebaseStorage.instance,
    firestore: FirebaseFirestore.instance,
  ),
);

class AuthRepository {
  final FirebaseAuth auth;
  final FirebaseStorage firebaseStorage;
  final FirebaseFirestore firestore;
  String? _verificationId;

  AuthRepository({
    required this.auth,
    required this.firebaseStorage,
    required this.firestore,
  });

  Future<void> sendOTP({
    required String phoneNumber,
  }) async {
    try {
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
    } catch (_) {
      rethrow;
    }
  }

  Future<void> verifyOTP({
    required String userOTP,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: userOTP,
      );

      await auth.signInWithCredential(credential);
    } catch (_) {
      rethrow;
    }
  }

  Future<UserModel> saveUserData({
    required String name,
    required File? profileImage,
  }) async {
    String? photoUrl;
    try {
      WriteBatch batch = firestore.batch();
      final uid = auth.currentUser!.uid;

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

      final userModel = UserModel(
        displayName: name,
        uid: uid,
        photoURL: photoUrl,
        phoneNumber: auth.currentUser!.phoneNumber!,
      );
      final currentUserDocRef = firestore.collection('users').doc(uid);
      final currentPhoneNumbersDocRef = firestore
          .collection('phoneNumbers')
          .doc(auth.currentUser!.phoneNumber!);

      batch.set(currentUserDocRef, userModel.toMap());
      batch.set(currentPhoneNumbersDocRef, {'uid': uid});
      // await currentUserDocRef.set(userModel.toMap());
      // await currentPhoneNumbersDocRef.set({'uid': uid});
      await batch.commit();

      await auth.currentUser!.updateDisplayName(name);

      return userModel;
    } catch (_) {
      if (photoUrl != null) {
        await firebaseStorage.refFromURL(photoUrl).delete();
      }
      rethrow;
    }
  }

  Future<UserModel> getCurrentUserData() async {
    try {
      final userModel = await firestore
          .collection('users')
          .doc(auth.currentUser!.uid)
          .get()
          .then((value) => UserModel.fromMap(value.data()!));
      return userModel;
    } catch (_) {
      rethrow;
    }
  }
}
