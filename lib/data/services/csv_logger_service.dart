import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

class CsvLoggerService {
  /// Melakukan logging hasil scan struk secara rahasia di background.
  /// Karena AI belum tahu harga asli (Ground Truth), kolom Harga Asli dikosongkan.
  static Future<void> logReceiptScan({
    required String systemTotal,
    required String rawJson,
  }) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/receipt_accuracy_log.csv');

      // Jika file belum ada, buat file dan tambahkan Header
      if (!await file.exists()) {
        await file.writeAsString(
          'ID Struk,Jenis Struk,Harga Asli (Ground Truth),Harga Terbaca oleh AI (Sistem),Status,Keterangan\n',
        );
      }

      // Generate ID unik simpel (berdasarkan timestamp)
      final timestampId = DateTime.now().millisecondsSinceEpoch
          .toString()
          .substring(5);

      // Karena kita butuh jenis struk, kita bisa mencoba tebak dari rawJson atau kita kosongi dulu
      String jenisStruk = "Tidak Diketahui";
      if (rawJson.toLowerCase().contains("indomaret") ||
          rawJson.toLowerCase().contains("alfamart")) {
        jenisStruk = "Minimarket";
      } else if (rawJson.toLowerCase().contains("spbu") ||
          rawJson.toLowerCase().contains("pertamina")) {
        jenisStruk = "SPBU";
      } else {
        jenisStruk = "Umum/Lainnya";
      }

      // Format baris CSV
      // ID Struk, Jenis Struk, Harga Asli, Harga Sistem, Status, Keterangan
      // Harga Asli dan Status dikosongkan agar bisa diisi manual
      final row =
          '$timestampId,$jenisStruk,-,$systemTotal,-,Raw JSON: ${rawJson.replaceAll('\n', '').replaceAll(',', ';')}\n';

      // Append ke file
      await file.writeAsString(row, mode: FileMode.append);

      debugPrint('CSV_LOG: Berhasil mencatat ke ${file.path}');
    } catch (e) {
      debugPrint('CSV_LOG_ERROR: $e');
    }
  }
}
