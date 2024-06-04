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

  Future<void> exitGroup({
    required GroupModel groupModel,
    required String currentUserId,
  }) async {
    try {
      final groupsDocRef = firestore.collection('groups').doc(groupModel.id);
      final usersChatsDocRef = firestore
          .collection('users')
          .doc(currentUserId)
          .collection('groups')
          .doc(groupModel.id);

      firestore.runTransaction((transaction) async {
        transaction.update(groupsDocRef, {
          'userList': FieldValue.arrayRemove([currentUserId]),
        });

        for (final userModel in groupModel.userList) {
          if (userModel.uid == currentUserId || userModel.uid.isEmpty) continue;
          final userChatDocRef = firestore
              .collection('users')
              .doc(userModel.uid)
              .collection('groups')
              .doc(groupModel.id);
          transaction.update(userChatDocRef, {
            'userList': FieldValue.arrayRemove([currentUserId]),
          });
          transaction.update(userChatDocRef, {
            'userList': FieldValue.arrayUnion(['']),
            'createAt': Timestamp.now(),
          });
        }

        transaction.delete(usersChatsDocRef);
      });
    } catch (_) {
      rethrow;
    }
  }

  Future<List<MessageModel>> getMessageList({
    required String groupId,
    String? lastMessageId,
    String? firstMessageId,
  }) async {
    try {
      Query<Map<String, dynamic>> query = firestore
          .collection('groups')
          .doc(groupId)
          .collection('messages')
          .orderBy('createdAt')
          .limitToLast(20);

      if (lastMessageId != null) {
        final lastDocRef = await firestore
            .collection('groups')
            .doc(groupId)
            .collection('messages')
            .doc(lastMessageId)
            .get();
        query = query.startAfterDocument(lastDocRef);
      } else if (firstMessageId != null) {
        final firstDocRef = await firestore
            .collection('groups')
            .doc(groupId)
            .collection('messages')
            .doc(firstMessageId)
            .get();
        query = query.endBeforeDocument(firstDocRef);
      }

      final snapshot = await query.get();
      return await Future.wait(snapshot.docs.map((messageDoc) async {
        final userModel = await firestore
            .collection('users')
            .doc(messageDoc.data()['userId'])
            .get()
            .then((value) => UserModel.fromMap(value.data()!));
        return MessageModel.fromMap(messageDoc.data(), userModel);
      }).toList());
    } catch (_) {
      rethrow;
    }
  }

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
