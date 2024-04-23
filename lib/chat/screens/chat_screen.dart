import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ktalk/chat/providers/chat_provider.dart';
import 'package:ktalk/common/providers/custom_theme_provider.dart';
import 'package:ktalk/common/widgets/message_input_field_widget.dart';
import 'package:ktalk/common/widgets/message_list_widget.dart';

class ChatScreen extends ConsumerStatefulWidget {
  static const String routeName = '/chat-screen';

  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    final chatModel = ref.watch(chatProvider).model;
    final themeColor = ref.watch(customThemeProvider).themeColor;

    final userModel = chatModel.userList[1];

    return Scaffold(
      backgroundColor: themeColor.background3Color,
      appBar: AppBar(
        backgroundColor: themeColor.background3Color,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: userModel.photoURL == null
                  ? const ExtendedAssetImageProvider(
                      'assets/images/profile.png') as ImageProvider
                  : ExtendedNetworkImageProvider(userModel.photoURL!),
            ),
            const SizedBox(width: 10),
            Text(userModel.displayName),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: MessageListWidget(),
          ),
          MessageInputFieldWidget(),
        ],
      ),
    );
  }
}
