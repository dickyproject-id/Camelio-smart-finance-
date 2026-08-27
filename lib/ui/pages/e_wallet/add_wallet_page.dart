import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_finance_app/data/models/e_wallet_model.dart';
import 'package:smart_finance_app/data/models/transaction_model.dart';
import 'package:smart_finance_app/providers/settings_provider.dart';
import 'package:smart_finance_app/providers/e_wallet_provider.dart';
import 'package:smart_finance_app/providers/auth_provider.dart';
import 'package:smart_finance_app/providers/transaction_provider.dart';
import 'package:smart_finance_app/core/constants/app_colors.dart';
import 'package:smart_finance_app/ui/pages/transaction/add_transaction_page.dart';
import 'package:smart_finance_app/ui/widgets/custom_popup.dart';

class AddWalletPage extends StatefulWidget {
  const AddWalletPage({super.key});

  @override
  State<AddWalletPage> createState() => _AddWalletPageState();
}

class _AddWalletPageState extends State<AddWalletPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _balanceController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _accountController = TextEditingController();
  String _type = 'banking';

  final List<String> _types = [
    'banking',
    'e-wallet',
    'marketplace',
    'loan',
    'investment',
    'cash',
  ];

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onNameChanged);
  }

  void _onNameChanged() {
    final name = _nameController.text.toLowerCase();

    // Auto-detect type based on popular names
    String? detectedType;

    if (name.contains('shopee') ||
        name.contains('lazada') ||
        name.contains('tokopedia') ||
        name.contains('tiktok') ||
        name.contains('blibli')) {
      detectedType = 'marketplace';
    } else if (name.contains('gopay') ||
        name.contains('ovo') ||
        name.contains('dana') ||
        name.contains('linkaja') ||
        name.contains('spay')) {
      detectedType = 'e-wallet';
    } else if (name.contains('bca') ||
        name.contains('bni') ||
        name.contains('bri') ||
        name.contains('mandiri') ||
        name.contains('cimb') ||
        name.contains('bank')) {
      detectedType = 'banking';
    } else if (name.contains('bibit') ||
        name.contains('ajaib') ||
        name.contains('pluang') ||
        name.contains('stockbit')) {
      detectedType = 'investment';
    } else if (name.contains('pinjam') ||
        name.contains('akrilaku') ||
        name.contains('kredivo')) {
      detectedType = 'loan';
    }

    if (detectedType != null && detectedType != _type) {
      setState(() {
        _type = detectedType!;
      });
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _balanceController.dispose();
    _nameController.dispose();
    _accountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final walletProvider = context.watch<EWalletProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          settings.translate('Tambah Dompet', 'Add Wallet'),
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_type != 'cash') ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.mark_email_unread_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  settings.translate(
                                    'Sinkronisasi Otomatis',
                                    'Automatic Sync',
                                  ),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  settings.translate(
                                    'Hubungkan dengan Gmail',
                                    'Connect with Gmail',
                                  ),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: walletProvider.isSyncing
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: settings.gmailSyncEnabled
                                      ? Colors.greenAccent
                                      : Colors.white,
                                  foregroundColor: settings.gmailSyncEnabled
                                      ? Colors.black87
                                      : AppColors.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                ),
                                onPressed: () async {
                                  final currentContext = context;
                                  final settingsProv = currentContext
                                      .read<SettingsProvider>();

                                  if (!settingsProv.gmailSyncEnabled) {
                                    bool? proceed = await showDialog<bool>(
                                      context: currentContext,
                                      builder: (context) => AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        title: Text(
                                          settings.translate(
                                            'Keamanan Sinkronisasi ✨',
                                            'Sync Security ✨',
                                          ),
                                        ),
                                        content: Text(
                                          settings.translate(
                                            'Aplikasi Camelio menggunakan enkripsi untuk membaca email transaksi Anda. Anda mungkin akan melihat peringatan "Aplikasi belum diverifikasi" dari Google karena aplikasi ini masih dalam tahap pengembangan skripsi. Ini aman, silakan klik "Lanjutan" lalu "Buka Camelio" untuk melanjutkan.',
                                            'Camelio app uses encryption to read your transaction emails. You might see an "App not verified" warning from Google because this app is still in the thesis development stage. This is safe, please click "Advanced" then "Go to Camelio" to proceed.',
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: Text(
                                              settings.translate(
                                                'Batal',
                                                'Cancel',
                                              ),
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppColors.primary,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                            child: Text(
                                              settings.translate(
                                                'Lanjutkan',
                                                'Proceed',
                                              ),
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (proceed != true ||
                                        !currentContext.mounted)
                                      return;
                                    await settingsProv.toggleGmailSync(true);
                                  } else {
                                    CustomPopup.show(
                                      context: currentContext,
                                      title: settings.translate(
                                        'Gmail Terhubung',
                                        'Gmail Connected',
                                      ),
                                      message: settings.translate(
                                        'Sinkronisasi otomatis sudah aktif. Anda dapat mematikan akses di halaman Pengaturan > Izin.',
                                        'Automatic sync is already active. You can disable access in Settings > Permissions.',
                                      ),
                                      isSuccess: true,
                                    );
                                  }
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (settings.gmailSyncEnabled) ...[
                                      const Icon(
                                        Icons.check_circle_outline,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                    Text(
                                      settings.gmailSyncEnabled
                                          ? settings.translate(
                                              'Gmail Terhubung',
                                              'Gmail Connected',
                                            )
                                          : settings.translate(
                                              'Hubungkan Sekarang',
                                              'Connect Now',
                                            ),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        settings.translate(
                          'Atau Tambah Manual',
                          'Or Add Manually',
                        ),
                        style: const TextStyle(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 32),
              ],

              Text(
                settings.translate('Pilih Tipe Wallet', 'Select Wallet Type'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _type,
                items: _types.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(
                      settings.translate(
                        type == 'banking'
                            ? 'Bank'
                            : type == 'e-wallet'
                            ? 'Dompet Digital'
                            : type == 'marketplace'
                            ? 'Toko Online'
                            : type == 'loan'
                            ? 'Pinjaman'
                            : type == 'investment'
                            ? 'Investasi'
                            : type == 'cash'
                            ? 'Tunai (Cash)'
                            : type,
                        type.toUpperCase(),
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _type = val!),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              if (_type != 'cash') ...[
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: settings.translate(
                      'Nama Bank/Wallet',
                      'Bank/Wallet Name',
                    ),
                    hintText: 'e.g. BCA, GoPay, OVO',
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (val) => val == null || val.isEmpty
                      ? settings.translate('Wajib diisi', 'Required')
                      : null,
                ),
              ],
              const SizedBox(height: 20),
              TextFormField(
                controller: _balanceController,
                decoration: InputDecoration(
                  labelText: settings.translate(
                    'Saldo Saat Ini',
                    'Current Balance',
                  ),
                  prefixText: 'Rp ',
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyInputFormatter()],
                validator: (val) => val == null || val.isEmpty
                    ? settings.translate('Wajib diisi', 'Required')
                    : null,
              ),
              if (_type != 'cash') ...[
                const SizedBox(height: 20),
                TextFormField(
                  controller: _accountController,
                  decoration: InputDecoration(
                    labelText: _type == 'marketplace' || _type == 'investment'
                        ? settings.translate(
                            'Email / ID Akun (Opsional)',
                            'Email / Account ID (Optional)',
                          )
                        : (_type == 'e-wallet'
                              ? settings.translate(
                                  'Nomor HP / WhatsApp (Opsional)',
                                  'Phone / WhatsApp Number (Optional)',
                                )
                              : settings.translate(
                                  'Nomor Rekening (Opsional)',
                                  'Account Number (Optional)',
                                )),
                    hintText: _type == 'e-wallet'
                        ? settings.translate(
                            '0812... (Opsional)',
                            '0812... (Optional)',
                          )
                        : settings.translate(
                            'email@example.com (Opsional)',
                            'email@example.com (Optional)',
                          ),
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon:
                        (_type == 'e-wallet' ||
                            _type == 'marketplace' ||
                            _type == 'investment')
                        ? IconButton(
                            icon: const Icon(
                              Icons.person_outline_rounded,
                              size: 20,
                            ),
                            onPressed: () {
                              final authProv = context.read<AuthProvider>();
                              if (_type == 'e-wallet') {
                                _accountController.text =
                                    authProv.userProfile?['whatsapp'] ?? '';
                              } else {
                                _accountController.text =
                                    authProv.user?.email ?? '';
                              }
                            },
                          )
                        : null,
                  ),
                ),
              ],
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: walletProvider.isLoading
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              String cleanBalance = _balanceController.text
                                  .replaceAll('.', '');
                              double parsedBalance =
                                  double.tryParse(cleanBalance) ?? 0;

                              final authProv = context.read<AuthProvider>();
                              final newWallet = EWalletModel(
                                userId: authProv.user!.uid,
                                name: _type == 'cash'
                                    ? 'Cash'
                                    : _nameController.text,
                                type: _type,
                                balance:
                                    0, // Inisialisasi 0, saldo akan diisi oleh transaksi awal di bawah
                                accountNumber: _accountController.text,
                                createdAt: DateTime.now(),
                              );
                              try {
                                final walletId = await walletProvider
                                    .saveWallet(newWallet);

                                // Jika saldo awal > 0, buat transaksi pemasukan awal agar tercatat di Portofolio
                                if (context.mounted && parsedBalance > 0) {
                                  final transProv = context
                                      .read<TransactionProvider>();
                                  await transProv.addTransaction(
                                    TransactionModel(
                                      userId: authProv.user!.uid,
                                      amount: parsedBalance,
                                      type: 'income',
                                      category: 'Lainnya',
                                      description:
                                          settings.translate(
                                            'Saldo Awal: ',
                                            'Initial Balance: ',
                                          ) +
                                          newWallet.name,
                                      date: DateTime.now(),
                                      walletId: walletId,
                                      source: 'manual',
                                    ),
                                  );
                                }
                                if (context.mounted) {
                                  CustomPopup.show(
                                    context: context,
                                    title: settings.translate(
                                      'Berhasil',
                                      'Success',
                                    ),
                                    message: settings.translate(
                                      'Dompet baru telah ditambahkan! ✨',
                                      'New wallet has been added! ✨',
                                    ),
                                    isSuccess: true,
                                    onConfirm: () {
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                      }
                                    },
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  CustomPopup.show(
                                    context: context,
                                    title: settings.translate(
                                      'Gagal',
                                      'Failed',
                                    ),
                                    message: settings.translate(
                                      'Gagal menyimpan dompet: ${e.toString().replaceAll('Exception: ', '')}',
                                      'Failed to save wallet: ${e.toString().replaceAll('Exception: ', '')}',
                                    ),
                                    isSuccess: false,
                                  );
                                }
                              }
                            }
                          },
                    child: walletProvider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            settings.translate('Tambah Dompet', 'Add Wallet'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
