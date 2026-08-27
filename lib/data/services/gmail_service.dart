import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/gmail/v1.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import '../../core/locator.dart';
import 'auth_service.dart';

class GmailService {
  GoogleSignIn get _googleSignIn => locator<AuthService>().googleSignIn;

  Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }

  Future<GoogleSignInAccount?> signIn() async {
    try {
      // 1. Pastikan user sudah sign in terlebih dahulu
      GoogleSignInAccount? account = await _googleSignIn.signInSilently();
      account ??= await _googleSignIn.signIn();

      if (account == null) return null;

      // 2. Request scopes setelah akun dipastikan ada
      final success = await _googleSignIn.requestScopes([
        GmailApi.gmailReadonlyScope,
        GmailApi.gmailSendScope,
      ]);

      if (success) {
        return account;
      }
    } catch (e) {
      debugPrint('Error during Gmail sign in: $e');
    }
    return null;
  }

  Future<void> signOut() async {
    // For disconnecting, we just sign out from the Google session if needed,
    // or just let the provider handle the state.
    // Usually we don't want to sign out from Firebase, just Google Sign In for scopes.
    await _googleSignIn.signOut();
  }

  Future<GmailApi?> getGmailApi() async {
    try {
      GoogleSignInAccount? googleUser = _googleSignIn.currentUser;

      // If no user or missing scopes, try to sign in/request scopes
      if (googleUser == null) {
        googleUser = await signIn();
      } else {
        // Request scopes to be sure
        await _googleSignIn.requestScopes([
          GmailApi.gmailReadonlyScope,
          GmailApi.gmailSendScope,
        ]);
      }

      if (googleUser == null) return null;

      final client = await _googleSignIn.authenticatedClient();
      if (client == null) return null;

      return GmailApi(client);
    } catch (e) {
      debugPrint('Error getting Gmail API: $e');
      return null;
    }
  }

  Future<List<Message>> fetchTransactionEmails(
    GmailApi api, {
    DateTime? afterDate,
  }) async {
    String query = 'label:inbox ';
    if (afterDate != null) {
      final seconds = (afterDate.millisecondsSinceEpoch / 1000).floor();
      query += 'after:$seconds ';
    }

    // Add common transaction keywords/senders for Indonesian users
    query +=
        '(BCA OR Mandiri OR BNI OR BRI OR Gojek OR Grab OR OVO OR Shopee OR Dana OR Tokopedia)';
    query +=
        ' (transaksi OR pembayaran OR transfer OR berhasil OR sukses)'; // Tambahan filter

    final ListMessagesResponse results = await api.users.messages.list(
      'me',
      q: query,
    );
    return results.messages ?? [];
  }

  Future<Map<String, dynamic>?> parseEmailContent(
    GmailApi api,
    String messageId,
  ) async {
    final Message message = await api.users.messages.get(
      'me',
      messageId,
      format: 'full',
    );
    final String snippet = message.snippet ?? '';

    return {
      'id': messageId,
      'snippet': snippet,
      'date': DateTime.fromMillisecondsSinceEpoch(
        int.parse(message.internalDate ?? '0'),
      ),
    };
  }

  Future<void> sendConfirmationEmail(GmailApi api) async {
    final message = Message()
      ..raw = base64Url.encode(
        utf8.encode(
          'To: me\r\n'
          'Subject: Aktivasi Sinkronisasi Camelio\r\n\r\n'
          'Email anda terdaftar di aplikasi camelio. Sekarang kami dapat membantu Anda mengelola transaksi secara otomatis.',
        ),
      );
    await api.users.messages.send(message, 'me');
  }
}
