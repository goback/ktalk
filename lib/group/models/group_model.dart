import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ktalk/auth/models/user_model.dart';
import 'package:ktalk/common/models/base_model.dart';

class GroupModel extends BaseModel {
  final String groupName;
  final String? groupImageUrl;

  const GroupModel({
    required super.id,
    super.lastMessage = '',
    required super.userList,
    required super.createAt,
    required this.groupName,
    this.groupImageUrl,
  });

  factory GroupModel.init() {
    return GroupModel(
      id: '',
      userList: [],
      createAt: Timestamp.now(),
      groupName: '',
      groupImageUrl: '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lastMessage': lastMessage,
      'userList': userList.map<String>((e) => e.uid).toList(),
      'createAt': createAt,
      'groupName': groupName,
      'groupImageUrl': groupImageUrl,
    };
  }

  factory GroupModel.fromMap({
    required Map<String, dynamic> map,
    required List<UserModel> userList,
  }) {
    return GroupModel(
      id: map['id'],
      lastMessage: map['lastMessage'],
      userList: userList,
      createAt: map['createAt'],
      groupName: map['groupName'],
      groupImageUrl: map['groupImageUrl'],
    );
  }

  GroupModel copyWith({
    String? id,
    String? lastMessage,
    List<UserModel>? userList,
    Timestamp? createAt,
    String? groupName,
    String? groupImageUrl,
  }) {
    return GroupModel(
      id: id ?? this.id,
      lastMessage: lastMessage ?? this.lastMessage,
      userList: userList ?? this.userList,
      createAt: createAt ?? this.createAt,
      groupName: groupName ?? this.groupName,
      groupImageUrl: groupImageUrl ?? this.groupImageUrl,
    );
  }
}
