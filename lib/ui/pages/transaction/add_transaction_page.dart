import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:smart_finance_app/providers/settings_provider.dart';

import 'package:smart_finance_app/core/constants/app_colors.dart';
import 'package:smart_finance_app/data/models/transaction_model.dart';
import 'package:smart_finance_app/providers/auth_provider.dart';
import 'package:smart_finance_app/providers/transaction_provider.dart';
import 'package:smart_finance_app/ui/widgets/custom_text_field.dart';
import 'package:smart_finance_app/ui/widgets/custom_popup.dart';
import 'package:smart_finance_app/providers/e_wallet_provider.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue.copyWith(text: '');

    // Hilangkan semua karakter non-digit
    String cleanText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanText.isEmpty) return newValue.copyWith(text: '');

    // Batasi angka agar tidak kepanjangan (misal max 12 digit / triliun)
    if (cleanText.length > 12) return oldValue;

    double value = double.parse(cleanText);
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 0,
    );

    String formatted = formatter.format(value).trim();

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  String _selectedType = 'expense';
  String _selectedCategory = 'Belanja';
  String? _selectedWalletId;
  final List<String> _expenseCategories = [
    'Makanan',
    'Minuman',
    'Belanja',
    'Transportasi',
    'Hiburan',
    'Tagihan',
    'Langganan',
    'Kebutuhan Rumah',
    'Perlengkapan Rumah',
    'Perawatan Rumah',
    'Kesehatan',
    'Pendidikan',
    'Pinjaman',
    'Top Up',
    'Elektronik',
    'Kendaraan',
    'Olahraga',
    'Liburan',
    'Pakaian & Aksesoris',
    'Transfer',
    'Lainnya',
  ];

  final List<String> _incomeCategories = [
    'Gaji',
    'Bonus',
    'Transfer',
    'Investasi',
    'Top Up',
    'Pinjaman',
    'Lainnya',
  ];

  @override
  void dispose() {
    _descController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final transProvider = Provider.of<TransactionProvider>(
      context,
      listen: false,
    );

    final currentCategories = _selectedType == 'expense'
        ? _expenseCategories
        : _incomeCategories;
    if (!currentCategories.contains(_selectedCategory)) {
      _selectedCategory = currentCategories.first;
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          settings.translate('Tambah Transaksi', 'Add Transaction'),
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        iconTheme: IconThemeData(
          color: Theme.of(context).textTheme.titleLarge?.color,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _selectedType = 'expense';
                      _selectedCategory = 'Belanja';
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: _selectedType == 'expense'
                            ? const Color(0xFFFF9E80)
                            : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: _selectedType == 'expense'
                            ? null
                            : Border.all(color: Colors.grey.withAlpha(51)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_selectedType == 'expense')
                            const Icon(
                              Icons.check,
                              size: 18,
                              color: Colors.black87,
                            ),
                          if (_selectedType == 'expense')
                            const SizedBox(width: 8),
                          Text(
                            settings.translate('Pengeluaran', 'Expense'),
                            style: TextStyle(
                              color: _selectedType == 'expense'
                                  ? Colors.black87
                                  : Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _selectedType = 'income';
                      _selectedCategory = 'Gaji';
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: _selectedType == 'income'
                            ? AppColors.primary
                            : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: _selectedType == 'income'
                            ? null
                            : Border.all(color: Colors.grey.withAlpha(51)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_selectedType == 'income')
                            const Icon(
                              Icons.check,
                              size: 18,
                              color: Colors.white,
                            ),
                          if (_selectedType == 'income')
                            const SizedBox(width: 8),
                          Text(
                            settings.translate('Pemasukan', 'Income'),
                            style: TextStyle(
                              color: _selectedType == 'income'
                                  ? Colors.white
                                  : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            CustomTextField(
              label: settings.translate('Keterangan', 'Description'),
              controller: _descController,
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  settings.translate('Nominal', 'Amount'),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [CurrencyInputFormatter()],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                  decoration: InputDecoration(
                    prefixText: 'Rp ',
                    prefixStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    hintText: '0',
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.withAlpha(51)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.withAlpha(51)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  settings.translate('Kategori', 'Category'),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  dropdownColor: Theme.of(context).cardColor,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  items: currentCategories.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Text(settings.translateCategory(cat)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCategory = val);
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.withAlpha(51)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.withAlpha(51)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  settings.translate('Sumber Dana / Wallet', 'Source / Wallet'),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                const SizedBox(height: 8),
                Consumer<EWalletProvider>(
                  builder: (context, walletProvider, _) {
                    final wallets = walletProvider.wallets;
                    if (_selectedWalletId == null && wallets.isNotEmpty) {
                      final cashWallet = wallets
                          .where((w) => w.type == 'cash')
                          .firstOrNull;
                      _selectedWalletId = cashWallet?.id ?? wallets.first.id;
                    }

                    return DropdownButtonFormField<String>(
                      initialValue: _selectedWalletId,
                      dropdownColor: Theme.of(context).cardColor,
                      isExpanded: true,
                      items: wallets
                          .map(
                            (w) => DropdownMenuItem(
                              value: w.id,
                              child: Text(
                                "${w.name} (${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(w.balance)})",
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedWalletId = val),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey.withAlpha(51),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey.withAlpha(51),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 40),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () async {
                  if (auth.user == null) return;
                  if (_descController.text.isEmpty ||
                      _amountController.text.isEmpty) {
                    CustomPopup.show(
                      context: context,
                      title: 'Oops!',
                      message: settings.translate(
                        'Lengkapi keterangan dan nominal dulu ya!',
                        'Please complete description and amount!',
                      ),
                      isSuccess: false,
                    );
                    return;
                  }
                  String cleanAmount = _amountController.text.replaceAll(
                    '.',
                    '',
                  );
                  double parsedAmount = double.tryParse(cleanAmount) ?? 0;
                  if (parsedAmount <= 0) {
                    CustomPopup.show(
                      context: context,
                      title: 'Oops!',
                      message: settings.translate(
                        'Nominal harus lebih dari Rp 0',
                        'Amount must be more than Rp 0',
                      ),
                      isSuccess: false,
                    );
                    return;
                  }
                  final tx = TransactionModel(
                    userId: auth.user!.uid,
                    walletId: _selectedWalletId,
                    amount: parsedAmount,
                    category: _selectedCategory,
                    description: _descController.text,
                    date: DateTime.now(),
                    type: _selectedType,
                    source: 'manual',
                  );
                  // Simpan di background (Optimistic)
                  transProvider.addTransaction(tx);

                  if (mounted) {
                    CustomPopup.show(
                      context: context,
                      title: settings.translate('Berhasil!', 'Success!'),
                      message: settings.translate(
                        'Transaksi Anda sudah tersimpan! ✨',
                        'Your transaction has been saved! ✨',
                      ),
                      isSuccess: true,
                      onConfirm: () {
                        Navigator.pop(context); // Kembali ke halaman utama
                      },
                    );
                  }
                },
                child: Text(
                  settings.translate("Simpan Transaksi", "Save Transaction"),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
