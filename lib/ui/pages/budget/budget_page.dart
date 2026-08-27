import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/transaction_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../widgets/custom_popup.dart';
import '../transaction/add_transaction_page.dart'; // Import for CurrencyInputFormatter

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  final TextEditingController _budgetController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final currentBudget = auth.userProfile?['monthlyBudget'] ?? 0.0;
    if (currentBudget > 0) {
      _budgetController.text = _formatNumber(currentBudget.toInt());
    }
  }

  String _formatNumber(int number) {
    String s = number.toString();
    String formatted = '';
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      if (count != 0 && count % 3 == 0) formatted = '.$formatted';
      formatted = s[i] + formatted;
      count++;
    }
    return formatted;
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final txProvider = Provider.of<TransactionProvider>(context);
    final settings = context.watch<SettingsProvider>();

    final double budget = (auth.userProfile?['monthlyBudget'] ?? 0).toDouble();
    final double expense = txProvider.totalExpense;
    final double remaining = budget - expense;
    final double progress = budget > 0
        ? (expense / budget).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          settings.translate('Target Keuangan', 'Financial Target'),
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Ringkasan Budget
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    settings.translate(
                      'Sisa Anggaran Bulan Ini',
                      'Remaining Budget This Month',
                    ),
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rp ${remaining < 0 ? 0 : _formatNumber(remaining.toInt())}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 12,
                      backgroundColor: Colors.white24,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progress > 0.9 ? Colors.redAccent : Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${settings.translate('Terpakai', 'Used')}: Rp ${_formatNumber(expense.toInt())}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'Total: Rp ${_formatNumber(budget.toInt())}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Atur Budget Baru
            Text(
              settings.translate('Atur Target Anggaran', 'Set Budget Target'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _budgetController,
              keyboardType: TextInputType.number,
              inputFormatters: [CurrencyInputFormatter()],
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                prefixText: 'Rp ',
                hintText: settings.translate(
                  'Masukkan nominal...',
                  'Enter amount...',
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(20),
              ),
            ),
            const SizedBox(height: 24),

            _isSaving
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_budgetController.text.isEmpty) return;

                        setState(() => _isSaving = true);
                        String cleanAmount = _budgetController.text.replaceAll(
                          '.',
                          '',
                        );
                        double amount = double.tryParse(cleanAmount) ?? 0;

                        final success = await auth.updateBudget(amount);
                        setState(() => _isSaving = false);

                        if (success && context.mounted) {
                          CustomPopup.show(
                            context: context,
                            title: settings.translate(
                              'Berhasil! ✨',
                              'Success! ✨',
                            ),
                            message: settings.translate(
                              'Target anggaran bulanan Anda sudah diperbarui.',
                              'Your monthly budget target has been updated.',
                            ),
                            isSuccess: true,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        settings.translate('Simpan Anggaran', 'Save Budget'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

            const SizedBox(height: 40),
            // Tips
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline, color: Colors.orange),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      settings.translate(
                        'Tips: Atur target keuangan yang realistis agar Anda bisa mencapai tujuan finansial lebih efektif setiap bulannya.',
                        'Tip: Set a realistic budget so you can save more effectively every month.',
                      ),
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
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
}
