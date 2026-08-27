import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../providers/transaction_provider.dart';
import '../../../../providers/e_wallet_provider.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/settings_provider.dart';
import '../../../../providers/notification_provider.dart';
import '../notification/notification_page.dart';

import 'widgets/balance_card.dart';
import 'widgets/action_button_row.dart';
import 'widgets/feature_cards.dart';
import 'widgets/recent_transactions.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final settings = context.watch<SettingsProvider>();
    // Menambahkan watch agar Dashboard selalu rebuild saat data berubah di Firestore
    context.watch<TransactionProvider>();
    context.watch<EWalletProvider>();

    return SingleChildScrollView(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- MENGAMBIL DATA DARI AUTH PROVIDER (AGAR SINKRON DENGAN DRAWER) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Scaffold.of(context).openDrawer();
                          },
                          onLongPress: () {
                            if (auth.userProfile?['photoUrl'] != null) {
                              _showZoomableImage(
                                context,
                                auth.userProfile!['photoUrl'],
                              );
                            }
                          },
                          child: CircleAvatar(
                            radius: 24,
                            backgroundColor: AppColors.primary,
                            backgroundImage:
                                (auth.userProfile?['photoUrl'] != null)
                                ? NetworkImage(auth.userProfile!['photoUrl'])
                                : null,
                            child: (auth.userProfile?['photoUrl'] == null)
                                ? Text(
                                    (auth.userProfile?['name'] ??
                                            auth.user?.displayName ??
                                            'U')[0]
                                        .toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${settings.translate('Hai', 'Hi')}, ${auth.userProfile?['name'] ?? auth.user?.displayName ?? settings.translate('Pengguna', 'User')}!',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.titleLarge?.color,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                settings.translate(
                                  'Kelola keuanganmu dengan cerdas',
                                  'Manage your finances wisely',
                                ),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.color,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Consumer<NotificationProvider>(
                    builder: (context, notifProvider, child) {
                      final unreadCount = notifProvider.unreadCount;
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const NotificationPage(),
                            ),
                          );
                        },
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.grey.withAlpha(76),
                                ), // 30% opacity
                              ),
                              child: Icon(
                                Icons.notifications_none_rounded,
                                color: Theme.of(context).iconTheme.color,
                              ),
                            ),
                            if (unreadCount > 0)
                              Positioned(
                                right: -4,
                                top: -4,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  child: Text(
                                    '$unreadCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 32),

              Consumer2<TransactionProvider, EWalletProvider>(
                builder: (context, transProvider, walletProvider, child) {
                  final totalBalance = walletProvider.totalBalance;
                  return BalanceCard(
                    title: settings.translate('Total Saldo', 'Total Balance'),
                    balance: CurrencyFormatter.format(totalBalance),
                    changes: 'Live Update', // Penanda visual data real-time
                    isPositive: totalBalance >= 0,
                    isVisible: transProvider.isBalanceVisible,
                    onToggleVisibility: transProvider.toggleBalanceVisibility,
                  );
                },
              ),

              const ActionButtonRow(),
              const FeatureCards(),
              const SizedBox(height: 24),
              const RecentTransactions(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  void _showZoomableImage(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Center(
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: CircleAvatar(
                backgroundColor: Colors.black26,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
