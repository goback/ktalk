import 'package:ktalk/auth/models/user_model.dart';

class AuthState {
  final UserModel userModel;

  const AuthState({
    required this.userModel,
  });

  factory AuthState.init() {
    return AuthState(
      userModel: UserModel.init(),
    );
  }

  AuthState copyWith({
    UserModel? userModel,
  }) {
    return AuthState(
      userModel: userModel ?? this.userModel,
    );
  }
}
