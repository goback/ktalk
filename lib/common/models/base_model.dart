import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ktalk/auth/models/user_model.dart';

abstract class BaseModel {
  final String id;
  final String lastMessage;
  final List<UserModel> userList;
  final Timestamp createAt;

  const BaseModel({
    required this.id,
    this.lastMessage = '',
    required this.userList,
    required this.createAt,
  });
}
