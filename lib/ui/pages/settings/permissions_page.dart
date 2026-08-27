import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/settings_provider.dart';
import '../../../providers/notification_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/custom_popup.dart';

class PermissionsPage extends StatelessWidget {
  const PermissionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          settings.translate('Izin', 'Permissions'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildPermissionTile(
            context,
            settings: settings,
            title: settings.translate('Kamera', 'Camera'),
            subtitle: settings.translate(
              'Digunakan untuk memindai struk dan foto profil',
              'Used for scanning receipts and profile photos',
            ),
            icon: Icons.camera_alt_outlined,
            isGranted: settings.cameraPermission,
            onChanged: (val) => settings.requestPermission(Permission.camera),
          ),
          const SizedBox(height: 12),
          _buildPermissionTile(
            context,
            settings: settings,
            title: settings.translate('Mikrofon', 'Microphone'),
            subtitle: settings.translate(
              'Digunakan untuk perintah suara AI',
              'Used for AI voice commands',
            ),
            icon: Icons.mic_none_rounded,
            isGranted: settings.microPermission,
            onChanged: (val) =>
                settings.requestPermission(Permission.microphone),
          ),
          const SizedBox(height: 12),
          _buildPermissionTile(
            context,
            settings: settings,
            title: settings.translate('Penyimpanan & Foto', 'Storage & Photos'),
            subtitle: settings.translate(
              'Digunakan untuk menyimpan laporan dan mengunggah gambar',
              'Used to save reports and upload images',
            ),
            icon: Icons.folder_open_rounded,
            isGranted: settings.storagePermission,
            onChanged: (val) => settings.requestStoragePermission(),
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: const Icon(
                Icons.notifications_none_rounded,
                color: AppColors.primary,
              ),
              title: Text(
                settings.translate(
                  'Pemberitahuan Sistem',
                  'System Notifications',
                ),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                settings.translate(
                  'Aktifkan notifikasi untuk transaksi dan sinkronisasi',
                  'Enable notifications for transactions and sync',
                ),
                style: const TextStyle(fontSize: 12),
              ),
              trailing: Switch(
                value: settings.notificationsEnabled,
                onChanged: (val) {
                  settings.toggleNotifications(val);
                  if (val) {
                    final auth = context.read<AuthProvider>();
                    if (auth.user != null) {
                      context.read<NotificationProvider>().sendTestNotification(
                        auth.user!.uid,
                        settings.translate,
                      );
                    }
                  }
                },
                activeThumbColor: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Consumer<SettingsProvider>(
              builder: (context, settingsProv, _) => ListTile(
                leading: const Icon(
                  Icons.email_outlined,
                  color: AppColors.primary,
                ),
                title: Text(
                  settingsProv.translate('Akses Gmail', 'Gmail Access'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  settingsProv.translate(
                    'Izinkan sinkronisasi data transaksi secara otomatis melalui email',
                    'Allow transaction data synchronization automatically via email',
                  ),
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: Switch(
                  value: settingsProv.gmailSyncEnabled,
                  onChanged: (val) async {
                    final success = await settingsProv.toggleGmailSync(val);
                    if (val && success) {
                      if (context.mounted) {
                        CustomPopup.show(
                          context: context,
                          title: settingsProv.translate(
                            'Izin Gmail Aktif',
                            'Gmail Permission Active',
                          ),
                          message: settingsProv.translate(
                            'Akses email telah diaktifkan untuk sinkronisasi otomatis.',
                            'Email access has been enabled for automatic synchronization.',
                          ),
                          isSuccess: true,
                        );
                      }
                    } else if (val && !success) {
                      if (context.mounted) {
                        CustomPopup.show(
                          context: context,
                          title: settingsProv.translate(
                            'Gagal Akses Gmail',
                            'Gmail Access Failed',
                          ),
                          message: settingsProv.translate(
                            'Gagal menghubungkan ke Gmail. Silakan coba lagi.',
                            'Failed to connect to Gmail. Please try again.',
                          ),
                          isSuccess: false,
                        );
                      }
                    }
                  },
                  activeThumbColor: AppColors.primary,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),
          Text(
            settings.translate(
              'Kelola izin sistem untuk kenyamanan fitur aplikasi.',
              'Manage system permissions for optimal app performance.',
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionTile(
    BuildContext context, {
    required SettingsProvider settings,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isGranted,
    required Function(bool) onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: Switch(
          value: isGranted,
          onChanged: onChanged,
          activeThumbColor: AppColors.primary,
        ),
      ),
    );
  }
}
