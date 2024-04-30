import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ktalk/chat/providers/chat_provider.dart';
import 'package:ktalk/common/widgets/message_card_widget.dart';

class MessageListWidget extends ConsumerStatefulWidget {
  const MessageListWidget({super.key});

  @override
  ConsumerState<MessageListWidget> createState() => _MessageListWidgetState();
}

class _MessageListWidgetState extends ConsumerState<MessageListWidget> {
  @override
  void initState() {
    super.initState();
    _getMessageList();
  }

  Future<void> _getMessageList() async {
    await ref.read(chatProvider.notifier).getMessageList();
  }

  @override
  Widget build(BuildContext context) {
    final baseModel = ref.watch(chatProvider).model;
    final messageList = ref.watch(chatProvider).messageList;

    ref.listen(chatListProvider, (previous, next) {
      final updatedModelList = next.value;
      final updatedModel = updatedModelList?.first;

      if (updatedModelList != null && updatedModel!.id == baseModel.id) {
        final lastMessageId =
            messageList.isNotEmpty ? messageList.last.messageId : null;
        ref.watch(chatProvider.notifier).getMessageList(
              lastMessageId: lastMessageId,
            );
      }
    });

    return ListView.builder(
      reverse: true,
      itemCount: messageList.length,
      itemBuilder: (context, index) {
        final reversedMessageList = messageList.reversed.toList();
        return MessageCardWidget(messageModel: reversedMessageList[index]);
      },
    );
  }
}
