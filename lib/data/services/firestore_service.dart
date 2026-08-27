import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/transaction_model.dart';
import '../models/e_wallet_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Nama koleksi utama di database Firestore
  final String _collectionPath = 'transactions';
  final String _walletCollection = 'wallets';

  /// --- FITUR BARU: Membuat Profil User di Firestore ---
  Future<void> createUserProfile(
    String uid,
    String name,
    String email, {
    String? primaryGmail,
    String? whatsapp,
    String accountType = 'Personal',
  }) async {
    try {
      final docRef = _db.collection('users').doc(uid);
      final docSnap = await docRef.get();

      if (!docSnap.exists) {
        // Jika belum ada, buat baru dengan saldo 0
        await docRef.set({
          'name': name,
          'email': email,
          'primaryGmail': primaryGmail,
          'whatsapp': whatsapp ?? '',
          'accountType': accountType,
          'createdAt': FieldValue.serverTimestamp(),
          'balance': 0,
          'monthlyBudget': 0, // Tambah field budget
          'gender': '-',
          'birthDate': null,
          'gmailSyncActive': false,
          'gmailLastSyncDate': null,
        });
      } else {
        // Jika sudah ada (login ulang), cukup update nama/email tanpa mereset saldo
        final updateData = {
          'name': name,
          'email': email,
          'updatedAt': FieldValue.serverTimestamp(),
        };
        if (primaryGmail != null) {
          updateData['primaryGmail'] = primaryGmail;
        }
        if (whatsapp != null) {
          updateData['whatsapp'] = whatsapp;
        }
        await docRef.set(updateData, SetOptions(merge: true));
      }
    } catch (e) {
      throw Exception('Gagal membuat/update profil user di Firestore: $e');
    }
  }

  /// Mengambil data profil user
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      return doc.data();
    } catch (e) {
      throw Exception('Gagal mengambil profil user: $e');
    }
  }

  /// Update data profil user
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      await _db.collection('users').doc(uid).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Gagal memperbarui profil user: $e');
    }
  }

  /// --- E-WALLET OPERATIONS ---

  /// Menambah atau mengupdate e-wallet
  Future<String> saveEWallet(EWalletModel wallet) async {
    try {
      final collectionRef = _db.collection(_walletCollection);
      if (wallet.id != null && wallet.id!.isNotEmpty) {
        await collectionRef.doc(wallet.id).update(wallet.toMap());
        return wallet.id!;
      } else {
        final docRef = await collectionRef.add(wallet.toMap());
        return docRef.id;
      }
    } catch (e) {
      throw Exception('Gagal menyimpan e-wallet: $e');
    }
  }

  /// Mengambil data e-wallet secara real-time
  Stream<List<EWalletModel>> getEWalletsStream(String userId) {
    return _db
        .collection(_walletCollection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => EWalletModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  /// Menghapus e-wallet beserta seluruh transaksi di dalamnya
  Future<void> deleteEWallet(String id, String userId) async {
    try {
      final batch = _db.batch();

      // 1. Hapus dokumen dompet
      batch.delete(_db.collection(_walletCollection).doc(id));

      // 2. Cari semua transaksi yang menggunakan walletId ini DAN milik user ini
      final transactionsQuery = await _db
          .collection(_collectionPath)
          .where('userId', isEqualTo: userId)
          .where('walletId', isEqualTo: id)
          .get();

      // 3. Masukkan semua penghapusan transaksi ke dalam batch
      for (var doc in transactionsQuery.docs) {
        batch.delete(doc.reference);
      }

      // 4. Eksekusi batch (Atomic)
      await batch.commit();
    } catch (e) {
      debugPrint('FIRESTORE_DELETE_WALLET_ERROR: $e');
      throw Exception('Gagal menghapus e-wallet dan riwayat transaksinya: $e');
    }
  }

  /// Update saldo e-wallet secara manual
  Future<void> updateEWalletBalance(String id, double newBalance) async {
    try {
      await _db.collection(_walletCollection).doc(id).update({
        'balance': newBalance,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Gagal memperbarui saldo e-wallet: $e');
    }
  }

  /// Update nomor akun e-wallet
  Future<void> updateEWalletAccountNumber(
    String id,
    String accountNumber,
  ) async {
    try {
      await _db.collection(_walletCollection).doc(id).update({
        'accountNumber': accountNumber,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Gagal memperbarui nomor akun e-wallet: $e');
    }
  }

  /// 1. Menambah atau Mengupdate Transaksi
  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      final collectionRef = _db.collection(_collectionPath);
      final walletRef = _db.collection(_walletCollection);

      // Gunakan transaction batch untuk konsistensi saldo
      final batch = _db.batch();

      DocumentReference transDoc;
      if (transaction.id != null && transaction.id!.isNotEmpty) {
        transDoc = collectionRef.doc(transaction.id);
        batch.set(transDoc, transaction.toMap(), SetOptions(merge: true));
      } else {
        transDoc = collectionRef.doc();
        batch.set(transDoc, transaction.toMap());
      }

      // Jika ada walletId, update saldo wallet tersebut
      if (transaction.walletId != null) {
        final walletDoc = walletRef.doc(transaction.walletId);
        final amountChange = transaction.type == 'income'
            ? transaction.amount
            : -transaction.amount;

        batch.update(walletDoc, {
          'balance': FieldValue.increment(amountChange),
          'lastSyncDate': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Gagal menyimpan data ke Firestore: $e');
    }
  }

  /// 2. Mengambil data stream real-time
  Stream<List<TransactionModel>> getTransactionsStream(String userId) {
    return _db
        .collection(_collectionPath)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TransactionModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  /// 3. Menghapus transaksi
  Future<void> deleteTransaction(
    String id, {
    String? walletId,
    double? amount,
    String? type,
  }) async {
    try {
      final batch = _db.batch();
      batch.delete(_db.collection(_collectionPath).doc(id));

      // Jika dihapus, kembalikan saldo wallet
      if (walletId != null && amount != null && type != null) {
        final walletDoc = _db.collection(_walletCollection).doc(walletId);
        final amountChange = type == 'income' ? -amount : amount;
        batch.update(walletDoc, {
          'balance': FieldValue.increment(amountChange),
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Gagal menghapus data dari Firestore: $e');
    }
  }

  /// 4. Mengambil detail satu transaksi spesifik berdasarkan ID
  Future<TransactionModel?> getTransactionById(String id) async {
    try {
      final doc = await _db.collection(_collectionPath).doc(id).get();
      if (doc.exists && doc.data() != null) {
        return TransactionModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Gagal mengambil data dari Firestore: $e');
    }
  }

  /// 5. Menyimpan Rating/Feedback dari Pengguna
  Future<void> submitRating({
    required String userId,
    required String name,
    required String email,
    required double rating,
    required String comment,
  }) async {
    try {
      await _db.collection('rating').add({
        'userId': userId,
        'name': name,
        'email': email,
        'rating': rating,
        'comment': comment,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Gagal mengirim rating ke Firestore: $e');
    }
  }

  /// --- NOTIFICATION OPERATIONS ---

  /// Simpan notifikasi baru
  Future<void> addNotification(Map<String, dynamic> data) async {
    try {
      await _db.collection('notifications').add({
        ...data,
        'date': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Gagal menyimpan notifikasi: $e');
    }
  }

  /// Ambil stream notifikasi user
  Stream<List<Map<String, dynamic>>> getNotificationsStream(String userId) {
    return _db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {...doc.data(), 'id': doc.id})
              .toList(),
        );
  }

  /// Tandai notifikasi sebagai terbaca
  Future<void> markNotificationAsRead(String id) async {
    try {
      await _db.collection('notifications').doc(id).update({'isRead': true});
    } catch (e) {
      throw Exception('Gagal memperbarui status notifikasi: $e');
    }
  }

  /// Hapus satu notifikasi
  Future<void> deleteNotification(String id) async {
    try {
      await _db.collection('notifications').doc(id).delete();
    } catch (e) {
      throw Exception('Gagal menghapus notifikasi: $e');
    }
  }

  /// Hapus semua notifikasi user
  Future<void> deleteAllNotifications(String userId) async {
    try {
      final batch = _db.batch();
      final query = await _db
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .get();
      for (var doc in query.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Gagal menghapus semua notifikasi: $e');
    }
  }
}
