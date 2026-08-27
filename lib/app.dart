import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_finance_app/core/theme/app_theme.dart';
import 'package:smart_finance_app/providers/settings_provider.dart';
import 'package:smart_finance_app/providers/auth_provider.dart';
import 'package:smart_finance_app/providers/transaction_provider.dart';
import 'package:smart_finance_app/providers/e_wallet_provider.dart';
import 'package:smart_finance_app/providers/ai_insight_provider.dart';
import 'package:smart_finance_app/providers/notification_provider.dart';
import 'package:smart_finance_app/ui/pages/splash/splash_page.dart';

class SmartFinanceApp extends StatelessWidget {
  const SmartFinanceApp({super.key});

  // GlobalKey untuk mengakses Navigator dari luar widget tree
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => EWalletProvider()),
        ChangeNotifierProvider(create: (_) => AIInsightProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            title: 'Camelio Finance',
            debugShowCheckedModeBanner: false,
            themeMode: settings.themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            home: const SplashPage(),
            builder: (context, navChild) {
              return GestureDetector(
                onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                child: navChild ?? const SizedBox.shrink(),
              );
            },
          );
        },
      ),
    );
  }
}
