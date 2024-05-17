import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ktalk/auth/providers/auth_provider.dart';
import 'package:ktalk/chat/models/message_model.dart';
import 'package:ktalk/common/enum/message_enum.dart';
import 'package:ktalk/common/providers/custom_theme_provider.dart';
import 'package:ktalk/common/widgets/custom_image_viewer_widget.dart';
import 'package:ktalk/common/widgets/video_download_widget.dart';

class MessageCardWidget extends ConsumerStatefulWidget {
  final MessageModel messageModel;

  const MessageCardWidget({
    super.key,
    required this.messageModel,
  });

  @override
  ConsumerState<MessageCardWidget> createState() => _MessageCardWidgetState();
}

class _MessageCardWidgetState extends ConsumerState<MessageCardWidget> {
  Widget _messageText({
    required String text,
    required MessageEnum messageType,
    required bool isMe,
  }) {
    final themeColor = ref.watch(customThemeProvider).themeColor;
    switch (messageType) {
      case MessageEnum.text:
        return Text(
          text,
          style: TextStyle(
            color: isMe ? Colors.black : themeColor.text1Color,
            fontSize: 16,
          ),
        );
      case MessageEnum.image:
        return CustomImageViewerWidget(imageUrl: text);
      default:
        return VideoDownloadWidget(downloadUrl: text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = ref.watch(customThemeProvider).themeColor;
    final messageModel = widget.messageModel;
    final userModel = messageModel.userModel;
    final createdAt = DateFormat.Hm().format(messageModel.createdAt.toDate());

    final currentUserId = ref.watch(authProvider).userModel.uid;
    final isMe = messageModel.userId == currentUserId;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe)
            CircleAvatar(
              backgroundImage: userModel.photoURL == null
                  ? const ExtendedAssetImageProvider(
                      'assets/images/profile.png') as ImageProvider
                  : ExtendedNetworkImageProvider(userModel.photoURL!),
            ),
          const SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isMe) Text(userModel.displayName),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (isMe)
                    Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: Text(
                        createdAt,
                        style: TextStyle(
                          fontSize: 13,
                          color: themeColor.text2Color,
                        ),
                      ),
                    ),
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.70,
                      minWidth: 80,
                    ),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.yellow : themeColor.background2Color,
                      borderRadius: BorderRadius.only(
                        topRight: const Radius.circular(12),
                        topLeft: isMe
                            ? const Radius.circular(12)
                            : const Radius.circular(0),
                        bottomRight: isMe
                            ? const Radius.circular(0)
                            : const Radius.circular(12),
                        bottomLeft: const Radius.circular(12),
                      ),
                    ),
                    padding: const EdgeInsets.all(7),
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: _messageText(
                      text: messageModel.text,
                      messageType: messageModel.type,
                      isMe: isMe,
                    ),
                  ),
                  if (!isMe)
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Text(
                        createdAt,
                        style: TextStyle(
                          fontSize: 13,
                          color: themeColor.text2Color,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
