import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ktalk/firend/repositories/friend_repository.dart';

class FriendListScreen extends ConsumerWidget {
  const FriendListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(friendRepositoryProvider).getFriendList();
    return Center(
      child: Text('친구 목록 화면'),
    );
  }
}
