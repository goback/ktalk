import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ktalk/auth/models/user_model.dart';
import 'package:ktalk/group/models/group_model.dart';
import 'package:mime/mime.dart';

final groupRepositoryProvider = Provider<GroupRepository>(
  (ref) {
    return GroupRepository(
      firestore: FirebaseFirestore.instance,
      storage: FirebaseStorage.instance,
    );
  },
);

class GroupRepository {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  const GroupRepository({
    required this.firestore,
    required this.storage,
  });

  Future<GroupModel> createGroup({
    required File? groupImage,
    required List<Contact> selectedFriendList,
    required UserModel currentUserModel,
    required String groupName,
  }) async {
    String? photoUrl;
    try {
      final groupDocRef = firestore.collection('groups').doc();

      if (groupImage != null) {
        final mimeType = lookupMimeType(groupImage.path);
        final metadata = SettableMetadata(contentType: mimeType);
        final snapshot = await storage
            .ref()
            .child('group')
            .child(groupDocRef.id)
            .putFile(groupImage, metadata);
        photoUrl = await snapshot.ref.getDownloadURL();
      }

      final userList = await Future.wait(selectedFriendList.map(
        (contact) async {
          final phoneNumber = contact.phones.first.normalizedNumber;
          final userId = await firestore
              .collection('phoneNumbers')
              .doc(phoneNumber)
              .get()
              .then((value) => value.data()!['uid']);
          return await firestore
              .collection('users')
              .doc(userId)
              .get()
              .then((value) => UserModel.fromMap(value.data()!));
        },
      ).toList());
      userList.add(currentUserModel);

      final groupModel = GroupModel(
        id: groupDocRef.id,
        userList: userList,
        lastMessage: '',
        groupName: groupName,
        groupImageUrl: photoUrl,
        createAt: Timestamp.now(),
      );

      await firestore.runTransaction(
        (transaction) async {
          transaction.set(groupDocRef, groupModel.toMap());

          for (final userModel in userList) {
            final usersGroupsDocRef = firestore
                .collection('users')
                .doc(userModel.uid)
                .collection('groups')
                .doc(groupModel.id);
            transaction.set(usersGroupsDocRef, groupModel.toMap());
          }
        },
      );

      return groupModel;
    } catch (_) {
      if (photoUrl != null) {
        await storage.refFromURL(photoUrl).delete();
      }
      rethrow;
    }
  }
}
