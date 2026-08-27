import 'package:flutter/material.dart';
import '../../../providers/settings_provider.dart';
import 'package:provider/provider.dart';

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.watch<SettingsProvider>().translate(
            'Kebijakan Privasi',
            'Privacy Policy',
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
            Text(
              '${context.read<SettingsProvider>().translate('Terakhir diperbarui', 'Last updated')}: May 4, 2026',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            SizedBox(height: 24),
            Text(
              context.watch<SettingsProvider>().translate(
                '1. Pendahuluan',
                '1. Introduction',
              ),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              context.watch<SettingsProvider>().translate(
                'Selamat datang di Camelio. Kami berkomitmen untuk melindungi informasi pribadi Anda dan hak privasi Anda.',
                'Welcome to Camelio. We are committed to protecting your personal information and your right to privacy.',
              ),
              style: const TextStyle(color: Colors.grey, height: 1.5),
            ),
            SizedBox(height: 24),
            Text(
              context.watch<SettingsProvider>().translate(
                '2. Informasi yang Kami Kumpulkan',
                '2. Information We Collect',
              ),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              context.watch<SettingsProvider>().translate(
                'Kami mengumpulkan informasi pribadi yang Anda berikan kepada kami seperti nama, alamat email, dan transaksi keuangan untuk tujuan pengelolaan keuangan pribadi. Kami juga mengakses data email transaksi melalui Google API jika Anda mengaktifkan fitur sinkronisasi.',
                'We collect personal information that you provide to us such as name, email address, and financial transactions for the purpose of personal finance management. We also access transaction email data via Google API if you enable the synchronization feature.',
              ),
              style: const TextStyle(color: Colors.grey, height: 1.5),
            ),
            const SizedBox(height: 24),
            Text(
              context.watch<SettingsProvider>().translate(
                '3. Penggunaan Data Gmail',
                '3. Use of Gmail Data',
              ),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              context.watch<SettingsProvider>().translate(
                'Akses Gmail digunakan secara eksklusif untuk memindai email konfirmasi transaksi. Data ini diproses secara lokal dan melalui enkripsi sebelum dikirim ke database cloud pribadi Anda. Kami tidak membagikan isi email Anda kepada pihak ketiga mana pun.',
                'Gmail access is used exclusively to scan transaction confirmation emails. This data is processed locally and via encryption before being sent to your private cloud database. We do not share your email content with any third parties.',
              ),
              style: const TextStyle(color: Colors.grey, height: 1.5),
            ),
            const SizedBox(height: 24),
            Text(
              context.watch<SettingsProvider>().translate(
                '4. Keamanan Data',
                '4. Data Security',
              ),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              context.watch<SettingsProvider>().translate(
                'Kami menerapkan langkah-langkah keamanan teknis dan organisasi untuk melindungi data Anda dari akses yang tidak sah, kehilangan, atau kerusakan. Data Anda disimpan di server Firebase yang aman dengan enkripsi SSL/TLS.',
                'We implement technical and organizational security measures to protect your data from unauthorized access, loss, or damage. Your data is stored on secure Firebase servers with SSL/TLS encryption.',
              ),
              style: const TextStyle(color: Colors.grey, height: 1.5),
            ),
            const SizedBox(height: 24),
            Text(
              context.watch<SettingsProvider>().translate(
                '5. Hak-Hak Anda',
                '5. Your Rights',
              ),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              context.watch<SettingsProvider>().translate(
                'Anda memiliki hak untuk mengakses, memperbarui, atau menghapus informasi pribadi Anda kapan saja melalui pengaturan profil di aplikasi. Anda juga dapat mencabut akses Gmail melalui pengaturan izin perangkat atau Google Account.',
                'You have the right to access, update, or delete your personal information at any time through the profile settings in the app. You can also revoke Gmail access via device permission settings or your Google Account.',
              ),
              style: const TextStyle(color: Colors.grey, height: 1.5),
            ),
            const SizedBox(height: 24),
            Text(
              context.watch<SettingsProvider>().translate(
                '6. Retensi Data',
                '6. Data Retention',
              ),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              context.watch<SettingsProvider>().translate(
                'Kami akan menyimpan informasi pribadi Anda hanya selama diperlukan untuk tujuan yang ditetapkan dalam Kebijakan Privasi ini. Jika Anda menghapus akun, seluruh data transaksi Anda akan dihapus secara permanen dari server kami.',
                'We will retain your personal information only for as long as necessary for the purposes set out in this Privacy Policy. If you delete your account, all your transaction data will be permanently deleted from our servers.',
              ),
              style: const TextStyle(color: Colors.grey, height: 1.5),
            ),
            const SizedBox(height: 24),
            Text(
              context.watch<SettingsProvider>().translate(
                '7. Perubahan Kebijakan',
                '7. Changes to Policy',
              ),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              context.watch<SettingsProvider>().translate(
                'Kami dapat memperbarui Kebijakan Privasi kami dari waktu ke waktu. Kami akan memberi tahu Anda tentang perubahan apa pun dengan memposting Kebijakan Privasi baru di halaman ini.',
                'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page.',
              ),
              style: const TextStyle(color: Colors.grey, height: 1.5),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
