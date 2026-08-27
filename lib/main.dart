import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/locator.dart';
import 'core/constants/api_keys.dart';
import 'data/services/notification_service.dart';
import 'firebase_options.dart';
import 'app.dart';

void main() async {
  try {
    // 1. Pastikan binding Flutter sudah siap
    WidgetsFlutterBinding.ensureInitialized();

    // 2. Setup Service Locator (GetIt)
    setupLocator();

    // 3. Load variabel lingkungan (.env)
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      debugPrint('Warning: .env file not found or failed to load: $e');
    }

    // 4. Inisialisasi Firebase
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      // Inisialisasi Remote Config (Tanpa await agar tidak menghambat splash)
      ApiKeys.initRemoteConfig();

      // Inisialisasi Notifikasi Sistem
      await NotificationService.init();
    } catch (e) {
      debugPrint('Firebase Initialization Error: $e');
    }

    // 5. Jalankan Aplikasi
    runApp(const SmartFinanceApp());
  } catch (e) {
    debugPrint('Critical Main Error: $e');
    // Fallback: Tetap coba jalankan app agar tidak blank screen total
    runApp(const SmartFinanceApp());
  }
}
