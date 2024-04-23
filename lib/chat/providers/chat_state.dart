import 'package:ktalk/chat/models/chat_model.dart';
import 'package:ktalk/chat/models/message_model.dart';
import 'package:ktalk/common/providers/base_state.dart';

class ChatState extends BaseState {
  ChatState({
    required super.model,
    required super.messageList,
  });

  factory ChatState.init() {
    return ChatState(
      model: ChatModel.init(),
      messageList: [],
    );
  }

  ChatState copyWith({
    ChatModel? model,
    List<MessageModel>? messageList,
  }) {
    return ChatState(
      model: model ?? this.model,
      messageList: messageList ?? this.messageList,
    );
  }
}
