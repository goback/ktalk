class UserModel {
  final String displayName;
  final String uid;
  final String? photoURL;
  final String phoneNumber;

  const UserModel({
    required this.displayName,
    required this.uid,
    this.photoURL,
    required this.phoneNumber,
  });

  factory UserModel.init() {
    return const UserModel(
      displayName: '',
      uid: '',
      photoURL: null,
      phoneNumber: '',
    );
  }
}
