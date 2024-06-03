import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ktalk/auth/models/user_model.dart';
import 'package:ktalk/chat/models/message_model.dart';
import 'package:ktalk/common/enum/message_enum.dart';
import 'package:ktalk/group/models/group_model.dart';
import 'package:mime/mime.dart';
import 'package:uuid/uuid.dart';

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

  Stream<List<GroupModel>> getGroupList({
    required UserModel currentUserModel,
  }) {
    try {
      return firestore
          .collection('users')
          .doc(currentUserModel.uid)
          .collection('groups')
          .orderBy('createAt', descending: true)
          .snapshots()
          .asyncMap((event) async {
        List<GroupModel> groupModelList = [];

        for (final doc in event.docs) {
          final groupData = doc.data();

          List<String> userIdList = List<String>.from(groupData['userList']);

          final userModelList = await Future.wait(userIdList.map(
            (userId) async {
              if (userId.isEmpty) {
                return UserModel.init();
              } else if (currentUserModel.uid != userId) {
                return await firestore
                    .collection('users')
                    .doc(userId)
                    .get()
                    .then(
                  (value) {
                    return UserModel.fromMap(value.data()!);
                  },
                );
              } else {
                return currentUserModel;
              }
            },
          ).toList());

          final groupModel = GroupModel.fromMap(
            map: groupData,
            userList: userModelList,
          );

          groupModelList.add(groupModel);
        }

        return groupModelList;
      });
    } catch (_) {
      rethrow;
    }
  }

  Future<void> sendMessage({
    String? text,
    File? file,
    required GroupModel groupModel,
    required UserModel currentUserModel,
    required MessageEnum messageType,
    required MessageModel? replyMessageModel,
  }) async {
    try {
      if (messageType != MessageEnum.text) {
        text = messageType.toText();
      }

      groupModel = groupModel.copyWith(
        createAt: Timestamp.now(),
        lastMessage: text,
      );

      final messageDocRef = firestore
          .collection('groups')
          .doc(groupModel.id)
          .collection('messages')
          .doc();

      if (messageType != MessageEnum.text) {
        String? mimeType = lookupMimeType(file!.path); // 'image/png'
        final metadata = SettableMetadata(contentType: mimeType);
        final filename = '${const Uuid().v1()}.${mimeType!.split('/')[1]}';

        TaskSnapshot snapshot = await storage
            .ref()
            .child('group')
            .child(groupModel.id)
            .child(filename)
            .putFile(file, metadata);
        text = await snapshot.ref.getDownloadURL();
      }

      final messageModel = MessageModel(
        userId: currentUserModel.uid,
        text: text!,
        type: messageType,
        createdAt: Timestamp.now(),
        messageId: messageDocRef.id,
        userModel: UserModel.init(),
        replyMessageModel: replyMessageModel,
      );

      await firestore.runTransaction((transaction) async {
        transaction.set(
          messageDocRef,
          messageModel.toMap(),
        );

        for (final userModel in groupModel.userList) {
          transaction.set(
            firestore
                .collection('users')
                .doc(userModel.uid)
                .collection('groups')
                .doc(groupModel.id),
            groupModel.toMap(),
          );
        }
      });
    } catch (_) {
      rethrow;
    }
  }

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
