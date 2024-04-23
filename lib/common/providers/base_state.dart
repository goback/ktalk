import 'package:ktalk/chat/models/message_model.dart';
import 'package:ktalk/common/models/base_model.dart';

abstract class BaseState {
  final BaseModel model;
  final List<MessageModel> messageList;

  const BaseState({
    required this.model,
    required this.messageList,
  });
}
