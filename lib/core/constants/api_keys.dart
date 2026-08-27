import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class ApiKeys {
  static String _remoteGeminiKey = '';

  // Inisialisasi Remote Config (Panggil di main.dart)
  static Future<void> initRemoteConfig() async {
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;

      // 1. Set Nilai Default (Sangat Penting agar koneksi sinkron)
      await remoteConfig.setDefaults({
        'gemini_api_key':
            '', // Biarkan kosong, akan diisi dari .env atau Firebase
      });

      // 2. Set strategi refresh (1 menit agar cepat saat sidang)
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 15),
          minimumFetchInterval: const Duration(minutes: 1),
        ),
      );

      // 3. Ambil data dari server Google
      debugPrint('REMOTE_CONFIG: Sedang mengambil data dari Firebase...');
      bool updated = await remoteConfig.fetchAndActivate();

      // 4. Update variabel lokal
      _remoteGeminiKey = remoteConfig.getString('gemini_api_key');
      debugPrint('REMOTE_CONFIG: Selesai! Status Update: $updated');
      debugPrint(
        'REMOTE_CONFIG: Key yang didapat: ${_remoteGeminiKey.substring(0, 10)}...',
      );
    } catch (e) {
      debugPrint('REMOTE_CONFIG_ERROR: Terjadi kesalahan saat fetch: $e');
    }
  }

  static int _currentKeyIndex = 0;

  static String get geminiApiKey {
    List<String> keys = [];

    // 1. Ambil dari Remote Config
    if (_remoteGeminiKey.isNotEmpty) {
      keys = _remoteGeminiKey.split(',').map((e) => e.trim()).toList();
    }

    // 2. Jika Remote Config kosong, ambil dari .env
    if (keys.isEmpty) {
      final envKey = dotenv.env['GEMINI_API_KEY'];
      if (envKey != null) {
        keys = envKey.split(',').map((e) => e.trim()).toList();
      }
    }

    // 3. Fallback terakhir jika semua kosong
    if (keys.isEmpty) {
      keys = [];
    }

    // Rotasi key (Pindah ke key berikutnya setiap kali dipanggil untuk bagi beban)
    _currentKeyIndex = (_currentKeyIndex + 1) % keys.length;
    final selectedKey = keys[_currentKeyIndex];

    if (selectedKey.length > 4) {
      debugPrint(
        'GEMINI_KEY_ROTATION: Menggunakan key #${_currentKeyIndex + 1} (...${selectedKey.substring(selectedKey.length - 4)})',
      );
    }

    return selectedKey;
  }
}
