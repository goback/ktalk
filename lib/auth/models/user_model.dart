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

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'uid': uid,
      'photoURL': photoURL,
      'phoneNumber': phoneNumber,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      displayName: map['displayName'],
      uid: map['uid'],
      photoURL: map['photoURL'],
      phoneNumber: map['phoneNumber'],
    );
  }

  @override
  String toString() {
    return 'UserModel{displayName: $displayName, uid: $uid, photoURL: $photoURL, phoneNumber: $phoneNumber}';
  }
}
