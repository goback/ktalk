import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:ktalk/chat/providers/chat_provider.dart';
import 'package:ktalk/chat/screens/chat_screen.dart';
import 'package:ktalk/common/utils/locale/generated/l10n.dart';
import 'package:ktalk/common/utils/logger.dart';
import 'package:loader_overlay/loader_overlay.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ref.watch(chatListProvider).when(
        data: (data) {
          context.loaderOverlay.hide();
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final chatModel = data[index];
              final userModel = chatModel.userList[1];
              return Slidable(
                startActionPane: ActionPane(
                  motion: const DrawerMotion(),
                  extentRatio: 0.25,
                  children: [
                    SlidableAction(
                      onPressed: (context) async {
                        await ref
                            .read(chatProvider.notifier)
                            .exitChat(chatModel: chatModel);
                      },
                      backgroundColor: Colors.red,
                      icon: Icons.exit_to_app_rounded,
                      label: S.current.exit,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: ListTile(
                    onTap: () {
                      ref.read(chatProvider.notifier).enterChatFromChatList(
                            chatModel: chatModel,
                          );
                      Navigator.pushNamed(
                        context,
                        ChatScreen.routeName,
                      ).then((value) => ref.invalidate(chatProvider));
                    },
                    leading: CircleAvatar(
                      backgroundImage: userModel.photoURL == null
                          ? const ExtendedAssetImageProvider(
                              'assets/images/profile.png') as ImageProvider
                          : ExtendedNetworkImageProvider(userModel.photoURL!),
                      radius: 30,
                    ),
                    title: Text(
                      userModel.displayName.isEmpty
                          ? S.current.unknown
                          : userModel.displayName,
                      style: const TextStyle(fontSize: 18),
                    ),
                    subtitle: Text(
                      chatModel.lastMessage,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.grey,
                      ),
                    ),
                    trailing: Text(
                      DateFormat.Hm().format(chatModel.createAt.toDate()),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
        error: (error, stackTrace) {
          context.loaderOverlay.hide();
          logger.e(error);
          logger.e(stackTrace);
          return null;
        },
        loading: () {
          context.loaderOverlay.show();
          return null;
        },
      ),
    );
  }
}
