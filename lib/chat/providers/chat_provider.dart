import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ktalk/chat/providers/chat_state.dart';
import 'package:ktalk/chat/repositories/chat_repository.dart';
import 'package:ktalk/common/providers/loader_provider.dart';

final chatProvider = NotifierProvider<ChatNotifier, ChatState>(
    // () => ChatNotifier(),
    ChatNotifier.new);

class ChatNotifier extends Notifier<ChatState> {
  late LoaderNotifier loaderNotifier;
  late ChatRepository chatRepository;

  @override
  ChatState build() {
    loaderNotifier = ref.watch(loaderProvider.notifier);
    chatRepository = ref.watch(chatRepositoryProvider);
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
}
