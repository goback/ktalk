import 'package:ktalk/chat/models/chat_model.dart';
import 'package:ktalk/chat/models/message_model.dart';
import 'package:ktalk/common/providers/base_state.dart';

class ChatState extends BaseState {
  ChatState({
    required super.model,
    required super.messageList,
    required super.hasPrev,
  });

  factory ChatState.init() {
    return ChatState(
      model: ChatModel.init(),
      messageList: [],
      hasPrev: false,
    );
  }

  ChatState copyWith({
    ChatModel? model,
    List<MessageModel>? messageList,
    bool? hasPrev,
  }) {
    return ChatState(
      model: model ?? this.model,
      messageList: messageList ?? this.messageList,
      hasPrev: hasPrev ?? this.hasPrev,
    );
  }
}
