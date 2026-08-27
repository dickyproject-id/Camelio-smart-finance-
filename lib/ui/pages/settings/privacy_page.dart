import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/settings_provider.dart';
import 'package:provider/provider.dart';

class PrivacyControlsPage extends StatefulWidget {
  const PrivacyControlsPage({super.key});

  @override
  State<PrivacyControlsPage> createState() => _PrivacyControlsPageState();
}

class _PrivacyControlsPageState extends State<PrivacyControlsPage> {
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          settings.translate('Kontrol Privasi', 'Privacy Controls'),
          style: const TextStyle(fontWeight: FontWeight.bold),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(
              context,
              title: settings.translate('Berbagi Data', 'Data Sharing'),
              description: settings.translate(
                'Kami tidak membagikan data keuangan Anda dengan pihak ketiga mana pun. Semua riwayat transaksi Anda disimpan dengan aman di server terenkripsi kami.',
                'We do not share your financial data with any third parties. All your transaction history is stored securely on our encrypted servers.',
              ),
              icon: Icons.phonelink_lock_rounded,
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              context,
              title: settings.translate('Analitik', 'Analytics'),
              description: settings.translate(
                'Kami menggunakan analitik anonim untuk meningkatkan pengalaman aplikasi. Tidak ada detail pribadi atau keuangan yang dikumpulkan selama proses ini.',
                'We use anonymous analytics to improve the app experience. No personal or financial details are collected during this process.',
              ),
              icon: Icons.analytics_outlined,
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              context,
              title: settings.translate(
                'Enkripsi End-to-End',
                'End-to-End Encryption',
              ),
              description: settings.translate(
                'Semua data sensitif Anda dienkripsi sebelum dikirim ke server kami, memastikan hanya Anda yang memiliki akses ke informasi keuangan Anda.',
                'All your sensitive data is encrypted before being sent to our servers, ensuring that only you have access to your financial information.',
              ),
              icon: Icons.security_rounded,
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              context,
              title: settings.translate('Keamanan Akses', 'Access Security'),
              description: settings.translate(
                'Aplikasi ini menggunakan sistem keamanan standar perangkat untuk melindungi akses ke data keuangan Anda, memastikan lapisan privasi tetap terjaga.',
                'This application uses standard device security systems to protect access to your financial data, ensuring privacy layers are maintained.',
              ),
              icon: Icons.vpn_key_outlined,
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              context,
              title: settings.translate(
                'Keamanan Gemini AI',
                'Gemini AI Security',
              ),
              description: settings.translate(
                'Fitur pemindaian struk dan asisten AI kami menggunakan teknologi Google Gemini. Data yang dikirim hanya berupa teks struk tanpa informasi identitas pribadi Anda.',
                'Our receipt scanning and AI assistant features use Google Gemini technology. Only receipt text is sent, without your personally identifiable information.',
              ),
              icon: Icons.auto_awesome_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    bool isWarning = false,
    Widget? action,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isWarning
              ? Colors.redAccent.withValues(alpha: 0.3)
              : (isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.grey.shade200),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: isWarning ? Colors.redAccent : AppColors.primary,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          if (action != null) ...[
            const SizedBox(height: 16),
            SizedBox(width: double.infinity, child: action),
          ],
        ],
      ),
    );
  }
}
