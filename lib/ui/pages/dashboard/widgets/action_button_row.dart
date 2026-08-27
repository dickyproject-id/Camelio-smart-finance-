import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

import 'package:provider/provider.dart';
import '../../../../providers/transaction_provider.dart';
import '../../../../providers/settings_provider.dart';
import '../../../../core/utils/currency_formatter.dart';

class ActionButtonRow extends StatelessWidget {
  const ActionButtonRow({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        // Hitung pengeluaran hari ini
        final now = DateTime.now();
        final todayExpense = provider.transactions
            .where((t) {
              return t.type == 'expense' &&
                  t.date.year == now.year &&
                  t.date.month == now.month &&
                  t.date.day == now.day;
            })
            .fold(0.0, (sum, item) => sum + item.amount);

        // Hitung pengeluaran 7 hari terakhir
        final sevenDaysAgo = now.subtract(const Duration(days: 7));
        final weekExpense = provider.transactions
            .where((t) {
              return t.type == 'expense' && t.date.isAfter(sevenDaysAgo);
            })
            .fold(0.0, (sum, item) => sum + item.amount);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  context,
                  title: settings.translate('Hari Ini', 'Today'),
                  subtitle: settings.translate(
                    'Total uang keluar',
                    'Total expense',
                  ),
                  amount: todayExpense,
                  icon: Icons
                      .receipt_long_rounded, // Diganti ke receipt_long_rounded
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  context,
                  title: settings.translate('7 Hari Terakhir', 'Last 7 Days'),
                  subtitle: settings.translate(
                    'Total uang keluar',
                    'Total expense',
                  ),
                  amount: weekExpense,
                  icon: Icons
                      .trending_down_rounded, // Diganti ke trending_down_rounded
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required double amount,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 10,
                        color:
                            Theme.of(context).textTheme.bodySmall?.color ??
                            Colors.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            CurrencyFormatter.format(amount),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
