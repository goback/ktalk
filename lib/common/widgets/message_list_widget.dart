import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ktalk/auth/providers/auth_provider.dart';
import 'package:ktalk/chat/models/chat_model.dart';
import 'package:ktalk/chat/providers/chat_provider.dart';
import 'package:ktalk/common/enum/message_enum.dart';
import 'package:ktalk/common/providers/base_provider.dart';
import 'package:ktalk/common/providers/message_provider.dart';
import 'package:ktalk/common/utils/global_navigator.dart';
import 'package:ktalk/common/widgets/message_card_widget.dart';
import 'package:ktalk/group/providers/group_provider.dart';

class MessageListWidget extends ConsumerStatefulWidget {
  const MessageListWidget({super.key});

  @override
  ConsumerState<MessageListWidget> createState() => _MessageListWidgetState();
}

class _MessageListWidgetState extends ConsumerState<MessageListWidget> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _getMessageList();
    scrollController.addListener(scrollListener);
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  Future<void> _getMessageList() async {
    final baseModel = ref.read(baseProvider);
    baseModel is ChatModel
        ? await ref.read(chatProvider.notifier).getMessageList()
        : await ref.read(groupProvider.notifier).getMessageList();
  }

  void scrollListener() {
    final baseModel = ref.read(baseProvider);
    final provider = baseModel is ChatModel ? chatProvider : groupProvider;
    final baseState = ref.read(provider);

    if (baseState.hasPrev &&
        scrollController.offset >= scrollController.position.maxScrollExtent) {
      baseModel is ChatModel
          ? ref.read(chatProvider.notifier).getMessageList(
                firstMessageId: baseState.messageList.first.messageId,
              )
          : ref.read(groupProvider.notifier).getMessageList(
                firstMessageId: baseState.messageList.first.messageId,
              );
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseModel = ref.read(baseProvider);
    final provider = baseModel is ChatModel ? chatProvider : groupProvider;
    final messageList = ref.watch(provider).messageList;
    final currentUserId = ref.watch(authProvider).userModel.uid;

    ref.listen(
      provider,
      (previous, next) {
        if (scrollController.offset <=
            scrollController.position.minScrollExtent + 20) return;

        if (previous == null ||
            next.model.id.isEmpty ||
            previous.messageList.first != next.messageList.first ||
            next.messageList.last.userId == currentUserId) return;
        final newMessage = next.messageList.last;
        GlobalNavigator.showToast(
          msg: newMessage.type != MessageEnum.text
              ? newMessage.type.toText()
              : newMessage.text,
        );
      },
    );

    final streamListProvider =
        baseModel is ChatModel ? chatListProvider : groupListProvider;

    ref.listen(streamListProvider, (previous, next) {
      final updatedModelList = next.value;
      final updatedModel = updatedModelList?.first;

      if (updatedModelList != null && updatedModel!.id == baseModel.id) {
        final lastMessageId =
            messageList.isNotEmpty ? messageList.last.messageId : null;

        baseModel is ChatModel
            ? ref.read(chatProvider.notifier).getMessageList(
                  lastMessageId: lastMessageId,
                )
            : ref.read(groupProvider.notifier).getMessageList(
                  lastMessageId: lastMessageId,
                );
      }
    });

    return SingleChildScrollView(
      controller: scrollController,
      reverse: true,
      child: Column(
        children: [
          for (final item in messageList)
            ProviderScope(
              overrides: [
                messageProvider.overrideWithValue(item),
              ],
              child: const MessageCardWidget(),
            )
        ],
      ),
    );
  }
}
