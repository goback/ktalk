import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ktalk/auth/models/user_model.dart';
import 'package:ktalk/auth/providers/auth_provider.dart';
import 'package:ktalk/chat/models/chat_model.dart';
import 'package:ktalk/chat/providers/chat_state.dart';
import 'package:ktalk/chat/repositories/chat_repository.dart';
import 'package:ktalk/common/enum/message_enum.dart';
import 'package:ktalk/common/providers/loader_provider.dart';

final chatProvider = NotifierProvider<ChatNotifier, ChatState>(
    // () => ChatNotifier(),
    ChatNotifier.new);

class ChatNotifier extends Notifier<ChatState> {
  late LoaderNotifier loaderNotifier;
  late ChatRepository chatRepository;
  late UserModel currentUserModel;

  @override
  ChatState build() {
    loaderNotifier = ref.watch(loaderProvider.notifier);
    chatRepository = ref.watch(chatRepositoryProvider);
    currentUserModel = ref.watch(authProvider).userModel;
    return ChatState.init();
  }

  Future<void> enterChatFromFriendList({
    required Contact selectedContact,
  }) async {
    try {
      loaderNotifier.show();
      final chatModel = await chatRepository.enterChatFromFriendList(
        selectedContact: selectedContact,
      );

      state = state.copyWith(
        model: chatModel,
      );
    } catch (_) {
      rethrow;
    } finally {
      loaderNotifier.hide();
    }
  }

  Future<void> sendMessage({
    String? text,
    required MessageEnum messageType,
  }) async {
    try {
      await chatRepository.sendMessage(
        text: text,
        chatModel: state.model as ChatModel,
        currentUserModel: currentUserModel,
        messageType: messageType,
      );
    } catch (_) {
      rethrow;
    }
  }
}
