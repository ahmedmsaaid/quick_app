enum StreamType {
  file(0),
  photo(1),
  video(2),
  unknown(3);

  const StreamType(this.value);

  final int value;
}
