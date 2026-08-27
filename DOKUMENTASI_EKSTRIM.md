# 📖 DOKUMENTASI TEKNIS EKSTRIM (SOURCE CODE & API REFERENCE)

Dokumen ini berisi hasil bedah kode secara menyeluruh dari aplikasi **Camelio Finance**. Dokumen ini digenerate secara otomatis dengan memindai setiap baris kode pada folder `lib/`.

## 1. Rincian Direktori & File

### 📄 `lib/app.dart`
- **Jumlah Baris Kode**: 53 lines
- **Class yang Dideklarasikan**: 
  - `SmartFinanceApp`
- **Fungsi / Method Utama**: 
  - `build()`

---

### 📄 `lib/core/constants/api_keys.dart`
- **Jumlah Baris Kode**: 78 lines
- **Class yang Dideklarasikan**: 
  - `ApiKeys`
- **Fungsi / Method Utama**: 
  - `initRemoteConfig()`

---

### 📄 `lib/core/constants/app_colors.dart`
- **Jumlah Baris Kode**: 42 lines
- **Class yang Dideklarasikan**: 
  - `AppColors`

---

### 📄 `lib/core/constants/app_constants.dart`
- **Jumlah Baris Kode**: 6 lines
- **Class yang Dideklarasikan**: 
  - `AppConstants`

---

### 📄 `lib/core/locator.dart`
- **Jumlah Baris Kode**: 24 lines
- **Fungsi / Method Utama**: 
  - `setupLocator()`

---

### 📄 `lib/core/theme/app_theme.dart`
- **Jumlah Baris Kode**: 107 lines
- **Class yang Dideklarasikan**: 
  - `AppTheme`

---

### 📄 `lib/core/utils/brand_utils.dart`
- **Jumlah Baris Kode**: 88 lines
- **Class yang Dideklarasikan**: 
  - `BrandUtils`
- **Fungsi / Method Utama**: 
  - `getBrandIcon()`

---

### 📄 `lib/core/utils/currency_formatter.dart`
- **Jumlah Baris Kode**: 31 lines
- **Class yang Dideklarasikan**: 
  - `CurrencyFormatter`
- **Fungsi / Method Utama**: 
  - `format()`

---

### 📄 `lib/core/utils/date_formatter.dart`
- **Jumlah Baris Kode**: 19 lines
- **Class yang Dideklarasikan**: 
  - `DateFormatter`
- **Fungsi / Method Utama**: 
  - `formatMedium()`
  - `formatTime()`

---

### 📄 `lib/data/models/e_wallet_model.dart`
- **Jumlah Baris Kode**: 82 lines
- **Class yang Dideklarasikan**: 
  - `EWalletModel`
- **Fungsi / Method Utama**: 
  - `toMap()`

---

### 📄 `lib/data/models/expense_model.dart`
- **Jumlah Baris Kode**: 105 lines
- **Class yang Dideklarasikan**: 
  - `ExpenseItem`
  - `ExpenseModel`
- **Fungsi / Method Utama**: 
  - `toJson()`
  - `toFirestore()`

---

### 📄 `lib/data/models/notification_model.dart`
- **Jumlah Baris Kode**: 50 lines
- **Class yang Dideklarasikan**: 
  - `NotificationModel`
- **Fungsi / Method Utama**: 
  - `toMap()`

---

### 📄 `lib/data/models/transaction_model.dart`
- **Jumlah Baris Kode**: 70 lines
- **Class yang Dideklarasikan**: 
  - `TransactionModel`
- **Fungsi / Method Utama**: 
  - `toMap()`

---

### 📄 `lib/data/models/user_model.dart`
- **Jumlah Baris Kode**: 73 lines
- **Class yang Dideklarasikan**: 
  - `UserModel`
- **Fungsi / Method Utama**: 
  - `toFirestore()`

---

### 📄 `lib/data/services/auth_service.dart`
- **Jumlah Baris Kode**: 83 lines
- **Class yang Dideklarasikan**: 
  - `AuthService`
- **Fungsi / Method Utama**: 
  - `signInAnonymously()`
  - `signInWithGoogle()`
  - `registerWithEmail()`
  - `signInWithEmail()`
  - `signOut()`

---

### 📄 `lib/data/services/cloudinary_service.dart`
- **Jumlah Baris Kode**: 64 lines
- **Class yang Dideklarasikan**: 
  - `CloudinaryService`
- **Fungsi / Method Utama**: 
  - `uploadImage()`

---

### 📄 `lib/data/services/csv_logger_service.dart`
- **Jumlah Baris Kode**: 55 lines
- **Class yang Dideklarasikan**: 
  - `CsvLoggerService`
- **Fungsi / Method Utama**: 
  - `logReceiptScan()`

---

### 📄 `lib/data/services/firestore_service.dart`
- **Jumlah Baris Kode**: 344 lines
- **Class yang Dideklarasikan**: 
  - `FirestoreService`
- **Fungsi / Method Utama**: 
  - `createUserProfile()`
  - `updateUserProfile()`
  - `saveEWallet()`
  - `deleteEWallet()`
  - `updateEWalletBalance()`
  - `updateEWalletAccountNumber()`
  - `addTransaction()`
  - `deleteTransaction()`
  - `getTransactionById()`
  - `submitRating()`
  - `addNotification()`
  - `markNotificationAsRead()`
  - `deleteNotification()`
  - `deleteAllNotifications()`

---

### 📄 `lib/data/services/gemini_ai_service.dart`
- **Jumlah Baris Kode**: 214 lines
- **Class yang Dideklarasikan**: 
  - `GeminiAIService`
- **Fungsi / Method Utama**: 
  - `classifyTransaction()`
  - `classifyReceiptFromImage()`
  - `getFinancialAdvice()`
  - `getPortfolioInsight()`
  - `generateContent()`

---

### 📄 `lib/data/services/gmail_service.dart`
- **Jumlah Baris Kode**: 128 lines
- **Class yang Dideklarasikan**: 
  - `GmailService`
- **Fungsi / Method Utama**: 
  - `isSignedIn()`
  - `signIn()`
  - `signOut()`
  - `getGmailApi()`
  - `sendConfirmationEmail()`

---

### 📄 `lib/data/services/notification_service.dart`
- **Jumlah Baris Kode**: 70 lines
- **Class yang Dideklarasikan**: 
  - `NotificationService`
- **Fungsi / Method Utama**: 
  - `init()`
  - `showNotification()`

---

### 📄 `lib/firebase_options.dart`
- **Jumlah Baris Kode**: 95 lines
- **Class yang Dideklarasikan**: 
  - `DefaultFirebaseOptions`

---

### 📄 `lib/main.dart`
- **Jumlah Baris Kode**: 47 lines
- **Fungsi / Method Utama**: 
  - `main()`

---

### 📄 `lib/providers/ai_insight_provider.dart`
- **Jumlah Baris Kode**: 48 lines
- **Class yang Dideklarasikan**: 
  - `AIInsightProvider`
- **Fungsi / Method Utama**: 
  - `askForFinancialInsight()`
  - `clearConversation()`

---

### 📄 `lib/providers/auth_provider.dart`
- **Jumlah Baris Kode**: 301 lines
- **Class yang Dideklarasikan**: 
  - `AuthProvider`
- **Fungsi / Method Utama**: 
  - `loadUserProfile()`
  - `updateProfile()`
  - `updateProfilePicture()`
  - `updateBudget()`
  - `deleteProfilePicture()`
  - `signInWithGoogle()`
  - `signInWithEmail()`
  - `registerWithEmail()`
  - `signOut()`
  - `_handleFirebaseError()`
  - `_setLoading()`
  - `_setError()`
  - `_clearError()`
  - `clearError()`
  - `dispose()`

---

### 📄 `lib/providers/e_wallet_provider.dart`
- **Jumlah Baris Kode**: 349 lines
- **Class yang Dideklarasikan**: 
  - `EWalletProvider`
- **Fungsi / Method Utama**: 
  - `loadWallets()`
  - `saveWallet()`
  - `deleteWallet()`
  - `updateWalletBalance()`
  - `updateWalletAccountNumber()`
  - `syncWithGmail()`
  - `_parseGeminiResponse()`
  - `dispose()`

---

### 📄 `lib/providers/notification_provider.dart`
- **Jumlah Baris Kode**: 115 lines
- **Class yang Dideklarasikan**: 
  - `NotificationProvider`
- **Fungsi / Method Utama**: 
  - `loadNotifications()`
  - `addNotification()`
  - `sendTestNotification()`
  - `Function()`
  - `markAsRead()`
  - `deleteNotification()`
  - `deleteAllNotifications()`
  - `dispose()`

---

### 📄 `lib/providers/settings_provider.dart`
- **Jumlah Baris Kode**: 298 lines
- **Class yang Dideklarasikan**: 
  - `SettingsProvider`
- **Fungsi / Method Utama**: 
  - `toggleTheme()`
  - `toggleNotifications()`
  - `toggleGmailSync()`
  - `resetUserSpecificSettings()`
  - `setLanguage()`
  - `setAccountType()`
  - `toggleCurrency()`
  - `_checkAllPermissions()`
  - `requestPermission()`
  - `requestStoragePermission()`
  - `_fetchRealtimeExchangeRate()`
  - `_loadSettings()`
  - `translate()`
  - `translateCategory()`

---

### 📄 `lib/providers/transaction_provider.dart`
- **Jumlah Baris Kode**: 131 lines
- **Class yang Dideklarasikan**: 
  - `TransactionProvider`
- **Fungsi / Method Utama**: 
  - `toggleBalanceVisibility()`
  - `loadTransactions()`
  - `addTransaction()`
  - `deleteTransaction()`
  - `clearTransactions()`
  - `dispose()`

---

### 📄 `lib/ui/pages/ai_advisor/ai_insight_page.dart`
- **Jumlah Baris Kode**: 423 lines
- **Class yang Dideklarasikan**: 
  - `AiInsightPage`
  - `_AiInsightPageState`
- **Fungsi / Method Utama**: 
  - `initState()`
  - `_generateInsight()`
  - `build()`

---

### 📄 `lib/ui/pages/auth/login_page.dart`
- **Jumlah Baris Kode**: 281 lines
- **Class yang Dideklarasikan**: 
  - `LoginPage`
  - `_LoginPageState`
- **Fungsi / Method Utama**: 
  - `_showLoginSuccess()`
  - `_handleLogin()`
  - `build()`

---

### 📄 `lib/ui/pages/auth/register_page.dart`
- **Jumlah Baris Kode**: 228 lines
- **Class yang Dideklarasikan**: 
  - `RegisterPage`
  - `_RegisterPageState`
- **Fungsi / Method Utama**: 
  - `_handleRegister()`
  - `build()`

---

### 📄 `lib/ui/pages/budget/budget_page.dart`
- **Jumlah Baris Kode**: 266 lines
- **Class yang Dideklarasikan**: 
  - `BudgetPage`
  - `_BudgetPageState`
- **Fungsi / Method Utama**: 
  - `initState()`
  - `_formatNumber()`
  - `dispose()`
  - `build()`

---

### 📄 `lib/ui/pages/dashboard/dashboard_page.dart`
- **Jumlah Baris Kode**: 245 lines
- **Class yang Dideklarasikan**: 
  - `DashboardPage`
  - `_DashboardPageState`
- **Fungsi / Method Utama**: 
  - `build()`
  - `_showZoomableImage()`

---

### 📄 `lib/ui/pages/dashboard/widgets/action_button_row.dart`
- **Jumlah Baris Kode**: 147 lines
- **Class yang Dideklarasikan**: 
  - `ActionButtonRow`
- **Fungsi / Method Utama**: 
  - `build()`
  - `_buildSummaryCard()`

---

### 📄 `lib/ui/pages/dashboard/widgets/balance_card.dart`
- **Jumlah Baris Kode**: 179 lines
- **Class yang Dideklarasikan**: 
  - `BalanceCard`
- **Fungsi / Method Utama**: 
  - `build()`

---

### 📄 `lib/ui/pages/dashboard/widgets/feature_cards.dart`
- **Jumlah Baris Kode**: 153 lines
- **Class yang Dideklarasikan**: 
  - `FeatureCards`
- **Fungsi / Method Utama**: 
  - `build()`
  - `_buildCard()`

---

### 📄 `lib/ui/pages/dashboard/widgets/finance_chart.dart`
- **Jumlah Baris Kode**: 2 lines

---

### 📄 `lib/ui/pages/dashboard/widgets/recent_transactions.dart`
- **Jumlah Baris Kode**: 232 lines
- **Class yang Dideklarasikan**: 
  - `RecentTransactions`
- **Fungsi / Method Utama**: 
  - `build()`

---

### 📄 `lib/ui/pages/e_wallet/add_wallet_page.dart`
- **Jumlah Baris Kode**: 625 lines
- **Class yang Dideklarasikan**: 
  - `AddWalletPage`
  - `_AddWalletPageState`
- **Fungsi / Method Utama**: 
  - `initState()`
  - `_onNameChanged()`
  - `dispose()`
  - `build()`

---

### 📄 `lib/ui/pages/e_wallet/e_wallet_detail_page.dart`
- **Jumlah Baris Kode**: 868 lines
- **Class yang Dideklarasikan**: 
  - `EWalletDetailPage`
  - `_EWalletDetailPageState`
- **Fungsi / Method Utama**: 
  - `build()`
  - `_buildBalanceCard()`
  - `_getWalletBranding()`
  - `_buildTransactionTabs()`
  - `_showEditBalanceDialog()`
  - `_showEditAccountDialog()`
  - `_showDeleteConfirmDialog()`

---

### 📄 `lib/ui/pages/e_wallet/e_wallet_page.dart`
- **Jumlah Baris Kode**: 481 lines
- **Class yang Dideklarasikan**: 
  - `EWalletPage`
  - `_EWalletPageState`
- **Fungsi / Method Utama**: 
  - `initState()`
  - `dispose()`
  - `build()`
  - `_buildAddWalletCard()`
  - `_buildWalletItem()`

---

### 📄 `lib/ui/pages/main/main_page.dart`
- **Jumlah Baris Kode**: 2406 lines
- **Class yang Dideklarasikan**: 
  - `MainPage`
  - `_MainPageState`
- **Fungsi / Method Utama**: 
  - `initState()`
  - `build()`
  - `_buildNavItem()`
  - `_showLogoutDialog()`
  - `_showRatingDialog()`
  - `_buildProfileDrawer()`
  - `_buildDrawerItem()`
  - `_buildDrawerSectionTitle()`
  - `_buildDrawerBox()`
  - `_showEditProfileModal()`
  - `_showImageSourcePicker()`
  - `_buildSourceOption()`
  - `_viewProfilePhoto()`
  - `_pickAndUploadImage()`
  - `_showConfirmDeletePhoto()`
  - `_showAddMenu()`
  - `_buildMenuOption()`
  - `_showAIBottomSheet()`
  - `_handleExportPdf()`
  - `_showPopup()`
  - `_containsKeyword()`
  - `_extractCategoryLocally()`

---

### 📄 `lib/ui/pages/notification/notification_page.dart`
- **Jumlah Baris Kode**: 415 lines
- **Class yang Dideklarasikan**: 
  - `NotificationPage`
  - `_NotificationPageState`
- **Fungsi / Method Utama**: 
  - `initState()`
  - `dispose()`
  - `build()`
  - `_buildEmptyState()`
  - `_buildNotificationItem()`
  - `_buildNotificationIcon()`
  - `_showDeleteAllDialog()`

---

### 📄 `lib/ui/pages/portfolio/portfolio_page.dart`
- **Jumlah Baris Kode**: 1066 lines
- **Class yang Dideklarasikan**: 
  - `PortfolioPage`
  - `_PortfolioPageState`
- **Fungsi / Method Utama**: 
  - `build()`
  - `_getChartTitle()`
  - `_buildTabItem()`
  - `_buildSummaryCards()`
  - `_buildCard()`
  - `_buildChart()`
  - `_buildCalendarStrip()`
  - `_buildChartContent()`
  - `_buildWeeklyChart()`
  - `_buildMonthlyChart()`
  - `_buildYearlyChart()`
  - `_buildChartContainer()`
  - `Function()`
  - `_buildPieChart()`
  - `_buildWalletPieChart()`
  - `_showAIInsight()`

---

### 📄 `lib/ui/pages/settings/about_camelio_page.dart`
- **Jumlah Baris Kode**: 271 lines
- **Class yang Dideklarasikan**: 
  - `AboutCamelioModal`
  - `_AboutCamelioModalState`
- **Fungsi / Method Utama**: 
  - `build()`
  - `_buildAboutFeatureItem()`

---

### 📄 `lib/ui/pages/settings/help_page.dart`
- **Jumlah Baris Kode**: 161 lines
- **Class yang Dideklarasikan**: 
  - `HelpFAQPage`
  - `_HelpFAQPageState`
- **Fungsi / Method Utama**: 
  - `build()`
  - `_buildFAQItem()`

---

### 📄 `lib/ui/pages/settings/pdf_generator.dart`
- **Jumlah Baris Kode**: 552 lines
- **Class yang Dideklarasikan**: 
  - `PdfGenerator`
- **Fungsi / Method Utama**: 
  - `generateAndShare()`
  - `_generateAIAdvice()`
  - `_buildSummaryBox()`
  - `buildExportChart()`

---

### 📄 `lib/ui/pages/settings/permissions_page.dart`
- **Jumlah Baris Kode**: 235 lines
- **Class yang Dideklarasikan**: 
  - `PermissionsPage`
- **Fungsi / Method Utama**: 
  - `build()`
  - `_buildPermissionTile()`

---

### 📄 `lib/ui/pages/settings/policy_page.dart`
- **Jumlah Baris Kode**: 159 lines
- **Class yang Dideklarasikan**: 
  - `PrivacyPolicyPage`
  - `_PrivacyPolicyPageState`
- **Fungsi / Method Utama**: 
  - `build()`

---

### 📄 `lib/ui/pages/settings/privacy_page.dart`
- **Jumlah Baris Kode**: 157 lines
- **Class yang Dideklarasikan**: 
  - `PrivacyControlsPage`
  - `_PrivacyControlsPageState`
- **Fungsi / Method Utama**: 
  - `build()`
  - `_buildInfoCard()`

---

### 📄 `lib/ui/pages/settings/report_generator.dart`
- **Jumlah Baris Kode**: 150 lines
- **Class yang Dideklarasikan**: 
  - `ReportGenerator`
- **Fungsi / Method Utama**: 
  - `buildDashboardReport()`
  - `buildEWalletReport()`

---

### 📄 `lib/ui/pages/settings/settings_page.dart`
- **Jumlah Baris Kode**: 287 lines
- **Class yang Dideklarasikan**: 
  - `SettingsPage`
- **Fungsi / Method Utama**: 
  - `build()`
  - `_buildSectionTitle()`
  - `_buildSettingCard()`
  - `_buildSwitchTile()`
  - `_buildNavigationTile()`

---

### 📄 `lib/ui/pages/settings/version_page.dart`
- **Jumlah Baris Kode**: 346 lines
- **Class yang Dideklarasikan**: 
  - `VersionHistoryPage`
  - `_VersionHistoryPageState`
- **Fungsi / Method Utama**: 
  - `build()`
  - `_buildVersionItem()`

---

### 📄 `lib/ui/pages/splash/splash_page.dart`
- **Jumlah Baris Kode**: 122 lines
- **Class yang Dideklarasikan**: 
  - `SplashPage`
  - `_SplashPageState`
- **Fungsi / Method Utama**: 
  - `initState()`
  - `build()`

---

### 📄 `lib/ui/pages/transaction/add_transaction_page.dart`
- **Jumlah Baris Kode**: 482 lines
- **Class yang Dideklarasikan**: 
  - `CurrencyInputFormatter`
  - `AddTransactionPage`
  - `_AddTransactionPageState`
- **Fungsi / Method Utama**: 
  - `dispose()`
  - `build()`

---

### 📄 `lib/ui/pages/transaction/scan_page.dart`
- **Jumlah Baris Kode**: 14 lines
- **Class yang Dideklarasikan**: 
  - `ScanPage`
- **Fungsi / Method Utama**: 
  - `build()`

---

### 📄 `lib/ui/pages/transaction/scan_receipt_page.dart`
- **Jumlah Baris Kode**: 868 lines
- **Class yang Dideklarasikan**: 
  - `ScanReceiptPage`
  - `_ScanReceiptPageState`
- **Fungsi / Method Utama**: 
  - `_processReceipt()`
  - `_saveTransaction()`
  - `_confirmDeleteItem()`
  - `_showEditTotalDialog()`
  - `_editItemPrice()`
  - `build()`

---

### 📄 `lib/ui/pages/transaction/top_up_page.dart`
- **Jumlah Baris Kode**: 14 lines
- **Class yang Dideklarasikan**: 
  - `TopUpPage`
- **Fungsi / Method Utama**: 
  - `build()`

---

### 📄 `lib/ui/pages/transaction/transaction_list_page.dart`
- **Jumlah Baris Kode**: 186 lines
- **Class yang Dideklarasikan**: 
  - `TransactionListPage`
  - `_TransactionListPageState`
- **Fungsi / Method Utama**: 
  - `build()`

---

### 📄 `lib/ui/pages/transaction/transfer_page.dart`
- **Jumlah Baris Kode**: 16 lines
- **Class yang Dideklarasikan**: 
  - `TransferPage`
- **Fungsi / Method Utama**: 
  - `build()`

---

### 📄 `lib/ui/widgets/custom_popup.dart`
- **Jumlah Baris Kode**: 77 lines
- **Class yang Dideklarasikan**: 
  - `CustomPopup`
- **Fungsi / Method Utama**: 
  - `show()`

---

### 📄 `lib/ui/widgets/custom_text_field.dart`
- **Jumlah Baris Kode**: 101 lines
- **Class yang Dideklarasikan**: 
  - `CustomTextField`
  - `_CustomTextFieldState`
- **Fungsi / Method Utama**: 
  - `initState()`
  - `build()`

---

### 📄 `lib/ui/widgets/transaction_card.dart`
- **Jumlah Baris Kode**: 367 lines
- **Class yang Dideklarasikan**: 
  - `TransactionCardListTile`
- **Fungsi / Method Utama**: 
  - `build()`
  - `_showItemsBottomSheet()`
  - `_buildTransactionIcon()`

---

