import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/settings_provider.dart';
import '../../../providers/e_wallet_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../data/models/e_wallet_model.dart';
import '../../../core/constants/app_colors.dart';
import 'add_wallet_page.dart';
import 'e_wallet_detail_page.dart';

class EWalletPage extends StatefulWidget {
  const EWalletPage({super.key});

  @override
  State<EWalletPage> createState() => _EWalletPageState();
}

class _EWalletPageState extends State<EWalletPage> {
  String selectedCategory = 'All';
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> categories = [
    {'name': 'All', 'icon': Icons.apps},
    {'name': 'Banking', 'icon': Icons.account_balance},
    {'name': 'E-Wallet', 'icon': Icons.account_balance_wallet},
    {'name': 'Marketplace', 'icon': Icons.shopping_bag},
    {'name': 'Loan', 'icon': Icons.credit_card},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.user != null) {
        context.read<EWalletProvider>().loadWallets(auth.user!.uid);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final walletProvider = context.watch<EWalletProvider>();
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    List<EWalletModel> filteredWallets = walletProvider.wallets.where((w) {
      bool matchesCategory =
          selectedCategory == 'All' ||
          w.type.toLowerCase() == selectedCategory.toLowerCase();
      bool matchesSearch =
          w.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          (w.accountNumber?.toLowerCase().contains(searchQuery.toLowerCase()) ??
              false);
      return matchesCategory && matchesSearch;
    }).toList();

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
                    settings.translate('Dompet Digital', 'E-Wallets'),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    settings.translate(
                      'Kelola semua aset digital Anda',
                      'Manage all your digital assets',
                    ),
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 0,
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() {
                          searchQuery = val;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: settings.translate(
                          'Cari dompet atau bank...',
                          'Search wallet or bank...',
                        ),
                        hintStyle: const TextStyle(color: Colors.grey),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                        suffixIcon: searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  color: Colors.grey,
                                  size: 18,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => searchQuery = '');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: categories.map((cat) {
                        bool isSelected = selectedCategory == cat['name'];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            label: Text(
                              settings.translate(
                                cat['name'] == 'All'
                                    ? 'Semua'
                                    : (cat['name'] == 'Banking'
                                          ? 'Perbankan'
                                          : (cat['name'] == 'E-Wallet'
                                                ? 'Dompet Digital'
                                                : (cat['name'] == 'Marketplace'
                                                      ? 'Toko Online'
                                                      : (cat['name'] == 'Loan'
                                                            ? 'Pinjaman'
                                                            : cat['name'])))),
                                cat['name'],
                              ),
                            ),
                            selected: isSelected,
                            showCheckmark: false,
                            onSelected: (val) {
                              setState(() {
                                selectedCategory = cat['name'];
                              });
                            },
                            backgroundColor: Theme.of(context).cardColor,
                            selectedColor: AppColors.secondary,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected
                                    ? Colors.transparent
                                    : Colors.grey.withValues(alpha: 0.2),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Stack(
                      children: [
                        ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AddWalletPage(),
                                ),
                              ),
                              child: _buildAddWalletCard(settings),
                            ),
                            const SizedBox(height: 16),
                            ...filteredWallets.map(
                              (wallet) => GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EWalletDetailPage(wallet: wallet),
                                  ),
                                ),
                                child: _buildWalletItem(
                                  wallet,
                                  currencyFormat,
                                  settings,
                                ),
                              ),
                            ),
                            if (filteredWallets.isEmpty &&
                                !walletProvider.isLoading)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(32.0),
                                  child: Text(
                                    settings.translate(
                                      'Belum ada dompet digital',
                                      'No wallets found',
                                    ),
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.color,
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 80),
                          ],
                        ),
                        if (walletProvider.isLoading)
                          const Center(child: CircularProgressIndicator()),
                      ],
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

  Widget _buildAddWalletCard(SettingsProvider settings) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.warmGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.add_circle_outline,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  settings.translate('Tambah Dompet Baru', 'Add New Wallet'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  settings.translate(
                    'Hubungkan bank, e-wallet, atau akun lainnya',
                    'Connect your bank, e-wallet, or other accounts',
                  ),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.white,
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildWalletItem(
    EWalletModel wallet,
    NumberFormat currencyFormat,
    SettingsProvider settings,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: wallet.iconUrl != null && wallet.iconUrl!.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(8),
                      child: wallet.iconUrl!.startsWith('assets/')
                          ? Image.asset(
                              wallet.iconUrl!,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                    Icons.account_balance_wallet,
                                    color: AppColors.secondary.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                            )
                          : Image.network(
                              wallet.iconUrl!,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                    Icons.account_balance_wallet,
                                    color: AppColors.secondary.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                            ),
                    )
                  : Icon(
                      Icons.account_balance_wallet,
                      color: AppColors.secondary.withValues(alpha: 0.5),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    settings.translate(
                      wallet.type == 'banking'
                          ? 'Bank'
                          : wallet.type == 'e-wallet'
                          ? 'Dompet Digital'
                          : wallet.type == 'marketplace'
                          ? 'Toko Online'
                          : wallet.type == 'loan'
                          ? 'Pinjaman'
                          : wallet.type == 'investment'
                          ? 'Investasi'
                          : wallet.type.toUpperCase(),
                      wallet.type.toUpperCase(),
                    ),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  wallet.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (wallet.accountNumber != null &&
                    wallet.accountNumber!.isNotEmpty)
                  Text(
                    wallet.accountNumber!,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                settings.translate('Saldo', 'Balance'),
                style: TextStyle(color: Colors.grey[500], fontSize: 10),
              ),
              Text(
                currencyFormat.format(wallet.balance),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.grey,
            size: 14,
          ),
        ],
      ),
    );
  }
}
