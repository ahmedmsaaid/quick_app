import 'package:easy_localization/easy_localization.dart';

String formatDateChatPMAM(DateTime? dt) {
  if (dt == null) return '';

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final thatDay = DateTime(dt.year, dt.month, dt.day);
  final diffDays = today.difference(thatDay).inDays;

  int hour = dt.hour;
  final minute = dt.minute.toString().padLeft(2, '0');

  final isAm = hour < 12;
  final period = isAm ? 'ص' : 'م';

  hour = hour % 12;
  if (hour == 0) hour = 12;
  final h = hour.toString();

  final timeStr = '$h:$minute $period';

  if (diffDays == 0) {
    return timeStr;
  }

  if (diffDays == 1) {
    return 'أمس $timeStr';
  }

  return '${dt.day}/${dt.month}/${dt.year} $timeStr';
}
