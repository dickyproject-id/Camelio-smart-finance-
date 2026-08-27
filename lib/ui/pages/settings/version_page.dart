import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../providers/settings_provider.dart';
import 'package:provider/provider.dart';

class VersionHistoryPage extends StatefulWidget {
  const VersionHistoryPage({super.key});

  @override
  State<VersionHistoryPage> createState() => _VersionHistoryPageState();
}

class _VersionHistoryPageState extends State<VersionHistoryPage> {
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          settings.translate('Versi Aplikasi', 'App Version'),
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
          _buildVersionItem(
            context,
            version: 'v${AppConstants.appVersion}',
            date: 'June 23, 2026 (Latest)',
            isLatest: true,
            changes: [
              settings.translate(
                'Peningkatan: Sinkronisasi Mode Akun (Pribadi/Bisnis) ke Firebase Firestore secara real-time.',
                'Improved: Sync Account Mode (Personal/Business) to Firebase Firestore in real-time.',
              ),
              settings.translate(
                'Peningkatan: Penambahan menu dropdown pilihan tipe akun pada halaman Registrasi awal.',
                'Improved: Added account type selection dropdown on the initial Registration page.',
              ),
              settings.translate(
                'Peningkatan: Pemindahan opsi pergantian Tipe Akun dari menu Pengaturan ke menu Edit Profil untuk pengalaman yang lebih terpusat.',
                'Improved: Moved Account Type toggle from Settings to Edit Profile menu for a centralized experience.',
              ),
              settings.translate(
                'Perbaikan: Teks instruksi internal pada AI (Prompt) diubah sepenuhnya dari UMKM menjadi Bisnis yang lebih umum.',
                'Fixed: AI internal instruction text (Prompt) changed entirely from UMKM to a more generic Business.',
              ),
              settings.translate(
                'Pembersihan: Tombol "Perbarui Analisis" dihapus untuk memastikan AI memuat ulang secara otomatis ketika ada transaksi baru saja.',
                'Cleanup: Removed "Refresh Insight" button to ensure AI automatically reloads only when there is a new transaction.',
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildVersionItem(
            context,
            version: 'v1.0.6',
            date: 'May 20, 2026',
            changes: [
              settings.translate(
                'Baru: Peningkatan Chat AI dengan penjumlahan otomatis beberapa nominal sekaligus (multi-item).',
                'New: Chat AI enhancement supporting automatic summing of multiple amounts (multi-item).',
              ),
              settings.translate(
                'Baru: Parser lokal untuk nominal desimal desimal (misal 1.5jt) dan nominal mata uang (misal rp 6.500).',
                'New: Local parser for decimal amounts (e.g. 1.5M) and currency formatting (e.g. rp 6.500).',
              ),
              settings.translate(
                'Peningkatan: Akurasi pemrosesan kategori lokal dengan regex batas kata (strict word boundaries) untuk mencegah salah pencocokan kata pendek.',
                'Improved: Local category parsing accuracy using strict word boundaries to avoid false matching short keywords.',
              ),
              settings.translate(
                'Perbaikan: Pembersihan tombol uji coba notifikasi (ikon biru) di halaman notifikasi.',
                'Fixed: Removed test notification button (blue icon) in the notifications page.',
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildVersionItem(
            context,
            version: 'v1.0.5',
            date: 'May 14, 2026',
            changes: [
              settings.translate(
                'Baru: Integrasi Notifikasi Sistem (Tray) untuk sinkronisasi & peringatan.',
                'New: System Notification (Tray) integration for sync & alerts.',
              ),
              settings.translate(
                'Baru: Deteksi otomatis tipe dompet (Marketplace, E-Wallet, Bank) berdasarkan nama.',
                'New: Automatic wallet type detection (Marketplace, E-Wallet, Bank) based on name.',
              ),
              settings.translate(
                'Baru: Ekspor PDF kini terintegrasi langsung dengan fitur Berbagi (Share) ke media sosial.',
                'New: PDF Export now integrates directly with Social Media Sharing.',
              ),
              settings.translate(
                'Peningkatan: Penataan ulang Drawer yang lebih rapi & navigasi terpusat.',
                'Improved: Cleaner Drawer layout & centralized navigation.',
              ),
              settings.translate(
                'Perbaikan: Sinkronisasi sakelar notifikasi pada drawer & integritas hapus dompet.',
                'Fixed: Notification switch sync in drawer & wallet deletion integrity.',
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildVersionItem(
            context,
            version: 'v1.0.4',
            date: 'May 12, 2026',
            changes: [
              settings.translate(
                'Baru: Integrasi Gmail API untuk sinkronisasi otomatis transaksi dompet.',
                'New: Gmail API integration for automatic wallet transaction sync.',
              ),
              settings.translate(
                'Baru: Redesain detail E-Wallet dengan filter (Semua, Pemasukan, Pengeluaran).',
                'New: E-Wallet detail redesign with filters (All, Income, Expense).',
              ),
              settings.translate(
                'Baru: Fitur edit saldo manual dan visibilitas saldo (ikon mata) di detail dompet.',
                'New: Manual balance edit and visibility toggle (eye icon) in wallet details.',
              ),
              settings.translate(
                'Peningkatan: Unifikasi Google Sign-In untuk stabilitas sesi login dan logout.',
                'Improved: Unified Google Sign-In for stable login and logout sessions.',
              ),
              settings.translate(
                'Peningkatan: Header halaman E-Wallet dan Transaksi kini selaras dengan gaya Portofolio.',
                'Improved: E-Wallet and Transaction headers now match Portfolio style.',
              ),
              settings.translate(
                'Perbaikan: Pembersihan antarmuka detail dompet dengan menghapus fitur redundan.',
                'Fixed: Wallet detail interface cleanup by removing redundant features.',
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildVersionItem(
            context,
            version: 'v1.0.3',
            date: 'May 8, 2026',
            changes: [
              settings.translate(
                'Perbaikan: Tampilan Splash Screen yang lebih stabil & kontras.',
                'Fixed: More stable & high-contrast Splash Screen display.',
              ),
              settings.translate(
                'Perbaikan: Alur Logout yang langsung mengarah ke halaman login.',
                'Fixed: Logout flow that explicitly redirects to login page.',
              ),
              settings.translate(
                'Peningkatan: Sinkronisasi bahasa kategori (ID/EN) dua arah secara real-time.',
                'Improved: Bidirectional real-time category language sync (ID/EN).',
              ),
              settings.translate(
                'Peningkatan: Akurasi AI dalam mendeteksi kategori sesuai bahasa pilihan.',
                'Improved: AI accuracy in detecting categories based on selected language.',
              ),
              settings.translate(
                'Pembersihan: Penghapusan tombol navigasi manual pada riwayat transaksi.',
                'Cleanup: Removed manual navigation buttons on transaction history.',
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildVersionItem(
            context,
            version: 'v1.0.2',
            date: 'May 4, 2026',
            changes: [
              settings.translate(
                'Baru: Grafik Pie Chart untuk distribusi pengeluaran di Portofolio.',
                'New: Pie Chart for expense distribution in Portfolio.',
              ),
              settings.translate(
                'Baru: Sinkronisasi izin perangkat (Kamera, Foto, Gmail) yang aktif.',
                'New: Active device permissions sync (Camera, Photos, Gmail).',
              ),
              settings.translate(
                'Baru: Pengaturan terintegrasi di dalam sidebar drawer.',
                'New: Unified settings within the sidebar drawer.',
              ),
              settings.translate(
                'Baru: Halaman khusus untuk Privasi, Izin, dan Bantuan.',
                'New: Dedicated pages for Privacy, Permissions, and Help.',
              ),
              settings.translate(
                'Baru: UI kotak modern untuk semua item menu drawer.',
                'New: Modern boxed UI for all drawer menu items.',
              ),
              settings.translate(
                'Peningkatan: Standarisasi tombol navigasi kembali (iOS Style).',
                'Improved: Standardized back navigation buttons (iOS Style).',
              ),
              settings.translate(
                'Peningkatan: Penyelarasan teks dan jarak pada splash screen.',
                'Improved: Splash screen text alignment and spacing.',
              ),
              settings.translate(
                'Peningkatan: Efek klik visual pada semua tombol.',
                'Improved: Visual click (ripple) effects on all buttons.',
              ),
              settings.translate(
                'Perbaikan: Perilaku input pelacak anggaran.',
                'Fixed: Budget tracker input behavior.',
              ),
              settings.translate(
                'Perbaikan: Masalah izin pengiriman rating.',
                'Fixed: Rating submission permission issues.',
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildVersionItem(
            context,
            version: 'v1.0.1',
            date: 'April 30, 2026',
            changes: [
              settings.translate(
                'Baru: Fitur pemindaian struk berbasis AI.',
                'New: AI-powered receipt scanning feature.',
              ),
              settings.translate(
                'Baru: Ikhtisar portofolio dashboard dengan grafik.',
                'New: Dashboard portfolio overview with charts.',
              ),
              settings.translate(
                'Peningkatan: Kelancaran transisi mode gelap.',
                'Improved: Dark mode transition smoothness.',
              ),
              settings.translate(
                'Perbaikan: Keandalan unggahan foto profil.',
                'Fixed: Profile picture upload reliability.',
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildVersionItem(
            context,
            version: 'v1.0.0',
            date: 'April 20, 2026',
            changes: [
              settings.translate(
                'Rilis awal aplikasi Camelio Finance.',
                'Initial release of Camelio Finance app.',
              ),
              settings.translate(
                'Pelacakan pengeluaran dan pemasukan inti.',
                'Core expense and income tracking.',
              ),
              settings.translate(
                'Autentikasi pengguna dengan Google & Email.',
                'User authentication with Google & Email.',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVersionItem(
    BuildContext context, {
    required String version,
    required String date,
    required List<String> changes,
    bool isLatest = false,
  }) {
    final settings = context.read<SettingsProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              version,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(width: 8),
            if (isLatest)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  settings.translate('TERBARU', 'LATEST'),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const Spacer(),
            Text(
              date,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...changes.map(
          (change) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '• ',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: Text(
                    change,
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
