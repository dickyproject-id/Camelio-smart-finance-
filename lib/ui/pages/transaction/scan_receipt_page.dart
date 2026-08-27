import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:smart_finance_app/core/constants/app_colors.dart';
import 'package:smart_finance_app/core/locator.dart';
import 'package:smart_finance_app/data/models/transaction_model.dart';
import 'package:smart_finance_app/data/services/gemini_ai_service.dart';
import 'package:smart_finance_app/data/services/cloudinary_service.dart';
import 'package:smart_finance_app/providers/auth_provider.dart';
import 'package:smart_finance_app/providers/settings_provider.dart';
import 'package:smart_finance_app/providers/transaction_provider.dart';
import 'package:smart_finance_app/providers/e_wallet_provider.dart';
import 'package:smart_finance_app/ui/widgets/custom_popup.dart';
import 'package:smart_finance_app/ui/pages/transaction/add_transaction_page.dart';

class ScanReceiptPage extends StatefulWidget {
  const ScanReceiptPage({super.key});

  @override
  State<ScanReceiptPage> createState() => _ScanReceiptPageState();
}

class _ScanReceiptPageState extends State<ScanReceiptPage> {
  final _geminiService = locator<GeminiAIService>();
  final _cloudinaryService = locator<CloudinaryService>();

  bool _isProcessing = false; // Loading saat scan AI
  bool _isSaving = false; // Loading saat klik tombol Simpan (Upload Cloudinary)
  String _statusText = ""; // Akan diisi di build/didChangeDependencies

  Map<String, dynamic>? _scannedData;
  List<Map<String, dynamic>> _scannedItems = [];
  XFile? _selectedImageFile; // Menyimpan gambar sementara untuk diupload nanti
  String? _selectedWalletId;

  double? _aiOriginalTotal;
  double? _manualTotalOverride;

  // --- 1. PROSES SCAN (HANYA AI, SANGAT CEPAT) ---
  Future<void> _processReceipt(bool fromCamera) async {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    setState(() {
      _isProcessing = true;
      _statusText = settings.translate(
        "Menyiapkan kamera/galeri...",
        "Preparing camera/gallery...",
      );
      _scannedData = null;
      _scannedItems.clear();
      _selectedImageFile = null;
    });

    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 70, // Diturunkan sedikit agar upload lebih cepat ke AI
        maxWidth: 1024, // 1024px sudah sangat cukup untuk OCR struk
      );

      if (image == null) {
        setState(() {
          _isProcessing = false;
          _statusText = settings.translate(
            "Dibatalkan. Siap memindai ulang.",
            "Cancelled. Ready to scan again.",
          );
        });
        return;
      }

      // Simpan gambar ke memori untuk diupload saat klik Simpan
      _selectedImageFile = image;

      setState(
        () => _statusText = settings.translate(
          "AI sedang mengekstrak data struk...",
          "AI is extracting receipt data...",
        ),
      );

      final imageBytes = await image.readAsBytes();
      String mimeType = 'image/jpeg';
      if (image.name.toLowerCase().endsWith('.png')) {
        mimeType = 'image/png';
      } else if (image.name.toLowerCase().endsWith('.webp')) {
        mimeType = 'image/webp';
      }

      // Panggil AI (Gemini 1.5 Flash)
      String aiResponseRaw = await _geminiService.classifyReceiptFromImage(
        imageBytes,
        mimeType,
        language: settings.languageCode,
      );

      // PARSER JSON SUPER AMAN
      // Walaupun model AI sudah dikunci ke JSON, kita tetap bersihkan sisa markdown jika ada
      String cleanJson = aiResponseRaw
          .replaceAll(RegExp(r'```json\n?|```'), '')
          .trim();
      int startIndex = cleanJson.indexOf('{');
      int endIndex = cleanJson.lastIndexOf('}');

      if (startIndex != -1 && endIndex != -1) {
        cleanJson = cleanJson.substring(startIndex, endIndex + 1);
        final Map<String, dynamic> data = jsonDecode(cleanJson);

        // Validasi apakah AI benar-benar menemukan barang
        if (data.isEmpty ||
            data['items'] == null ||
            (data['items'] as List).isEmpty) {
          throw Exception("AI tidak dapat menemukan daftar barang.");
        }

        setState(() {
          _scannedData = data;
          _scannedItems = List<Map<String, dynamic>>.from(data['items']);
          _isProcessing = false;
        });

        // Simpan nilai awal tebakan AI murni setelah parsing selesai
        _aiOriginalTotal = _currentTotal;
      } else {
        throw Exception("Format data dari AI tidak dapat diproses.");
      }
    } catch (e) {
      debugPrint("Scan Error: $e");
      setState(() {
        _isProcessing = false;
        _statusText = settings.translate(
          "AI kesulitan membaca struk ini. Coba foto lebih dekat atau input manual.",
          "AI is having trouble reading this receipt. Try taking a closer photo or enter manually.",
        );
      });
    }
  }

  // --- MENGHITUNG TOTAL HARGA BERSIH ---
  double get _currentTotal {
    if (_manualTotalOverride != null) return _manualTotalOverride!;
    double total = 0;
    for (var item in _scannedItems) {
      String rawLineTotal = (item['line_total'] ?? item['price'] ?? 0)
          .toString();
      String cleanPrice = rawLineTotal.replaceAll(RegExp(r'[^\d-]'), '');
      double priceValue = double.tryParse(cleanPrice) ?? 0.0;

      // Jika AI tidak kasih line_total, kalikan manual
      if (item['line_total'] == null && item['price_unit'] != null) {
        String cleanUnit = item['price_unit'].toString().replaceAll(
          RegExp(r'[^\d-]'),
          '',
        );
        double unitValue = double.tryParse(cleanUnit) ?? 0.0;
        double qtyValue = double.tryParse(item['qty'].toString()) ?? 1.0;
        priceValue = unitValue * qtyValue;
      }

      total += priceValue;
    }
    return total;
  }

  // --- 2. PROSES SIMPAN (UPLOAD CLOUDINARY & FIRESTORE) ---
  Future<void> _saveTransaction() async {
    if (_scannedData == null ||
        _scannedItems.isEmpty ||
        _selectedImageFile == null) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final txProvider = Provider.of<TransactionProvider>(
        context,
        listen: false,
      );

      // Upload gambar ke Cloudinary hanya terjadi saat tombol Simpan diklik
      String? uploadedImageUrl;
      if (!kIsWeb) {
        uploadedImageUrl = await _cloudinaryService.uploadImage(
          File(_selectedImageFile!.path),
        );
      }

      // Rangkai nama barang untuk deskripsi
      List<String> itemNames = _scannedItems
          .map((e) => "${e['qty'] ?? 1}x ${e['name']}")
          .toList();
      String storeName = _scannedData!['storeName']?.toString() ?? 'Toko';
      String finalDesc = "$storeName: ${itemNames.join(', ')}";

      // Buat model transaksi
      final tx = TransactionModel(
        userId: auth.user!.uid,
        walletId: _selectedWalletId, // Wallet yang dipilih
        amount: _currentTotal,
        aiPredictedAmount:
            _aiOriginalTotal, // Harga asli yang ditebak AI sebelum diedit
        category: _scannedData!['category']?.toString() ?? 'Belanja',
        description: finalDesc,
        date: DateTime.now(),
        type: _scannedData!['type']?.toString() ?? 'expense',
        source: 'ocr',
        imageUrl: uploadedImageUrl, // Gambar asli sukses masuk ke database
        items: _scannedItems, // Simpan daftar barang yang discan
      );

      // Simpan ke Firestore
      await txProvider.addTransaction(tx);

      setState(() => _isSaving = false);
      if (mounted) {
        final settings = Provider.of<SettingsProvider>(context, listen: false);
        CustomPopup.show(
          context: context,
          title: settings.translate('Berhasil! ✨', 'Success! ✨'),
          message: settings.translate(
            'Transaksi dari struk sudah disimpan.',
            'Transaction from receipt has been saved.',
          ),
          isSuccess: true,
          onConfirm: () {
            Navigator.pop(context); // Kembali ke Dashboard
          },
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        final settings = Provider.of<SettingsProvider>(context, listen: false);
        CustomPopup.show(
          context: context,
          title: settings.translate('Gagal', 'Failed'),
          message:
              '${settings.translate('Error saat menyimpan', 'Error saving')}: $e',
          isSuccess: false,
        );
      }
    }
  }

  void _confirmDeleteItem(int index) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          settings.translate('Hapus Item?', 'Delete Item?'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          settings.translate(
            'Apakah Anda yakin ingin menghapus barang ini dari daftar?',
            'Are you sure you want to delete this item from the list?',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(settings.translate('Batal', 'Cancel')),
          ),
          TextButton(
            onPressed: () {
              setState(() => _scannedItems.removeAt(index));
              Navigator.pop(context);
            },
            child: Text(
              settings.translate('Hapus', 'Delete'),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditTotalDialog() {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final ctrl = TextEditingController(text: _currentTotal.toInt().toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(settings.translate('Koreksi Total', 'Correct Total')),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: settings.translate('Total Sebenarnya', 'Actual Total'),
            prefixText: 'Rp ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(settings.translate('Batal', 'Cancel')),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _manualTotalOverride = double.tryParse(ctrl.text);
              });
              Navigator.pop(context);
            },
            child: Text(settings.translate('Simpan', 'Save')),
          ),
        ],
      ),
    );
  }

  void _editItemPrice(int index) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final item = _scannedItems[index];
    final ctrlName = TextEditingController(text: item['name'].toString());

    String lineTotal = (item['line_total'] ?? 0).toString().replaceAll(
      RegExp(r'[^\d-]'),
      '',
    );
    String unitPrice = (item['price_unit'] ?? item['price'] ?? 0)
        .toString()
        .replaceAll(RegExp(r'[^\d-]'), '');
    if (lineTotal == '0') {
      lineTotal = ((int.tryParse(unitPrice) ?? 0) * (item['qty'] ?? 1))
          .toString();
    }

    final ctrlPrice = TextEditingController(text: lineTotal);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(settings.translate('Edit Barang', 'Edit Item')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: ctrlName,
              decoration: InputDecoration(
                labelText: settings.translate('Nama Barang', 'Item Name'),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrlPrice,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: settings.translate(
                  'Total Harga (Rp)',
                  'Total Price (Rp)',
                ),
                prefixText: 'Rp ',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(settings.translate('Batal', 'Cancel')),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _scannedItems[index]['name'] = ctrlName.text;
                _scannedItems[index]['line_total'] =
                    int.tryParse(ctrlPrice.text) ?? 0;
                // Jika item diedit, bersihkan override manual Total agar menghitung ulang dari item
                _manualTotalOverride = null;
              });
              Navigator.pop(context);
            },
            child: Text(settings.translate('Simpan', 'Save')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    // Inisialisasi statusText jika kosong
    if (_statusText.isEmpty) {
      _statusText = settings.translate(
        "Siap memindai struk belanja Anda.",
        "Ready to scan your shopping receipt.",
      );
    }
    // === LAYAR 2: REVIEW BARANG (Muncul setelah AI selesai scan) ===
    if (_scannedData != null && !_isProcessing) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            settings.translate('Review Barang', 'Review Items'),
            style: TextStyle(
              color: Theme.of(context).textTheme.titleLarge?.color,
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
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                settings.translate(
                  'Hapus barang yang tidak ingin dicatat dengan tap ikon tempat sampah.',
                  'Delete items you don\'t want to record by tapping the trash icon.',
                ),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(26),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    _scannedData!['storeName']?.toString().toUpperCase() ??
                        'TOKO / TEMPAT',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    "${settings.translate('Kategori', 'Category')}: ${settings.translateCategory(_scannedData!['category'])}",
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            ),
            // --- PILIH SUMBER DANA (WALLET) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Consumer<EWalletProvider>(
                builder: (context, walletProvider, _) {
                  final wallets = walletProvider.wallets;

                  // Set default wallet ke Cash jika ada dan belum dipilih
                  if (_selectedWalletId == null && wallets.isNotEmpty) {
                    final cashWallet = wallets
                        .where((w) => w.type == 'cash')
                        .firstOrNull;
                    if (cashWallet != null) {
                      _selectedWalletId = cashWallet.id;
                    } else {
                      _selectedWalletId = wallets.first.id;
                    }
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        settings.translate('Bayar Menggunakan:', 'Pay Using:'),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedWalletId,
                        isExpanded: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Theme.of(context).cardColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: wallets
                            .map(
                              (w) => DropdownMenuItem(
                                value: w.id,
                                child: Row(
                                  children: [
                                    Icon(
                                      w.type == 'cash'
                                          ? Icons.money
                                          : Icons.account_balance_wallet,
                                      size: 16,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      w.name,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const Spacer(),
                                    Text(
                                      NumberFormat.currency(
                                        locale: 'id_ID',
                                        symbol: 'Rp',
                                        decimalDigits: 0,
                                      ).format(w.balance),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _selectedWalletId = val),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _scannedItems.isEmpty
                  ? Center(
                      child: Text(
                        settings.translate(
                          "Semua barang telah dihapus.",
                          "All items have been removed.",
                        ),
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _scannedItems.length,
                      itemBuilder: (context, index) {
                        final item = _scannedItems[index];
                        String unitPrice =
                            (item['price_unit'] ?? item['price'] ?? 0)
                                .toString()
                                .replaceAll(RegExp(r'[^\d-]'), '');
                        String lineTotal = (item['line_total'] ?? 0)
                            .toString()
                            .replaceAll(RegExp(r'[^\d-]'), '');
                        if (lineTotal == '0') {
                          // Fallback jika AI hanya kasih unit price
                          lineTotal =
                              ((int.tryParse(unitPrice) ?? 0) *
                                      (item['qty'] ?? 1))
                                  .toString();
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey.withAlpha(26),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(5),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name'].toString(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Theme.of(
                                          context,
                                        ).textTheme.titleLarge?.color,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          "${item['qty'] ?? 1}x Rp $unitPrice",
                                          style: TextStyle(
                                            color: Theme.of(
                                              context,
                                            ).textTheme.bodyMedium?.color,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          "Rp $lineTotal",
                                          style: const TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                    onPressed: () => _editItemPrice(index),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                    onPressed: () => _confirmDeleteItem(index),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withAlpha(13)
                        : Colors.black.withAlpha(13),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        settings.translate('Total Disimpan', 'Total Saved'),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            'Rp ${NumberFormat('#,###').format(_currentTotal)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              size: 20,
                              color: AppColors.primary,
                            ),
                            onPressed: _showEditTotalDialog,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Jika tombol ditekan, tampilkan indikator loading
                  _isSaving
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _scannedItems.isEmpty
                              ? null
                              : _saveTransaction,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            settings.translate(
                              "Simpan Transaksi",
                              "Save Transaction",
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // === LAYAR 1: TAMPILAN AWAL SCAN (Memilih Gambar) ===
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          settings.translate('Scan Struk', 'Scan Receipt'),
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.document_scanner_rounded,
                size: 100,
                color: _isProcessing ? AppColors.primary : Colors.grey.shade400,
              ),
              const SizedBox(height: 24),
              Text(
                _statusText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 40),

              if (_isProcessing)
                const CircularProgressIndicator()
              else ...[
                if (!kIsWeb)
                  ElevatedButton.icon(
                    onPressed: () => _processReceipt(true),
                    icon: const Icon(Icons.camera_alt),
                    label: Text(
                      settings.translate('Buka Kamera', 'Open Camera'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                if (!kIsWeb) const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => _processReceipt(false),
                  icon: const Icon(Icons.photo_library),
                  label: Text(
                    settings.translate(
                      'Pilih dari Galeri',
                      'Choose from Gallery',
                    ),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddTransactionPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit_note, color: Colors.grey),
                  label: Text(
                    settings.translate(
                      'Gagal Scan? Input Manual Saja',
                      'Scan failed? Use Manual Input',
                    ),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
