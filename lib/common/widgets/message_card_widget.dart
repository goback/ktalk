import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ktalk/chat/models/message_model.dart';
import 'package:ktalk/common/providers/custom_theme_provider.dart';

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
  @override
  Widget build(BuildContext context) {
    final themeColor = ref.watch(customThemeProvider).themeColor;
    final messageModel = widget.messageModel;
    final userModel = messageModel.userModel;
    final createdAt = DateFormat.Hm().format(messageModel.createdAt.toDate());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage: userModel.photoURL == null
                ? const ExtendedAssetImageProvider('assets/images/profile.png')
                    as ImageProvider
                : ExtendedNetworkImageProvider(userModel.photoURL!),
          ),
          const SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(userModel.displayName),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.70,
                      minWidth: 80,
                    ),
                    decoration: BoxDecoration(
                      color: themeColor.background2Color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(7),
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: Text(messageModel.text),
                  ),
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
