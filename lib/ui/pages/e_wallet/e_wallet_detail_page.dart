import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../data/models/e_wallet_model.dart';
import '../../../data/models/transaction_model.dart';
import '../../../providers/settings_provider.dart';
import '../../../providers/transaction_provider.dart';
import '../../../providers/e_wallet_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../transaction/add_transaction_page.dart';
import '../../widgets/transaction_card.dart';

class EWalletDetailPage extends StatefulWidget {
  final EWalletModel wallet;

  const EWalletDetailPage({super.key, required this.wallet});

  @override
  State<EWalletDetailPage> createState() => _EWalletDetailPageState();
}

class _EWalletDetailPageState extends State<EWalletDetailPage> {
  bool _isBalanceVisible = true;
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final transactionProvider = context.watch<TransactionProvider>();
    final walletProvider = context.watch<EWalletProvider>();
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    final currentWallet = walletProvider.wallets.firstWhere(
      (w) => w.id == widget.wallet.id,
      orElse: () => widget.wallet,
    );

    List<TransactionModel> walletTransactions = transactionProvider.transactions
        .where((t) => t.walletId == currentWallet.id)
        .toList();

    if (_selectedFilter == 'Income') {
      walletTransactions = walletTransactions
          .where((t) => t.type == 'income')
          .toList();
    } else if (_selectedFilter == 'Expense') {
      walletTransactions = walletTransactions
          .where((t) => t.type == 'expense')
          .toList();
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              currentWallet.name,
              style: TextStyle(
                color: Theme.of(context).textTheme.titleLarge?.color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              settings.translate(
                currentWallet.type == 'banking'
                    ? 'Bank'
                    : currentWallet.type == 'e-wallet'
                    ? 'Dompet Digital'
                    : currentWallet.type == 'marketplace'
                    ? 'Toko Online'
                    : currentWallet.type == 'loan'
                    ? 'Pinjaman'
                    : currentWallet.type == 'investment'
                    ? 'Investasi'
                    : currentWallet.type.toUpperCase(),
                currentWallet.type.toUpperCase(),
              ),
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            onSelected: (value) {
              if (value == 'edit_balance') {
                _showEditBalanceDialog(
                  context,
                  currentWallet,
                  walletProvider,
                  settings,
                );
              } else if (value == 'edit_account') {
                _showEditAccountDialog(
                  context,
                  currentWallet,
                  walletProvider,
                  settings,
                );
              } else if (value == 'delete') {
                _showDeleteConfirmDialog(
                  context,
                  currentWallet,
                  walletProvider,
                  settings,
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit_balance',
                child: Row(
                  children: [
                    const Icon(Icons.edit_note_rounded, size: 20),
                    const SizedBox(width: 12),
                    Text(settings.translate('Ubah Saldo', 'Edit Balance')),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'edit_account',
                child: Row(
                  children: [
                    const Icon(Icons.credit_card_rounded, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      settings.translate('Ubah No. Akun', 'Edit Account No.'),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(
                      Icons.delete_outline_rounded,
                      size: 20,
                      color: Colors.red,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      settings.translate('Hapus Dompet', 'Delete Wallet'),
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildBalanceCard(currentWallet, currencyFormat, settings),
            const SizedBox(height: 24),
            _buildTransactionTabs(settings, walletTransactions, currencyFormat),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(
    EWalletModel wallet,
    NumberFormat currencyFormat,
    SettingsProvider settings,
  ) {
    final colors = _getWalletBranding(wallet.name);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors['gradient'] as List<Color>,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (colors['main'] as Color).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: 16,
            bottom: 16,
            child: Opacity(
              opacity: 0.15,
              child: wallet.iconUrl?.isNotEmpty == true
                  ? Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        wallet.iconUrl!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox(),
                      ),
                    )
                  : const Icon(
                      Icons.account_balance_wallet,
                      size: 80,
                      color: Colors.white,
                    ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        settings.translate('Total Saldo', 'Total Balance'),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => setState(
                          () => _isBalanceVisible = !_isBalanceVisible,
                        ),
                        child: Icon(
                          _isBalanceVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.white70,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  if (wallet.lastSyncDate != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Text(
                            settings.translate('Sinkron', 'Synced'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _isBalanceVisible
                    ? currencyFormat.format(wallet.balance)
                    : '••••••••',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    wallet.accountNumber?.isNotEmpty == true
                        ? wallet.accountNumber!
                        : 'No Account Detail',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  if (wallet.iconUrl?.isNotEmpty == true)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          wallet.iconUrl!,
                          width: 24,
                          height: 24,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const SizedBox(),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getWalletBranding(String name) {
    final n = name.toLowerCase();
    if (n.contains('shopee')) {
      return {
        'main': const Color(0xFFFF5722),
        'gradient': [const Color(0xFFFE6433), const Color(0xFFFF5722)],
      };
    }
    if (n.contains('ovo')) {
      return {
        'main': const Color(0xFF4C2A86),
        'gradient': [const Color(0xFF6B3AB7), const Color(0xFF4C2A86)],
      };
    }
    if (n.contains('gopay') || n.contains('gojek')) {
      return {
        'main': const Color(0xFF00AED6),
        'gradient': [const Color(0xFF00AED6), const Color(0xFF0097B8)],
      };
    }
    if (n.contains('dana')) {
      return {
        'main': const Color(0xFF118EEA),
        'gradient': [const Color(0xFF118EEA), const Color(0xFF0D7BCC)],
      };
    }
    if (n.contains('bca')) {
      return {
        'main': const Color(0xFF0060AF),
        'gradient': [const Color(0xFF0060AF), const Color(0xFF004A87)],
      };
    }
    if (n.contains('akulaku')) {
      return {
        'main': const Color(0xFFE51C23),
        'gradient': [const Color(0xFFE51C23), const Color(0xFFC62828)],
      };
    }
    if (n.contains('mifx')) {
      return {
        'main': const Color(0xFF1A1A2E),
        'gradient': [const Color(0xFF16213E), const Color(0xFF0F3460)],
      };
    }
    if (n.contains('mandiri')) {
      return {
        'main': const Color(0xFF003D79),
        'gradient': [const Color(0xFF00529B), const Color(0xFF003D79)],
      };
    }
    if (n.contains('bni')) {
      return {
        'main': const Color(0xFFE55300),
        'gradient': [const Color(0xFFFF6D00), const Color(0xFFE55300)],
      };
    }
    if (n.contains('bri')) {
      return {
        'main': const Color(0xFF00529C),
        'gradient': [const Color(0xFF00529C), const Color(0xFF00407A)],
      };
    }
    if (n.contains('jenius')) {
      return {
        'main': const Color(0xFF00AEEF),
        'gradient': [const Color(0xFF00AEEF), const Color(0xFF0091C7)],
      };
    }
    if (n.contains('linkaja')) {
      return {
        'main': const Color(0xFFE21F26),
        'gradient': [const Color(0xFFFF2D35), const Color(0xFFE21F26)],
      };
    }
    if (n.contains('tokopedia')) {
      return {
        'main': const Color(0xFF42B549),
        'gradient': [const Color(0xFF42B549), const Color(0xFF38963D)],
      };
    }
    if (n.contains('bibit') || n.contains('investment')) {
      return {
        'main': const Color(0xFF00AE64),
        'gradient': [const Color(0xFF00AE64), const Color(0xFF008F52)],
      };
    }
    if (n.contains('seabank') || n.contains('shopee')) {
      return {
        'main': const Color(0xFFFF5722),
        'gradient': [const Color(0xFFFE6433), const Color(0xFFFF5722)],
      };
    }
    return {
      'main': AppColors.primary,
      'gradient': [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
    };
  }

  Widget _buildTransactionTabs(
    SettingsProvider settings,
    List<TransactionModel> transactions,
    NumberFormat currencyFormat,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            settings.translate('Transaksi', 'Transactions'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: ['All', 'Income', 'Expense'].map((filter) {
              final isSelected = _selectedFilter == filter;
              String label = filter == 'All'
                  ? 'Semua'
                  : (filter == 'Income' ? 'Pemasukan' : 'Pengeluaran');
              Color labelColor = filter == 'Income'
                  ? Colors.green
                  : (filter == 'Expense'
                        ? Colors.red
                        : Theme.of(context).colorScheme.onSurface);

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (filter == 'Income')
                        const Icon(
                          Icons.arrow_upward_rounded,
                          size: 14,
                          color: Colors.green,
                        ),
                      if (filter == 'Expense')
                        const Icon(
                          Icons.arrow_downward_rounded,
                          size: 14,
                          color: Colors.red,
                        ),
                      if (filter != 'All') const SizedBox(width: 4),
                      Text(settings.translate(label, filter)),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedFilter = filter);
                  },
                  backgroundColor: Theme.of(context).cardColor,
                  selectedColor: filter == 'Income'
                      ? Colors.green.withValues(alpha: 0.2)
                      : (filter == 'Expense'
                            ? Colors.red.withValues(alpha: 0.2)
                            : AppColors.primary.withValues(alpha: 0.2)),
                  labelStyle: TextStyle(
                    color: isSelected
                        ? labelColor
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 13,
                  ),
                  showCheckmark: false,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected
                          ? labelColor
                          : Colors.grey.withValues(alpha: 0.2),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        if (transactions.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Text(
                settings.translate(
                  'Belum ada transaksi',
                  'No transactions yet',
                ),
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final t = transactions[index];
              return Dismissible(
                key: Key('detail_${t.id ?? t.hashCode}'),
                direction: DismissDirection.endToStart,
                background: Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 20,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
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
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      content: Text(
                        settings.translate(
                          'Yakin ingin menghapus data transaksi ini?',
                          'Are you sure you want to delete this transaction?',
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(settings.translate('Batal', 'Cancel')),
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
                  try {
                    final transProv = Provider.of<TransactionProvider>(
                      context,
                      listen: false,
                    );
                    await transProv.deleteTransaction(t);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            settings.translate(
                              'Gagal menghapus transaksi',
                              'Failed to delete transaction',
                            ),
                          ),
                        ),
                      );
                    }
                  }
                },
                child: TransactionCardListTile(transaction: t),
              );
            },
          ),
        const SizedBox(height: 40),
      ],
    );
  }

  void _showEditBalanceDialog(
    BuildContext context,
    EWalletModel wallet,
    EWalletProvider provider,
    SettingsProvider settings,
  ) {
    final controller = TextEditingController(
      text: NumberFormat('#,###').format(wallet.balance),
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(settings.translate('Ubah Saldo', 'Edit Balance')),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [CurrencyInputFormatter()],
          decoration: InputDecoration(
            prefixText: 'Rp ',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(settings.translate('Batal', 'Cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              String clean = controller.text.replaceAll('.', '');
              double newBalance = double.tryParse(clean) ?? 0;
              double oldBalance = wallet.balance;

              if (newBalance != oldBalance) {
                // Buat transaksi penyesuaian agar tercatat di Portofolio
                // Saldo wallet akan otomatis diperbarui oleh FirestoreService.addTransaction
                final transProv = context.read<TransactionProvider>();
                double diff = newBalance - oldBalance;
                await transProv.addTransaction(
                  TransactionModel(
                    userId: wallet.userId,
                    amount: diff.abs(),
                    type: diff > 0 ? 'income' : 'expense',
                    category: 'Lainnya',
                    description:
                        settings.translate(
                          'Penyesuaian Saldo: ',
                          'Balance Adjustment: ',
                        ) +
                        wallet.name,
                    date: DateTime.now(),
                    walletId: wallet.id,
                    source: 'manual',
                  ),
                );
              }
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              settings.translate('Simpan', 'Save'),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditAccountDialog(
    BuildContext context,
    EWalletModel wallet,
    EWalletProvider provider,
    SettingsProvider settings,
  ) {
    final controller = TextEditingController(text: wallet.accountNumber);
    String label = wallet.type == 'marketplace' || wallet.type == 'investment'
        ? settings.translate('Email / ID Akun', 'Email / Account ID')
        : (wallet.type == 'e-wallet'
              ? settings.translate(
                  'Nomor HP / WhatsApp',
                  'Phone / WhatsApp Number',
                )
              : settings.translate('Nomor Rekening', 'Account Number'));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(label),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Masukkan detail baru',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(settings.translate('Batal', 'Cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              await provider.updateWalletAccountNumber(
                wallet.id!,
                controller.text,
              );
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              settings.translate('Simpan', 'Save'),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(
    BuildContext context,
    EWalletModel wallet,
    EWalletProvider provider,
    SettingsProvider settings,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(settings.translate('Hapus Dompet?', 'Delete Wallet?')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              settings.translate(
                'Apakah Anda yakin ingin menghapus dompet "${wallet.name}"?',
                'Are you sure you want to delete "${wallet.name}"?',
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.amber,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      settings.translate(
                        'Peringatan: Menghapus dompet ini akan menghapus seluruh saldo dan riwayat transaksi yang ada didalamnya secara permanen.',
                        'Warning: Deleting this wallet will permanently delete all balance and transaction history within it.',
                      ),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(settings.translate('Batal', 'Cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await provider.deleteWallet(wallet.id!, wallet.userId);
                if (context.mounted) {
                  Navigator.pop(context); // Pop Dialog
                  Navigator.pop(context); // Pop Detail Page
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        settings.translate(
                              'Gagal menghapus: ',
                              'Delete failed: ',
                            ) +
                            e.toString(),
                      ),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              settings.translate('Hapus', 'Delete'),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
