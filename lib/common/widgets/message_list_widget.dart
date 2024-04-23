import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ktalk/chat/providers/chat_provider.dart';

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
    final messageList = ref.watch(chatProvider).messageList;
    return ListView.builder(
      itemCount: messageList.length,
      itemBuilder: (context, index) {
        return Text(messageList[index].text);
      },
    );
  }
}
