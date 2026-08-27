<div align="center">
  <img src="file:///Users/prasdadestriyana/Flutter_Projects/smart_finance_app/assets/logo_camelio.png" width="200" alt="Logo Camelio">
  <br>
  <h1>DOKUMENTASI TEKNIS & REFERENSI KODE (SOURCE CODE)</h1>
  <h3>Aplikasi Camelio Finance - Versi 1.0.6</h3>
</div>

<br>

---

## 1. Tumpukan Teknologi (Tech Stack)

Aplikasi ini dibangun menggunakan teknologi modern yang berfokus pada skalabilitas dan integrasi AI:

- **Frontend / Mobile Framework**: Flutter (Dart) - Mendukung Cross-Platform (Android & iOS).
- **State Management**: `provider` - Mengelola state UI secara reaktif dan efisien.
- **Dependency Injection**: `get_it` - Mengelola *Service Locator* untuk instance API.
- **Backend & Autentikasi**: Firebase (Firebase Auth, Cloud Firestore, Firebase Remote Config).
- **Artificial Intelligence**: Google Generative AI (Gemini 1.5 Flash) untuk pemrosesan teks dan gambar OCR.
- **Media Optimization**: Cloudinary (Mengkompresi dan mengunggah gambar struk sebelum diproses oleh AI).
- **Local Storage**: `shared_preferences` untuk menyimpan preferensi pengguna lokal.

---

## 2. Struktur Database (Cloud Firestore)

Sistem menggunakan arsitektur data **Flat (Koleksi Root)** tipe NoSQL untuk memastikan *query* berkinerja tinggi. Berikut adalah skema koleksi:

1. **Koleksi: `users`** (Profil Pengguna Utama)
   - Field: `balance`, `monthlyBudget`, `name`, `email`, `status`.
2. **Koleksi: `wallets`** (Dompet Digital / Kas Bank)
   - Field: `accountNumber`, `balance`, `name`, `type`, `userId`.
3. **Koleksi: `transactions`** (Riwayat Arus Kas)
   - Field: `amount`, `category`, `date`, `description`, `type` (income/expense), `items` (Array dari detail belanja), `userId`.
4. **Koleksi: `notifications`** & **`rating`**
   - Menyimpan log riwayat notifikasi sistem dan form feedback (*rating* aplikasi).

---

## 3. Alur Kerja Integrasi Multimodal AI (Gemini 1.5)

Kekuatan utama aplikasi ini terletak pada integrasi AI cerdas, dengan tiga modul utama:

### A. Fitur Scan Struk (OCR + Vision AI)
1. Pengguna memotret fisik struk belanja melalui fitur kamera.
2. Gambar langsung dikompresi dan dikirim ke server **Cloudinary** (mengembalikan URL).
3. URL gambar beserta perintah rahasia (*System Prompt*) dikirim ke **Gemini Vision AI**.
4. Gemini membaca teks (OCR), mengidentifikasi nama barang & total harga.
5. Gemini mengembalikan hasil ekstraksi tersebut dalam format **JSON** yang ketat.
6. Aplikasi menyusun JSON menjadi objek transaksi untuk dikonfirmasi pengguna.

### B. Input Suara & Chat Pintar (Natural Language)
1. Pengguna mengetik atau berbicara (contoh: *"Beli bahan baku kopi 50 ribu"*).
2. Teks diproses oleh **Gemini LLM** menggunakan *prompt* klasifikasi khusus.
3. AI membedah semantik kalimat, mengubah "50 ribu" menjadi angka `50000`, dan menetapkan kategori "Bahan Baku".
4. Hasil JSON langsung diparsing ke Firestore.

### C. AI Financial Advisor (AI Insight)
1. Modul menarik data pengeluaran (30 hari terakhir) dari Firestore.
2. Data diagregasi menjadi teks ringkas dan dikirim ke **Gemini LLM** dengan *persona* "Penasihat Keuangan UMKM".
3. AI mencari letak pemborosan (anomali) dan merumuskan teks rekomendasi operasional yang rasional.

---

## 4. Referensi Kode Sumber (Deep Dive Source Code)

Bagian ini membedah isi dari folder `lib/`, yang menggunakan gabungan **MVVM Pattern** dan **Service Locator**.

### A. Lapisan Data & Model (`lib/data/`)
Berisi pemetaan JSON dari dan ke database Firestore (Data Transfer Object).
- `user_model.dart`: Blueprint profil pengguna (`uid`, `name`, `email`, `monthlyBudget`).
- `transaction_model.dart`: Blueprint data nominal, kategori, catatan, dan _array item_ barang belanja.
- `e_wallet_model.dart`: Penampung data integrasi layanan pihak ketiga (Gopay, OVO, dll).

### B. Lapisan Service / API (`lib/data/services/`)
Menjalankan fungsi berat yang dipanggil oleh Provider melalui `locator()`.
- **`gemini_ai_service.dart`**: Modul pusat kecerdasan. Berisi *prompt engineering* (`extractReceipt()`, `analyzeFinancials()`).
- **`firestore_service.dart`**: Pembungkus CRUD (*Create, Read, Update, Delete*) Firebase.
- **`auth_service.dart`**: Eksekutor login (Email, Google, Apple).
- **`gmail_service.dart`**: Sinkronisasi otomatis mutasi bank (e-wallet) melalui kotak masuk pengguna via *Gmail API*.
- **`cloudinary_service.dart`**: Layanan optimasi dan hosting gambar struk sementara.

### C. Lapisan Logika Bisnis / Provider (`lib/providers/`)
Berada di `lib/providers/`. Bertugas menjadi jembatan View (UI) dan Service (Data).
- **`e_wallet_provider.dart`**: Logika kompleks untuk manajemen koneksi dan sinkronisasi saldo dompet digital lintas akun.
- **`transaction_provider.dart`**: Pusat kalkulasi _income_ vs _expense_ dan mem-filter data berdasarkan bulan aktif.
- **`auth_provider.dart`**: Melacak *state* `currentUser` dari layar Splash hingga Dashboard.
- **`ai_insight_provider.dart`**: Mengontrol interaksi Chat AI (*loading state* dan history pesan).

### D. Lapisan Antarmuka / UI (`lib/ui/`)
- **`pages/main/`**: Memegang navigasi tab bawah (Bottom Navigation Bar) tanpa mematikan sesi (*keep alive*).
- **`pages/transaction/`**: Pintu masuk pembuatan transaksi (melalui manual, mikrofon, atau kamera scanner).
- **`pages/dashboard/`**: Pusat pantauan saldo dengan grafik *fl_chart*.
- **`widgets/custom_popup.dart`**: Modul _dialog alert_ elegan pengganti popup bawaan sistem Android/iOS.
- **`widgets/custom_text_field.dart`**: Elemen input seragam dengan estetika tema _Glassmorphism_.

---

## 5. Sistem Keamanan

1. **Proteksi Kredensial**: Menggunakan *package* `flutter_dotenv` (`.env`) dipadukan dengan Firebase Remote Config agar *API Key* tidak dapat direkayasa (reverse-engineering) melalui *source code*.
2. **Aturan Firestore (Security Rules)**: Mengimplementasikan sistem otorisasi Role-Based yang ketat. Pengguna **hanya bisa membaca dan menulis** data dengan ID yang cocok dengan _token otentikasi_ mereka saat itu.
