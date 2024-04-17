import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ktalk/auth/models/user_model.dart';

final friendRepositoryProvider = Provider<FriendRepository>(
  (ref) => FriendRepository(
    firebaseFirestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
  ),
);

class FriendRepository {
  final FirebaseFirestore firebaseFirestore;
  final FirebaseAuth auth;

  FriendRepository({
    required this.firebaseFirestore,
    required this.auth,
  });

  Future<List<Contact>> getFriendList() async {
    try {
      final myPhoneNumber = auth.currentUser!.phoneNumber;
      List<Contact> result = [];

      List<Contact> contacts =
          await FlutterContacts.getContacts(withProperties: true);

      for (final contact in contacts) {
        final phoneNumber = contact.phones.firstOrNull?.normalizedNumber;

        if (phoneNumber == null || phoneNumber == myPhoneNumber) continue;

        final querySnapshot = await firebaseFirestore
            .collection('phoneNumbers')
            .where(FieldPath.documentId, isEqualTo: phoneNumber)
            .get();

        if (querySnapshot.docs.isEmpty) continue;

        final uid = querySnapshot.docs.first.data()['uid'];

        final documentSnapshot =
            await firebaseFirestore.collection('users').doc(uid).get();
        final userModel = UserModel.fromMap(documentSnapshot.data()!);

        contact.displayName = userModel.displayName;

        if (userModel.photoURL != null) {
          contact.photo =
              await ExtendedNetworkImageProvider(userModel.photoURL!)
                  .getNetworkImageData();
        }

        result.add(contact);
      }

      return result;
    } catch (_) {
      rethrow;
    }
  }
}
