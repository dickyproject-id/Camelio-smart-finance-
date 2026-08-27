import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../providers/settings_provider.dart';
import 'package:provider/provider.dart';
// Import ke folder ai_advisor
import '../../ai_advisor/ai_insight_page.dart';
import '../../budget/budget_page.dart';

class FeatureCards extends StatelessWidget {
  const FeatureCards({super.key});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch, // Pastikan tinggi sama
        children: [
          Expanded(
            child: _buildCard(
              context: context,
              title: context.watch<SettingsProvider>().translate(
                'Analisis AI',
                'AI Insight',
              ),
              subtitle: context.watch<SettingsProvider>().translate(
                'Analisis pengeluaran dan tips hemat untukmu',
                'Expense analysis and savings tips for you',
              ),
              buttonText: context.watch<SettingsProvider>().translate(
                'Lihat Wawasan',
                'View Insight',
              ),
              backgroundColor: const Color(0xFF8B75FF), // Ungu muda solid
              icon: Icons.pie_chart,
              iconColor: Colors.white.withAlpha(50),
              onTap: () {
                // Menuju halaman AI Insight
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AiInsightPage()),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildCard(
              context: context,
              title: context.watch<SettingsProvider>().translate(
                'Target Keuangan',
                'Financial Target',
              ),
              subtitle: context.watch<SettingsProvider>().translate(
                'Pantau target keuanganmu dengan mudah',
                'Monitor your financial target easily',
              ),
              buttonText: context.watch<SettingsProvider>().translate(
                'Atur Target',
                'Set Target',
              ),
              backgroundColor: const Color(
                0xFFFFD4C4,
              ), // Orange pucat tetap cerah
              textColor: Colors.black87, // Hitam agar kontras di orange pucat
              icon: Icons.account_balance_wallet,
              iconColor: AppColors.secondary.withValues(alpha: 0.2),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BudgetPage()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String buttonText,
    required Color backgroundColor,
    required IconData icon,
    required Color iconColor,
    Color textColor = Colors.white,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              right: -10,
              bottom: -10,
              child: Icon(icon, size: 80, color: iconColor),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: textColor.withAlpha(204), // 80% opacity
                    fontSize: 10,
                    height: 1.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(), // Dorong tombol ke paling bawah agar sejajar
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      buttonText,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios, size: 10, color: textColor),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
