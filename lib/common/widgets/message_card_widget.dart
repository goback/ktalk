import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ktalk/auth/providers/auth_provider.dart';
import 'package:ktalk/chat/models/message_model.dart';
import 'package:ktalk/chat/providers/chat_provider.dart';
import 'package:ktalk/common/enum/message_enum.dart';
import 'package:ktalk/common/models/theme_color.dart';
import 'package:ktalk/common/providers/custom_theme_provider.dart';
import 'package:ktalk/common/providers/message_provider.dart';
import 'package:ktalk/common/utils/locale/generated/l10n.dart';
import 'package:ktalk/common/widgets/custom_image_viewer_widget.dart';
import 'package:ktalk/common/widgets/video_download_widget.dart';

class MessageCardWidget extends ConsumerStatefulWidget {
  const MessageCardWidget({super.key});

  @override
  ConsumerState<MessageCardWidget> createState() => _MessageCardWidgetState();
}

class _MessageCardWidgetState extends ConsumerState<MessageCardWidget>
    with SingleTickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _messageText({
    required String text,
    required MessageEnum messageType,
    required bool isMe,
    required ThemeColor themeColor,
  }) {
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

  Widget mediaPreviewWidget({
    required String url,
    required MessageEnum messageType,
  }) {
    switch (messageType) {
      case MessageEnum.image:
        return CustomImageViewerWidget(imageUrl: url);
      default:
        return VideoDownloadWidget(downloadUrl: url);
    }
  }

  Widget replyMessageInfoWidget({
    required bool isMe,
    required MessageModel replyMessageModel,
    required String currentUserId,
    required ThemeColor themeColor,
  }) {
    final baseModel = ref.read(chatProvider).model;
    final userName = currentUserId == replyMessageModel.userId
        ? S.current.receiver
        : baseModel.userList[1].displayName.isNotEmpty
            ? baseModel.userList[1].displayName
            : S.current.unknown;

    return ListTile(
      visualDensity: VisualDensity.compact,
      horizontalTitleGap: 10,
      contentPadding: const EdgeInsets.symmetric(horizontal: 5),
      leading: replyMessageModel.type != MessageEnum.text
          ? FittedBox(
              child: mediaPreviewWidget(
                url: replyMessageModel.text,
                messageType: replyMessageModel.type,
              ),
            )
          : null,
      title: Text(
        S.current.replyTo(userName),
        style: TextStyle(
          color: isMe ? Colors.black : themeColor.text1Color,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        replyMessageModel.type == MessageEnum.text
            ? replyMessageModel.text
            : replyMessageModel.type.toText(),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: themeColor.text2Color),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = ref.watch(customThemeProvider).themeColor;
    final messageModel = ref.watch(messageProvider);
    final userModel = messageModel.userModel;
    final createdAt = DateFormat.Hm().format(messageModel.createdAt.toDate());

    final currentUserId = ref.watch(authProvider).userModel.uid;
    final isMe = messageModel.userId == currentUserId;

    return Stack(
      alignment: AlignmentDirectional.centerEnd,
      children: [
        AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Opacity(
                opacity: _animation.value,
                child: Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: Icon(
                    Icons.subdirectory_arrow_right,
                    color: themeColor.text2Color,
                  ),
                ),
              );
            }),
        GestureDetector(
          onHorizontalDragUpdate: (details) {
            _controller.value -= (details.primaryDelta ?? 0.0) / 150;
          },
          onHorizontalDragEnd: (details) {
            if (_controller.value >= 0.4) {
              ref.read(replyMessageModelProvider.notifier).state =
                  messageModel.copyWith(
                replyMessageModel: null,
              );
            }
            _controller.reverse();
          },
          child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_controller.value * -50, 0),
                  child: Container(
                    color: Colors.transparent,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: isMe
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isMe)
                            CircleAvatar(
                              backgroundImage: userModel.photoURL == null
                                  ? const ExtendedAssetImageProvider(
                                          'assets/images/profile.png')
                                      as ImageProvider
                                  : ExtendedNetworkImageProvider(
                                      userModel.photoURL!),
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
                                      maxWidth:
                                          MediaQuery.of(context).size.width *
                                              0.70,
                                      minWidth: 80,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isMe
                                          ? Colors.yellow
                                          : themeColor.background2Color,
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
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 5),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (messageModel.replyMessageModel !=
                                            null)
                                          replyMessageInfoWidget(
                                            isMe: isMe,
                                            replyMessageModel:
                                                messageModel.replyMessageModel!,
                                            currentUserId: currentUserId,
                                            themeColor: themeColor,
                                          ),
                                        _messageText(
                                          text: messageModel.text,
                                          messageType: messageModel.type,
                                          isMe: isMe,
                                          themeColor: themeColor,
                                        ),
                                      ],
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
                    ),
                  ),
                );
              }),
        ),
      ],
    );
  }
}
