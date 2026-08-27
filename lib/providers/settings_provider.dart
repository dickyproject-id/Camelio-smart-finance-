import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import '../core/locator.dart';
import '../data/services/gmail_service.dart';

class SettingsProvider with ChangeNotifier {
  // Config States
  ThemeMode _themeMode = ThemeMode.light;
  String _languageCode = 'id'; // 'id' atau 'en'
  String _accountType = 'Personal'; // 'Personal' atau 'UMKM'
  bool _isUSD = false; // false = IDR, true = USD

  // Cache live exchange rate (USD to IDR)
  double _usdToIdrRate = 16000.0; // Default fallback fallback
  bool _isLoadingRate = false;
  bool _notificationsEnabled = true;

  // Permission States
  bool _cameraPermission = false;
  bool _microPermission = false;
  bool _storagePermission = false;
  bool _gmailSyncEnabled = false;

  ThemeMode get themeMode => _themeMode;
  String get languageCode => _languageCode;
  String get accountType => _accountType;
  bool get isUSD => _isUSD;
  double get usdToIdrRate => _usdToIdrRate;
  bool get isLoadingRate => _isLoadingRate;
  bool get notificationsEnabled => _notificationsEnabled;

  bool get cameraPermission => _cameraPermission;
  bool get microPermission => _microPermission;
  bool get storagePermission => _storagePermission;
  bool get gmailSyncEnabled => _gmailSyncEnabled;

  SettingsProvider() {
    _loadSettings();
    _fetchRealtimeExchangeRate();
    _checkAllPermissions();
  }

  // ==== 1. MANAJEMEN TEMA ====
  void toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', isDark);
  }

  void toggleNotifications(bool val) async {
    _notificationsEnabled = val;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('notificationsEnabled', val);
  }

  Future<bool> toggleGmailSync(bool val) async {
    final gmailService = locator<GmailService>();
    if (val) {
      final user = await gmailService.signIn();
      if (user == null) {
        _gmailSyncEnabled = false;
        notifyListeners();
        return false;
      }
    } else {
      await gmailService.signOut();
    }

    _gmailSyncEnabled = val;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('gmailSyncEnabled', val);
    return true;
  }

  Future<void> resetUserSpecificSettings() async {
    _gmailSyncEnabled = false;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('gmailSyncEnabled');
  }

  // ==== 2. MANAJEMEN BAHASA & AKUN ====
  void setLanguage(String code) async {
    _languageCode = code;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('languageCode', code);
  }

  void setAccountType(String type) async {
    _accountType = type;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('accountType', type);
  }

  // ==== 3. MANAJEMEN KURS MATA UANG ====
  void toggleCurrency(bool toUSD) async {
    _isUSD = toUSD;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isUSD', toUSD);

    // Perbarui rate setiap kali user mengganti untuk dapet rate paling fresh
    if (toUSD) _fetchRealtimeExchangeRate();
  }

  // ==== 4. MANAJEMEN IZIN (PERMISSIONS) ====
  Future<void> _checkAllPermissions() async {
    _cameraPermission = await Permission.camera.status.isGranted;
    _microPermission = await Permission.microphone.status.isGranted;
    // photos is safer for iOS/Android 13+
    _storagePermission =
        await Permission.photos.status.isGranted ||
        await Permission.storage.status.isGranted;
    notifyListeners();
  }

  Future<void> requestPermission(Permission permission) async {
    final status = await permission.request();
    await _checkAllPermissions(); // Refresh states

    if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  Future<void> requestStoragePermission() async {
    // Mencoba request photos (Android 13+ / iOS)
    PermissionStatus status = await Permission.photos.request();

    // Jika tidak diberikan (mungkin Android lama), coba request storage
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }

    await _checkAllPermissions(); // Refresh states

    if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  // ==== INTERNAL: FETCH EXCHANGE RATE ====
  Future<void> _fetchRealtimeExchangeRate() async {
    _isLoadingRate = true;
    notifyListeners();

    try {
      final url = Uri.parse('https://api.exchangerate-api.com/v4/latest/USD');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['rates'] != null && data['rates']['IDR'] != null) {
          _usdToIdrRate = double.parse(data['rates']['IDR'].toString());
        }
      }
    } catch (e) {
      debugPrint('Gagal menarik data kurs live dari internasional: $e');
    } finally {
      _isLoadingRate = false;
      notifyListeners();
    }
  }

  // ==== INTERNAL: MEMUAT SETTING YANG DISIMPAN SEBELUMNYA ====
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey('isDarkMode')) {
      _themeMode = prefs.getBool('isDarkMode')!
          ? ThemeMode.dark
          : ThemeMode.light;
    }

    if (prefs.containsKey('languageCode')) {
      _languageCode = prefs.getString('languageCode')!;
    }

    if (prefs.containsKey('isUSD')) {
      _isUSD = prefs.getBool('isUSD')!;
    }

    if (prefs.containsKey('notificationsEnabled')) {
      _notificationsEnabled = prefs.getBool('notificationsEnabled')!;
    }

    if (prefs.containsKey('gmailSyncEnabled')) {
      _gmailSyncEnabled = prefs.getBool('gmailSyncEnabled')!;
    }

    if (prefs.containsKey('accountType')) {
      _accountType = prefs.getString('accountType')!;
    }

    notifyListeners();
  }

  /// Helper untuk translasi statis sederhana berdasarkan `_languageCode`
  String translate(String indonesianText, String englishText) {
    return _languageCode == 'en' ? englishText : indonesianText;
  }

  /// Helper untuk translasi kategori transaksi secara dinamis (Dua arah)
  String translateCategory(String category) {
    if (category.isEmpty) return category;

    final Map<String, String> toEnglish = {
      'Makanan': 'Dining',
      'Minuman': 'Drinks',
      'Belanja': 'Shopping',
      'Transportasi': 'Transport',
      'Hiburan': 'Entertainment',
      'Tagihan': 'Bills',
      'Transfer': 'Transfer',
      'Lainnya': 'Others',
      'Gaji': 'Salary',
      'Bonus': 'Bonus',
      'Investasi': 'Investment',
      'Elektronik': 'Electronics',
      'Kesehatan': 'Health',
      'Pendidikan': 'Education',
      'Kebutuhan Rumah': 'Household',
      'Langganan': 'Subscription',
      'Top Up': 'Top Up',
      'Pinjaman': 'Loan',
      'Perlengkapan Rumah': 'Home Equipment',
      'Perawatan Rumah': 'Home Maintenance',
      'Kendaraan': 'Vehicle',
      'Olahraga': 'Sports',
      'Liburan': 'Vacation',
      'Pakaian & Aksesoris': 'Clothing',
    };

    final Map<String, String> toIndo = {
      'Dining': 'Makanan',
      'Food': 'Makanan',
      'Drinks': 'Minuman',
      'Beverage': 'Minuman',
      'Shopping': 'Belanja',
      'Groceries': 'Belanja',
      'Transport': 'Transportasi',
      'Transportation': 'Transportasi',
      'Fuel': 'Transportasi',
      'Entertainment': 'Hiburan',
      'Movie': 'Hiburan',
      'Bills': 'Tagihan',
      'Electricity': 'Tagihan',
      'Water': 'Tagihan',
      'Internet': 'Tagihan',
      'Transfer': 'Transfer',
      'Others': 'Lainnya',
      'Other': 'Lainnya',
      'Salary': 'Gaji',
      'Bonus': 'Bonus',
      'Investment': 'Investasi',
      'Electronics': 'Elektronik',
      'Gadget': 'Elektronik',
      'Health': 'Kesehatan',
      'Medical': 'Kesehatan',
      'Education': 'Pendidikan',
      'School': 'Pendidikan',
      'Household': 'Kebutuhan Rumah',
      'Home': 'Kebutuhan Rumah',
      'Subscription': 'Langganan',
      'Streaming': 'Langganan',
      'Top Up': 'Top Up',
      'E-Wallet': 'Top Up',
      'Cashback': 'Bonus',
      'Refund': 'Bonus',
      'Loan': 'Pinjaman',
      'Debt': 'Pinjaman',
      'Home Equipment': 'Perlengkapan Rumah',
      'Home Maintenance': 'Perawatan Rumah',
      'Vehicle': 'Kendaraan',
      'Sports': 'Olahraga',
      'Vacation': 'Liburan',
      'Clothing': 'Pakaian & Aksesoris',
      'Clothing & Accessories': 'Pakaian & Aksesoris',
    };

    if (_languageCode == 'en') {
      if (toIndo.containsKey(category)) return category;
      return toEnglish[category] ?? category;
    } else {
      if (toEnglish.containsKey(category)) return category;
      return toIndo[category] ?? category;
    }
  }
}
