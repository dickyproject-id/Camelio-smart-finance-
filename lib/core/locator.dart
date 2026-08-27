import 'package:get_it/get_it.dart';
import '../data/services/auth_service.dart';
import '../data/services/firestore_service.dart';
import '../data/services/gemini_ai_service.dart';
import '../data/services/cloudinary_service.dart';
import '../data/services/gmail_service.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  // Database & Auth
  locator.registerLazySingleton<AuthService>(() => AuthService());
  locator.registerLazySingleton<FirestoreService>(() => FirestoreService());

  // Media Storage (Cloudinary)
  locator.registerLazySingleton<CloudinaryService>(() => CloudinaryService());

  // AI Parsers
  locator.registerLazySingleton<GeminiAIService>(() => GeminiAIService());

  // Gmail API Sync
  locator.registerLazySingleton<GmailService>(() => GmailService());
}
