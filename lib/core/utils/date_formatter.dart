import 'package:intl/intl.dart';

class DateFormatter {
  // Format tanggal standard (Contoh: 25 Apr 2026)
  static String formatMedium(DateTime date, {String languageCode = 'en'}) {
    // Membaca local bahasa, default english
    final format = DateFormat(
      'dd MMM yyyy',
      languageCode == 'id' ? 'id_ID' : 'en_US',
    );
    return format.format(date);
  }

  // Format Jam (Contoh: 14:30)
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }
}
