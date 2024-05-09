import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ktalk/auth/models/user_model.dart';
import 'package:ktalk/chat/models/chat_model.dart';
import 'package:ktalk/chat/models/message_model.dart';
import 'package:ktalk/common/enum/message_enum.dart';

final chatRepositoryProvider = Provider<ChatRepository>(
  (ref) => ChatRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
  ),
);

class ChatRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  const ChatRepository({
    required this.firestore,
    required this.auth,
  });

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
          final chatData = doc.data();

          List<String> userIdList = List<String>.from(chatData['userList']);

          final userId = userIdList.firstWhere(
            (element) => element != currentUserModel.uid,
          );

          final userModel = await firestore
              .collection('users')
              .doc(userId)
              .get()
              .then((value) => UserModel.fromMap(value.data()!));

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
    required ChatModel chatModel,
    required UserModel currentUserModel,
    required MessageEnum messageType,
  }) async {
    try {
      chatModel = chatModel.copyWith(
        createAt: Timestamp.now(),
        lastMessage: text,
      );

      final messageDocRef = firestore
          .collection('chats')
          .doc(chatModel.id)
          .collection('messages')
          .doc();

      final messageModel = MessageModel(
        userId: currentUserModel.uid,
        text: text!,
        type: messageType,
        createdAt: Timestamp.now(),
        messageId: messageDocRef.id,
        userModel: UserModel.init(),
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
