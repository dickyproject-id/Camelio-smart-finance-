import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/settings_provider.dart';
import 'package:provider/provider.dart';

class HelpFAQPage extends StatefulWidget {
  const HelpFAQPage({super.key});

  @override
  State<HelpFAQPage> createState() => _HelpFAQPageState();
}

class _HelpFAQPageState extends State<HelpFAQPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.watch<SettingsProvider>().translate(
            'Bantuan & FAQ',
            'Help & FAQ',
          ),
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
            _buildFAQItem(
              context.watch<SettingsProvider>().translate(
                'Bagaimana cara memindai struk?',
                'How do I scan a receipt?',
              ),
              context.watch<SettingsProvider>().translate(
                'Ketuk tombol "+" di layar beranda dan pilih "Pindai Struk". Arahkan kamera Anda ke struk dan tunggu AI memprosesnya.',
                'Tap the "+" button on the home screen and select "Scan Struk". Point your camera at the receipt and wait for the AI to process it.',
              ),
            ),
            _buildFAQItem(
              context.watch<SettingsProvider>().translate(
                'Apakah data saya aman?',
                'Is my data safe?',
              ),
              context.watch<SettingsProvider>().translate(
                'Ya, kami menggunakan enkripsi standar industri dan keamanan Firebase untuk memastikan data keuangan Anda hanya dapat diakses oleh Anda.',
                'Yes, we use industry-standard encryption and Firebase security to ensure your financial data is only accessible by you.',
              ),
            ),
            _buildFAQItem(
              context.watch<SettingsProvider>().translate(
                'Bagaimana cara sinkronisasi Gmail?',
                'How do I sync Gmail?',
              ),
              context.watch<SettingsProvider>().translate(
                '1. Buka menu "Dompet" > "Tambah Dompet".\n2. Klik "Hubungkan dengan Gmail".\n3. Pilih akun Google Anda.\n4. Jika muncul peringatan "Google belum memverifikasi aplikasi ini", klik "Lanjutan" lalu pilih "Buka Camelio (tidak aman)" untuk memberikan izin.',
                '1. Go to "Wallet" > "Add Wallet".\n2. Click "Connect with Gmail".\n3. Select your Google account.\n4. If an "App not verified" warning appears, click "Advanced" then select "Go to Camelio (unsafe)" to grant permission.',
              ),
            ),
            _buildFAQItem(
              context.watch<SettingsProvider>().translate(
                'Kenapa muncul "Aplikasi belum diverifikasi"?',
                'Why "App not verified" appears?',
              ),
              context.watch<SettingsProvider>().translate(
                'Ini terjadi karena aplikasi Camelio sedang dalam tahap pengembangan skripsi dan belum didaftarkan secara publik ke Google. Data Anda tetap aman dan enkripsi tetap berjalan secara lokal di perangkat Anda.',
                'This happens because the Camelio app is in the thesis development stage and has not been publicly registered with Google. Your data remains safe and encryption still runs locally on your device.',
              ),
            ),
            _buildFAQItem(
              context.watch<SettingsProvider>().translate(
                'Platform apa saja yang didukung?',
                'Which platforms are supported?',
              ),
              context.watch<SettingsProvider>().translate(
                'Camelio mendukung otomatisasi untuk Bank (BCA, Mandiri, BNI, dll), E-Wallet (GoPay, OVO, ShopeePay, Dana), dan Marketplace (Tokopedia, Shopee).',
                'Camelio supports automation for Banks (BCA, Mandiri, BNI, etc.), E-Wallets (GoPay, OVO, ShopeePay, Dana), and Marketplaces (Tokopedia, Shopee).',
              ),
            ),
            _buildFAQItem(
              context.watch<SettingsProvider>().translate(
                'Bisakah saya mengekspor laporan?',
                'Can I export my reports?',
              ),
              context.watch<SettingsProvider>().translate(
                'Ya, Anda dapat mengekspor laporan keuangan dalam format PDF. Caranya, buka Menu Drawer (ikon profil) > Alat & Laporan > Export PDF Laporan.',
                'Yes, you can export financial reports in PDF format. To do this, open the Drawer Menu (profile icon) > Tools & Reports > Export PDF Report.',
              ),
            ),
            _buildFAQItem(
              context.watch<SettingsProvider>().translate(
                'Bagaimana cara melihat foto profil?',
                'How do I view my profile photo?',
              ),
              context.watch<SettingsProvider>().translate(
                'Tekan lama (hold) pada foto profil Anda di pojok kiri atas layar Beranda atau di dalam Sidebar. Foto akan muncul secara penuh dan bisa di-zoom.',
                'Long press (hold) on your profile photo in the top left corner of the Home screen or inside the Sidebar. The photo will appear in full size and can be zoomed.',
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: Text(
                context.watch<SettingsProvider>().translate(
                  'Masih butuh bantuan?',
                  'Still need help?',
                ),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.email_outlined, color: Colors.white),
              label: Text(
                context.watch<SettingsProvider>().translate(
                  'Hubungi Dukungan',
                  'Contact Support',
                ),
                style: const TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            answer,
            style: const TextStyle(color: Colors.grey, height: 1.5),
          ),
        ),
      ],
    );
  }
}
