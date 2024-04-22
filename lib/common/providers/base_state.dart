import 'package:ktalk/common/models/base_model.dart';

abstract class BaseState {
  final BaseModel model;

  const BaseState({
    required this.model,
  });
}
