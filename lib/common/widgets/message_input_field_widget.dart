import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ktalk/common/providers/custom_theme_provider.dart';
import 'package:ktalk/common/utils/locale/generated/l10n.dart';

class MessageInputFieldWidget extends ConsumerStatefulWidget {
  const MessageInputFieldWidget({super.key});

  @override
  ConsumerState<MessageInputFieldWidget> createState() =>
      _MessageInputFieldWidgetState();
}

class _MessageInputFieldWidgetState
    extends ConsumerState<MessageInputFieldWidget> {
  @override
  Widget build(BuildContext context) {
    final themeColor = ref.watch(customThemeProvider).themeColor;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          child: Icon(
            Icons.add,
            color: themeColor.text2Color,
          ),
        ),
        Expanded(
          child: TextField(
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
          ),
        ),
        Icon(
          Icons.emoji_emotions_outlined,
          color: themeColor.text2Color,
        ),
        const SizedBox(width: 15),
        Container(
          height: 55,
          width: 55,
          color: Colors.yellow,
          child: const Icon(
            Icons.send,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
