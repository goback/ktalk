import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ktalk/friend/repositories/friend_repository.dart';

final getFriendListProvider = FutureProvider<List<Contact>>(
  (ref) => ref.watch(friendRepositoryProvider).getFriendList(),
);
