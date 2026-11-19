import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String formatDate(String isoDate) {
    if (isoDate.isEmpty) return '-';
    try {
      final date = DateTime.parse(isoDate).toLocal();
      return DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(date);
    } catch (_) {
      return isoDate;
    }
  }
}
