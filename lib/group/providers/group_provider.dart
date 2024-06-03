import 'dart:io';

import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ktalk/auth/models/user_model.dart';
import 'package:ktalk/auth/providers/auth_provider.dart';
import 'package:ktalk/chat/providers/chat_provider.dart';
import 'package:ktalk/common/enum/message_enum.dart';
import 'package:ktalk/common/providers/loader_provider.dart';
import 'package:ktalk/group/models/group_model.dart';
import 'package:ktalk/group/providers/group_state.dart';
import 'package:ktalk/group/repositories/group_repository.dart';

final groupProvider = NotifierProvider<GroupNotifier, GroupState>(
  // () => GroupNotifier(),
  GroupNotifier.new,
);

final groupListProvider = StreamProvider<List<GroupModel>>(
  (ref) {
    final currentUserModel = ref.watch(authProvider).userModel;
    return ref.watch(groupRepositoryProvider).getGroupList(
          currentUserModel: currentUserModel,
        );
  },
);

class GroupNotifier extends Notifier<GroupState> {
  late LoaderNotifier loaderNotifier;
  late GroupRepository groupRepository;
  late UserModel currentUserModel;

  @override
  GroupState build() {
    loaderNotifier = ref.watch(loaderProvider.notifier);
    groupRepository = ref.watch(groupRepositoryProvider);
    currentUserModel = ref.watch(authProvider).userModel;
    return GroupState.init();
  }

  void enterGroupChatFromGroupList({
    required GroupModel groupModel,
  }) {
    try {
      loaderNotifier.show();
      state = state.copyWith(model: groupModel);
    } catch (_) {
      rethrow;
    } finally {
      loaderNotifier.hide();
    }
  }

  Future<void> sendMessage({
    String? text,
    File? file,
    required MessageEnum messageType,
  }) async {
    try {
      await groupRepository.sendMessage(
        text: text,
        file: file,
        groupModel: state.model as GroupModel,
        currentUserModel: currentUserModel,
        messageType: messageType,
        replyMessageModel: ref.read(replyMessageModelProvider),
      );
    } catch (_) {
      rethrow;
    }

    ref.read(replyMessageModelProvider.notifier).state = null;
  }

  Future<void> createGroup({
    required String groupName,
    required File? groupImage,
    required List<Contact> selectedFriendList,
  }) async {
    try {
      loaderNotifier.show();
      final groupModel = await groupRepository.createGroup(
        groupImage: groupImage,
        selectedFriendList: selectedFriendList,
        currentUserModel: currentUserModel,
        groupName: groupName,
      );

      state = state.copyWith(model: groupModel);
    } catch (_) {
      rethrow;
    } finally {
      loaderNotifier.hide();
    }
  }
}
