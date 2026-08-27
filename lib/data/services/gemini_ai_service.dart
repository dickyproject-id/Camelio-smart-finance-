import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../core/constants/api_keys.dart';
import 'csv_logger_service.dart';

class GeminiAIService {
  // Fokus 100% pada Gemini 1.5 Flash (Tercepat & Kuota Terbesar)
  // Menggunakan gemini-1.5-flash-latest (alias dari gemini-flash-latest) sesuai permintaan user
  GenerativeModel get _model => GenerativeModel(
    model: 'gemini-1.5-flash-latest',
    apiKey: ApiKeys.geminiApiKey,
  );

  GenerativeModel get _jsonModel => GenerativeModel(
    model: 'gemini-1.5-flash-latest',
    apiKey: ApiKeys.geminiApiKey,
    generationConfig: GenerationConfig(responseMimeType: 'application/json'),
  );

  /// 1. Klasifikasi dari Teks (Untuk Chat AI & Suara)
  Future<String> classifyTransaction(
    String userInput, {
    String language = 'id',
  }) async {
    try {
      final prompt =
          """
      Ekstrak data transaksi dari teks ini: "$userInput"
      Format JSON:
      {
        "description": "Nama kegiatannya tanpa nominal di dalamnya",
        "amount": 10000,
        "category": "Makanan",
        "type": "expense" 
      }
      PENTING UNTUK TYPE: Tentukan "type" dengan "income" jika transaksi adalah pemasukan (contoh: gaji masuk, transfer masuk, top up ke dompet, bonus, dikasih uang). Gunakan "expense" jika transaksi adalah pengeluaran (belanja, bayar tagihan, beli makanan).
      PENTING UNTUK NOMINAL: "amount" WAJIB berupa ANGKA bulat (integer) tanpa titik, koma, atau 'Rp'.
      Jika user menulis nominal "12k", "12 ribu", "12rb", jumlahnya adalah 12000. Jika menulis "Rp 12000" atau "Rp12.000", jumlahnya 12000.
      Jika menulis desimal seperti "1.5jt", "1.5 jt", atau "1,5 juta", jumlahnya adalah 1500000. Jika menulis "rp 6.500" atau "Rp. 6,500", jumlahnya adalah 6500.
      PENTING MULTI-ITEM/MULTIPLE TRANSACTIONS: Jika terdapat beberapa nominal di dalam teks (misalnya: "tiket ke bali 500k, tiket pesawat 1jt, dan sewa hotel 800k"), jumlahkan seluruh nominal tersebut untuk menghasilkan nilai "amount" tunggal (dalam contoh ini: 500000 + 1000000 + 800000 = 2300000). Sesuaikan "category" dengan kategori utama yang paling mendominasi (contoh: "Liburan").
      PENTING: Gunakan bahasa ${language == 'en' ? 'English' : 'Indonesia'} untuk "category" dan "description".

      Kategori yang tersedia: Makanan, Minuman, Belanja, Transportasi, Hiburan, Tagihan, Langganan, Transfer, Elektronik, Kesehatan, Pendidikan, Kebutuhan Rumah, Perlengkapan Rumah, Perawatan Rumah, Kendaraan, Olahraga, Liburan, Pakaian & Aksesoris, Investasi, Top Up, Gaji, Bonus, Pinjaman, Lainnya.
      ATURAN KATEGORI:
      - Minuman: Gunakan untuk semua minuman (misal kopi, teh, susu, air putih, air mineral, air, jus, es, bir, soda, boba, teh pucuk, yakult, sirup, dll).
      - Makanan: Gunakan untuk makanan berat/snack (misal nasi, roti, gandum, kue, keripik, kripik, lauk, biskuit, bakso, mie, sate, cemilan, gorengan, donat, pizza, burger, ayam, sayur, dll).
      - Perlengkapan Rumah: Untuk perabot/alat rumah tangga besar/perlengkapan permanen (misal kasur, lemari, meja, kursi, lampu, ac, kulkas, mesin cuci, kipas angin, blender, kompor, rice cooker, sofa, tv, gorden, sprei, bantal).
      - Perawatan Rumah: Untuk renovasi, perbaikan, atau pemeliharaan fisik rumah (misal renovasi, semen, cat tembok, genteng, pipa, keran, paku, palu, bor, ledeng, sedot wc, servis ac, perbaikan rumah, tukang, pasang wifi, kunci, gembok).
      - Kebutuhan Rumah: Untuk barang habis pakai rumah tangga sehari-hari (misal sabun, sampo, pasta gigi, odol, deterjen, pewangi, tisu, minyak goreng, beras, gula, garam, bumbu, kecap, saus, popok, pampers, pembersih lantai, lpg).
      - Kendaraan: Untuk servis/biaya kendaraan (misal servis motor/mobil, ganti oli, ban motor, helm, bensin, pertamax, pertalite, solar, shell, parkir, cuci motor/mobil, knalpot, aki).
      - Olahraga: Untuk kebugaran/alat olahraga (gym, fitness, sewa lapangan, futsal, badminton, raket, bola, sepatu olahraga, jersey, sepeda, kacamata renang, running, lari).
      - Liburan: Untuk perjalanan rekreasi/wisata/staycation (hotel, villa, staycation, tiket pesawat/kereta, travel, pantai, wisata, paspor, koper, sewa mobil/motor, tiket masuk wahana, camping, dufan).
      - Pakaian & Aksesoris: Untuk pakaian/fashion (baju, kaos, celana, kemeja, jaket, sepatu, sandal, kaos kaki, topi, tas, dompet, jam tangan, kacamata, kalung, cincin, ikat pinggang, sabuk, gaun, rok).
      - Hiburan: Untuk bioskop, nonton film, karaoke, game, konser, topup game, steam, playstation, ps5.
      - Tagihan vs Langganan: Tagihan untuk utilitas (Listrik, Air, PDAM, Pulsa, Internet/Paket Data, BPJS). Langganan untuk layanan berbayar periodik/digital (Netflix, Spotify, Cloud, Gym Bulanan, YouTube Premium).
      - Elektronik vs Belanja: Gunakan Elektronik untuk Gadget, Laptop, HP, Aksesoris PC. Belanja untuk barang fisik umum lainnya.
      - Top Up: Untuk pengisian saldo e-wallet atau marketplace.
      """;

      final response = await _jsonModel
          .generateContent([Content.text(prompt)])
          .timeout(const Duration(seconds: 20));

      return response.text ?? '{}';
    } catch (e) {
      debugPrint('GEMINI_LOG Error: $e');
      return '{}';
    }
  }

  /// 2. Klasifikasi Langsung dari Gambar Struk
  Future<String> classifyReceiptFromImage(
    Uint8List imageBytes,
    String mimeType, {
    String language = 'id',
  }) async {
    int retryCount = 0;
    const int maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        final prompt =
            """
        Ekstrak data dari struk belanja ini menjadi format JSON:
        {
          "storeName": "Nama Toko",
          "category": "Belanja", 
          "type": "expense",
          "items": [
            { 
              "name": "Nama Barang", 
              "price_unit": 10000, 
              "qty": 2,
              "line_total": 20000
            }
          ]
        }
        Wajib JSON murni. Pastikan "line_total" adalah hasil qty dikali price_unit.
        PENTING: Tentukan "type" dengan "income" jika ini adalah bukti struk pemasukan (seperti slip setoran tunai bank, gaji, nota pembayaran dari pelanggan, top up masuk). Gunakan "expense" jika ini adalah struk belanja/pengeluaran biasa.
        PENTING: Gunakan bahasa ${language == 'en' ? 'English' : 'Indonesia'} untuk "category" dan "name" barang.
        Kategori yang tersedia: Makanan, Minuman, Belanja, Transportasi, Hiburan, Tagihan, Langganan, Transfer, Elektronik, Kesehatan, Pendidikan, Kebutuhan Rumah, Investasi, Top Up, Gaji, Bonus, Pinjaman, Lainnya.
        ATURAN KATEGORI:
        1. Jika struk dari restoran/warung makan, gunakan Makanan. Namun jika item dominan adalah minuman (Coffee Shop), gunakan Minuman.
        2. Jika struk dari toko gadget/komputer, gunakan Elektronik.
        3. Jika struk dari apotek/rumah sakit, gunakan Kesehatan.
        4. Jika struk dari supermarket (Indomaret/Alfamart), bedakan item: makanan berat (Makanan), minuman (Minuman), alat rumah tangga (Kebutuhan Rumah), sisanya (Belanja).
        5. Gunakan Tagihan untuk Listrik/Air/Pulsa/Internet. Gunakan Langganan untuk layanan digital hiburan.
        Jika ada diskon/potongan harga pada struk, masukkan sebagai salah satu item dengan "name" mengandung kata "Diskon" atau "Potongan", "qty": 1, dan "price_unit" serta "line_total" WAJIB bernilai negatif (contoh: -5000).
        """;

        final imagePart = DataPart(mimeType, imageBytes);
        final response = await _jsonModel
            .generateContent([
              Content.multi([TextPart(prompt), imagePart]),
            ])
            .timeout(const Duration(seconds: 30));

        final resultText = response.text ?? '{}';

        // Hitung total dari JSON untuk di-log ke CSV (Sistem Prediksi)
        try {
          final Map<String, dynamic> data = jsonDecode(resultText);
          double predictedTotal = 0;
          if (data['items'] != null) {
            for (var item in data['items']) {
              predictedTotal += (item['line_total'] ?? 0).toDouble();
            }
          }
          // Log ke background CSV
          CsvLoggerService.logReceiptScan(
            systemTotal: 'Rp ${predictedTotal.toInt()}',
            rawJson: resultText,
          );
        } catch (e) {
          debugPrint('Gagal log CSV: $e');
        }

        return resultText;
      } catch (e) {
        if (e.toString().contains('503') ||
            e.toString().contains('UNAVAILABLE')) {
          retryCount++;
          debugPrint(
            'GEMINI_LOG: 503 Error. Percobaan ulang $retryCount dari $maxRetries...',
          );
          if (retryCount >= maxRetries) {
            throw Exception(
              'Server AI sedang penuh (503). Sistem telah mencoba 3 kali namun gagal. Silakan coba beberapa saat lagi.',
            );
          }
          // Exponential backoff: tunggu 2 detik, lalu 4 detik, dst.
          await Future.delayed(Duration(seconds: retryCount * 2));
        } else {
          debugPrint('GEMINI_LOG: Error di Receipt: $e');
          throw Exception(
            'AI sedang sibuk atau terjadi kesalahan jaringan. Silakan coba lagi dalam 1 menit.',
          );
        }
      }
    }
    return '{}';
  }

  /// 3. Nasehat Keuangan
  Future<String?> getFinancialAdvice(String prompt) async {
    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text;
    } catch (e) {
      debugPrint('GEMINI_LOG Advice Error: $e');
      return null;
    }
  }

  /// 4. Portofolio Insight (Digunakan di Dashboard)
  Future<String> getPortfolioInsight({
    required String range,
    required double income,
    required double expense,
    required List<String> topCategories,
    String language = 'id',
  }) async {
    try {
      final prompt =
          """
      Analisis data keuangan: Pemasukan Rp $income, Pengeluaran Rp $expense.
      Kategori terboros: ${topCategories.join(', ')}.
      Berikan 2 kalimat saran singkat dalam bahasa ${language == 'en' ? 'English' : 'Indonesia'}.
      """;
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ??
          (language == 'en'
              ? 'Keep up the good work managing your finances!'
              : 'Tetap semangat mengelola keuangan!');
    } catch (e) {
      return language == 'en'
          ? 'AI is taking a break. Keep saving!'
          : 'AI sedang beristirahat. Tetap hemat ya!';
    }
  }

  /// 5. Generic Text Generation
  Future<String> generateContent(String prompt) async {
    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? '';
    } catch (e) {
      debugPrint('GEMINI_LOG General Error: $e');
      return '';
    }
  }
}
