import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ktalk/auth/models/user_model.dart';
import 'package:ktalk/common/enum/message_enum.dart';

class MessageModel {
  final String userId;
  final String text;
  final MessageEnum type;
  final Timestamp createdAt;
  final String messageId;
  final UserModel userModel;

  const MessageModel({
    required this.userId,
    required this.text,
    required this.type,
    required this.createdAt,
    required this.messageId,
    required this.userModel,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'text': text,
      'type': type.name,
      'createdAt': createdAt,
      'messageId': messageId,
    };
  }

  MessageModel copyWith({
    String? userId,
    String? text,
    MessageEnum? type,
    Timestamp? createdAt,
    String? messageId,
    UserModel? userModel,
  }) {
    return MessageModel(
      userId: userId ?? this.userId,
      text: text ?? this.text,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      messageId: messageId ?? this.messageId,
      userModel: userModel ?? this.userModel,
    );
  }

  @override
  String toString() {
    return 'MessageModel{userId: $userId, text: $text, type: $type, createdAt: $createdAt, messageId: $messageId, userModel: $userModel}';
  }
}
