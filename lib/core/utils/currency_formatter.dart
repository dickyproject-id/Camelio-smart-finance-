import 'package:intl/intl.dart';

class CurrencyFormatter {
  // Metode statis yang mengubah double menjadi format uang
  // Nilai kurs dan mode USD/IDR akan dipassing dari SettingsProvider
  static String format(
    double amount, {
    bool isUSD = false,
    double exchangeRate = 1.0,
  }) {
    if (isUSD) {
      // Jika mode USD, konversi dengan exchange rate (jika amount aslinya IDR, dibagi rate)
      double convertedAmount = amount / exchangeRate;
      final format = NumberFormat.currency(
        locale: 'en_US',
        symbol: '\$',
        decimalDigits: 2,
      );
      return format.format(convertedAmount);
    } else {
      // Default Mode IDR
      final format = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp',
        decimalDigits: 0,
      );
      return format.format(amount);
    }
  }
}
