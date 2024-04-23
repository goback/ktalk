import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ktalk/auth/models/user_model.dart';
import 'package:ktalk/common/models/base_model.dart';

class ChatModel extends BaseModel {
  ChatModel({
    required super.id,
    super.lastMessage = '',
    required super.userList,
    required super.createAt,
  });

  factory ChatModel.init() {
    return ChatModel(
      id: '',
      userList: [],
      createAt: Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lastMessage': lastMessage,
      'userList': userList.map<String>((e) => e.uid).toList(),
      'createAt': createAt,
    };
  }

  factory ChatModel.fromMap({
    required Map<String, dynamic> map,
    required List<UserModel> userList,
  }) {
    return ChatModel(
      id: map['id'],
      lastMessage: map['lastMessage'],
      userList: userList,
      createAt: map['createAt'],
    );
  }

  ChatModel copyWith({
    String? id,
    String? lastMessage,
    List<UserModel>? userList,
    Timestamp? createAt,
  }) {
    return ChatModel(
      id: id ?? this.id,
      lastMessage: lastMessage ?? this.lastMessage,
      userList: userList ?? this.userList,
      createAt: createAt ?? this.createAt,
    );
  }
}
