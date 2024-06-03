import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ktalk/common/models/base_model.dart';

final baseProvider = AutoDisposeProvider<BaseModel>(
  (ref) {
    throw UnimplementedError();
  },
);
