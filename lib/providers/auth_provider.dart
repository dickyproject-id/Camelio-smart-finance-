import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/locator.dart';
import '../data/services/auth_service.dart';
import '../data/services/firestore_service.dart';
import '../data/services/cloudinary_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = locator<AuthService>();
  final FirestoreService _firestoreService = locator<FirestoreService>();
  final CloudinaryService _cloudinaryService = locator<CloudinaryService>();

  User? _user;
  Map<String, dynamic>? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;

  StreamSubscription<User?>? _authSubscription;

  User? get user => _user;
  Map<String, dynamic>? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _user = _authService.currentUser;
    if (_user != null) {
      loadUserProfile();
    }
    _authSubscription = _authService.authStateChanges.listen((User? user) {
      _user = user;
      if (user != null) {
        loadUserProfile();
      } else {
        _userProfile = null;
      }
      notifyListeners();
    });
  }

  Future<void> loadUserProfile() async {
    if (_user == null) return;
    try {
      _userProfile = await _firestoreService.getUserProfile(_user!.uid);
      notifyListeners();
    } catch (e) {
      debugPrint("Gagal load profile: $e");
    }
  }

  Future<bool> updateProfile({
    required String name,
    required String gender,
    required DateTime? birthDate,
    required String whatsapp,
    String? accountType,
  }) async {
    if (_user == null) return false;
    _setLoading(true);
    try {
      final data = {
        'name': name,
        'gender': gender,
        'birthDate': birthDate != null ? Timestamp.fromDate(birthDate) : null,
        'whatsapp': whatsapp,
      };
      if (accountType != null) {
        data['accountType'] = accountType;
      }
      await _firestoreService.updateUserProfile(_user!.uid, data);
      await loadUserProfile(); // Refresh local state
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateProfilePicture(File imageFile) async {
    if (_user == null) return false;
    _setLoading(true);
    try {
      // 1. Upload ke Cloudinary (folder khusus profil)
      final imageUrl = await _cloudinaryService.uploadImage(
        imageFile,
        folder: 'profile_pictures',
      );

      if (imageUrl != null) {
        // 2. Simpan URL ke Firestore
        await _firestoreService.updateUserProfile(_user!.uid, {
          'photoUrl': imageUrl,
        });
        await loadUserProfile(); // Refresh state
        _setLoading(false);
        return true;
      }
      _setLoading(false);
      return false;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateBudget(double amount) async {
    if (_user == null) return false;
    _setLoading(true);
    try {
      await _firestoreService.updateUserProfile(_user!.uid, {
        'monthlyBudget': amount,
      });
      await loadUserProfile();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteProfilePicture() async {
    if (_user == null) return false;
    _setLoading(true);
    try {
      await _firestoreService.updateUserProfile(_user!.uid, {'photoUrl': null});
      await loadUserProfile();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _clearError();
    _setLoading(true);
    try {
      final credential = await _authService.signInWithGoogle();

      // FIX: Jika login Google berhasil, WAJIB masukkan ke Firestore
      if (credential != null && credential.user != null) {
        await _firestoreService.createUserProfile(
          credential.user!.uid,
          credential.user!.displayName ?? "User Google",
          credential.user!.email ?? "",
          whatsapp:
              credential.user!.phoneNumber, // Use Google phone if available
        );
      }

      _setLoading(false);
      return credential != null;
    } catch (e) {
      _setError(_handleFirebaseError(e));
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signInWithEmail(String email, String password) async {
    _clearError();
    _setLoading(true);
    try {
      final user = await _authService.signInWithEmail(email, password);
      _setLoading(false);
      return user != null;
    } catch (e) {
      _setError(_handleFirebaseError(e));
      _setLoading(false);
      return false;
    }
  }

  Future<bool> registerWithEmail(
    String email,
    String password,
    String name,
    String primaryGmail,
    String whatsapp,
    String accountType,
  ) async {
    _clearError();
    _setLoading(true);
    try {
      // 1. Daftar Akun di Firebase Auth
      final credential = await _authService.registerWithEmail(
        email,
        password,
        name,
      );

      if (credential != null && credential.user != null) {
        // 2. Buat dokumen profil user di Firestore
        await _firestoreService.createUserProfile(
          credential.user!.uid,
          name,
          email,
          primaryGmail: primaryGmail,
          whatsapp: whatsapp,
          accountType: accountType,
        );

        debugPrint("User berhasil didaftarkan: ${credential.user!.email}");
        _setLoading(false);
        return true;
      }
      _setLoading(false);
      return false;
    } catch (e) {
      _setError(_handleFirebaseError(e));
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _authService.signOut();
      _user = null;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  String _handleFirebaseError(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'invalid-credential':
          return 'Email atau kata sandi salah. Silakan coba lagi.';
        case 'user-not-found':
          return 'Akun dengan email ini tidak ditemukan.';
        case 'wrong-password':
          return 'Kata sandi yang Anda masukkan salah.';
        case 'email-already-in-use':
          return 'Email ini sudah terdaftar. Gunakan email lain.';
        case 'invalid-email':
          return 'Format email tidak valid.';
        case 'weak-password':
          return 'Kata sandi terlalu lemah. Gunakan minimal 6 karakter.';
        case 'user-disabled':
          return 'Akun ini telah dinonaktifkan oleh sistem.';
        case 'too-many-requests':
          return 'Terlalu banyak percobaan masuk. Silakan coba lagi nanti.';
        case 'network-request-failed':
          return 'Koneksi internet bermasalah. Periksa jaringan Anda.';
        case 'operation-not-allowed':
          return 'Metode masuk ini tidak diaktifkan.';
        default:
          return e.message ?? 'Terjadi kesalahan sistem. Silakan coba lagi.';
      }
    }

    // Jika error string berisi technical terms, bersihkan atau beri pesan umum
    final errorStr = e.toString().toLowerCase();
    if (errorStr.contains('firebase') ||
        errorStr.contains('backend') ||
        errorStr.contains('exception')) {
      return 'Terjadi gangguan pada sistem. Silakan coba beberapa saat lagi.';
    }

    return e.toString();
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  void _setError(String msg) {
    _errorMessage = msg;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() => _clearError();

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
