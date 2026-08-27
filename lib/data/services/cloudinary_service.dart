import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class CloudinaryService {
  // Ambil config dari data asli yang lo kasih tadi
  final String _cloudName =
      dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? 'dicky-adicandra';
  final String _uploadPreset =
      dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? 'camelio-smartfinance';

  /// Fungsi Upload Gambar Otomatis
  /// Lo tinggal masukin file-nya, urusan folder & preset udah gue beresin di dalem.
  Future<String?> uploadImage(
    File imageFile, {
    String folder = 'kertas_struk',
  }) async {
    try {
      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
      );

      final request = http.MultipartRequest('POST', url);

      // SETTING OTOMATIS
      request.fields['upload_preset'] = _uploadPreset;
      request.fields['folder'] =
          folder; // Gunakan folder yang dikirim atau default

      if (folder == 'kertas_struk') {
        request.fields['tags'] =
            'temp_receipt_6_months'; // Tag untuk mempermudah bulk delete 6 bulan
      }

      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        String imageUrl = responseData['secure_url'];

        debugPrint('--- [Cloudinary] Upload Berhasil ---');
        debugPrint('URL: $imageUrl');

        return imageUrl;
      } else {
        debugPrint('--- [Cloudinary] Upload Gagal ---');
        debugPrint('Error: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('--- [Cloudinary] Exception ---');
      debugPrint('Error: $e');
      return null;
    }
  }
}
