import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../main/main_page.dart';
import 'package:provider/provider.dart';
import '../../../../providers/auth_provider.dart';
import '../auth/login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (authProvider.user != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainPage()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        }
      } catch (e) {
        debugPrint('Error navigasi splash: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Terjadi kesalahan saat memuat (Firebase belum di-setup?): $e',
            ),
            duration: const Duration(seconds: 10),
          ),
        );
        // Fallback pindah ke LoginPage saja agar tidak stuck
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final isWide = constraints.maxWidth > 600;

            return Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/logo_camelio.png',
                    width: isWide ? 200 : 140, // Sedikit dibesarkan di tablet
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.account_balance_wallet,
                      size: isWide ? 200 : 140,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: isWide
                        ? 400
                        : 160, // Lebar dikecilkan agar pas dengan logo
                    child: FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Text(
                        'Camelio',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0B083A),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 0),
                  SizedBox(
                    width: isWide
                        ? 400
                        : 160, // Lebar dikecilkan agar pas dengan logo
                    child: FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Text(
                        'Manage Money Efficiently',
                        style: TextStyle(
                          color: isDark
                              ? Colors.grey.shade300
                              : const Color(0xFF0B083A),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
