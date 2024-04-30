import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ktalk/chat/providers/chat_provider.dart';
import 'package:ktalk/common/utils/logger.dart';
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
    ref.listen(chatListProvider, (previous, next) {
      logger.d('참여중인 채팅방이 업데이트됨');
    });

    final messageList = ref.watch(chatProvider).messageList;
    return ListView.builder(
      itemCount: messageList.length,
      itemBuilder: (context, index) {
        return MessageCardWidget(messageModel: messageList[index]);
      },
    );
  }
}
