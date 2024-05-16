import 'package:ktalk/common/utils/locale/generated/l10n.dart';

enum MessageEnum {
  text,
  image,
  video,
}

extension ConvertMessage on String {
  MessageEnum toEnum() {
    switch (this) {
      case 'text':
        return MessageEnum.text;
      case 'image':
        return MessageEnum.image;
      default:
        return MessageEnum.video;
    }
  }
}

extension ConvertString on MessageEnum {
  String toText() {
    switch (this) {
      case MessageEnum.image:
        return '📷 ${S.current.image.toUpperCase()}';
      case MessageEnum.video:
        return '🎬 ${S.current.video.toUpperCase()}';
      case MessageEnum.text:
        return 'TEXT';
    }
  }
}
