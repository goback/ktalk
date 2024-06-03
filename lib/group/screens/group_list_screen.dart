import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:ktalk/common/utils/global_navigator.dart';
import 'package:ktalk/common/utils/locale/generated/l10n.dart';
import 'package:ktalk/common/utils/logger.dart';
import 'package:ktalk/group/providers/group_provider.dart';
import 'package:ktalk/group/screens/create_group_screen.dart';
import 'package:ktalk/group/screens/group_screen.dart';
import 'package:loader_overlay/loader_overlay.dart';

class GroupListScreen extends ConsumerWidget {
  const GroupListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: ref.watch(groupListProvider).when(
        data: (data) {
          context.loaderOverlay.hide();
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final groupModel = data[index];
              return Slidable(
                startActionPane: ActionPane(
                  motion: const DrawerMotion(),
                  extentRatio: 0.25,
                  children: [
                    SlidableAction(
                      onPressed: (context) {},
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
                      ref
                          .read(groupProvider.notifier)
                          .enterGroupChatFromGroupList(
                            groupModel: groupModel,
                          );

                      Navigator.pushNamed(
                        context,
                        GroupScreen.routeName,
                      ).then((value) => ref.invalidate(groupProvider));
                    },
                    leading: CircleAvatar(
                      backgroundImage: groupModel.groupImageUrl == null
                          ? const ExtendedAssetImageProvider(
                              'assets/images/profile.png') as ImageProvider
                          : ExtendedNetworkImageProvider(
                              groupModel.groupImageUrl!),
                      radius: 30,
                    ),
                    title: Text(
                      groupModel.groupName,
                      style: const TextStyle(fontSize: 18),
                    ),
                    subtitle: Text(
                      groupModel.lastMessage,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.grey,
                      ),
                    ),
                    trailing: Text(
                      DateFormat.Hm().format(groupModel.createAt.toDate()),
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
        loading: () {
          context.loaderOverlay.show();
          return null;
        },
        error: (error, stackTrace) {
          context.loaderOverlay.hide();
          GlobalNavigator.showAlertDialog(text: error.toString());
          logger.e(error);
          logger.e(stackTrace);
          return null;
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, CreateGroupScreen.routeName);
        },
        child: const Icon(Icons.add_comment_outlined),
      ),
    );
  }
}
