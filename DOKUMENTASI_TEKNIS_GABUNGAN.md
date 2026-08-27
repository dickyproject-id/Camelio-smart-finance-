<div class="logo-container">
  <img src="file:///Users/prasdadestriyana/Flutter_Projects/smart_finance_app/assets/logo_camelio.png" width="150" alt="Logo Camelio">
</div>

<div class="center-title">Dokumentasi Teknis & Source Code Lengkap</div>
<div class="center-subtitle">(Buku Panduan Teknis Pengembangan Camelio Finance)</div>

---

<h2 class="section-title">1. Tumpukan Teknologi (Tech Stack)</h2>

Aplikasi ini dibangun menggunakan teknologi modern yang berfokus pada skalabilitas dan integrasi AI:

- **Frontend / Mobile Framework**: Flutter (Dart) - Mendukung Cross-Platform.
- **State Management**: `provider` - Untuk mengelola state UI secara reaktif dan efisien.
- **Dependency Injection**: `get_it` - Mengelola *Service Locator* untuk instance service & API agar tidak membebani memori.
- **Backend & Autentikasi**: Firebase (Firebase Auth, Cloud Firestore, Firebase Remote Config).
- **Artificial Intelligence**: Google Generative AI (Gemini 1.5 Flash) untuk pemrosesan teks dan gambar.
- **Media Optimization**: Cloudinary (Mengkompresi dan mengunggah gambar struk sebelum diproses oleh AI).
- **Local Storage**: `shared_preferences` untuk menyimpan preferensi pengguna (seperti tema atau sesi).

---

<h2 class="section-title">2. Arsitektur dan Struktur Folder (Directory Structure)</h2>

Aplikasi ini menggunakan pola arsitektur **Feature-First** (MVVM Pattern) yang memisahkan logika dan tampilan dengan tegas:

### 🎨 `core/` (Pusat Konfigurasi & Desain)
Berisi aturan global yang tidak berubah-ubah.
- `constants/`: Menyimpan skema warna (Hex) dan API Key.
- `theme/`: Mengatur font (Outfit), ukuran teks, dan gaya komponen untuk Light & Dark Mode.
- `utils/`: Fungsi formatter uang, tanggal, dan utility screenshot.
- `locator.dart`: Menggunakan `GetIt` untuk mendaftarkan Service (Service Locator Pattern).

### 🧠 `data/` (Lapisan Data & Services)
Bagian backend logic aplikasi yang berurusan dengan API.
- `models/`: Blueprint data.
- `services/`: File-file logika untuk komunikasi API dan Cloud.

### 🔗 `providers/` (Lapisan Logika Bisnis)
Mengatur aliran data agar tampilan (UI) otomatis terupdate saat data berubah.

### 📱 `ui/` (Antarmuka Pengguna)
Semua file yang bertanggung jawab atas tampilan visual, dipisah menjadi `pages/` (Layar Halaman Utama) dan `widgets/` (Komponen yang digunakan ulang).

---

<h2 class="section-title">3. Struktur Database (Cloud Firestore)</h2>

Sistem menggunakan arsitektur data **Flat (Koleksi Root)** untuk memudahkan *query* berkinerja tinggi (NoSQL):

1. **Koleksi: `users`** (Profil Pengguna)
   - Field: `balance`, `monthlyBudget`, `name`, `email`, `status`.
2. **Koleksi: `wallets`** (Dompet Digital / Bank)
   - Field: `accountNumber`, `balance`, `name`, `type`, `userId`.
3. **Koleksi: `transactions`** (Riwayat Transaksi)
   - Field: `amount`, `category`, `date`, `description`, `type` (income/expense), `items` (List detail belanja), `userId`.
4. **Koleksi: `notifications`** & **`rating`** (Log sistem dan Feedback).

---

<h2 class="section-title">4. Alur Kerja Integrasi AI (Google Gemini 1.5 Flash)</h2>

Kekuatan utama aplikasi ini terletak pada integrasi Multimodal AI. Berikut alurnya:

### A. Fitur Scan Struk (OCR + Vision AI)
1. Pengguna membuka kamera di dalam aplikasi dan memotret fisik struk belanja.
2. Gambar dikompresi dan dikirim ke server **Cloudinary**. Cloudinary mengembalikan URL gambar.
3. Aplikasi mengirimkan URL gambar beserta *prompt* rahasia ke **Gemini Vision AI**.
4. Gemini bertindak sebagai OCR cerdas; membaca teks, dan membedakan nominal harga dan nama barang.
5. Gemini mengembalikan hasil ekstraksi tersebut dalam format data **JSON terstruktur**.
6. Aplikasi mengubah JSON tersebut menjadi objek `TransactionModel` lalu menampilkannya sebelum dikonfirmasi pengguna untuk disimpan ke Firestore.

### B. Fitur Input Suara & Chat AI (Natural Language Input)
1. Pengguna mengetik atau berbicara (contoh: *"Saya beli bahan baku seharga 50 ribu"*).
2. Teks tersebut dikirim ke **Gemini LLM** beserta *prompt* klasifikasi khusus.
3. AI membedah makna kalimat, mendeteksi nominal angka ("50 ribu" -> 50000), dan menentukan kategori ("Bahan Baku").
4. Data dikembalikan dalam format JSON dan langsung disimpan ke Firestore.

### C. AI Insight (Rekomendasi Pembelian Ekonomis)
1. Aplikasi menarik data seluruh pengeluaran (30 hari terakhir) dari Firestore.
2. Data dirangkum dan dikirim ke **Gemini LLM** dengan *prompt* khusus untuk melakukan "Analisis Keuangan UMKM".
3. AI mencari anomali pengeluaran dan merumuskan saran penghematan atau strategi pembelian bahan baku. Teks rekomendasi ditampilkan di Halaman "AI Insight".

---

<h2 class="section-title">5. Keamanan Aplikasi (Security)</h2>

1. **Proteksi API Key**: Menggunakan package `flutter_dotenv` (`.env`) dipadukan dengan Firebase Remote Config agar API Key tidak masuk dalam *source code* secara *hardcoded*.
2. **Firebase Rules**: Konfigurasi *Security Rules* Firestore memastikan pengguna hanya dapat membaca dan menulis dokumen data dengan `userId` yang cocok dengan sesi otentikasi (Auth) mereka saat ini.

---

<h2 class="section-title">6. Referensi Ekstraksi Source Code (Bedah File)</h2>

Bagian ini membedah peran dan isi dari spesifik file yang menyusun aplikasi di dalam folder `lib/`. *(Ekstraksi dari file DOKUMENTASI_KODE_SUMBER)*

### A. Rincian Lapisan Data (Models)
Setiap entitas utama di aplikasi memiliki representasi kelas Model agar _type-safe_.
- **`user_model.dart`**: Blueprint profil user. Terdiri dari field dasar (`uid`, `name`, `email`, `monthlyBudget`, `balance`). Dilengkapi metode `fromJson` dan `toJson` untuk konversi data Firestore.
- **`transaction_model.dart`**: Blueprint pencatatan kas. Menampung data nominal, kategori, catatan, serta List/Array detail barang belanjaan yang diekstrak oleh AI.
- **`e_wallet_model.dart`**: Menampung data integrasi e-wallet, termasuk ikon dan status sinkronisasi.
- **`expense_model.dart`**: Struktur data khusus untuk chart/grafik analitik keuangan.
- **`notification_model.dart`**: Data log peringatan sistem dan peringatan AI Advisor.

### B. Rincian Lapisan Servis API (Services)
- **`gemini_ai_service.dart` (Core AI)**: Modul pusat integrasi Google Gemini. Terdapat fungsi `extractReceipt()` untuk mengirim URL Cloudinary ke Gemini Vision, dan `analyzeFinancials()` untuk sistem AI Insight.
- **`firestore_service.dart`**: Pembungkus (*wrapper*) untuk semua operasi CRUD (Create, Read, Update, Delete) ke Cloud Firestore. 
- **`auth_service.dart`**: Logika Firebase Auth. Meliputi Login Email/Pass, Register, dan integrasi Google Sign-In (OAuth).
- **`gmail_service.dart`**: Mengakses Gmail API via OAuth 2.0 untuk memindai email mutasi masuk dari bank atau dompet digital dan menyinkronkannya sebagai data transaksi.
- **`cloudinary_service.dart`**: Menggunakan REST API untuk mengunggah (POST) foto struk ke server Cloudinary sebelum diproses AI (agar ukuran gambar kecil dan memori efisien).
- **`csv_logger_service.dart`**: Menyediakan fitur eksport data transaksi ke format CSV.
- **`notification_service.dart`**: Menginisialisasi *Flutter Local Notifications Plugin* untuk push-notification lokal.

### C. Rincian Lapisan Logika Bisnis (Providers)
- **`e_wallet_provider.dart`**: Modul yang mengatur alur logika kompleks dari penambahan akun dompet eksternal hingga sinkronisasi total saldo kumulatif pengguna.
- **`transaction_provider.dart`**: Menarik data (fetch) riwayat transaksi ke memori perangkat, mem-filter grafik bulanan/kategori, dan menghitung total *income* serta *expense*.
- **`auth_provider.dart`**: Memegang status login (`isLoading`, `isAuthenticated`, `currentUser`). Menangani aliran rute dari Splash Screen menuju layar berikutnya.
- **`ai_insight_provider.dart`**: Mengelola logika dan interaksi obrolan saat AI Gemini sedang memproses jawaban (Chatbot State).
- **`settings_provider.dart`**: Mengambil pengaturan lokal seperti mode gelap dari `SharedPreferences`.
- **`notification_provider.dart`**: Mengontrol logika penanda dibaca (*Read/Unread*) dari notifikasi peringatan overbudget.

### D. Rincian Lapisan Tampilan & Komponen (UI)
- **`pages/main/`**: Rute utama yang memuat `main_page.dart` (Bottom Navigation Bar) yang mempertahankan *state* masing-masing tab halaman agar tidak _reload_.
- **`pages/transaction/`**: Halaman operasi finansial, mulai dari pembuatan kas baru (`add_transaction_page.dart`) hingga *scanner* kamera (`scan_receipt_page.dart`).
- **`pages/dashboard/` & `pages/portfolio/`**: Halaman visualisasi data dengan grafik komponen *fl_chart*.
- **`pages/e_wallet/`**: Layar tempat sinkronisasi saldo bank / e-wallet.
- **`pages/settings/`**: Layar pengaturan profil dan izin perangkat (Microphone & Kamera).
- **`widgets/custom_text_field.dart`**: Didesain khusus agar seragam di semua form aplikasi dengan gaya modern.
- **`widgets/custom_popup.dart`**: Menggantikan pesan _AlertDialog_ bawaan iOS/Android dengan modul popup mewah khusus tema aplikasi.

---
*Dokumen ini merupakan hasil kombinasi final dan paripurna dari seluruh entitas dokumentasi sistem dan arsitektur kode sumber (Camelio Finance V1.0.6).*
