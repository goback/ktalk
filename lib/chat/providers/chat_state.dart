import 'package:ktalk/chat/models/chat_model.dart';
import 'package:ktalk/common/providers/base_state.dart';

class ChatState extends BaseState {
  ChatState({
    required super.model,
  });

  factory ChatState.init() {
    return ChatState(
      model: ChatModel.init(),
    );
  }

  ChatState copyWith({
    ChatModel? model,
}) {
    return ChatState(
      model: model ?? this.model,
    );
  }
}
