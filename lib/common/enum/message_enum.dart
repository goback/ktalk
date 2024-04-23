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
