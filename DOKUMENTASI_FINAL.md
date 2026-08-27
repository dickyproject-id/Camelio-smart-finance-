
<div class="logo-container">
  <img src="file:///Users/prasdadestriyana/Flutter_Projects/smart_finance_app/assets/logo_camelio.png" width="150" alt="Logo Camelio">
</div>

<div class="center-title">Dokumentasi Teknis Lengkap & API Reference</div>
<div class="center-subtitle">(Dokumentasi Arsitektur Kode Camelio Finance)</div>

<div class="intro-card">
  <p>Halo! Selamat datang di <b>Dokumentasi Source Code Camelio Finance</b>.</p>
  <p>Dokumen ini dirancang khusus untuk memberikan gambaran arsitektur sistem (High-Level) sekaligus bedah kode spesifik (Low-Level) pada keseluruhan project ini.</p>
  <p>Dokumen ini mengekstrak secara otomatis semua file, class, dan fungsi dari dalam <i>source code</i> aplikasi untuk memastikan tidak ada file yang terlewat. Mari kita mulai!</p>
</div>

<h2 class="section-title">🧱 1. Tumpukan Teknologi (Tech Stack) Utama</h2>

- **Framework**: Flutter (Dart)
- **Architecture**: MVVM dengan Provider & GetIt (Service Locator)
- **Backend & Auth**: Firebase Auth, Cloud Firestore
- **Kecerdasan Buatan (AI)**: Google Gemini 1.5 Flash (Vision & LLM)
- **Cloud Storage**: Cloudinary (Image Optimization & Hosting)

<h2 class="section-title">🗄️ 2. Struktur Database (Firestore NoSQL)</h2>

1. **`users`**: Profil Pengguna (balance, monthlyBudget, dll)
2. **`wallets`**: Data E-Wallet dan Rekening Bank
3. **`transactions`**: History Pemasukan/Pengeluaran beserta detail item (OCR AI)
4. **`notifications`** & **`rating`**: Log peringatan AI Insight dan Feedback User.

<h2 class="section-title">🤖 3. Alur Kerja Integrasi AI (Gemini 1.5)</h2>

- **Scan Struk OCR**: Foto diupload ke Cloudinary -> URL dikirim ke Gemini Vision -> Ekstrak Entity JSON -> Simpan ke Firestore.
- **Input Suara/Teks Pintar**: Prompt Chat dikirim ke Gemini LLM -> Ekstrak nominal dan kategori secara otomatis.
- **AI Financial Advisor**: Sistem fetch data transaksi 30 hari -> Dikirim ke Gemini -> Gemini berperan sebagai Konsultan Bisnis UMKM dan mengembalikan rekomendasi.

<h2 class="section-title">📂 4. Bedah Kode Sumber (API Reference)</h2>

Berikut adalah rincian lengkap dari seluruh file `.dart` yang ada di folder `lib/`, beserta `class` dan `fungsi` yang ada di dalamnya:

### 📄 `lib/app.dart`
- **Panjang Baris**: 53 lines
- **Class Name**: <code>SmartFinanceApp</code>
- **Method / Fungsi**: <code>build()</code>

<hr>

### 📄 `lib/core/constants/api_keys.dart`
- **Panjang Baris**: 78 lines
- **Class Name**: <code>ApiKeys</code>
- **Method / Fungsi**: <code>initRemoteConfig()</code>

<hr>

### 📄 `lib/core/constants/app_colors.dart`
- **Panjang Baris**: 42 lines
- **Class Name**: <code>AppColors</code>

<hr>

### 📄 `lib/core/constants/app_constants.dart`
- **Panjang Baris**: 6 lines
- **Class Name**: <code>AppConstants</code>

<hr>

### 📄 `lib/core/locator.dart`
- **Panjang Baris**: 24 lines
- **Method / Fungsi**: <code>setupLocator()</code>

<hr>

### 📄 `lib/core/theme/app_theme.dart`
- **Panjang Baris**: 107 lines
- **Class Name**: <code>AppTheme</code>

<hr>

### 📄 `lib/core/utils/brand_utils.dart`
- **Panjang Baris**: 88 lines
- **Class Name**: <code>BrandUtils</code>
- **Method / Fungsi**: <code>getBrandIcon()</code>

<hr>

### 📄 `lib/core/utils/currency_formatter.dart`
- **Panjang Baris**: 31 lines
- **Class Name**: <code>CurrencyFormatter</code>
- **Method / Fungsi**: <code>format()</code>

<hr>

### 📄 `lib/core/utils/date_formatter.dart`
- **Panjang Baris**: 19 lines
- **Class Name**: <code>DateFormatter</code>
- **Method / Fungsi**: <code>formatMedium()</code>, <code>formatTime()</code>

<hr>

### 📄 `lib/data/models/e_wallet_model.dart`
- **Panjang Baris**: 82 lines
- **Class Name**: <code>EWalletModel</code>
- **Method / Fungsi**: <code>toMap()</code>

<hr>

### 📄 `lib/data/models/expense_model.dart`
- **Panjang Baris**: 105 lines
- **Class Name**: <code>ExpenseItem</code>, <code>ExpenseModel</code>
- **Method / Fungsi**: <code>toJson()</code>, <code>toFirestore()</code>

<hr>

### 📄 `lib/data/models/notification_model.dart`
- **Panjang Baris**: 50 lines
- **Class Name**: <code>NotificationModel</code>
- **Method / Fungsi**: <code>toMap()</code>

<hr>

### 📄 `lib/data/models/transaction_model.dart`
- **Panjang Baris**: 70 lines
- **Class Name**: <code>TransactionModel</code>
- **Method / Fungsi**: <code>toMap()</code>

<hr>

### 📄 `lib/data/models/user_model.dart`
- **Panjang Baris**: 73 lines
- **Class Name**: <code>UserModel</code>
- **Method / Fungsi**: <code>toFirestore()</code>

<hr>

### 📄 `lib/data/services/auth_service.dart`
- **Panjang Baris**: 83 lines
- **Class Name**: <code>AuthService</code>
- **Method / Fungsi**: <code>signInAnonymously()</code>, <code>signInWithGoogle()</code>, <code>registerWithEmail()</code>, <code>signInWithEmail()</code>, <code>signOut()</code>

<hr>

### 📄 `lib/data/services/cloudinary_service.dart`
- **Panjang Baris**: 64 lines
- **Class Name**: <code>CloudinaryService</code>
- **Method / Fungsi**: <code>uploadImage()</code>

<hr>

### 📄 `lib/data/services/csv_logger_service.dart`
- **Panjang Baris**: 55 lines
- **Class Name**: <code>CsvLoggerService</code>
- **Method / Fungsi**: <code>logReceiptScan()</code>

<hr>

### 📄 `lib/data/services/firestore_service.dart`
- **Panjang Baris**: 344 lines
- **Class Name**: <code>FirestoreService</code>
- **Method / Fungsi**: <code>createUserProfile()</code>, <code>updateUserProfile()</code>, <code>saveEWallet()</code>, <code>deleteEWallet()</code>, <code>updateEWalletBalance()</code>, <code>updateEWalletAccountNumber()</code>, <code>addTransaction()</code>, <code>deleteTransaction()</code>, <code>getTransactionById()</code>, <code>submitRating()</code>, <code>addNotification()</code>, <code>markNotificationAsRead()</code>, <code>deleteNotification()</code>, <code>deleteAllNotifications()</code>

<hr>

### 📄 `lib/data/services/gemini_ai_service.dart`
- **Panjang Baris**: 214 lines
- **Class Name**: <code>GeminiAIService</code>
- **Method / Fungsi**: <code>classifyTransaction()</code>, <code>classifyReceiptFromImage()</code>, <code>getFinancialAdvice()</code>, <code>getPortfolioInsight()</code>, <code>generateContent()</code>

<hr>

### 📄 `lib/data/services/gmail_service.dart`
- **Panjang Baris**: 128 lines
- **Class Name**: <code>GmailService</code>
- **Method / Fungsi**: <code>isSignedIn()</code>, <code>signIn()</code>, <code>signOut()</code>, <code>getGmailApi()</code>, <code>sendConfirmationEmail()</code>

<hr>

### 📄 `lib/data/services/notification_service.dart`
- **Panjang Baris**: 70 lines
- **Class Name**: <code>NotificationService</code>
- **Method / Fungsi**: <code>init()</code>, <code>showNotification()</code>

<hr>

### 📄 `lib/firebase_options.dart`
- **Panjang Baris**: 95 lines
- **Class Name**: <code>DefaultFirebaseOptions</code>

<hr>

### 📄 `lib/main.dart`
- **Panjang Baris**: 47 lines
- **Method / Fungsi**: <code>main()</code>

<hr>

### 📄 `lib/providers/ai_insight_provider.dart`
- **Panjang Baris**: 48 lines
- **Class Name**: <code>AIInsightProvider</code>
- **Method / Fungsi**: <code>askForFinancialInsight()</code>, <code>clearConversation()</code>

<hr>

### 📄 `lib/providers/auth_provider.dart`
- **Panjang Baris**: 301 lines
- **Class Name**: <code>AuthProvider</code>
- **Method / Fungsi**: <code>loadUserProfile()</code>, <code>updateProfile()</code>, <code>updateProfilePicture()</code>, <code>updateBudget()</code>, <code>deleteProfilePicture()</code>, <code>signInWithGoogle()</code>, <code>signInWithEmail()</code>, <code>registerWithEmail()</code>, <code>signOut()</code>, <code>_handleFirebaseError()</code>, <code>_setLoading()</code>, <code>_setError()</code>, <code>_clearError()</code>, <code>clearError()</code>, <code>dispose()</code>

<hr>

### 📄 `lib/providers/e_wallet_provider.dart`
- **Panjang Baris**: 349 lines
- **Class Name**: <code>EWalletProvider</code>
- **Method / Fungsi**: <code>loadWallets()</code>, <code>saveWallet()</code>, <code>deleteWallet()</code>, <code>updateWalletBalance()</code>, <code>updateWalletAccountNumber()</code>, <code>syncWithGmail()</code>, <code>_parseGeminiResponse()</code>, <code>dispose()</code>

<hr>

### 📄 `lib/providers/notification_provider.dart`
- **Panjang Baris**: 115 lines
- **Class Name**: <code>NotificationProvider</code>
- **Method / Fungsi**: <code>loadNotifications()</code>, <code>addNotification()</code>, <code>sendTestNotification()</code>, <code>Function()</code>, <code>markAsRead()</code>, <code>deleteNotification()</code>, <code>deleteAllNotifications()</code>, <code>dispose()</code>

<hr>

### 📄 `lib/providers/settings_provider.dart`
- **Panjang Baris**: 298 lines
- **Class Name**: <code>SettingsProvider</code>
- **Method / Fungsi**: <code>toggleTheme()</code>, <code>toggleNotifications()</code>, <code>toggleGmailSync()</code>, <code>resetUserSpecificSettings()</code>, <code>setLanguage()</code>, <code>setAccountType()</code>, <code>toggleCurrency()</code>, <code>_checkAllPermissions()</code>, <code>requestPermission()</code>, <code>requestStoragePermission()</code>, <code>_fetchRealtimeExchangeRate()</code>, <code>_loadSettings()</code>, <code>translate()</code>, <code>translateCategory()</code>

<hr>

### 📄 `lib/providers/transaction_provider.dart`
- **Panjang Baris**: 131 lines
- **Class Name**: <code>TransactionProvider</code>
- **Method / Fungsi**: <code>toggleBalanceVisibility()</code>, <code>loadTransactions()</code>, <code>addTransaction()</code>, <code>deleteTransaction()</code>, <code>clearTransactions()</code>, <code>dispose()</code>

<hr>

### 📄 `lib/ui/pages/ai_advisor/ai_insight_page.dart`
- **Panjang Baris**: 423 lines
- **Class Name**: <code>AiInsightPage</code>, <code>_AiInsightPageState</code>
- **Method / Fungsi**: <code>initState()</code>, <code>_generateInsight()</code>, <code>build()</code>

<hr>

### 📄 `lib/ui/pages/auth/login_page.dart`
- **Panjang Baris**: 281 lines
- **Class Name**: <code>LoginPage</code>, <code>_LoginPageState</code>
- **Method / Fungsi**: <code>_showLoginSuccess()</code>, <code>_handleLogin()</code>, <code>build()</code>

<hr>

### 📄 `lib/ui/pages/auth/register_page.dart`
- **Panjang Baris**: 228 lines
- **Class Name**: <code>RegisterPage</code>, <code>_RegisterPageState</code>
- **Method / Fungsi**: <code>_handleRegister()</code>, <code>build()</code>

<hr>

### 📄 `lib/ui/pages/budget/budget_page.dart`
- **Panjang Baris**: 266 lines
- **Class Name**: <code>BudgetPage</code>, <code>_BudgetPageState</code>
- **Method / Fungsi**: <code>initState()</code>, <code>_formatNumber()</code>, <code>dispose()</code>, <code>build()</code>

<hr>

### 📄 `lib/ui/pages/dashboard/dashboard_page.dart`
- **Panjang Baris**: 245 lines
- **Class Name**: <code>DashboardPage</code>, <code>_DashboardPageState</code>
- **Method / Fungsi**: <code>build()</code>, <code>_showZoomableImage()</code>

<hr>

### 📄 `lib/ui/pages/dashboard/widgets/action_button_row.dart`
- **Panjang Baris**: 147 lines
- **Class Name**: <code>ActionButtonRow</code>
- **Method / Fungsi**: <code>build()</code>, <code>_buildSummaryCard()</code>

<hr>

### 📄 `lib/ui/pages/dashboard/widgets/balance_card.dart`
- **Panjang Baris**: 179 lines
- **Class Name**: <code>BalanceCard</code>
- **Method / Fungsi**: <code>build()</code>

<hr>

### 📄 `lib/ui/pages/dashboard/widgets/feature_cards.dart`
- **Panjang Baris**: 153 lines
- **Class Name**: <code>FeatureCards</code>
- **Method / Fungsi**: <code>build()</code>, <code>_buildCard()</code>

<hr>

### 📄 `lib/ui/pages/dashboard/widgets/recent_transactions.dart`
- **Panjang Baris**: 232 lines
- **Class Name**: <code>RecentTransactions</code>
- **Method / Fungsi**: <code>build()</code>

<hr>

### 📄 `lib/ui/pages/e_wallet/add_wallet_page.dart`
- **Panjang Baris**: 625 lines
- **Class Name**: <code>AddWalletPage</code>, <code>_AddWalletPageState</code>
- **Method / Fungsi**: <code>initState()</code>, <code>_onNameChanged()</code>, <code>dispose()</code>, <code>build()</code>

<hr>

### 📄 `lib/ui/pages/e_wallet/e_wallet_detail_page.dart`
- **Panjang Baris**: 868 lines
- **Class Name**: <code>EWalletDetailPage</code>, <code>_EWalletDetailPageState</code>
- **Method / Fungsi**: <code>build()</code>, <code>_buildBalanceCard()</code>, <code>_getWalletBranding()</code>, <code>_buildTransactionTabs()</code>, <code>_showEditBalanceDialog()</code>, <code>_showEditAccountDialog()</code>, <code>_showDeleteConfirmDialog()</code>

<hr>

### 📄 `lib/ui/pages/e_wallet/e_wallet_page.dart`
- **Panjang Baris**: 481 lines
- **Class Name**: <code>EWalletPage</code>, <code>_EWalletPageState</code>
- **Method / Fungsi**: <code>initState()</code>, <code>dispose()</code>, <code>build()</code>, <code>_buildAddWalletCard()</code>, <code>_buildWalletItem()</code>

<hr>

### 📄 `lib/ui/pages/main/main_page.dart`
- **Panjang Baris**: 2406 lines
- **Class Name**: <code>MainPage</code>, <code>_MainPageState</code>
- **Method / Fungsi**: <code>initState()</code>, <code>build()</code>, <code>_buildNavItem()</code>, <code>_showLogoutDialog()</code>, <code>_showRatingDialog()</code>, <code>_buildProfileDrawer()</code>, <code>_buildDrawerItem()</code>, <code>_buildDrawerSectionTitle()</code>, <code>_buildDrawerBox()</code>, <code>_showEditProfileModal()</code>, <code>_showImageSourcePicker()</code>, <code>_buildSourceOption()</code>, <code>_viewProfilePhoto()</code>, <code>_pickAndUploadImage()</code>, <code>_showConfirmDeletePhoto()</code>, <code>_showAddMenu()</code>, <code>_buildMenuOption()</code>, <code>_showAIBottomSheet()</code>, <code>_handleExportPdf()</code>, <code>_showPopup()</code>, <code>_containsKeyword()</code>, <code>_extractCategoryLocally()</code>

<hr>

### 📄 `lib/ui/pages/notification/notification_page.dart`
- **Panjang Baris**: 415 lines
- **Class Name**: <code>NotificationPage</code>, <code>_NotificationPageState</code>
- **Method / Fungsi**: <code>initState()</code>, <code>dispose()</code>, <code>build()</code>, <code>_buildEmptyState()</code>, <code>_buildNotificationItem()</code>, <code>_buildNotificationIcon()</code>, <code>_showDeleteAllDialog()</code>

<hr>

### 📄 `lib/ui/pages/portfolio/portfolio_page.dart`
- **Panjang Baris**: 1066 lines
- **Class Name**: <code>PortfolioPage</code>, <code>_PortfolioPageState</code>
- **Method / Fungsi**: <code>build()</code>, <code>_getChartTitle()</code>, <code>_buildTabItem()</code>, <code>_buildSummaryCards()</code>, <code>_buildCard()</code>, <code>_buildChart()</code>, <code>_buildCalendarStrip()</code>, <code>_buildChartContent()</code>, <code>_buildWeeklyChart()</code>, <code>_buildMonthlyChart()</code>, <code>_buildYearlyChart()</code>, <code>_buildChartContainer()</code>, <code>Function()</code>, <code>_buildPieChart()</code>, <code>_buildWalletPieChart()</code>, <code>_showAIInsight()</code>

<hr>

### 📄 `lib/ui/pages/settings/about_camelio_page.dart`
- **Panjang Baris**: 271 lines
- **Class Name**: <code>AboutCamelioModal</code>, <code>_AboutCamelioModalState</code>
- **Method / Fungsi**: <code>build()</code>, <code>_buildAboutFeatureItem()</code>

<hr>

### 📄 `lib/ui/pages/settings/help_page.dart`
- **Panjang Baris**: 161 lines
- **Class Name**: <code>HelpFAQPage</code>, <code>_HelpFAQPageState</code>
- **Method / Fungsi**: <code>build()</code>, <code>_buildFAQItem()</code>

<hr>

### 📄 `lib/ui/pages/settings/pdf_generator.dart`
- **Panjang Baris**: 552 lines
- **Class Name**: <code>PdfGenerator</code>
- **Method / Fungsi**: <code>generateAndShare()</code>, <code>_generateAIAdvice()</code>, <code>_buildSummaryBox()</code>, <code>buildExportChart()</code>

<hr>

### 📄 `lib/ui/pages/settings/permissions_page.dart`
- **Panjang Baris**: 235 lines
- **Class Name**: <code>PermissionsPage</code>
- **Method / Fungsi**: <code>build()</code>, <code>_buildPermissionTile()</code>

<hr>

### 📄 `lib/ui/pages/settings/policy_page.dart`
- **Panjang Baris**: 159 lines
- **Class Name**: <code>PrivacyPolicyPage</code>, <code>_PrivacyPolicyPageState</code>
- **Method / Fungsi**: <code>build()</code>

<hr>

### 📄 `lib/ui/pages/settings/privacy_page.dart`
- **Panjang Baris**: 157 lines
- **Class Name**: <code>PrivacyControlsPage</code>, <code>_PrivacyControlsPageState</code>
- **Method / Fungsi**: <code>build()</code>, <code>_buildInfoCard()</code>

<hr>

### 📄 `lib/ui/pages/settings/report_generator.dart`
- **Panjang Baris**: 150 lines
- **Class Name**: <code>ReportGenerator</code>
- **Method / Fungsi**: <code>buildDashboardReport()</code>, <code>buildEWalletReport()</code>

<hr>

### 📄 `lib/ui/pages/settings/settings_page.dart`
- **Panjang Baris**: 287 lines
- **Class Name**: <code>SettingsPage</code>
- **Method / Fungsi**: <code>build()</code>, <code>_buildSectionTitle()</code>, <code>_buildSettingCard()</code>, <code>_buildSwitchTile()</code>, <code>_buildNavigationTile()</code>

<hr>

### 📄 `lib/ui/pages/settings/version_page.dart`
- **Panjang Baris**: 346 lines
- **Class Name**: <code>VersionHistoryPage</code>, <code>_VersionHistoryPageState</code>
- **Method / Fungsi**: <code>build()</code>, <code>_buildVersionItem()</code>

<hr>

### 📄 `lib/ui/pages/splash/splash_page.dart`
- **Panjang Baris**: 122 lines
- **Class Name**: <code>SplashPage</code>, <code>_SplashPageState</code>
- **Method / Fungsi**: <code>initState()</code>, <code>build()</code>

<hr>

### 📄 `lib/ui/pages/transaction/add_transaction_page.dart`
- **Panjang Baris**: 482 lines
- **Class Name**: <code>CurrencyInputFormatter</code>, <code>AddTransactionPage</code>, <code>_AddTransactionPageState</code>
- **Method / Fungsi**: <code>dispose()</code>, <code>build()</code>

<hr>

### 📄 `lib/ui/pages/transaction/scan_page.dart`
- **Panjang Baris**: 14 lines
- **Class Name**: <code>ScanPage</code>
- **Method / Fungsi**: <code>build()</code>

<hr>

### 📄 `lib/ui/pages/transaction/scan_receipt_page.dart`
- **Panjang Baris**: 868 lines
- **Class Name**: <code>ScanReceiptPage</code>, <code>_ScanReceiptPageState</code>
- **Method / Fungsi**: <code>_processReceipt()</code>, <code>_saveTransaction()</code>, <code>_confirmDeleteItem()</code>, <code>_showEditTotalDialog()</code>, <code>_editItemPrice()</code>, <code>build()</code>

<hr>

### 📄 `lib/ui/pages/transaction/top_up_page.dart`
- **Panjang Baris**: 14 lines
- **Class Name**: <code>TopUpPage</code>
- **Method / Fungsi**: <code>build()</code>

<hr>

### 📄 `lib/ui/pages/transaction/transaction_list_page.dart`
- **Panjang Baris**: 186 lines
- **Class Name**: <code>TransactionListPage</code>, <code>_TransactionListPageState</code>
- **Method / Fungsi**: <code>build()</code>

<hr>

### 📄 `lib/ui/pages/transaction/transfer_page.dart`
- **Panjang Baris**: 16 lines
- **Class Name**: <code>TransferPage</code>
- **Method / Fungsi**: <code>build()</code>

<hr>

### 📄 `lib/ui/widgets/custom_popup.dart`
- **Panjang Baris**: 77 lines
- **Class Name**: <code>CustomPopup</code>
- **Method / Fungsi**: <code>show()</code>

<hr>

### 📄 `lib/ui/widgets/custom_text_field.dart`
- **Panjang Baris**: 101 lines
- **Class Name**: <code>CustomTextField</code>, <code>_CustomTextFieldState</code>
- **Method / Fungsi**: <code>initState()</code>, <code>build()</code>

<hr>

### 📄 `lib/ui/widgets/transaction_card.dart`
- **Panjang Baris**: 367 lines
- **Class Name**: <code>TransactionCardListTile</code>
- **Method / Fungsi**: <code>build()</code>, <code>_showItemsBottomSheet()</code>, <code>_buildTransactionIcon()</code>

<hr>

