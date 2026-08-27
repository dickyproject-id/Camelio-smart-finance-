import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/transaction_provider.dart';
import '../../widgets/transaction_card.dart';
import '../../widgets/custom_popup.dart';
import '../../../providers/settings_provider.dart';

class TransactionListPage extends StatefulWidget {
  const TransactionListPage({super.key});

  @override
  State<TransactionListPage> createState() => _TransactionListPageState();
}

class _TransactionListPageState extends State<TransactionListPage> {
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    settings.translate(
                      'Riwayat Transaksi',
                      'Transaction History',
                    ),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    settings.translate(
                      'Pantau semua aktivitas keuangan Anda.',
                      'Monitor all your financial activities.',
                    ),
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer<TransactionProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (provider.transactions.isEmpty) {
                    return Center(
                      child: Text(
                        settings.translate("Belum ada data", "No data yet"),
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    itemCount: provider.transactions.length,
                    itemBuilder: (context, index) {
                      final tx = provider.transactions[index];
                      return Dismissible(
                        key: Key(tx.id ?? tx.hashCode.toString()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
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
                        confirmDismiss: (direction) async {
                          return await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              title: Text(
                                settings.translate(
                                  'Hapus Transaksi?',
                                  'Delete Transaction?',
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              content: Text(
                                settings.translate(
                                  'Yakin ingin menghapus data transaksi ini?',
                                  'Are you sure you want to delete this transaction?',
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: Text(
                                    settings.translate('Batal', 'Cancel'),
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text(
                                    settings.translate('Hapus', 'Delete'),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        onDismissed: (direction) async {
                          if (tx.id != null) {
                            try {
                              await provider.deleteTransaction(tx);
                              if (context.mounted) {
                                CustomPopup.show(
                                  context: context,
                                  title: settings.translate(
                                    'Berhasil',
                                    'Success',
                                  ),
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
                        child: TransactionCardListTile(transaction: tx),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
