<div class="logo-container">
  <img src="file:///Users/prasdadestriyana/Flutter_Projects/smart_finance_app/assets/logo_camelio.png" width="150" alt="Logo Camelio">
</div>

<div class="center-title">Buku Panduan Teknis & Arsitektur Kode</div>
<div class="center-subtitle">(Dokumentasi Sistem Camelio Finance)</div>

Dokumen ini menjelaskan secara komprehensif mengenai arsitektur perangkat lunak, tumpukan teknologi (tech stack), alur logika sistem, skema database, dan integrasi Artificial Intelligence (Google Gemini) pada aplikasi **Camelio Finance**.

---

<h2 class="section-title">🧱 1. Tumpukan Teknologi & Arsitektur</h2>

Aplikasi ini dibangun menggunakan teknologi modern yang berfokus pada skalabilitas dan integrasi AI dengan pola arsitektur **Feature-First (MVVM Pattern)**:

- **Frontend / Mobile Framework**: Flutter (Dart) - Mendukung Cross-Platform.
- **Model-View-ViewModel (MVVM)**: 
  - **View**: Komponen pasif di folder `ui/` yang murni menangani tampilan.
  - **ViewModel**: Dikelola oleh `provider` untuk *state management* reaktif (`providers/`).
  - **Model & Data**: Memetakan struktur data API & Firebase ke Dart (`data/models/`).
- **Dependency Injection**: Menggunakan `get_it` sebagai *Service Locator* untuk meregistrasi layer *Services* agar efisien dalam penggunaan memori.
- **Artificial Intelligence**: Google Generative AI (Gemini 1.5 Flash) terintegrasi langsung via Cloudinary & REST API.

---

<h2 class="section-title">📂 2. Rincian Struktur Direktori Utama</h2>

### 🎨 `core/` (Pusat Konfigurasi)
Berisi aturan global yang konstan di seluruh aplikasi.
- `constants/`: Menyimpan skema warna (Hex), teks standar, dan API Key.
- `theme/`: Mengatur hierarki font (Outfit), ukuran teks, dan gaya (Light/Dark Mode).
- `utils/`: Fungsi formatter uang, waktu, dan penanganan ekstensi.
- `locator.dart`: Tempat registrasi semua *Service* backend secara *lazy singleton*.

### 📱 `ui/` (Lapisan Antarmuka Pengguna)
Berisi layar (Pages) dan komponen (Widgets) yang mengadopsi estetika _Glassmorphism_.
- **`pages/main/`**: Rute utama (Bottom Navigation Bar) yang memegang state antar tab.
- **`pages/dashboard/` & `pages/portfolio/`**: Area visualisasi data dengan grafik (`fl_chart`).
- **`pages/transaction/`**: Pintu masuk pembuatan transaksi (input manual, suara, dan kamera/OCR).
- **`pages/ai_advisor/`**: Antarmuka interaktif layaknya *chatbot* cerdas untuk konsultasi.
- **`widgets/`**: `custom_popup.dart` (Dialog premium) dan `custom_text_field.dart` (Form input dinamis).

---

<h2 class="section-title">🗄️ 3. Bedah Lapisan Data & Database (Cloud Firestore)</h2>

Sistem menggunakan arsitektur data **Flat (Koleksi Root)** untuk kueri NoSQL yang ringan.

### A. Skema Koleksi Database
1. **`users`**: Profil Pengguna (balance, monthlyBudget, dll).
2. **`wallets`**: Data E-Wallet dan Rekening Bank.
3. **`transactions`**: History pengeluaran/pemasukan, berisi rincian `items` yang diekstrak OCR.
4. **`notifications`** & **`rating`**: Log sistem dan feedback pengguna.

### B. Implementasi Data Models (`lib/data/models/`)
Setiap data yang ditarik dari Firestore akan diparsing menjadi objek Dart (Type-Safe):
- `user_model.dart`, `transaction_model.dart`, `e_wallet_model.dart`, `expense_model.dart`.

### C. Implementasi Services (`lib/data/services/`)
- `firestore_service.dart`: Menangani seluruh fungsi CRUD (Create, Read, Update, Delete) ke server Firebase.
- `auth_service.dart`: Mengeksekusi Firebase Auth (Login, Register, Google Sign-In).
- `gmail_service.dart`: Sinkronisasi kotak masuk Gmail via OAuth 2.0 untuk mendeteksi transaksi e-wallet/bank.

---

<h2 class="section-title">🤖 4. Alur Kerja Logika Bisnis & Integrasi AI</h2>

Folder `lib/providers/` adalah nyawa aplikasi tempat logika bisnis bersinggungan langsung dengan kecerdasan buatan.

### A. Fitur Scan Struk (Vision AI)
- Diinisiasi di UI, gambar dikirim ke `cloudinary_service.dart` untuk optimasi ukuran.
- URL gambar dilempar ke `gemini_ai_service.dart`.
- Fungsi `extractReceipt()` akan memerintahkan Gemini membaca OCR dan mendeteksi rincian harga. Data JSON dikembalikan dan diproses oleh `transaction_provider.dart`.

### B. Natural Language (Input Pintar)
- Kalimat ("Beli ayam 20 ribu") dikirim ke LLM. Gemini mengonversinya menjadi angka `20000` dan mengklasifikasikan kategori "Bahan Baku" secara otonom.

### C. AI Financial Advisor (`ai_insight_provider.dart`)
- `transaction_provider.dart` mengagregasi total kas keluar 30 hari terakhir.
- Data dilempar ke Gemini (berperan sebagai konsultan UMKM). Gemini memberikan respon analitik dan menyarankan strategi efisiensi dana operasional.

### D. Provider Tambahan
- `e_wallet_provider.dart`: Menangani kalkulasi sinkronisasi dompet digital lintas bank/akun.
- `auth_provider.dart`: Melacak state login pengguna (`currentUser`).
- `settings_provider.dart`: Melacak preferensi sistem menggunakan `SharedPreferences`.

---

<h2 class="section-title">🔒 5. Konfigurasi Sistem Utama & Keamanan</h2>

1. **`main.dart` & `app.dart`**: Titik masuk (*Entry Point*). Tempat menginisialisasi `FirebaseOptions`, mendeklarasikan *Service Locator*, dan menyuntikkan `MultiProvider` ke seluruh aplikasi.
2. **Proteksi API Key**: Menggunakan library `flutter_dotenv` (`.env`) dipadukan dengan konfigurasi server sehingga token/kredensial rahasia tidak pernah diekspos dalam *source code*.
3. **Firestore Security Rules**: Otorisasi perlindungan ketat (Role-Based). Pengguna tidak dapat membaca apalagi memodifikasi riwayat transaksi jika `userId` pada *document* tidak cocok dengan Token ID sesi *Auth* yang aktif.

---
*Dokumen teknis ini mempresentasikan standar kualitas arsitektur production-ready dari aplikasi Camelio Finance.*
