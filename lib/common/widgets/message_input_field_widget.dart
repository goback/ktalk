import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ktalk/chat/providers/chat_provider.dart';
import 'package:ktalk/common/enum/message_enum.dart';
import 'package:ktalk/common/providers/custom_theme_provider.dart';
import 'package:ktalk/common/utils/global_navigator.dart';
import 'package:ktalk/common/utils/locale/generated/l10n.dart';
import 'package:ktalk/common/utils/logger.dart';

class MessageInputFieldWidget extends ConsumerStatefulWidget {
  const MessageInputFieldWidget({super.key});

  @override
  ConsumerState<MessageInputFieldWidget> createState() =>
      _MessageInputFieldWidgetState();
}

class _MessageInputFieldWidgetState
    extends ConsumerState<MessageInputFieldWidget> {
  final TextEditingController _textEditingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool isTextInputted = false;
  bool isEmojiShow = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      setState(() {
        isEmojiShow = false;
      });
    }
  }

  Future<void> _sendTextMessage() async {
    try {
      ref.watch(chatProvider.notifier).sendMessage(
            text: _textEditingController.text,
            messageType: MessageEnum.text,
          );
      _textEditingController.clear();
      setState(() {
        isTextInputted = false;
        isEmojiShow = false;
      });
    } catch (e, stackTrace) {
      logger.e(e);
      logger.e(stackTrace);
      GlobalNavigator.showAlertDialog(text: e.toString());
    }
  }

  Widget _mediaFileUploadButton({
    required IconData iconData,
    required Color backgroundColor,
    required VoidCallback onPressed,
    required String text,
  }) {
    final themeColor = ref.watch(customThemeProvider).themeColor;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              backgroundColor: backgroundColor,
              minimumSize: const Size(50, 50),
            ),
            onPressed: onPressed,
            child: Icon(
              iconData,
              color: themeColor.text1Color,
            ),
          ),
          const SizedBox(height: 5),
          Text(text),
        ],
      ),
    );
  }

  void _showMediaFileUploadSheet() {
    final themeColor = ref.watch(customThemeProvider).themeColor;
    showBottomSheet(
      shape: const LinearBorder(),
      backgroundColor: themeColor.background2Color,
      context: context,
      builder: (context) {
        return Row(
          children: [
            _mediaFileUploadButton(
              iconData: Icons.image_outlined,
              backgroundColor: Colors.lightGreen,
              onPressed: () {
                _sendMediaMessage(
                  messageType: MessageEnum.image,
                );
              },
              text: S.current.image,
            ),
            _mediaFileUploadButton(
              iconData: Icons.camera_alt_outlined,
              backgroundColor: Colors.blueAccent,
              onPressed: () {},
              text: S.current.video,
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendMediaMessage({
    required MessageEnum messageType,
  }) async {
    XFile? xFile;
    if (messageType == MessageEnum.image) {
      xFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxHeight: 1024,
        maxWidth: 1024,
      );
    }

    if (xFile == null) return;

    ref.watch(chatProvider.notifier).sendMessage(
          messageType: messageType,
          file: File(xFile.path),
        );
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = ref.watch(customThemeProvider).themeColor;

    return PopScope(
      canPop: !isEmojiShow,
      onPopInvoked: (didPop) {
        setState(() {
          isEmojiShow = false;
        });
      },
      child: Column(
        children: [
          Offstage(
            offstage: !isEmojiShow,
            child: SizedBox(
              height: 250,
              child: EmojiPicker(
                textEditingController: _textEditingController,
                onEmojiSelected: (category, emoji) {
                  setState(() {
                    isTextInputted = true;
                  });
                },
                onBackspacePressed: () {
                  if (_textEditingController.text.isEmpty) {
                    setState(() {
                      isTextInputted = false;
                    });
                  }
                },
              ),
            ),
          ),
          Container(
            color: themeColor.background2Color,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _showMediaFileUploadSheet(),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      Icons.add,
                      color: themeColor.text2Color,
                    ),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _textEditingController,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: S.current.messageInputFieldWidgetText1,
                      hintStyle: TextStyle(color: themeColor.text2Color),
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 0,
                          style: BorderStyle.none,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(5),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty && !isTextInputted) {
                        setState(() {
                          isTextInputted = true;
                        });
                      } else if (value.isEmpty && isTextInputted) {
                        setState(() {
                          isTextInputted = false;
                        });
                      }
                    },
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    await SystemChannels.textInput
                        .invokeListMethod('TextInput.hide');
                    // FocusScope.of(context).unfocus();
                    setState(() {
                      isEmojiShow = !isEmojiShow;
                    });
                  },
                  child: Icon(
                    Icons.emoji_emotions_outlined,
                    color: themeColor.text2Color,
                  ),
                ),
                const SizedBox(width: 15),
                if (isTextInputted)
                  Container(
                    height: 55,
                    width: 55,
                    color: Colors.yellow,
                    child: GestureDetector(
                      onTap: _sendTextMessage,
                      child: const Icon(
                        Icons.send,
                        color: Colors.black,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
