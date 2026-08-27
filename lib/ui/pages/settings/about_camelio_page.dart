import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/settings_provider.dart';

class AboutCamelioModal extends StatefulWidget {
  const AboutCamelioModal({super.key});

  @override
  State<AboutCamelioModal> createState() => _AboutCamelioModalState();
}

class _AboutCamelioModalState extends State<AboutCamelioModal> {
  @override
  Widget build(BuildContext context) {
    final settings = context.read<SettingsProvider>();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/logo_app_camelio.png',
                          height: 50,
                          width: 50,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.auto_graph_rounded,
                                color: AppColors.primary,
                                size: 50,
                              ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Camelio Finance',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Smart Finance Assistant',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    settings.translate('Deskripsi', 'Description'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    settings.translate(
                      'Camelio Finance adalah asisten keuangan cerdas yang membantu Anda mengelola uang dengan lebih bijak. Aplikasi ini melacak pengeluaran Anda secara otomatis, memberikan wawasan berbasis AI, dan membantu Anda mencapai kebebasan finansial tanpa kerumitan teknis.',
                      'Camelio Finance is a smart financial assistant that helps you manage your money more wisely. This app tracks your expenses automatically, provides AI-driven insights, and helps you achieve financial freedom without technical complexity.',
                    ),
                    style: const TextStyle(height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    settings.translate('Misi Kami', 'Our Mission'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    settings.translate(
                      'Membantu setiap orang memiliki kendali penuh atas masa depan finansial mereka melalui teknologi yang mudah digunakan dan dapat diandalkan.',
                      'Helping everyone have full control over their financial future through easy-to-use and reliable technology.',
                    ),
                    style: const TextStyle(height: 1.5, fontSize: 13),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    settings.translate('Fitur Unggulan', 'Key Features'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildAboutFeatureItem(
                    Icons.sync_rounded,
                    settings.translate(
                      'Sinkronisasi Otomatis',
                      'Automatic Sync',
                    ),
                    settings.translate(
                      'Terhubung dengan Gmail untuk mencatat transaksi bank & e-wallet secara real-time.',
                      'Connect with Gmail to record bank & e-wallet transactions in real-time.',
                    ),
                  ),
                  _buildAboutFeatureItem(
                    Icons.psychology_rounded,
                    settings.translate(
                      'Analisis AI Gemini',
                      'Gemini AI Analysis',
                    ),
                    settings.translate(
                      'Memanfaatkan Google Gemini untuk klasifikasi transaksi yang presisi.',
                      'Leveraging Google Gemini for precise transaction classification.',
                    ),
                  ),
                  _buildAboutFeatureItem(
                    Icons.security_rounded,
                    settings.translate('Keamanan Terjamin', 'Secure & Private'),
                    settings.translate(
                      'Data Anda dienkripsi dan disimpan dengan aman menggunakan standar industri Firebase.',
                      'Your data is encrypted and securely stored using industry-standard Firebase.',
                    ),
                  ),
                  _buildAboutFeatureItem(
                    Icons.auto_awesome_rounded,
                    settings.translate('Nasehat Cerdas', 'Smart Advice'),
                    settings.translate(
                      'Dapatkan saran keuangan personal berdasarkan pola pengeluaran Anda.',
                      'Get personalized financial advice based on your spending patterns.',
                    ),
                  ),
                  const SizedBox(height: 24),
                  Divider(color: Colors.grey.shade200),
                  const SizedBox(height: 24),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          settings.translate(
                            'Dikembangkan oleh',
                            'Developed by',
                          ),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Muhammad Dicky Adicandra',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '© 2026 Camelio Finance. All Rights Reserved.',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                settings.translate('Tutup', 'Close'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildAboutFeatureItem(IconData icon, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  desc,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
