enum AppMessageType {
  text,
  video,
  audio,
  image,
  file;

  static AppMessageType fromProtoValue(int value) {
    switch (value) {
      case 0:
        return AppMessageType.text;
      case 1:
        return AppMessageType.video;
      case 2:
        return AppMessageType.audio;
      case 3:
        return AppMessageType.image;
      case 4:
        return AppMessageType.file;
      default:
        return AppMessageType.text;
    }
  }

  int toProtoValue() => index;
}
