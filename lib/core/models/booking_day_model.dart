class BookingDay {
  final String label; // "السبت 4 أكتوبر"
  final DateTime date;

  BookingDay({required this.label, required this.date});
}

class BookingTime {
  final String label; // "7:00 AM"
  final String value; // مثلاً "07:00"

  BookingTime({required this.label, required this.value});
}
