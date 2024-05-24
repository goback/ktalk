import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ktalk/auth/models/user_model.dart';
import 'package:ktalk/chat/models/chat_model.dart';
import 'package:ktalk/chat/models/message_model.dart';
import 'package:ktalk/common/enum/message_enum.dart';
import 'package:mime/mime.dart';
import 'package:uuid/uuid.dart';

final chatRepositoryProvider = Provider<ChatRepository>(
  (ref) => ChatRepository(
    firestore: FirebaseFirestore.instance,
    storage: FirebaseStorage.instance,
    auth: FirebaseAuth.instance,
  ),
);

class ChatRepository {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  final FirebaseAuth auth;

  const ChatRepository({
    required this.firestore,
    required this.storage,
    required this.auth,
  });

  Future<void> exitChat({
    required ChatModel chatModel,
    required String currentUserId,
  }) async {
    try {
      final chatsDocRef = firestore.collection('chats').doc(chatModel.id);
      final usersChatsDocRef = firestore
          .collection('users')
          .doc(currentUserId)
          .collection('chats')
          .doc(chatModel.id);

      firestore.runTransaction((transaction) async {
        transaction.update(chatsDocRef, {
          'userList': FieldValue.arrayRemove([currentUserId]),
        });

        for (final userModel in chatModel.userList) {
          if (userModel.uid == currentUserId || userModel.uid.isEmpty) continue;
          final userChatDocRef = firestore
              .collection('users')
              .doc(userModel.uid)
              .collection('chats')
              .doc(chatModel.id);
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

  Stream<List<ChatModel>> getChatList({
    required UserModel currentUserModel,
  }) {
    try {
      return firestore
          .collection('users')
          .doc(currentUserModel.uid)
          .collection('chats')
          .orderBy('createAt', descending: true)
          .snapshots()
          .asyncMap((event) async {
        List<ChatModel> chatModelList = [];

        for (final doc in event.docs) {
          UserModel userModel = UserModel.init();
          final chatData = doc.data();

          List<String> userIdList = List<String>.from(chatData['userList']);

          final userId = userIdList.firstWhere(
            (element) => element != currentUserModel.uid,
          );

          if (userId.isNotEmpty) {
            userModel = await firestore
                .collection('users')
                .doc(userId)
                .get()
                .then((value) => UserModel.fromMap(value.data()!));
          }

          final chatModel = ChatModel.fromMap(
            map: chatData,
            userList: [currentUserModel, userModel],
          );

          chatModelList.add(chatModel);
        }

        return chatModelList;
      });
    } catch (_) {
      rethrow;
    }
  }

  Future<ChatModel> enterChatFromFriendList({
    required Contact selectedContact,
  }) async {
    try {
      final phoneNumber = selectedContact.phones.first.normalizedNumber;
      final userId = await firestore
          .collection('phoneNumbers')
          .doc(phoneNumber)
          .get()
          .then((value) => value.data()!['uid']);

      final currentUserId = auth.currentUser!.uid;

      final userModelList = [
        await firestore
            .collection('users')
            .doc(currentUserId)
            .get()
            .then((value) => UserModel.fromMap(value.data()!)),
        await firestore
            .collection('users')
            .doc(userId)
            .get()
            .then((value) => UserModel.fromMap(value.data()!)),
      ];

      final querySnapshot = await firestore
          .collection('users')
          .doc(currentUserId)
          .collection('chats')
          .where('userList', arrayContains: userId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return await _createChat(userModelList: userModelList);
      }

      return ChatModel.fromMap(
        map: querySnapshot.docs.first.data(),
        userList: userModelList,
      );
    } catch (_) {
      rethrow;
    }
  }

  Future<ChatModel> _createChat({
    required List<UserModel> userModelList,
  }) async {
    try {
      final chatDocRef = firestore.collection('chats').doc();
      final chatModel = ChatModel(
        id: chatDocRef.id,
        userList: userModelList,
        lastMessage: '',
        createAt: Timestamp.now(),
      );

      await firestore.runTransaction((transaction) async {
        transaction.set(chatDocRef, chatModel.toMap());

        for (var userModel in userModelList) {
          final usersChatsDocRef = firestore
              .collection('users')
              .doc(userModel.uid)
              .collection('chats')
              .doc(chatDocRef.id);
          transaction.set(usersChatsDocRef, chatModel.toMap());
        }
      });
      return chatModel;
    } catch (_) {
      rethrow;
    }
  }

  Future<void> sendMessage({
    String? text,
    File? file,
    required ChatModel chatModel,
    required UserModel currentUserModel,
    required MessageEnum messageType,
    required MessageModel? replyMessageModel,
  }) async {
    try {
      if (messageType != MessageEnum.text) {
        text = messageType.toText();
      }

      chatModel = chatModel.copyWith(
        createAt: Timestamp.now(),
        lastMessage: text,
      );

      final messageDocRef = firestore
          .collection('chats')
          .doc(chatModel.id)
          .collection('messages')
          .doc();

      if (messageType != MessageEnum.text) {
        String? mimeType = lookupMimeType(file!.path); // 'image/png'
        final metadata = SettableMetadata(contentType: mimeType);
        final filename = '${const Uuid().v1()}.${mimeType!.split('/')[1]}';

        TaskSnapshot snapshot = await storage
            .ref()
            .child('chat')
            .child(chatModel.id)
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

        for (final userModel in chatModel.userList) {
          transaction.set(
            firestore
                .collection('users')
                .doc(userModel.uid)
                .collection('chats')
                .doc(chatModel.id),
            chatModel.toMap(),
          );
        }
      });
    } catch (_) {
      rethrow;
    }
  }

  Future<List<MessageModel>> getMessageList({
    required String chatId,
    String? lastMessageId,
    String? firstMessageId,
  }) async {
    try {
      Query<Map<String, dynamic>> query = firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('createdAt')
          .limitToLast(20);

      if (lastMessageId != null) {
        final lastDocRef = await firestore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .doc(lastMessageId)
            .get();
        query = query.startAfterDocument(lastDocRef);
      } else if (firstMessageId != null) {
        final firstDocRef = await firestore
            .collection('chats')
            .doc(chatId)
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
}
