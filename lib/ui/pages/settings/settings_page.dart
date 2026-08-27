import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/settings_provider.dart';
import 'privacy_page.dart';
import 'permissions_page.dart';
import 'help_page.dart';
import 'policy_page.dart';
import 'version_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          settings.translate('Pengaturan', 'Settings'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(
              settings.translate(
                'Perangkat \u0026 Tema',
                'Device \u0026 Theme',
              ),
            ),
            const SizedBox(height: 12),
            _buildSettingCard(
              context,
              children: [
                _buildSwitchTile(
                  icon: Icons.wb_sunny_outlined,
                  title: settings.translate('Mode Gelap', 'Dark Mode'),
                  subtitle: isDark
                      ? settings.translate('Aktif', 'Enabled')
                      : settings.translate('Nonaktif', 'Disabled'),
                  value: isDark,
                  onChanged: (val) => settings.toggleTheme(val),
                ),
                const Divider(height: 1),
                _buildSwitchTile(
                  icon: Icons.language_rounded,
                  title: settings.translate(
                    'Bahasa Inggris',
                    'English Language',
                  ),
                  subtitle: settings.languageCode == 'en'
                      ? settings.translate('Aktif', 'Enabled')
                      : settings.translate('Nonaktif', 'Disabled'),
                  value: settings.languageCode == 'en',
                  onChanged: (val) => settings.setLanguage(val ? 'en' : 'id'),
                ),
                const Divider(height: 1),
                _buildSwitchTile(
                  icon: Icons.notifications_none_rounded,
                  title: settings.translate('Notifikasi', 'Notifications'),
                  subtitle: settings.translate(
                    'Kelola preferensi peringatan',
                    'Manage alert preferences',
                  ),
                  value: settings.notificationsEnabled,
                  onChanged: (val) => settings.toggleNotifications(val),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildSectionTitle(
              settings.translate(
                'Privasi \u0026 Keamanan',
                'Privacy \u0026 Security',
              ),
            ),
            const SizedBox(height: 12),
            _buildSettingCard(
              context,
              children: [
                _buildNavigationTile(
                  icon: Icons.lock_outline_rounded,
                  title: settings.translate(
                    'Kontrol Privasi',
                    'Privacy Controls',
                  ),
                  subtitle: settings.translate(
                    'Kelola data Anda',
                    'Manage your data',
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PrivacyControlsPage(),
                    ),
                  ),
                ),
                const Divider(height: 1),
                _buildNavigationTile(
                  icon: Icons.security_outlined,
                  title: settings.translate('Izin Perangkat', 'Permissions'),
                  subtitle: settings.translate(
                    'Tinjau izin aplikasi',
                    'Review app permissions',
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PermissionsPage()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildSectionTitle(settings.translate('Dukungan', 'Support')),
            const SizedBox(height: 12),
            _buildSettingCard(
              context,
              children: [
                _buildNavigationTile(
                  icon: Icons.help_outline_rounded,
                  title: settings.translate(
                    'Bantuan \u0026 FAQ',
                    'Help \u0026 FAQ',
                  ),
                  subtitle: settings.translate(
                    'Dapatkan jawaban',
                    'Get answers',
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HelpFAQPage()),
                  ),
                ),
                const Divider(height: 1),
                _buildNavigationTile(
                  icon: Icons.privacy_tip_outlined,
                  title: settings.translate(
                    'Kebijakan Privasi',
                    'Privacy Policy',
                  ),
                  subtitle: settings.translate(
                    'Baca kebijakan kami',
                    'Read our policy',
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PrivacyPolicyPage(),
                    ),
                  ),
                ),
                const Divider(height: 1),
                _buildNavigationTile(
                  icon: Icons.info_outline_rounded,
                  title: settings.translate('Versi Aplikasi', 'App Version'),
                  subtitle: settings.translate(
                    'Riwayat pembaruan',
                    'Update history',
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const VersionHistoryPage(),
                    ),
                  ),
                  trailing: Text(
                    'v1.0.3',
                    style: TextStyle(
                      color: isDark ? Colors.grey : Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildSettingCard(
    BuildContext context, {
    required List<Widget> children,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.primary.withAlpha(25),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.primary,
      ),
    );
  }

  Widget _buildNavigationTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.primary.withAlpha(25),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      trailing:
          trailing ??
          const Icon(Icons.chevron_right_rounded, color: Colors.grey),
    );
  }
}
