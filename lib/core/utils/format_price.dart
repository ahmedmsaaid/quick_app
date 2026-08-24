/// Utility function and extension for formatting prices and fees nicely.
/// E.g. 337.0 -> "337", 8.425 -> "8.43", 8.5 -> "8.5"
String formatPrice(double price) {
  if (price == price.roundToDouble()) {
    return price.toInt().toString();
  }
  final str = price.toStringAsFixed(2);
  return str.replaceAll(RegExp(r'\.?0+$'), '');
}

extension DoublePriceFormatExtension on double {
  String get formattedPrice => formatPrice(this);
}
