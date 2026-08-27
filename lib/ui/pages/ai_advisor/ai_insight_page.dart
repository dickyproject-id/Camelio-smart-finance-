import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_finance_app/core/constants/app_colors.dart';
import 'package:smart_finance_app/core/locator.dart';
import 'package:smart_finance_app/data/services/gemini_ai_service.dart';
import 'dart:io';
import 'package:smart_finance_app/providers/transaction_provider.dart';
import 'package:smart_finance_app/providers/auth_provider.dart';
import 'package:smart_finance_app/providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class AiInsightPage extends StatefulWidget {
  const AiInsightPage({super.key});

  @override
  State<AiInsightPage> createState() => _AiInsightPageState();
}

class _AiInsightPageState extends State<AiInsightPage> {
  final _geminiService = locator<GeminiAIService>();
  bool _isLoading = true;
  String _aiResponse = "";

  @override
  void initState() {
    super.initState();
    // Jalankan fungsi analisis AI saat halaman pertama kali dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateInsight();
    });
  }

  Future<void> _generateInsight({bool forceRefresh = false}) async {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    try {
      final txProvider = Provider.of<TransactionProvider>(
        context,
        listen: false,
      );
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final namaUser =
          auth.userProfile?['name'] ??
          auth.user?.displayName ??
          settings.translate('Pengguna', 'User');

      // Gunakan seluruh transaksi BULAN INI agar AI bisa menganalisis semua data operasional UMKM/Pribadi
      final now = DateTime.now();
      final currentMonthTransactions = txProvider.transactions.where((tx) {
        return tx.date.month == now.month && tx.date.year == now.year;
      }).toList();

      // --- LOGIKA CACHING: Hemat Kuota & Loading Instan ---
      final prefs = await SharedPreferences.getInstance();
      final userId = auth.user?.uid ?? 'guest';
      final cacheKey = 'ai_insight_$userId';
      final cacheCountKey = 'ai_insight_count_$userId';

      if (!forceRefresh) {
        final cachedInsight = prefs.getString(cacheKey);
        final cachedCount = prefs.getInt(cacheCountKey);

        // Jika jumlah transaksi bulan ini tidak berubah, tampilkan dari Cache saja!
        if (cachedInsight != null &&
            cachedCount == currentMonthTransactions.length) {
          if (mounted) {
            setState(() {
              _aiResponse = cachedInsight;
              _isLoading = false;
            });
          }
          return; // Skip panggil API Gemini! Loading jadi instan 0 detik!
        }
      }
      // ----------------------------------------------------

      if (currentMonthTransactions.isEmpty) {
        if (mounted) {
          setState(() {
            _aiResponse = settings.translate(
              "Halo $namaUser! Belum ada catatan transaksi di bulan ini. Yuk, catat agar AI bisa memberikan analisis akurat!",
              "Hello $namaUser! No transactions this month yet. Start recording so AI can analyze!",
            );
            _isLoading = false;
          });
        }
        return;
      }

      // 1. Format SEMUA data transaksi bulan ini menjadi list teks sederhana untuk AI
      String txData = "";
      for (var tx in currentMonthTransactions) {
        String tipe = tx.type == 'expense'
            ? settings.translate('Keluar', 'Expense')
            : settings.translate('Masuk', 'Income');
        txData +=
            "- Tanggal ${tx.date.day}/${tx.date.month}: [${tx.category}] ${tx.description} ($tipe Rp${tx.amount.toInt()})\n";
      }

      final double totalExpense = currentMonthTransactions
          .where((t) => t.type == 'expense')
          .fold(0, (sum, item) => sum + item.amount);

      final double totalIncome = currentMonthTransactions
          .where((t) => t.type == 'income')
          .fold(0, (sum, item) => sum + item.amount);

      final double budget = (auth.userProfile?['monthlyBudget'] ?? 0)
          .toDouble();
      final double remaining = budget - totalExpense;
      final String accountType = auth.userProfile?['accountType'] ?? 'Personal';

      final String contextPromptEn = accountType == 'Business'
          ? "CRITICAL RULE: The user has explicitly set their account type to BUSINESS. You MUST provide advice, cost-saving tips, and operational analysis tailored strictly for a business. Do NOT treat this as personal finance."
          : "CRITICAL RULE: The user has explicitly set their account type to PERSONAL. This is for personal or household finance. DO NOT assume this is a business, even if they buy groceries in bulk or wholesale quantities. Treat bulk purchases as household stocking, not business inventory.";

      final String contextPromptId = accountType == 'Business'
          ? "ATURAN KRITIS: Pengguna telah menyetel tipe akunnya sebagai BISNIS. Anda WAJIB memberikan saran, tips hemat, dan analisis operasional yang dikhususkan untuk bisnis. JANGAN memberikan nasihat keuangan pribadi."
          : "ATURAN KRITIS: Pengguna menyetel tipe akunnya sebagai PRIBADI. Ini adalah keuangan pribadi atau rumah tangga. JANGAN berasumsi ini adalah sebuah bisnis meskipun mereka membeli bahan makanan dalam jumlah grosir atau kartonan. Anggap pembelian grosir sebagai stok bulanan rumah tangga, bukan stok barang dagangan.";

      // 2. Prompt Engineering: Instruksi khusus untuk Gemini
      final prompt = settings.languageCode == 'en'
          ? """
      Act as a smart, friendly, and helpful financial advisor and AI purchase recommendation system using the RAD method and DSR approach.
      The user or business owner's name is $namaUser.
      
      $contextPromptEn
      
      Here is the recent transaction data:
      $txData

      This Month's Budget & Cashflow Status:
      - Total Income: Rp${totalIncome.toInt()}
      - Target Budget: Rp${budget.toInt()}
      - Total Expense: Rp${totalExpense.toInt()}
      - Remaining Budget: Rp${remaining.toInt()}

      Provide a response ONLY in the following format:
      
      Quick Analysis:
      (1 paragraph analysis of the spending habits compared to the budget target. Explicitly state insights relevant to their declared account type).

      Purchase Recommendations & Savings Tips:
      - (Recommendation 1: tailored to either personal savings OR business operational cost efficiency)
      - (Recommendation 2: tailored to either personal shopping OR business inventory/raw materials)
      - (Recommendation 3: relevant financial tips based on the transaction types)
      - (Recommendation 4: specific purchase advice to maintain healthy cash flow)
      - (Recommendation 5: actionable solutions for the user's daily life or business needs)
      """
          : """
      Bertindaklah sebagai penasihat keuangan dan sistem rekomendasi pembelian AI yang pintar, ramah, dan solutif menggunakan metode RAD dan pendekatan DSR.
      Nama pengguna atau pemilik bisnis adalah $namaUser.
      
      $contextPromptId
      Berikut adalah data transaksi terbarunya:
      $txData

      Status Arus Kas & Anggaran Bulan Ini:
      - Total Pemasukan: Rp${totalIncome.toInt()}
      - Target Budget: Rp${budget.toInt()}
      - Total Pengeluaran: Rp${totalExpense.toInt()}
      - Sisa Anggaran: Rp${remaining.toInt()}

      Berikan tanggapan HANYA dengan format berikut (tanpa markdown tebal/bintang yang berlebihan):
      
      Analisis Singkat:
      (1 paragraf analisis tentang kebiasaan pengeluaran dibandingkan dengan target budgetnya. Sesuaikan gaya bahasanya sesuai dengan Tipe Akun yang telah ditetapkan pengguna).

      Rekomendasi Pembelian & Tips Hemat:
      - (Rekomendasi 1: disesuaikan untuk penghematan pribadi ATAU efisiensi biaya operasional bisnis seperti supplier/sewa)
      - (Rekomendasi 2: disesuaikan untuk strategi belanja pribadi ATAU pembelian stok barang/bahan baku bisnis)
      - (Rekomendasi 3: tips keuangan yang relevan dengan tipe data transaksi yang masuk)
      - (Rekomendasi 4: saran pembelian spesifik untuk menjaga arus kas tetap sehat)
      - (Rekomendasi 5: solusi praktis dan hemat untuk kebutuhan sehari-hari personal atau operasional UMKM)
      """;

      // 3. Panggil fungsi yang sudah kita buat di gemini_ai_service.dart
      final response = await _geminiService.getFinancialAdvice(prompt);

      // --- SIMPAN KE CACHE JIKA SUKSES ---
      if (response != null) {
        await prefs.setString(cacheKey, response);
        await prefs.setInt(cacheCountKey, currentMonthTransactions.length);
      }

      if (mounted) {
        setState(() {
          _aiResponse =
              response ??
              settings.translate(
                "Maaf, AI sedang mengalami gangguan koneksi. Coba lagi nanti ya!",
                "Sorry, AI is experiencing connection issues. Please try again later!",
              );
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _aiResponse = settings.translate(
            "Terjadi kesalahan sistem saat memproses AI. Pastikan internet stabil.",
            "A system error occurred while processing AI. Make sure your internet is stable.",
          );
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: GestureDetector(
          onLongPress: () async {
            try {
              final txProvider = Provider.of<TransactionProvider>(
                context,
                listen: false,
              );
              final receiptTx = txProvider.transactions;

              if (receiptTx.isEmpty) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Belum ada data transaksi di database.'),
                    ),
                  );
                }
                return;
              }

              final directory = await getApplicationDocumentsDirectory();
              final file = File('${directory.path}/receipt_accuracy_log.csv');

              StringBuffer csvData = StringBuffer();
              csvData.writeln(
                'No.,ID Struk,Jenis Struk,Harga Asli (Ground Truth),Harga Terbaca oleh AI (Sistem),Status,Keterangan',
              );

              int no = 1;
              int row = 2; // Mulai dari baris ke-2 karena baris 1 adalah Header

              // Urutkan dari yang terlama (atas) ke terbaru (bawah)
              final sortedTx = receiptTx.toList()
                ..sort((a, b) => a.date.compareTo(b.date));

              for (var tx in sortedTx) {
                final String id = tx.id ?? '-';
                final String jenis = tx.category;
                final String finalAmount = tx.amount.toInt().toString();
                final String aiPredictedAmount =
                    (tx.aiPredictedAmount?.toInt() ?? tx.amount.toInt())
                        .toString();
                final String url = tx.imageUrl ?? '-';

                // Rumus Excel otomatis untuk kolom Status (Kolom F). Mengecek D (Ground Truth) vs E (Sistem).
                final String formulaStatus =
                    '"=IF(D$row=""-"",""-"",IF(D$row*1=E$row*1,""Benar (True Positive)"",""Salah (False Negative)""))"';

                // Kolom: No., ID, Jenis, Harga Asli(Final/GroundTruth), Harga AI(Original Prediction), Status(Formula), Keterangan
                csvData.writeln(
                  '${no++},$id,$jenis,$finalAmount,$aiPredictedAmount,$formulaStatus,URL Gambar: $url',
                );
                row++;
              }

              // Tambahkan Baris Kosong sebagai pemisah
              csvData.writeln(',,,,,,');
              csvData.writeln(',,,,,,');

              // Tambahkan Tabel Rekapitulasi Akurasi Otomatis di bagian bawah
              int lastRow = row - 1;
              csvData.writeln(
                ',,,,Total Struk Terverifikasi,"=COUNT(D2:D$lastRow)"',
              );
              csvData.writeln(
                ',,,,Total Benar (TP),"=COUNTIF(F2:F$lastRow, ""Benar (True Positive)"")"',
              );
              csvData.writeln(
                ',,,,Total Salah (FN),"=COUNTIF(F2:F$lastRow, ""Salah (False Negative)"")"',
              );
              csvData.writeln(
                ',,,,AKURASI AI (%) ,"=IF(COUNT(D2:D$lastRow)=0, ""0%"", ROUND((COUNTIF(F2:F$lastRow, ""Benar (True Positive)"")/COUNT(D2:D$lastRow))*100, 2) & ""%"")"',
              );
              csvData.writeln(
                ',,,,PERSENTASE GAGAL (%) ,"=IF(COUNT(D2:D$lastRow)=0, ""0%"", ROUND((COUNTIF(F2:F$lastRow, ""Salah (False Negative)"")/COUNT(D2:D$lastRow))*100, 2) & ""%"")"',
              );

              await file.writeAsString(csvData.toString());
              if (!mounted) return;

              // ignore: deprecated_member_use
              await Share.shareXFiles([
                XFile(file.path),
              ], text: 'Log Akurasi & Gambar Struk (CSV)');
            } catch (e) {
              debugPrint('Error generating CSV: $e');
            }
          },
          child: Text(
            settings.translate('Analisis AI', 'AI Insight'),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Ilustrasi AI - Selalu Muncul (Instant Feel)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B75FF), AppColors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.white, size: 48),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          settings.translate("Laporan Cerdas", "Smart Report"),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          settings.translate(
                            "Dianalisis secara real-time oleh teknologi AI",
                            "Analyzed in real-time by AI technology",
                          ),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Kotak Hasil Analisis AI
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _isLoading
                  ? Column(
                      children: [
                        const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          settings.translate(
                            "Menganalisis data...",
                            "Analyzing data...",
                          ),
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      _aiResponse,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
