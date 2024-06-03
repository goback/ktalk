import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ktalk/common/providers/base_provider.dart';
import 'package:ktalk/common/providers/custom_theme_provider.dart';
import 'package:ktalk/common/utils/locale/generated/l10n.dart';
import 'package:ktalk/common/widgets/message_input_field_widget.dart';
import 'package:ktalk/group/models/group_model.dart';
import 'package:ktalk/group/providers/group_provider.dart';

class GroupScreen extends ConsumerWidget {
  static const String routeName = '/group-screen';

  const GroupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupModel = ref.watch(groupProvider).model as GroupModel;

    if (groupModel.id.isEmpty) {
      return Container();
    }

    final themeColor = ref.watch(customThemeProvider).themeColor;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: themeColor.background3Color,
        appBar: AppBar(
          backgroundColor: themeColor.background3Color,
          title: Row(
            children: [
              CircleAvatar(
                backgroundImage: groupModel.groupImageUrl == null
                    ? const ExtendedAssetImageProvider(
                        'assets/images/profile.png') as ImageProvider
                    : ExtendedNetworkImageProvider(groupModel.groupImageUrl!),
              ),
              const SizedBox(width: 10),
              Text(
                '${groupModel.groupName}(${groupModel.userList.where((userModel) => userModel.uid.isNotEmpty).length}${S.current.groupScreenText1})',
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        body: ProviderScope(
          overrides: [
            baseProvider.overrideWithValue(groupModel),
          ],
          child: const Column(
            children: [
              Expanded(
                child: Text('message list'),
              ),
              MessageInputFieldWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
