import 'dart:async'; // Tambahan wajib untuk StreamSubscription
import 'package:flutter/material.dart';
import '../core/locator.dart';
import '../data/models/transaction_model.dart';
import '../data/services/firestore_service.dart';

class TransactionProvider with ChangeNotifier {
  final FirestoreService _firestoreService = locator<FirestoreService>();

  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  bool _isBalanceVisible = true;

  // Penjaga Stream agar tidak bocor di memory
  StreamSubscription<List<TransactionModel>>? _subscription;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  bool get isBalanceVisible => _isBalanceVisible;

  void toggleBalanceVisibility() {
    _isBalanceVisible = !_isBalanceVisible;
    notifyListeners();
  }

  // Logika Saldo: Total Pemasukan - Total Pengeluaran
  double get totalBalance {
    double total = 0;
    for (var item in _transactions) {
      if (item.type == 'income') {
        total += item.amount;
      } else {
        total -= item.amount;
      }
    }
    return total;
  }

  // Getter khusus untuk total pengeluaran saja (buat statistik)
  double get totalExpense {
    return _transactions
        .where((t) => t.type == 'expense')
        .fold(0, (sum, item) => sum + item.amount);
  }

  // Getter khusus untuk total pemasukan saja (buat statistik)
  double get totalIncome {
    return _transactions
        .where((t) => t.type == 'income')
        .fold(0, (sum, item) => sum + item.amount);
  }

  /// Memantau data transaksi secara real-time dari Firestore
  void loadTransactions(String userId) {
    _isLoading = true;
    notifyListeners();

    _subscription?.cancel(); // Batalkan antrean stream lama jika ada

    // Pastikan nama fungsi di FirestoreService adalah getTransactionsStream
    _subscription = _firestoreService
        .getTransactionsStream(userId)
        .listen(
          (data) {
            // FIX: Urutkan data secara lokal (dari yang terbaru ke terlama)
            data.sort((a, b) => b.date.compareTo(a.date));

            _transactions = data;
            _isLoading = false;
            notifyListeners(); // PENTING: Ini yang bikin UI langsung berubah otomatis
          },
          onError: (e) {
            _isLoading = false;
            debugPrint('Error loading transactions: $e');
            notifyListeners();
          },
        );
  }

  /// Menambah transaksi baru
  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      await _firestoreService.addTransaction(transaction);

      // Kirim notifikasi real-time ke database agar muncul di halaman notifikasi
      await _firestoreService.addNotification({
        'userId': transaction.userId,
        'title': transaction.type == 'income'
            ? 'Pemasukan Baru! 💰'
            : 'Pengeluaran Baru! 💸',
        'message':
            'Berhasil mencatat "${transaction.description}" sebesar Rp ${transaction.amount.toInt()}',
        'type': 'transaction',
        'isRead': false,
      });
    } catch (e) {
      debugPrint('Gagal menyimpan transaksi: $e');
      rethrow;
    }
  }

  /// Menghapus transaksi
  Future<void> deleteTransaction(TransactionModel transaction) async {
    try {
      if (transaction.id == null) return;
      await _firestoreService.deleteTransaction(
        transaction.id!,
        walletId: transaction.walletId,
        amount: transaction.amount,
        type: transaction.type,
      );
    } catch (e) {
      debugPrint('Gagal menghapus transaksi: $e');
      rethrow;
    }
  }

  void clearTransactions() {
    _transactions = [];
    _subscription?.cancel();
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel(); // Hapus stream saat provider dimatikan
    super.dispose();
  }
}
