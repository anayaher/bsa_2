import 'package:intl/intl.dart';

class THelper {
  static String formatDate(String rawDate) {
    try {
      final date = DateTime.parse(rawDate);
      return DateFormat("dd MMM yyyy").format(date);
    } catch (_) {
      return rawDate; // if parsing fails
    }
  }
}
