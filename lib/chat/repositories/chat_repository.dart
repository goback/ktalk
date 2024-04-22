import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ktalk/auth/models/user_model.dart';
import 'package:ktalk/chat/models/chat_model.dart';

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
}
