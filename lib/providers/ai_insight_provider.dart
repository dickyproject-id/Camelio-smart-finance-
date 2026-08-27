import 'package:flutter/material.dart';
import '../core/locator.dart';
import '../data/services/gemini_ai_service.dart';

class AIInsightProvider with ChangeNotifier {
  final GeminiAIService _geminiService = locator<GeminiAIService>();

  bool _isLoading = false;
  String _insightMessage = '';

  bool get isLoading => _isLoading;
  String get insightMessage => _insightMessage;

  /// Meminta saran keuangan (financial advice) dari model Gemini
  Future<void> askForFinancialInsight(
    String totalBalance,
    String monthlyBudget,
  ) async {
    _isLoading = true;
    _insightMessage = '';
    notifyListeners();

    try {
      final String prompt =
          '''
Saya memiliki total pengeluaran sebesar $totalBalance dan target bulanan saya maksimal adalah $monthlyBudget.
Berdasarkan kondisi tersebut, berikan saran finansial singkat (maksimal 3 paragraf) dengan nada yang santai, memotivasi, dan berkelas seperti asisten pribadi keuangan modern.
Gunakan format paragraf biasa tanpa markdown berlebihan.
''';

      final String? response = await _geminiService.getFinancialAdvice(prompt);

      _insightMessage =
          response ?? 'Maaf, asisten AI sedang beristirahat. Coba lagi nanti.';
    } catch (e) {
      _insightMessage = 'Gagal menghubungi server asisten AI: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearConversation() {
    _insightMessage = '';
    notifyListeners();
  }
}
