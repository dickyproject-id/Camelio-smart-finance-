# 🛠️ Dokumentasi Teknis (Technical Documentation) - Camelio Finance

Dokumen ini berisi rangkuman arsitektur perangkat lunak, tumpukan teknologi (tech stack), dan alur logika sistem dari aplikasi **Camelio Finance**.

---

## 1. Tumpukan Teknologi (Tech Stack)

Aplikasi ini dibangun menggunakan teknologi modern yang berfokus pada skalabilitas dan integrasi Kecerdasan Buatan (AI):

- **Frontend / Mobile Framework**: Flutter (Dart) - Mendukung Cross-Platform (Android & iOS).
- **State Management**: `provider` - Untuk mengelola state UI secara reaktif dan efisien.
- **Dependency Injection**: `get_it` - Mengelola *Service Locator* untuk instance service & API agar tidak membebani memori.
- **Backend & Autentikasi**: Firebase (Firebase Auth, Cloud Firestore, Firebase Remote Config).
- **Artificial Intelligence**: Google Generative AI (Gemini 1.5 Flash) untuk pemrosesan teks dan gambar.
- **Media Optimization**: Cloudinary (Digunakan untuk mengkompresi dan mengunggah gambar struk fisik sebelum diproses oleh AI).
- **Local Storage**: `shared_preferences` untuk menyimpan preferensi pengguna (seperti tema atau sesi sementara).

---

## 2. Arsitektur Folder (Directory Structure)

Aplikasi ini menggunakan pola arsitektur **Feature-First** yang digabung dengan pemisahan lapisan (Layered Architecture):

```text
lib/
│
├── core/            # Berisi konfigurasi utama, konstanta, warna tema (Design System), dan utilitas global.
├── data/            # Lapisan Data (Data Layer)
│   ├── models/      # Representasi struktur data (User, Transaction, Notification).
│   └── services/    # Logika eksekusi eksternal (AuthService, FirestoreService, GeminiAIService, CloudinaryService).
│
├── providers/       # Lapisan Bisnis (Business Logic Layer)
│                    # Menghubungkan UI dengan Services (Contoh: AuthProvider, TransactionProvider, AIInsightProvider).
│
└── ui/              # Lapisan Antarmuka (Presentation Layer)
    ├── pages/       # Layar/Halaman utama yang dikelompokkan per fitur (auth/, dashboard/, transaction/).
    └── widgets/     # Komponen UI yang dapat digunakan ulang (CustomTextField, TransactionCard).
```

---

## 3. Struktur Database (Cloud Firestore)

Camelio menggunakan pendekatan database NoSQL dengan struktur **Flat-Root Collection** untuk menghindari nested collections yang rumit dan memastikan kueri (query) berjalan cepat.

Koleksi Utama (Root Collections):
1. **`users`**: Menyimpan profil pengguna UMKM, preferensi bisnis, dan batas anggaran (budget limit).
2. **`transactions`**: Menyimpan setiap catatan arus kas (pemasukan & pengeluaran). Field utama meliputi: `amount`, `type` (income/expense), `category`, `date`, dan `notes`.
3. **`wallets`**: Menyimpan saldo dari kas fisik maupun E-Wallet yang dimiliki pengguna.
4. **`notifications`**: Log pemberitahuan sistem dan peringatan anggaran.
5. **`rating`**: Data feedback pengguna terhadap aplikasi.

---

## 4. Alur Integrasi AI & Fitur Cerdas

Kekuatan utama aplikasi ini terletak pada integrasi Multimodal AI. Berikut adalah alur kerjanya:

### A. Auto-Input via Scan Struk (Vision AI)
1. Pengguna memotret nota/struk belanja menggunakan kamera perangkat.
2. Gambar dikompresi dan diunggah secara sementara ke **Cloudinary**.
3. `GeminiAIService` mengirimkan URL gambar dari Cloudinary beserta instruksi khusus (*Prompt*) ke model **Gemini 1.5 Flash**.
4. Gemini membaca teks dalam gambar (OCR pintar) dan mengekstrak entitas (Nama Barang, Total Harga, Tanggal) menjadi format data terstruktur **JSON**.
5. Aplikasi mengubah JSON tersebut menjadi objek `TransactionModel` dan menyimpannya ke Firestore.

### B. Input Pintar via Teks (Natural Language)
1. Pengguna mengetik pengeluaran secara bebas (Contoh: *"Hari ini beli token listrik 100 ribu dan galon 20 ribu"*).
2. Teks dikirim ke Gemini AI.
3. Model membedah kalimat tersebut menjadi dua entitas transaksi terpisah yang terstruktur, lengkap dengan kategorinya (Utilitas & Operasional).

### C. AI Financial Advisor (Insight)
1. `TransactionProvider` menarik seluruh data pengeluaran pengguna selama **30 hari terakhir** dari Firestore.
2. Data mentah tersebut diagregasi dan dikirim ke Gemini AI dengan System Prompt yang bertindak sebagai "Penasihat Keuangan UMKM".
3. AI menganalisis pola pembengkakan biaya, membandingkannya dengan tren, dan mengembalikan teks rekomendasi penghematan di layar "AI Insight".

---

## 5. Sistem Keamanan

1. **Proteksi API Key**: Menggunakan package `flutter_dotenv` agar rahasia (seperti Gemini API Key) tidak masuk dalam *source code* secara langsung. Tersimpan pada file `.env` yang masuk dalam `.gitignore`.
2. **Firebase Rules**: Konfigurasi *Security Rules* Firestore membatasi agar pengguna hanya dapat membaca dan menulis dokumen transaksi yang memiliki `userId` yang sama dengan ID otentikasi mereka (Role-Based Access).
