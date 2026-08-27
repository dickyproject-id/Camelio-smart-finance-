import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/transaction_model.dart';
import '../../providers/settings_provider.dart';
import '../../providers/e_wallet_provider.dart';
import '../../core/utils/brand_utils.dart';

class TransactionCardListTile extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionCardListTile({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isExpense = transaction.type == 'expense';

    // Format mata uang Rupiah
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final amountText =
        '${isExpense ? '-' : '+'}${formatCurrency.format(transaction.amount)}';

    // Format Tanggal
    final dateText = DateFormat('dd MMM yyyy, HH:mm').format(transaction.date);

    return InkWell(
      onTap: () {
        if (transaction.items != null && transaction.items!.isNotEmpty) {
          _showItemsBottomSheet(context);
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16, top: 8, left: 8, right: 8),
        child: Row(
          children: [
            _buildTransactionIcon(context, isExpense),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Consumer<EWalletProvider>(
                    builder: (context, walletProvider, _) {
                      final wallet = walletProvider.wallets
                          .where((w) => w.id == transaction.walletId)
                          .firstOrNull;
                      final walletName = wallet?.name ?? '';
                      final sourceText = transaction.source == 'gmail'
                          ? 'Gmail'
                          : (transaction.source == 'ai' ? 'AI' : '');

                      return Text(
                        '${settings.translateCategory(transaction.category)}${walletName.isNotEmpty ? " • $walletName" : ""}${sourceText.isNotEmpty ? " ($sourceText)" : ""} • $dateText',
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      );
                    },
                  ),
                ],
              ),
            ),
            Text(
              amountText,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isExpense ? Colors.red : Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showItemsBottomSheet(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final formatCurrency = NumberFormat.currency(
          locale: 'id_ID',
          symbol: 'Rp ',
          decimalDigits: 0,
        );

        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                settings.translate('Detail Barang Bawaan', 'Item Details'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: transaction.items!.length,
                  itemBuilder: (context, index) {
                    final item = transaction.items![index];
                    final qty = item['qty'] ?? 1;

                    // Ekstrak unit price
                    String unitPriceStr =
                        (item['price_unit'] ?? item['price'] ?? 0)
                            .toString()
                            .replaceAll(RegExp(r'[^\d-]'), '');
                    double unitPrice = double.tryParse(unitPriceStr) ?? 0.0;

                    // Ekstrak line total
                    String lineTotalStr = (item['line_total'] ?? 0)
                        .toString()
                        .replaceAll(RegExp(r'[^\d-]'), '');
                    double lineTotal = double.tryParse(lineTotalStr) ?? 0.0;

                    if (lineTotal == 0) {
                      lineTotal = unitPrice * double.parse(qty.toString());
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['name'] ??
                                      settings.translate('Barang', 'Item'),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: Theme.of(
                                      context,
                                    ).textTheme.titleLarge?.color,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$qty x ${formatCurrency.format(unitPrice)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            formatCurrency.format(lineTotal),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(
                  settings.translate('Tutup', 'Close'),
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
  }

  Widget _buildTransactionIcon(BuildContext context, bool isExpense) {
    final desc = transaction.description.toLowerCase();
    final walletProvider = Provider.of<EWalletProvider>(context, listen: false);
    final wallet = walletProvider.wallets
        .where((w) => w.id == transaction.walletId)
        .firstOrNull;
    final walletName = wallet?.name.toLowerCase() ?? '';

    final isSystemTransaction =
        desc.contains('transfer') ||
        desc.contains('saldo awal') ||
        desc.contains('penyesuaian');

    // 1. Coba cari icon brand dari deskripsi (misal "Starbucks", "Gojek")
    String? assetPath = BrandUtils.getAssetPath(desc);

    // 2. Jika ini adalah transaksi sistem, DAN tidak ada icon dari deskripsi, coba ambil dari nama wallet
    if (assetPath == null && isSystemTransaction) {
      assetPath = BrandUtils.getAssetPath(walletName);
    }

    if (assetPath != null) {
      return BrandUtils.getBrandIcon(assetPath, size: 48, isExpense: isExpense);
    }

    // Icon kategori standar dengan background berwarna (seperti Minuman/Rumah)
    return Container(
      width: 48,
      height: 48,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: !isExpense
            ? Colors.green.withValues(alpha: 0.15)
            : _getCategoryColor(transaction.category),
        shape: BoxShape.circle,
      ),
      child: Icon(
        !isExpense
            ? Icons.arrow_upward_rounded
            : _getCategoryIcon(transaction.category),
        color: !isExpense ? Colors.green : Colors.white,
        size: 24,
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('makanan')) return Icons.restaurant_rounded;
    if (cat.contains('minuman')) return Icons.local_cafe_rounded;
    if (cat.contains('transport') || cat.contains('bensin'))
      return Icons.directions_car_rounded;
    if (cat.contains('belanja') || cat.contains('shopping'))
      return Icons.shopping_bag_rounded;
    if (cat.contains('top up') || cat.contains('wallet'))
      return Icons.account_balance_wallet_rounded;
    if (cat.contains('gaji') || cat.contains('bonus'))
      return Icons.payments_rounded;
    if (cat.contains('tagihan') || cat.contains('listrik'))
      return Icons.receipt_long_rounded;
    if (cat.contains('internet') ||
        cat.contains('kuota') ||
        cat.contains('data'))
      return Icons.wifi_rounded;
    if (cat.contains('langganan')) return Icons.autorenew_rounded;
    if (cat.contains('hiburan')) return Icons.confirmation_number_rounded;
    if (cat.contains('transfer')) return Icons.swap_horiz_rounded;
    if (cat.contains('elektronik') || cat.contains('gadget'))
      return Icons.devices_other_rounded;
    if (cat.contains('kesehatan') || cat.contains('obat'))
      return Icons.medical_services_rounded;
    if (cat.contains('pendidikan') || cat.contains('sekolah'))
      return Icons.school_rounded;
    if (cat.contains('perlengkapan rumah') || cat.contains('home equipment'))
      return Icons.weekend_rounded;
    if (cat.contains('perawatan rumah') || cat.contains('home maintenance'))
      return Icons.handyman_rounded;
    if (cat.contains('kebutuhan rumah') ||
        cat.contains('household') ||
        cat.contains('home'))
      return Icons.home_work_rounded;
    if (cat.contains('kendaraan') || cat.contains('vehicle'))
      return Icons.directions_car_filled_rounded;
    if (cat.contains('olahraga') || cat.contains('sports'))
      return Icons.fitness_center_rounded;
    if (cat.contains('liburan') ||
        cat.contains('vacation') ||
        cat.contains('holiday'))
      return Icons.beach_access_rounded;
    if (cat.contains('pakaian') ||
        cat.contains('clothing') ||
        cat.contains('clothes'))
      return Icons.checkroom_rounded;
    if (cat.contains('investasi')) return Icons.trending_up_rounded;
    if (cat.contains('pinjaman') || cat.contains('hutang'))
      return Icons.monetization_on_rounded;
    return Icons.category_rounded;
  }

  Color _getCategoryColor(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('makanan')) return const Color(0xFFFF9800); // Orange
    if (cat.contains('minuman')) return const Color(0xFF03A9F4); // Light Blue
    if (cat.contains('transport') || cat.contains('bensin'))
      return const Color(0xFF9C27B0); // Purple
    if (cat.contains('belanja') || cat.contains('shopping'))
      return const Color(0xFFE91E63); // Pink
    if (cat.contains('tagihan') || cat.contains('listrik'))
      return const Color(0xFF607D8B); // Blue Grey
    if (cat.contains('langganan')) return const Color(0xFF3F51B5); // Indigo
    if (cat.contains('gaji') || cat.contains('bonus'))
      return const Color(0xFF4CAF50); // Green
    if (cat.contains('hiburan')) return const Color(0xFFFFC107); // Amber
    if (cat.contains('transfer')) return const Color(0xFF009688); // Teal
    if (cat.contains('elektronik')) return const Color(0xFF795548); // Brown
    if (cat.contains('kesehatan')) return const Color(0xFFF44336); // Red
    if (cat.contains('pendidikan')) return const Color(0xFF2196F3); // Blue
    if (cat.contains('perlengkapan rumah') || cat.contains('home equipment'))
      return const Color(0xFFE040FB); // Violet/Magenta
    if (cat.contains('perawatan rumah') || cat.contains('home maintenance'))
      return const Color(0xFF8D6E63); // Brown
    if (cat.contains('kebutuhan rumah') ||
        cat.contains('household') ||
        cat.contains('home'))
      return const Color(0xFF8BC34A); // Light Green
    if (cat.contains('kendaraan') || cat.contains('vehicle'))
      return const Color(0xFF00E676); // Bright Green
    if (cat.contains('olahraga') || cat.contains('sports'))
      return const Color(0xFF00B0FF); // Vibrant Blue
    if (cat.contains('liburan') ||
        cat.contains('vacation') ||
        cat.contains('holiday'))
      return const Color(0xFFFF5722); // Deep Orange
    if (cat.contains('pakaian') ||
        cat.contains('clothing') ||
        cat.contains('clothes'))
      return const Color(0xFFF50057); // Deep Pink
    if (cat.contains('investasi')) return const Color(0xFF00BCD4); // Cyan
    if (cat.contains('pinjaman')) return const Color(0xFF455A64); // Dark Grey
    return Colors.grey.shade600; // Default color
  }
}
