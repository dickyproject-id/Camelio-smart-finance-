import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_finance_app/core/constants/app_colors.dart';
import 'package:smart_finance_app/providers/transaction_provider.dart';
import 'package:smart_finance_app/providers/settings_provider.dart';
import 'package:smart_finance_app/ui/widgets/transaction_card.dart';
import 'package:smart_finance_app/ui/pages/transaction/transaction_list_page.dart';
import 'package:smart_finance_app/ui/widgets/custom_popup.dart';

class RecentTransactions extends StatelessWidget {
  const RecentTransactions({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              settings.translate('Transaksi Terakhir', 'Recent Transactions'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TransactionListPage(),
                  ),
                );
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    settings.translate('Lihat Semua', 'See All'),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.primary,
                    size: 16,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        Consumer<TransactionProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.transactions.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Text(
                  settings.translate(
                    'Belum ada transaksi.\nYuk, catat keuangan pertamamu!',
                    'No transactions yet.\nLet\'s record your first finance!',
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              );
            }

            final recentList = provider.transactions.take(7).toList();

            return Column(
              children: recentList.map((tx) {
                // --- FITUR BARU: SWIPE TO DELETE ---
                return Dismissible(
                  // Key wajib ada agar Flutter tahu item mana spesifik yang sedang diusap
                  key: Key(tx.id ?? tx.hashCode.toString()),

                  // Hanya izinkan usap dari kanan ke kiri
                  direction: DismissDirection.endToStart,

                  // Latar belakang merah & ikon tempat sampah yang muncul saat diusap
                  background: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 4.0,
                    ), // Sesuaikan jarak antar card
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    decoration: BoxDecoration(
                      color: Colors.red.shade400,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.centerRight,
                    child: const Icon(
                      Icons.delete_sweep,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),

                  // Fungsi Pop-Up Peringatan sebelum dihapus
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: Row(
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                settings.translate(
                                  'Hapus Transaksi?',
                                  'Delete Transaction?',
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          content: Text(
                            settings.translate(
                              'Yakin ingin menghapus data transaksi ini?\nSaldo Anda akan otomatis disesuaikan ulang.',
                              'Are you sure you want to delete this transaction?\nYour balance will be automatically adjusted.',
                            ),
                            style: const TextStyle(height: 1.5),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text(
                                settings.translate('Batal', 'Cancel'),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () => Navigator.of(context).pop(true),
                              child: Text(
                                settings.translate('Hapus', 'Delete'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },

                  // Eksekusi penghapusan ke Firebase kalau Pop-Up di-klik "Hapus"
                  onDismissed: (direction) async {
                    if (tx.id != null) {
                      try {
                        // Memanggil fungsi delete di provider lo
                        await provider.deleteTransaction(tx);

                        if (context.mounted) {
                          CustomPopup.show(
                            context: context,
                            title: settings.translate('Berhasil', 'Success'),
                            message: settings.translate(
                              'Transaksi berhasil dihapus ✨',
                              'Transaction deleted successfully ✨',
                            ),
                            isSuccess: true,
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          CustomPopup.show(
                            context: context,
                            title: settings.translate('Gagal', 'Failed'),
                            message: settings.translate(
                              'Gagal menghapus transaksi.',
                              'Failed to delete transaction.',
                            ),
                            isSuccess: false,
                          );
                        }
                      }
                    }
                  },

                  // Card UI asli lo dibungkus di dalam sini
                  child: TransactionCardListTile(transaction: tx),
                );
                // -----------------------------------
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
