import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ktalk/auth/providers/auth_provider.dart';
import 'package:ktalk/friend/repositories/friend_repository.dart';

final getFriendListProvider = AutoDisposeFutureProvider<List<Contact>>(
  (ref) {
    final link = ref.keepAlive();
    ref.listen(authStateProvider, (previous, next) {
      if (next.value == null) {
        link.close();
      }
    });

    return ref.watch(friendRepositoryProvider).getFriendList();
  },
);
