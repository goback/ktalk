import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ktalk/chat/providers/chat_provider.dart';
import 'package:ktalk/common/providers/message_provider.dart';
import 'package:ktalk/common/widgets/message_card_widget.dart';

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
    await ref.read(chatProvider.notifier).getMessageList();
  }

  void scrollListener() {
    final baseState = ref.read(chatProvider);

    if (baseState.hasPrev &&
        scrollController.offset >= scrollController.position.maxScrollExtent) {
      ref.read(chatProvider.notifier).getMessageList(
            firstMessageId: baseState.messageList.first.messageId,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(chatProvider);
    final baseModel = status.model;
    final messageList = status.messageList;

    ref.listen(chatListProvider, (previous, next) {
      final updatedModelList = next.value;
      final updatedModel = updatedModelList?.first;

      if (updatedModelList != null && updatedModel!.id == baseModel.id) {
        final lastMessageId =
            messageList.isNotEmpty ? messageList.last.messageId : null;
        ref.read(chatProvider.notifier).getMessageList(
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
