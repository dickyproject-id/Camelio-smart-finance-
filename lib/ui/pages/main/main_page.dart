import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';

import 'package:smart_finance_app/core/constants/app_colors.dart';
import 'package:smart_finance_app/core/constants/app_constants.dart';
import 'package:smart_finance_app/core/locator.dart';
import 'package:smart_finance_app/providers/auth_provider.dart';
import 'package:smart_finance_app/providers/transaction_provider.dart';
import 'package:smart_finance_app/providers/e_wallet_provider.dart';
import 'package:smart_finance_app/providers/notification_provider.dart';
import 'package:smart_finance_app/data/models/transaction_model.dart';
import 'package:smart_finance_app/data/services/gemini_ai_service.dart';
import 'package:smart_finance_app/ui/pages/settings/pdf_generator.dart';

import 'package:smart_finance_app/ui/pages/dashboard/dashboard_page.dart';
import 'package:smart_finance_app/ui/pages/e_wallet/e_wallet_page.dart';
import 'package:smart_finance_app/ui/pages/transaction/transaction_list_page.dart';
import 'package:smart_finance_app/ui/pages/portfolio/portfolio_page.dart';
import 'package:smart_finance_app/ui/pages/transaction/add_transaction_page.dart';
import 'package:smart_finance_app/ui/pages/transaction/scan_receipt_page.dart';
import 'package:smart_finance_app/ui/widgets/custom_popup.dart';
import 'package:smart_finance_app/data/services/firestore_service.dart';
import 'package:smart_finance_app/providers/settings_provider.dart';
import 'package:smart_finance_app/ui/pages/auth/login_page.dart';

import 'package:smart_finance_app/ui/pages/settings/privacy_page.dart';
import 'package:smart_finance_app/ui/pages/settings/permissions_page.dart';
import 'package:smart_finance_app/ui/pages/settings/help_page.dart';
import 'package:smart_finance_app/ui/pages/settings/policy_page.dart';
import 'package:smart_finance_app/ui/pages/settings/version_page.dart';
import 'package:smart_finance_app/ui/pages/settings/about_camelio_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  final _geminiService = locator<GeminiAIService>();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final GlobalKey _drawerScrollKey = GlobalKey(); // Key untuk scroll drawer

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.user != null) {
        Provider.of<TransactionProvider>(
          context,
          listen: false,
        ).loadTransactions(auth.user!.uid);

        // Load wallets as well
        Provider.of<EWalletProvider>(
          context,
          listen: false,
        ).loadWallets(auth.user!.uid);

        // Load notifications
        Provider.of<NotificationProvider>(
          context,
          listen: false,
        ).loadNotifications(auth.user!.uid);
      }
    });
  }

  final List<Widget> _pages = [
    const DashboardPage(),
    const EWalletPage(),
    const TransactionListPage(),
    const PortfolioPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        if (_currentIndex != 0) {
          // Jika tidak di home, kembali ke home
          setState(() => _currentIndex = 0);
        } else {
          // Jika sudah di home, jangan lakukan apa-apa
        }
      },
      child: Scaffold(
        drawer: _buildProfileDrawer(context),
        body: IndexedStack(index: _currentIndex, children: _pages),
        floatingActionButton: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: () => _showAddMenu(context),
            backgroundColor: Colors.transparent,
            elevation: 0,
            shape: const CircleBorder(),
            child: const Icon(Icons.add, color: Colors.white, size: 30),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 8.0,
          color: Theme.of(context).cardColor,
          child: Consumer<SettingsProvider>(
            builder: (context, settings, _) => SizedBox(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    icon: Icons.home_rounded,
                    label: settings.translate('Beranda', 'Home'),
                    index: 0,
                  ),
                  _buildNavItem(
                    icon: Icons.account_balance_wallet_outlined,
                    label: settings.translate('Dompet', 'E-Wallet'),
                    index: 1,
                  ),
                  const SizedBox(width: 40),
                  _buildNavItem(
                    icon: Icons.receipt_long_outlined,
                    label: settings.translate('Transaksi', 'Transactions'),
                    index: 2,
                  ),
                  _buildNavItem(
                    icon: Icons.pie_chart_outline,
                    label: settings.translate('Portofolio', 'Portfolio'),
                    index: 3,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () {
        setState(() => _currentIndex = index);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.primary : Colors.grey,
            size: 26,
          ),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.primary : Colors.grey,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (dialogContext) => Consumer<SettingsProvider>(
        builder: (settingsContext, settings, _) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            settings.translate('Keluar', 'Logout'),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            settings.translate(
              'Apakah Anda yakin ingin keluar dari akun Anda?',
              'Are you sure you want to log out of your account?',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(settings.translate('Batal', 'Cancel')),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext); // Tutup dialog

                // 1. Bersihkan data lokal & Gmail session
                await settings.resetUserSpecificSettings();

                if (context.mounted) {
                  Provider.of<TransactionProvider>(
                    context,
                    listen: false,
                  ).clearTransactions();
                }

                // 2. Logout dari Auth
                await auth.signOut();

                // 3. Pindah ke Halaman Login
                if (context.mounted) {
                  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                }
              },
              child: Text(
                settings.translate('Keluar', 'Logout'),
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showRatingDialog(BuildContext context) async {
    double rating = 5;
    final commentController = TextEditingController();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final firestore = locator<FirestoreService>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            context.read<SettingsProvider>().translate(
              'Beri Nilai Kami',
              'Rate Us',
            ),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.read<SettingsProvider>().translate(
                  'Bagaimana pengalaman Anda menggunakan Camelio?',
                  'How is your experience using Camelio?',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < rating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: Colors.orange,
                      size: 32,
                    ),
                    onPressed: () => setState(() => rating = index + 1.0),
                  );
                }),
              ),
              TextField(
                controller: commentController,
                decoration: InputDecoration(
                  hintText: context.read<SettingsProvider>().translate(
                    'Tulis saran atau kesan Anda...',
                    'Write your feedback or suggestions...',
                  ),
                  hintStyle: const TextStyle(fontSize: 14),
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                context.read<SettingsProvider>().translate('Batal', 'Cancel'),
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await firestore.submitRating(
                    userId: auth.user?.uid ?? 'anonymous',
                    name: auth.userProfile?['name'] ?? 'User',
                    email: auth.user?.email ?? '',
                    rating: rating,
                    comment: commentController.text,
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    CustomPopup.show(
                      context: context,
                      title: context.read<SettingsProvider>().translate(
                        'Terima Kasih! ✨',
                        'Thank You! ✨',
                      ),
                      message: context.read<SettingsProvider>().translate(
                        'Rating Anda sangat berharga bagi kami.',
                        'Your rating is very valuable to us.',
                      ),
                      isSuccess: true,
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    final settings = context.read<SettingsProvider>();
                    CustomPopup.show(
                      context: context,
                      title: settings.translate('Gagal', 'Failed'),
                      message: settings.translate(
                        'Gagal mengirim rating: $e',
                        'Failed to submit rating: $e',
                      ),
                      isSuccess: false,
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                context.read<SettingsProvider>().translate('Kirim', 'Submit'),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDrawer(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final settings = context.watch<SettingsProvider>();
    final profile = auth.userProfile;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      width: MediaQuery.of(context).size.width * 0.8,
      child: SingleChildScrollView(
        key: _drawerScrollKey,
        child: Column(
          children: [
            // CUSTOM HEADER WITH SPECIFIC BORDER RADIUS (AS REQUESTED)
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20,
                left: 24,
                right: 24,
                bottom: 30,
              ),
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(80),
                ),
              ),
              child: Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.white,
                        backgroundImage: profile?['photoUrl'] != null
                            ? NetworkImage(profile!['photoUrl'])
                            : null,
                        child: profile?['photoUrl'] == null
                            ? Text(
                                (profile?['name'] ??
                                        auth.user?.displayName ??
                                        'U')[0]
                                    .toUpperCase(),
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            _showEditProfileModal(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.edit_rounded,
                              color: AppColors.primary,
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile?['name'] ?? auth.user?.displayName ?? 'User',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          auth.user?.email ?? '',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  _buildDrawerItem(
                    icon: Icons.home_max_rounded,
                    title: settings.translate('Dashboard', 'Dashboard'),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => _currentIndex = 0);
                    },
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    child: Divider(),
                  ),

                  // PROTECTION SECTION
                  _buildDrawerSectionTitle(
                    settings.translate('Proteksi', 'Protection'),
                  ),
                  _buildDrawerBox(
                    context,
                    icon: Icons.wb_sunny_outlined,
                    title: settings.translate('Mode Gelap', 'Dark Mode'),
                    subtitle: Theme.of(context).brightness == Brightness.dark
                        ? settings.translate('Aktif', 'Enabled')
                        : settings.translate('Nonaktif', 'Disabled'),
                    trailing: Consumer<SettingsProvider>(
                      builder: (context, settings, _) => Switch(
                        value: Theme.of(context).brightness == Brightness.dark,
                        onChanged: (val) => settings.toggleTheme(val),
                        activeThumbColor: AppColors.primary,
                      ),
                    ),
                  ),
                  _buildDrawerBox(
                    context,
                    icon: Icons.notifications_none_rounded,
                    title: settings.translate('Notifikasi', 'Notifications'),
                    subtitle: settings.translate(
                      'Aktifkan pemberitahuan sistem',
                      'Enable system notifications',
                    ),
                    trailing: Switch(
                      value: settings.notificationsEnabled,
                      onChanged: (val) {
                        settings.toggleNotifications(val);
                        if (val) {
                          final auth = context.read<AuthProvider>();
                          if (auth.user != null) {
                            context
                                .read<NotificationProvider>()
                                .sendTestNotification(
                                  auth.user!.uid,
                                  settings.translate,
                                );
                          }
                        }
                      },
                      activeThumbColor: AppColors.primary,
                    ),
                  ),
                  _buildDrawerBox(
                    context,
                    icon: Icons.language_rounded,
                    title: settings.translate('Bahasa', 'Language'),
                    subtitle: settings.translate(
                      'Ganti bahasa aplikasi',
                      'Switch app language',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          settings.languageCode == 'id' ? 'ID' : 'EN',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Switch(
                          value: settings.languageCode == 'en',
                          onChanged: (val) =>
                              settings.setLanguage(val ? 'en' : 'id'),
                          activeThumbColor: AppColors.primary,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  // PRIVACY SECTION
                  _buildDrawerSectionTitle(
                    settings.translate(
                      'Privasi & Keamanan',
                      'Privacy & Security',
                    ),
                  ),
                  _buildDrawerBox(
                    context,
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
                  _buildDrawerBox(
                    context,
                    icon: Icons.security_outlined,
                    title: settings.translate('Izin', 'Permissions'),
                    subtitle: settings.translate(
                      'Tinjau izin aplikasi',
                      'Review app permissions',
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PermissionsPage(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  // TOOLS & REPORTS SECTION
                  _buildDrawerSectionTitle(
                    settings.translate('Alat & Laporan', 'Tools & Reports'),
                  ),

                  _buildDrawerBox(
                    context,
                    icon: Icons.picture_as_pdf_rounded,
                    title: settings.translate(
                      'Export PDF Laporan',
                      'Export PDF Report',
                    ),
                    subtitle: settings.translate(
                      'Bagikan laporan format PDF',
                      'Share report in PDF format',
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _handleExportPdf(context);
                    },
                  ),
                  const SizedBox(height: 12),

                  const SizedBox(height: 16),
                  // SUPPORT SECTION
                  _buildDrawerSectionTitle(
                    settings.translate('Dukungan', 'Support'),
                  ),
                  _buildDrawerBox(
                    context,
                    icon: Icons.help_outline_rounded,
                    title: settings.translate('Bantuan & FAQ', 'Help & FAQ'),
                    subtitle: settings.translate(
                      'Dapatkan jawaban',
                      'Get answers',
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HelpFAQPage()),
                    ),
                  ),
                  _buildDrawerBox(
                    context,
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
                  _buildDrawerBox(
                    context,
                    icon: Icons.info_outline_rounded,
                    title: settings.translate(
                      'Tentang Camelio',
                      'About Camelio',
                    ),
                    subtitle: settings.translate(
                      'Pelajari tentang aplikasi ini',
                      'Learn about this app',
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const AboutCamelioModal(),
                      );
                    },
                  ),
                  _buildDrawerBox(
                    context,
                    icon: Icons.history_rounded,
                    title: settings.translate('Versi Aplikasi', 'App Version'),
                    subtitle: 'v${AppConstants.appVersion}',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const VersionHistoryPage(),
                      ),
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    child: Divider(),
                  ),

                  // LOGOUT SECTION
                  _buildDrawerBox(
                    context,
                    icon: Icons.logout_rounded,
                    title: settings.translate('Keluar', 'Sign Out'),
                    subtitle: settings.translate(
                      'Keluar dari akun Anda',
                      'Log out of your account',
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showLogoutDialog(context);
                    },
                    titleColor: Colors.redAccent,
                    iconColor: Colors.redAccent,
                  ),

                  // BOTTOM SECTION WITH RATING & VERSION (INSIDE SCROLL)
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () => _showRatingDialog(context),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 16,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.favorite_rounded,
                                  color: Colors.redAccent,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  settings.translate(
                                    'Suka aplikasi ini? Beri nilai kami',
                                    'Enjoying this app? Rate us',
                                  ),
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.grey.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'v${AppConstants.appVersion}',
                          style: TextStyle(
                            color: Colors.grey.withValues(alpha: 0.6),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? titleColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: titleColor ?? AppColors.primary),
      title: Text(
        title,
        style: TextStyle(color: titleColor, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
    );
  }

  Widget _buildDrawerSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, top: 10, bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerBox(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Widget? trailing,
    Color? titleColor,
    Color? iconColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.grey.shade200,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (iconColor ?? AppColors.primary).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor ?? AppColors.primary, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: titleColor,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
        trailing:
            trailing ??
            (onTap != null
                ? const Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: Colors.grey,
                  )
                : null),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  void _showEditProfileModal(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final profile = auth.userProfile;
    final nameController = TextEditingController(text: profile?['name']);
    final whatsappController = TextEditingController(
      text: profile?['whatsapp'] ?? '',
    );
    String gender = profile?['gender'] ?? '-';
    DateTime? birthDate;
    if (profile?['birthDate'] != null) {
      birthDate = (profile?['birthDate'] as dynamic).toDate();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final settings = context.read<SettingsProvider>();
        String accountTypeStr = profile?['accountType'] ?? 'Personal';
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      settings.translate('Edit Profil', 'Edit Profile'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // FOTO PROFIL SECTION
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: profile?['photoUrl'] != null
                                ? NetworkImage(profile!['photoUrl'])
                                : null,
                            child: profile?['photoUrl'] == null
                                ? Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Image.asset(
                                      'assets/logo_camelio.png',
                                    ),
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () =>
                                  _showImageSourcePicker(context, auth),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (profile?['photoUrl'] != null)
                      TextButton(
                        onPressed: () async {
                          final confirm = await _showConfirmDeletePhoto(
                            context,
                          );
                          if (confirm == true) {
                            await auth.deleteProfilePicture();
                            if (context.mounted) Navigator.pop(context);
                          }
                        },
                        child: Text(
                          settings.translate('Hapus Foto', 'Delete Photo'),
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),

                    const SizedBox(height: 24),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: settings.translate(
                          'Nama Lengkap',
                          'Full Name',
                        ),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue:
                          ['male', 'female', '-'].contains(gender.toLowerCase())
                          ? gender.toLowerCase()
                          : (gender == settings.translate('Laki-laki', 'Male')
                                ? 'male'
                                : (gender ==
                                          settings.translate(
                                            'Perempuan',
                                            'Female',
                                          )
                                      ? 'female'
                                      : '-')),
                      decoration: InputDecoration(
                        labelText: settings.translate(
                          'Jenis Kelamin',
                          'Gender',
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      items:
                          [
                            {'val': '-', 'label': '-'},
                            {
                              'val': 'male',
                              'label': settings.translate('Laki-laki', 'Male'),
                            },
                            {
                              'val': 'female',
                              'label': settings.translate(
                                'Perempuan',
                                'Female',
                              ),
                            },
                          ].map((item) {
                            return DropdownMenuItem<String>(
                              value: item['val'],
                              child: Text(item['label']!),
                            );
                          }).toList(),
                      onChanged: (val) => setModalState(() => gender = val!),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: Text(
                        settings.translate('Tanggal Lahir', 'Date of Birth'),
                      ),
                      subtitle: Text(
                        birthDate == null
                            ? settings.translate('Pilih tanggal', 'Select date')
                            : DateFormat('dd MMMM yyyy').format(birthDate!),
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: birthDate ?? DateTime(2000),
                          firstDate: DateTime(1950),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setModalState(() => birthDate = picked);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: whatsappController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: settings.translate(
                          'Nomor WhatsApp',
                          'WhatsApp Number',
                        ),
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(
                          Icons.phone_iphone_rounded,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: accountTypeStr,
                      decoration: InputDecoration(
                        labelText: settings.translate(
                          'Konteks AI (Mode Akun)',
                          'AI Context (Account Mode)',
                        ),
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(
                          Icons.storefront_rounded,
                          size: 20,
                        ),
                      ),
                      items: [
                        DropdownMenuItem<String>(
                          value: 'Personal',
                          child: Text(
                            settings.translate('Pribadi', 'Personal'),
                          ),
                        ),
                        DropdownMenuItem<String>(
                          value: 'Business',
                          child: Text(settings.translate('Bisnis', 'Business')),
                        ),
                      ],
                      onChanged: (val) =>
                          setModalState(() => accountTypeStr = val!),
                    ),
                    const SizedBox(height: 24),
                    auth.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: () async {
                              final success = await auth.updateProfile(
                                name: nameController.text,
                                gender: gender,
                                birthDate: birthDate,
                                whatsapp: whatsappController.text,
                                accountType: accountTypeStr,
                              );
                              settings.setAccountType(accountTypeStr);
                              if (success && context.mounted) {
                                Navigator.pop(context);
                                _showPopup(
                                  settings.translate('Berhasil', 'Success'),
                                  settings.translate(
                                    'Profil Anda sudah diperbarui! ✨',
                                    'Your profile has been updated! ✨',
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              settings.translate(
                                'Simpan Perubahan',
                                'Save Changes',
                              ),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showImageSourcePicker(BuildContext context, AuthProvider auth) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final settings = context.read<SettingsProvider>();
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                settings.translate(
                  'Pilih Foto Profil',
                  'Choose Profile Picture',
                ),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (auth.userProfile?['photoUrl'] != null)
                    _buildSourceOption(
                      context,
                      icon: Icons.visibility_outlined,
                      label: settings.translate('Lihat Foto', 'View Photo'),
                      onTap: () {
                        Navigator.pop(context);
                        _viewProfilePhoto(
                          context,
                          auth.userProfile!['photoUrl'],
                        );
                      },
                    ),
                  _buildSourceOption(
                    context,
                    icon: Icons.camera_alt_outlined,
                    label: settings.translate('Kamera', 'Camera'),
                    onTap: () =>
                        _pickAndUploadImage(context, auth, ImageSource.camera),
                  ),
                  _buildSourceOption(
                    context,
                    icon: Icons.photo_library_outlined,
                    label: settings.translate('Galeri', 'Gallery'),
                    onTap: () =>
                        _pickAndUploadImage(context, auth, ImageSource.gallery),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSourceOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }

  void _viewProfilePhoto(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(url, fit: BoxFit.cover),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUploadImage(
    BuildContext context,
    AuthProvider auth,
    ImageSource source,
  ) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 50);

    if (pickedFile != null && context.mounted) {
      Navigator.pop(context); // Tutup picker modal
      Navigator.pop(context); // Tutup edit profile modal agar refresh

      final success = await auth.updateProfilePicture(File(pickedFile.path));
      if (success && context.mounted) {
        final settings = context.read<SettingsProvider>();
        _showPopup(
          settings.translate('Berhasil', 'Success'),
          settings.translate(
            'Foto profil berhasil diperbarui! 📸',
            'Profile picture updated! 📸',
          ),
        );
      }
    }
  }

  Future<bool?> _showConfirmDeletePhoto(BuildContext context) {
    final settings = context.read<SettingsProvider>();
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(settings.translate('Hapus Foto', 'Delete Photo')),
        content: Text(
          settings.translate(
            'Apakah Anda yakin ingin menghapus foto profil?',
            'Are you sure you want to delete your profile photo?',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(settings.translate('Batal', 'Cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              settings.translate('Hapus', 'Delete'),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Consumer<SettingsProvider>(
          builder: (context, settings, _) => Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  settings.translate('Tambah Transaksi', 'Add Transaction'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMenuOption(
                      context,
                      icon: Icons.auto_awesome,
                      title: settings.translate('Obrolan AI', 'Chat AI'),
                      onTap: () {
                        Navigator.pop(context);
                        _showAIBottomSheet(context, isVoice: false);
                      },
                    ),
                    _buildMenuOption(
                      context,
                      icon: Icons.document_scanner_outlined,
                      title: settings.translate('Scan Struk', 'Scan Receipt'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ScanReceiptPage(),
                          ),
                        ).then((_) => setState(() => _currentIndex = 0));
                      },
                    ),
                    _buildMenuOption(
                      context,
                      icon: Icons.mic_none,
                      title: settings.translate('Suara', 'Voice'),
                      onTap: () {
                        Navigator.pop(context);
                        _showAIBottomSheet(context, isVoice: true);
                      },
                    ),
                    _buildMenuOption(
                      context,
                      icon: Icons.edit_note,
                      title: settings.translate('Manual', 'Manual'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddTransactionPage(),
                          ),
                        ).then((_) => setState(() => _currentIndex = 0));
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withAlpha(26)),
            ),
            child: Icon(icon, color: AppColors.primary, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  void _showAIBottomSheet(BuildContext context, {required bool isVoice}) {
    final aiController = TextEditingController();
    bool isProcessing = false;
    bool isListening = false;
    String? selectedWalletId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            final settings = Provider.of<SettingsProvider>(context);

            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    isVoice
                        ? settings.translate(
                            'Catat dengan Suara',
                            'Record with Voice',
                          )
                        : settings.translate(
                            'Catat Cepat dengan AI',
                            'Quick Note with AI',
                          ),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  if (isVoice) ...[
                    GestureDetector(
                      onTap: () async {
                        if (!isListening) {
                          try {
                            // Cek izin dari provider (sinkronisasi)
                            if (!settings.microPermission) {
                              await settings.requestPermission(
                                Permission.microphone,
                              );
                            }

                            if (settings.microPermission) {
                              bool available = await _speech.initialize(
                                onStatus: (status) =>
                                    debugPrint('STT Status: $status'),
                                onError: (error) =>
                                    debugPrint('STT Error: $error'),
                              );

                              if (available && context.mounted) {
                                setStateModal(() => isListening = true);
                                _speech.listen(
                                  onResult: (result) {
                                    setStateModal(() {
                                      aiController.text =
                                          result.recognizedWords;
                                      if (result.finalResult) {
                                        isListening = false;
                                      }
                                    });
                                  },
                                );
                              }
                            }
                          } catch (e) {
                            debugPrint('Voice Error: $e');
                          }
                        } else {
                          setStateModal(() => isListening = false);
                          _speech.stop();
                        }
                      },
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: isListening
                            ? Colors.red
                            : AppColors.primary,
                        child: Icon(
                          isListening ? Icons.mic : Icons.mic_none,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isListening
                          ? settings.translate(
                              "Mendengarkan...",
                              "Listening...",
                            )
                          : settings.translate(
                              "Ketuk untuk mulai bicara",
                              "Tap to start speaking",
                            ),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.lightTextSecondary),
                    ),
                    const SizedBox(height: 16),
                  ],
                  TextField(
                    controller: aiController,
                    maxLines: 2,
                    readOnly: isVoice,
                    onChanged: (val) => setStateModal(() {}),
                    style: TextStyle(
                      color: aiController.text.isEmpty
                          ? Colors.grey
                          : Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    decoration: InputDecoration(
                      hintText: isVoice
                          ? settings.translate(
                              "Hasil suara akan muncul di sini",
                              "Voice result will appear here",
                            )
                          : settings.translate(
                              "Contoh: Beli Kopi 25rb tadi sore, tiket 1.5jt, beli makanan rp 6.500",
                              "Example: Bought coffee 25k, ticket 1.5M, bought food rp 6.500",
                            ),
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Consumer<EWalletProvider>(
                    builder: (context, walletProvider, _) {
                      final wallets = walletProvider.wallets;
                      if (selectedWalletId == null && wallets.isNotEmpty) {
                        final cashWallet = wallets
                            .where((w) => w.type == 'cash')
                            .firstOrNull;
                        selectedWalletId = cashWallet?.id ?? wallets.first.id;
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            settings.translate(
                              'Sumber Dana / Wallet:',
                              'Source / Wallet:',
                            ),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: selectedWalletId,
                            dropdownColor: Theme.of(context).cardColor,
                            isExpanded: true,
                            items: wallets
                                .map(
                                  (w) => DropdownMenuItem(
                                    value: w.id,
                                    child: Text(
                                      "${w.name} (${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(w.balance)})",
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) =>
                                setStateModal(() => selectedWalletId = val),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Theme.of(context).cardColor,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Colors.grey.withAlpha(51),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  isProcessing
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () async {
                            if (aiController.text.isEmpty) return;
                            setStateModal(() => isProcessing = true);

                            try {
                              final auth = Provider.of<AuthProvider>(
                                context,
                                listen: false,
                              );
                              final transProvider =
                                  Provider.of<TransactionProvider>(
                                    context,
                                    listen: false,
                                  );

                              String responseRaw = await _geminiService
                                  .classifyTransaction(
                                    aiController.text,
                                    language: settings.languageCode,
                                  );
                              responseRaw = responseRaw
                                  .replaceAll('```json', '')
                                  .replaceAll('```', '')
                                  .trim();
                              final Map<String, dynamic> data = jsonDecode(
                                responseRaw,
                              );

                              double amountVal = 0;
                              if (data['amount'] != null) {
                                amountVal =
                                    double.tryParse(
                                      data['amount'].toString().replaceAll(
                                        RegExp(r'[^0-9]'),
                                        '',
                                      ),
                                    ) ??
                                    0;
                              }

                              String categoryVal =
                                  data['category'] ?? 'Lainnya';

                              // Validasi dan Fallback Lokal jika Gemini gagal atau mengembalikan nominal 0 / Lainnya
                              if (amountVal == 0) {
                                final localAmount = _extractAmountLocally(
                                  aiController.text,
                                );
                                if (localAmount != null) {
                                  amountVal = localAmount;
                                }
                              }

                              if (categoryVal == 'Lainnya') {
                                final localCategory = _extractCategoryLocally(
                                  aiController.text,
                                );
                                if (localCategory != 'Lainnya') {
                                  categoryVal = localCategory;
                                }
                              }

                              final tx = TransactionModel(
                                userId: auth.user!.uid,
                                walletId: selectedWalletId,
                                amount: amountVal,
                                category: categoryVal,
                                description:
                                    data['description'] ?? aiController.text,
                                date: DateTime.now(),
                                type: data['type'] ?? 'expense',
                                source: isVoice ? 'voice' : 'ai',
                              );

                              await transProvider.addTransaction(tx);

                              if (context.mounted) {
                                Navigator.pop(context);
                                _showPopup(
                                  settings.translate('Berhasil!', 'Success!'),
                                  settings.translate(
                                    'Catatan keuangan Anda sudah disimpan!',
                                    'Saved!',
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                setStateModal(() => isProcessing = false);
                                _showPopup(
                                  settings.translate('Error', 'Error'),
                                  settings.translate(
                                    'Gagal memproses data.',
                                    'Failed to process data.',
                                  ),
                                );
                              }
                            }
                          },
                          child: Text(
                            settings.translate('Simpan Data', 'Save Data'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _handleExportPdf(BuildContext context) async {
    final settings = context.read<SettingsProvider>();
    final transProvider = context.read<TransactionProvider>();
    final walletProvider = context.read<EWalletProvider>();

    //Pilih rentang tanggal laporan
    final DateTimeRange? pickedRange = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 7)),
        end: DateTime.now(),
      ),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Theme.of(context).scaffoldBackgroundColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedRange != null) {
      if (!context.mounted) return;
      // Bangun chart widget untuk dieksport dengan range yang dipilih
      final chartWidget = PdfGenerator.buildExportChart(
        context,
        transProvider,
        startDate: pickedRange.start,
        endDate: pickedRange.end,
      );

      if (context.mounted) {
        await PdfGenerator.generateAndShare(
          context,
          settings: settings,
          transProvider: transProvider,
          walletProvider: walletProvider,
          chartWidget: chartWidget,
          startDate: pickedRange.start,
          endDate: pickedRange.end,
        );
      }
    }
  }

  void _showPopup(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.read<SettingsProvider>().translate('OK', 'OK')),
          ),
        ],
      ),
    );
  }

  bool _containsKeyword(String text, String keyword) {
    final cleanText = text.toLowerCase();
    final cleanKeyword = keyword.toLowerCase();

    // Jika kata kunci sangat pendek (<= 3 karakter, misal es, air, teh, jus, bir, tf, gas, ac, hp), gunakan strict word boundary + suffix
    if (cleanKeyword.length <= 3) {
      final regex = RegExp(
        r'\b' + RegExp.escape(cleanKeyword) + r'(nya|ku|mu)?\b',
      );
      return regex.hasMatch(cleanText);
    }

    // Jika lebih panjang, gunakan boundary standar dengan opsional akhiran
    final regex = RegExp(
      r'\b' + RegExp.escape(cleanKeyword) + r'(nya|ku|mu|an)?\b',
    );
    if (regex.hasMatch(cleanText)) return true;

    // Fallback pencocokan substring jika merupakan kata majemuk atau berimbuhan lain
    return cleanText.contains(cleanKeyword);
  }

  double? _extractAmountLocally(String text) {
    double totalAmount = 0;
    bool foundAny = false;

    // 1. Cocokkan angka dengan multiplier (e.g., 500k, 1.5jt, 12ribu, rp 500k, 800 k)
    final multiplierRegex = RegExp(
      r'(\d+[\.,]?\d*)\s*(rb|ribu|k|jt|juta)\b',
      caseSensitive: false,
    );
    final multiMatches = multiplierRegex.allMatches(text);

    final List<int> matchedIndices = [];

    for (final match in multiMatches) {
      final numStr = match
          .group(1)!
          .replaceAll(',', '.'); // perlakukan koma sebagai titik desimal
      final unit = match.group(2)!.toLowerCase();
      final val = double.tryParse(numStr);
      if (val != null) {
        double multiplier = 1000;
        if (unit == 'jt' || unit == 'juta') {
          multiplier = 1000000;
        }
        totalAmount += val * multiplier;
        foundAny = true;

        for (int i = match.start; i < match.end; i++) {
          matchedIndices.add(i);
        }
      }
    }

    // 2. Cocokkan angka dengan prefix RP/IDR (e.g. rp 6.500, rp. 6.500, rp6500)
    final rpRegex = RegExp(
      r'(?:rp\.?|idr)\s*(\d+(?:[\.,]\d+)*)',
      caseSensitive: false,
    );
    final rpMatches = rpRegex.allMatches(text);
    for (final match in rpMatches) {
      bool overlap = false;
      for (int i = match.start; i < match.end; i++) {
        if (matchedIndices.contains(i)) {
          overlap = true;
          break;
        }
      }
      if (overlap) continue;

      // Hapus pemisah ribuan titik/koma
      final numStr = match.group(1)!.replaceAll(RegExp(r'[\.,]'), '');
      final val = double.tryParse(numStr);
      if (val != null) {
        totalAmount += val;
        foundAny = true;
        for (int i = match.start; i < match.end; i++) {
          matchedIndices.add(i);
        }
      }
    }

    // 3. Standalone angka berdurasi 3 digit atau lebih (e.g. 12000, 6500, 800000)
    final standaloneRegex = RegExp(r'\b\d+(?:[\.,]\d+)*\b');
    final standaloneMatches = standaloneRegex.allMatches(text);
    for (final match in standaloneMatches) {
      bool overlap = false;
      for (int i = match.start; i < match.end; i++) {
        if (matchedIndices.contains(i)) {
          overlap = true;
          break;
        }
      }
      if (overlap) continue;

      final rawStr = match.group(0)!;
      final numStr = rawStr.replaceAll(RegExp(r'[\.,]'), '');
      final val = double.tryParse(numStr);
      if (val != null && val >= 100) {
        // Hindari pencocokan tahun (2020-2030)
        if (val >= 2020 &&
            val <= 2030 &&
            !text.contains(RegExp(r'(tahun|thn)\s*' + rawStr))) {
          continue;
        }
        totalAmount += val;
        foundAny = true;
      }
    }

    return foundAny ? totalAmount : null;
  }

  String _extractCategoryLocally(String text) {
    final drinksKeywords = [
      'minum',
      'air',
      'air putih',
      'air mineral',
      'susu',
      'kopi',
      'teh',
      'jus',
      'es',
      'bir',
      'coffee',
      'boba',
      'soda',
      'coca',
      'fanta',
      'sprite',
      'teh pucuk',
      'ice',
      'cendol',
      'dawet',
      'sirup',
      'yakult',
      'aqua',
      'le minerale',
      'vit',
      'juice',
      'beer',
    ];

    final foodKeywords = [
      'makan',
      'nasi',
      'roti',
      'gandum',
      'kue',
      'keripik',
      'kripik',
      'lauk',
      'biskuit',
      'bakso',
      'mie',
      'sate',
      'cemilan',
      'snack',
      'gorengan',
      'donat',
      'pizza',
      'burger',
      'ayam',
      'daging',
      'ikan',
      'sayur',
      'pecel',
      'soto',
      'rawon',
      'seblak',
      'cilok',
      'bread',
      'cake',
      'biscuit',
      'rice',
      'chips',
    ];

    final perlengkapanRumahKeywords = [
      'kasur',
      'lemari',
      'meja',
      'kursi',
      'lampu',
      'ac',
      'kulkas',
      'mesin cuci',
      'kipas angin',
      'blender',
      'kompor',
      'rice cooker',
      'sofa',
      'tv',
      'televisi',
      'cermin',
      'rak',
      'oven',
      'kipas',
      'gorden',
      'sprei',
      'bantal',
      'sapu',
      'pel',
      'jemuran',
      'bed',
      'wardrobe',
      'table',
      'chair',
      'refrigerator',
      'fridge',
      'washing machine',
      'stove',
    ];

    final perawatanRumahKeywords = [
      'renovasi',
      'semen',
      'cat tembok',
      'genteng',
      'pipa',
      'keran',
      'paku',
      'palu',
      'bor',
      'perkakas',
      'ledeng',
      'sedot wc',
      'service ac',
      'servis ac',
      'perbaikan rumah',
      'tukang',
      'pasang wifi',
      'kunci',
      'gembok',
      'kuas',
      'kabel',
      'cement',
      'paint',
      'tile',
      'pipe',
      'tap',
      'hammer',
      'tool',
      'plumbing',
      'technician',
    ];

    final kebutuhanRumahKeywords = [
      'sabun',
      'sampo',
      'pasta gigi',
      'odol',
      'deterjen',
      'pewangi',
      'tisu',
      'tissue',
      'minyak goreng',
      'beras',
      'gula',
      'garam',
      'bumbu',
      'kecap',
      'saus',
      'popok',
      'pampers',
      'pembersih lantai',
      'sikat',
      'gas elpiji',
      'gas lpg',
      'sembako',
      'shampoo',
      'toothpaste',
      'diaper',
    ];

    final kendaraanKeywords = [
      'servis motor',
      'servis mobil',
      'ganti oli',
      'ban motor',
      'ban mobil',
      'helm',
      'bensin',
      'pertamax',
      'pertalite',
      'solar',
      'shell',
      'parkir',
      'cuci motor',
      'cuci mobil',
      'knalpot',
      'aki',
      'ojek',
      'taxi',
      'taksi',
      'mobil',
      'motor',
      'fuel',
      'gasoline',
      'engine oil',
      'tire',
      'helmet',
      'car wash',
    ];

    final olahragaKeywords = [
      'gym',
      'fitness',
      'sewa lapangan',
      'futsal',
      'badminton',
      'raket',
      'bola',
      'sepatu olahraga',
      'jersey',
      'sepeda',
      'kacamata renang',
      'kolam renang',
      'running',
      'lari',
      'workout',
      'sports',
      'soccer',
      'racket',
      'bicycle',
    ];

    final liburanKeywords = [
      'hotel',
      'villa',
      'staycation',
      'tiket pesawat',
      'tiket kereta',
      'travel',
      'pantai',
      'wisata',
      'paspor',
      'koper',
      'sewa mobil',
      'sewa motor',
      'tiket masuk',
      'camping',
      'kemping',
      'wahana',
      'dufan',
      'vacation',
      'holiday',
      'beach',
      'tourism',
      'passport',
      'suitcase',
      'bali',
      'tiket',
      'pesawat',
      'rekreasi',
      'jalan-jalan',
      'jalan jalan',
      'trip',
    ];

    final pakaianKeywords = [
      'baju',
      'kaos',
      'celana',
      'kemeja',
      'jaket',
      'sepatu',
      'sandal',
      'kaos kaki',
      'topi',
      'tas',
      'dompet',
      'jam tangan',
      'kacamata',
      'kalung',
      'cincin',
      'ikat pinggang',
      'sabuk',
      'gaun',
      'rok',
      'shirt',
      'pants',
      'shoes',
      'sandals',
      'hat',
      'bag',
      'watch',
      'glasses',
    ];

    final entertainmentKeywords = [
      'bioskop',
      'nonton',
      'film',
      'karaoke',
      'game',
      'main game',
      'konser',
      'tiket bioskop',
      'topup game',
      'steam',
      'playstation',
      'ps5',
      'ps4',
      'cinema',
      'movie',
    ];

    final subscriptionKeywords = [
      'langganan',
      'subscription',
      'bulanan netflix',
      'bulanan spotify',
      'iuran',
      'membership',
      'gym bulanan',
      'streaming',
      'netflix',
      'spotify',
      'youtube premium',
      'disneyland',
      'disney+',
    ];

    final billingKeywords = [
      'listrik',
      'air',
      'pdam',
      'pulsa',
      'kuota',
      'data',
      'wifi',
      'indome',
      'indohome',
      'indihome',
      'bpjs',
      'bills',
      'electricity',
      'water',
      'internet',
    ];

    final topupKeywords = [
      'topup',
      'top up',
      'isi saldo',
      'gopay',
      'ovo',
      'dana',
      'linkaja',
      'shopeepay',
      'e-money',
      'emoney',
      'flazz',
      'wallet',
    ];

    final transferKeywords = ['transfer', 'tf', 'kirim uang', 'kirim saldo'];

    final salaryKeywords = ['gaji', 'salary', 'upah', 'pay'];

    final bonusKeywords = ['bonus', 'komisi', 'cashback', 'refund', 'reward'];

    final investmentKeywords = [
      'investasi',
      'saham',
      'crypto',
      'reksadana',
      'emas',
      'obligasi',
      'investment',
    ];

    final loanKeywords = ['pinjaman', 'hutang', 'utang', 'loan', 'debt'];

    for (var key in drinksKeywords) {
      if (_containsKeyword(text, key)) return 'Minuman';
    }
    for (var key in foodKeywords) {
      if (_containsKeyword(text, key)) return 'Makanan';
    }
    for (var key in perlengkapanRumahKeywords) {
      if (_containsKeyword(text, key)) return 'Perlengkapan Rumah';
    }
    for (var key in perawatanRumahKeywords) {
      if (_containsKeyword(text, key)) return 'Perawatan Rumah';
    }
    for (var key in kebutuhanRumahKeywords) {
      if (_containsKeyword(text, key)) return 'Kebutuhan Rumah';
    }
    for (var key in kendaraanKeywords) {
      if (_containsKeyword(text, key)) return 'Kendaraan';
    }
    for (var key in olahragaKeywords) {
      if (_containsKeyword(text, key)) return 'Olahraga';
    }
    for (var key in liburanKeywords) {
      if (_containsKeyword(text, key)) return 'Liburan';
    }
    for (var key in pakaianKeywords) {
      if (_containsKeyword(text, key)) return 'Pakaian & Aksesoris';
    }
    for (var key in subscriptionKeywords) {
      if (_containsKeyword(text, key)) return 'Langganan';
    }
    for (var key in billingKeywords) {
      if (_containsKeyword(text, key)) return 'Tagihan';
    }
    for (var key in topupKeywords) {
      if (_containsKeyword(text, key)) return 'Top Up';
    }
    for (var key in transferKeywords) {
      if (_containsKeyword(text, key)) return 'Transfer';
    }
    for (var key in salaryKeywords) {
      if (_containsKeyword(text, key)) return 'Gaji';
    }
    for (var key in bonusKeywords) {
      if (_containsKeyword(text, key)) return 'Bonus';
    }
    for (var key in investmentKeywords) {
      if (_containsKeyword(text, key)) return 'Investasi';
    }
    for (var key in loanKeywords) {
      if (_containsKeyword(text, key)) return 'Pinjaman';
    }
    for (var key in entertainmentKeywords) {
      if (_containsKeyword(text, key)) return 'Hiburan';
    }

    return 'Lainnya';
  }
}
