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
      'displayName': this.displayName,
      'uid': this.uid,
      'photoURL': this.photoURL,
      'phoneNumber': this.phoneNumber,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      displayName: map['displayName'] as String,
      uid: map['uid'] as String,
      photoURL: map['photoURL'] as String,
      phoneNumber: map['phoneNumber'] as String,
    );
  }
}
