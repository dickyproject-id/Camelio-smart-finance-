import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../core/locator.dart';
import '../data/models/e_wallet_model.dart';
import '../data/models/transaction_model.dart';
import '../data/services/firestore_service.dart';
import '../data/services/gmail_service.dart';
import '../data/services/gemini_ai_service.dart';
import '../data/services/notification_service.dart';

class EWalletProvider with ChangeNotifier {
  final FirestoreService _firestoreService = locator<FirestoreService>();
  final GmailService _gmailService = locator<GmailService>();
  final GeminiAIService _geminiService = locator<GeminiAIService>();

  List<EWalletModel> _wallets = [];
  bool _isLoading = false;
  bool _isSyncing = false;

  StreamSubscription<List<EWalletModel>>? _subscription;

  List<EWalletModel> get wallets => _wallets;
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;

  double get totalBalance {
    return _wallets.fold(0, (sum, wallet) => sum + wallet.balance);
  }

  void loadWallets(String userId) {
    _isLoading = true;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _firestoreService
        .getEWalletsStream(userId)
        .listen(
          (data) {
            _wallets = data;
            _isLoading = false;
            notifyListeners();
          },
          onError: (error) {
            debugPrint('Error loading wallets: $error');
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  Future<String> saveWallet(EWalletModel wallet) async {
    // Cek Duplikat berdasarkan Nama (Case Insensitive)
    final isDuplicate = _wallets.any(
      (w) => w.name.toLowerCase() == wallet.name.toLowerCase(),
    );
    if (isDuplicate) {
      throw Exception('Dompet dengan nama "${wallet.name}" sudah ada.');
    }
    try {
      _isLoading = true;
      notifyListeners();
      // Tambahkan Icon URL jika sesuai dengan brand tertentu
      final walletWithIcon = wallet.copyWith(
        iconUrl: wallet.iconUrl ?? _getIconUrlForWallet(wallet.name),
      );
      final id = await _firestoreService.saveEWallet(walletWithIcon);
      _isLoading = false;
      notifyListeners();
      return id;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  String? _getIconUrlForWallet(String name) {
    final n = name.toLowerCase();

    // Perbankan
    if (n.contains('ocbc')) return 'assets/ocbc.png';
    if (n.contains('bca')) return 'assets/bca.png';
    if (n.contains('mandiri')) return 'assets/mandiri.png';
    if (n.contains('bri')) return 'assets/bri.png';
    if (n.contains('bni')) return 'assets/bni.png';

    // E-Wallet
    if (n.contains('gopay')) return 'assets/gopay.jpg';
    if (n.contains('ovo')) return 'assets/ovo.png';
    if (n.contains('dana')) return 'assets/dana.jpeg';
    if (n.contains('shopeepay')) return 'assets/shopeepay.png';
    if (n.contains('linkaja')) return 'assets/linkaja.png';

    // Marketplace
    if (n.contains('shopee')) return 'assets/shopee.png';
    if (n.contains('tokopedia') || n.contains('tokpedia'))
      return 'assets/tokopedia.png';
    if (n.contains('lazada')) return 'assets/lazada.png';
    if (n.contains('tiktokshop')) return 'assets/tiktokshop.png';
    if (n.contains('klikindomaret')) return 'assets/klikindomaret.png';

    // Investasi
    if (n.contains('stockbit')) return 'assets/stockbit.png';
    if (n.contains('bibit')) return 'assets/bibit.jpeg';
    if (n.contains('indodax')) return 'assets/indodax.png';
    if (n.contains('pluang')) return 'assets/pluang.png';
    if (n.contains('mifx')) return 'assets/mifx.png';

    // Pinjaman Online & Lainnya
    if (n.contains('akulaku')) return 'assets/akulaku.jpeg';
    if (n.contains('fifgroup')) return 'assets/fifgroup.png';
    if (n.contains('kredivo')) return 'assets/kredivo.png';
    if (n.contains('easycash')) return 'assets/easycash.png';
    if (n.contains('pegadaian')) return 'assets/pegadaian.png';
    if (n.contains('pintu')) return 'assets/pintu.png';
    if (n.contains('ajaib')) return 'assets/ajaib.png';
    if (n.contains('nanovest')) return 'assets/nanovest.png';
    if (n.contains('linkaja')) return 'assets/linkaja.png';
    if (n.contains('jenius')) return 'assets/jenius.png';
    if (n.contains('seabank')) return 'assets/seabank.png';
    if (n.contains('jago')) return 'assets/jago.png';
    if (n.contains('blu')) return 'assets/blu.png';
    if (n.contains('tmw')) return 'assets/tmw.png';
    if (n.contains('digibank')) return 'assets/digibank.png';
    if (n.contains('maybank')) return 'assets/maybank.png';
    if (n.contains('ocbc')) return 'assets/ocbc.png';
    if (n.contains('cimb')) return 'assets/cimb.png';
    if (n.contains('panin')) return 'assets/panin.png';
    if (n.contains('danamon')) return 'assets/danamon.png';
    if (n.contains('permata')) return 'assets/permata.png';
    if (n.contains('bukalapak')) return 'assets/bukalapak.png';
    if (n.contains('blibli')) return 'assets/blibli.png';
    if (n.contains('lazada')) return 'assets/lazada.png';
    if (n.contains('shopee')) return 'assets/shopee.png';

    return null;
  }

  Future<void> deleteWallet(String id, String userId) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _firestoreService.deleteEWallet(id, userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateWalletBalance(String walletId, double newBalance) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _firestoreService.updateEWalletBalance(walletId, newBalance);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateWalletAccountNumber(
    String walletId,
    String accountNumber,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _firestoreService.updateEWalletAccountNumber(
        walletId,
        accountNumber,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> syncWithGmail(String userId) async {
    if (_isSyncing) return; // Mencegah sinkronisasi ganda berjalan bersamaan
    _isSyncing = true;
    notifyListeners();

    try {
      final api = await _gmailService.getGmailApi();
      if (api == null)
        throw Exception(
          'Gagal akses Gmail API. Pastikan Anda telah memberikan izin.',
        );

      // Kirim email konfirmasi (pancingan) sesuai permintaan user
      try {
        await _gmailService.sendConfirmationEmail(api);
      } catch (e) {
        debugPrint('Gagal mengirim email konfirmasi: $e');
        // Lanjutkan sync meskipun gagal kirim email konfirmasi
      }

      // Ambil tanggal sinkronisasi terakhir (bisa dari profil user atau dompet terbaru)
      DateTime? lastSync;
      for (var w in _wallets) {
        if (lastSync == null ||
            (w.lastSyncDate != null && w.lastSyncDate!.isAfter(lastSync))) {
          lastSync = w.lastSyncDate;
        }
      }

      // Jika belum pernah sinkron, mulai dari 1 hari terakhir agar tidak overload
      lastSync ??= DateTime.now().subtract(const Duration(days: 1));

      final messages = await _gmailService.fetchTransactionEmails(
        api,
        afterDate: lastSync,
      );

      // Batasi maksimal 20 email per sinkronisasi untuk menjaga performa dan kuota
      final limitedMessages = messages.take(20).toList();

      for (var msg in limitedMessages) {
        // Tambahkan jeda 300ms agar tidak terkena Rate Limit Google dan menjaga stabilitas
        await Future.delayed(const Duration(milliseconds: 300));

        final emailData = await _gmailService.parseEmailContent(api, msg.id!);
        if (emailData != null) {
          final prompt =
              """
          Parse detail transaksi dari cuplikan email berikut:
          "${emailData['snippet']}"
          
          Berikan output HANYA dalam format JSON valid tanpa penjelasan tambahan:
          {
            "amount": 0.0,
            "category": "makanan/belanja/transportasi/tagihan/gaji/transfer",
            "description": "nama toko atau keterangan singkat",
            "type": "expense/income",
            "walletName": "BCA/GoPay/OVO/ShopeePay/DANA/Cash/dll"
          }
          """;

          try {
            final response = await _geminiService.generateContent(prompt);
            // Bersihkan markdown jika ada
            final cleanJson = response
                .replaceAll('```json', '')
                .replaceAll('```', '')
                .trim();
            final Map<String, dynamic> data = _parseGeminiResponse(cleanJson);

            // 1. Cari atau buat Wallet
            String? walletId;
            final walletName = data['walletName']?.toString() ?? 'Unknown';
            final existingWallet = _wallets
                .where((w) => w.name.toLowerCase() == walletName.toLowerCase())
                .toList();

            if (existingWallet.isNotEmpty) {
              walletId = existingWallet.first.id;
            } else {
              // Create temporary wallet automatically
              final newWallet = EWalletModel(
                userId: userId,
                name: walletName,
                type: 'e-wallet', // Default type
                balance: 0, // User must set initial balance later
                iconUrl: _getIconUrlForWallet(walletName),
                createdAt: DateTime.now(),
              );
              await _firestoreService.saveEWallet(newWallet);
            }

            // 2. Simpan Transaksi
            if (walletId != null) {
              final transaction = TransactionModel(
                userId: userId,
                walletId: walletId,
                amount: (data['amount'] ?? 0).toDouble(),
                category: data['category'] ?? 'lainnya',
                description: data['description'] ?? 'Transaksi Gmail',
                date: emailData['date'] ?? DateTime.now(),
                type: data['type'] ?? 'expense',
                source: 'gmail',
              );
              await _firestoreService.addTransaction(transaction);
            }
          } catch (e) {
            debugPrint('Error processing email ${msg.id}: $e');
          }
        }
      }

      _isSyncing = false;
      notifyListeners();

      // Kirim Notifikasi Sistem
      await NotificationService.showNotification(
        title: 'Sinkronisasi Berhasil ✨',
        body: 'Data transaksi Gmail telah diperbarui secara otomatis.',
      );
    } catch (e) {
      _isSyncing = false;
      notifyListeners();
      rethrow;
    }
  }

  Map<String, dynamic> _parseGeminiResponse(String response) {
    try {
      return jsonDecode(response) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('JSON Decode Error: $e. Falling back to regex.');
      // Regex fallback
      final amountMatch = RegExp(r'"amount":\s*([\d\.]+)').firstMatch(response);
      final categoryMatch = RegExp(
        r'"category":\s*"([^"]+)"',
      ).firstMatch(response);
      final descMatch = RegExp(
        r'"description":\s*"([^"]+)"',
      ).firstMatch(response);
      final typeMatch = RegExp(r'"type":\s*"([^"]+)"').firstMatch(response);
      final walletMatch = RegExp(
        r'"walletName":\s*"([^"]+)"',
      ).firstMatch(response);

      return {
        'amount': double.tryParse(amountMatch?.group(1) ?? '0') ?? 0.0,
        'category': categoryMatch?.group(1) ?? 'lainnya',
        'description': descMatch?.group(1) ?? 'Transaksi Gmail',
        'type': typeMatch?.group(1) ?? 'expense',
        'walletName': walletMatch?.group(1) ?? 'Unknown',
      };
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
