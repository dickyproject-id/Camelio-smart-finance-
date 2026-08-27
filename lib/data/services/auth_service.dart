import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  FirebaseAuth? get _firebaseAuth {
    if (Firebase.apps.isEmpty) return null;
    return FirebaseAuth.instance;
  }

  final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: ['email', 'https://www.googleapis.com/auth/userinfo.profile'],
  );

  Stream<User?> get authStateChanges {
    if (_firebaseAuth == null) return const Stream.empty();
    return _firebaseAuth!.authStateChanges();
  }

  User? get currentUser => _firebaseAuth?.currentUser;

  Future<UserCredential?> signInAnonymously() async {
    if (_firebaseAuth == null) {
      throw Exception('Firebase belum dikonfigurasi (No App).');
    }
    return await _firebaseAuth!.signInAnonymously();
  }

  Future<UserCredential?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    if (_firebaseAuth == null) {
      throw Exception('Firebase belum dikonfigurasi (No App).');
    }
    return await _firebaseAuth!.signInWithCredential(credential);
  }

  // PERBAIKAN: Tambah parameter 'name' dan update profil user
  Future<UserCredential?> registerWithEmail(
    String email,
    String password,
    String name, // <-- Parameter ke-3 ditambahkan di sini
  ) async {
    if (_firebaseAuth == null) {
      throw Exception('Firebase belum dikonfigurasi (No App).');
    }
    UserCredential credential = await _firebaseAuth!
        .createUserWithEmailAndPassword(email: email, password: password);

    // Update Display Name di Firebase Authentication
    await credential.user?.updateDisplayName(name);

    return credential;
  }

  Future<UserCredential?> signInWithEmail(String email, String password) async {
    if (_firebaseAuth == null) {
      throw Exception('Firebase belum dikonfigurasi (No App).');
    }
    return await _firebaseAuth!.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await Future.wait([
      if (_firebaseAuth != null) _firebaseAuth!.signOut(),
      // Perbaikan: Cek status menggunakan currentUser
      googleSignIn.signOut(),
    ]);
  }
}
