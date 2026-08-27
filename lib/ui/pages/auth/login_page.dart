import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Import Font Awesome
import '../../../../core/constants/app_colors.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/settings_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_popup.dart';
import 'package:google_fonts/google_fonts.dart';
import 'register_page.dart';
import '../main/main_page.dart';

// ... rest of the imports (kept for context)

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Popup Estetik buat Login
  void _showLoginSuccess() {
    CustomPopup.show(
      context: context,
      title: 'Selamat Datang! ✨',
      message: 'Menuju Dashboard Camelio...',
      isSuccess: true,
      onConfirm: () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => MainPage()),
          (route) => false,
        );
      },
    );

    // Otomatis pindah setelah 1 detik agar user sempat lihat popup
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => MainPage()),
          (route) => false,
        );
      }
    });
  }

  Future<void> _handleLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      CustomPopup.show(
        context: context,
        title: 'Error',
        message: 'Email dan Password harus diisi',
        isSuccess: false,
      );
      return;
    }

    final success = await authProvider.signInWithEmail(email, password);

    if (!mounted) return;

    if (success) {
      _showLoginSuccess();
      // Navigator push ditangani otomatis oleh Consumer<AuthProvider> di app.dart
    } else {
      if (authProvider.errorMessage != null) {
        CustomPopup.show(
          context: context,
          title: 'Gagal',
          message: authProvider.errorMessage!,
          isSuccess: false,
        );
        authProvider.clearError();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Row(
            children: [
              Icon(
                Theme.of(context).brightness == Brightness.dark
                    ? Icons.dark_mode
                    : Icons.light_mode,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                Theme.of(context).brightness == Brightness.dark ? 'ON' : 'OFF',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Switch(
                value: Theme.of(context).brightness == Brightness.dark,
                onChanged: (val) => settings.toggleTheme(val),
                activeThumbColor: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset(
                  'assets/logo_camelio.png',
                  height: 80,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.account_balance_wallet,
                    size: 120,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  settings.translate('Masuk ke Akun', 'Sign In to Account'),
                  style: GoogleFonts.outfit(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                CustomTextField(label: 'Email', controller: _emailController),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Password',
                  controller: _passwordController,
                  isPassword: true,
                ),
                const SizedBox(height: 32),
                authProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Masuk',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Atau masuk dengan',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final success = await authProvider.signInWithGoogle();
                          if (success && context.mounted) {
                            _showLoginSuccess();
                          } else if (context.mounted &&
                              authProvider.errorMessage != null) {
                            CustomPopup.show(
                              context: context,
                              title: 'Gagal',
                              message: authProvider.errorMessage!,
                              isSuccess: false,
                            );
                            authProvider.clearError();
                          }
                        },
                        icon: Image.asset(
                          'assets/google.png',
                          width: 24,
                          height: 24,
                          errorBuilder: (context, error, stackTrace) =>
                              const FaIcon(
                                FontAwesomeIcons.google,
                                color: Color(0xFF4285F4),
                                size: 20,
                              ),
                        ),
                        label: Text(
                          'Google',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Colors.grey.withAlpha(51)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Belum punya akun?',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterPage()),
                      ),
                      child: const Text(
                        'Daftar',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
