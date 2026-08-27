# 📂 Catatan Struktur & Fungsi File (Camelio)

Dokumen ini mendetailkan fungsi setiap folder dan file kunci dalam arsitektur aplikasi Camelio.

---

## 🏗️ 1. Arsitektur Folder `lib/`

### 🎨 `core/` (Pusat Konfigurasi)
Berisi aturan global yang tidak berubah-ubah.
- **`constants/`**:
  - `app_colors.dart`: Menyimpan skema warna (Hex) untuk konsistensi UI (ungu primary, peach secondary).
  - `api_keys.dart`: Menyimpan API Key (seperti Gemini) yang diambil dari Remote Config atau .env.
- **`theme/`**:
  - `app_theme.dart`: Mengatur font (Outfit), ukuran teks, dan gaya komponen untuk Light & Dark Mode.
- **`utils/`**:
  - `currency_formatter.dart`: Fungsi utilitas untuk mengubah angka `10000` menjadi `Rp 10.000`.
  - `date_formatter.dart`: Fungsi untuk memformat tanggal transaksi agar mudah dibaca manusia.
  - `screenshot_utils.dart`: Modul untuk menangkap tampilan layar (termasuk screenshot panjang/gulir) dan membagikannya.
- **`pdf_generator.dart`** (di `lib/ui/pages/settings/`): Mesin pembuat laporan keuangan PDF dengan pratinjau cetak dan fitur berbagi.
- **`locator.dart`**: Menggunakan `GetIt` untuk mendaftarkan Service agar bisa dipanggil di mana saja tanpa membuat instance baru (Service Locator Pattern).

### 🧠 `data/` (Pengolah Data)
Bagian "belakang" aplikasi yang berurusan dengan logika dan API.
- **`models/`**:
  - `transaction_model.dart`: Blueprint data transaksi (id, jumlah, kategori, tanggal, dll).
  - `user_model.dart`: Struktur data profil pengguna (nama, email, foto, preferensi).
  - `e_wallet_model.dart`: Struktur data untuk akun dompet digital (Gopay, OVO, ShopeePay).
  - `expense_model.dart`: Model khusus untuk analisis pengeluaran detail.
- **`services/`**:
  - `auth_service.dart`: Logika teknis Firebase Auth (Login, Register, Logout).
  - `firestore_service.dart`: Komunikasi langsung dengan database Cloud Firestore.
  - `gemini_ai_service.dart`: Integrasi AI Gemini untuk proses scan struk, suara, dan analisis teks.
  - `cloudinary_service.dart`: Mengunggah foto struk ke server Cloudinary.
  - `gmail_service.dart`: Mengelola akses ke Gmail API dan sinkronisasi email transaksi.
  - `notification_service.dart`: Integrasi `flutter_local_notifications` untuk peringatan tray sistem.

### 🔗 `providers/` (Pengelola Status)
Mengatur aliran data agar tampilan (UI) otomatis terupdate saat data berubah.
- `auth_provider.dart`: Melacak siapa yang login dan memegang data profil user.
- `transaction_provider.dart`: Pusat data keuangan; menghitung saldo total dan memegang daftar transaksi.
- `ai_insight_provider.dart`: Mengelola percakapan Chat AI dan riwayat insight.
- `settings_provider.dart`: Mengatur perpindahan tema (Light/Dark), bahasa, dan izin akses sistem.
- `e_wallet_provider.dart`: Mengelola data dompet digital dan sinkronisasi saldo otomatis.

### 📱 `ui/` (Antarmuka Pengguna)
Semua file yang bertanggung jawab atas tampilan visual.
- **`pages/`**:
  - `splash/`: Halaman animasi awal saat aplikasi dibuka.
  - `auth/`: Halaman login dan pendaftaran pengguna.
  - `main/`: Container utama yang mengatur navigasi antar halaman dashboard.
  - `dashboard/`: Layar utama ringkasan saldo dan transaksi terakhir.
  - `transaction/`: Halaman tambah manual dan scan struk belanja via AI.
  - `ai_advisor/`: Fitur konsultasi keuangan berbasis chatbot AI Gemini.
  - `portfolio/`: Visualisasi grafik performa keuangan pengguna.
  - `e_wallet/`: Manajemen koneksi dan saldo dompet digital.
  - `budget/`: Fitur pengaturan limit pengeluaran per kategori.
  - `notification/`: Pusat informasi update dan pengingat transaksi.
  - `settings/`: Pusat pengaturan akun, keamanan, dan bantuan.
- **`widgets/`**:
  - `balance_card.dart`: Kartu saldo utama dengan fitur privasi (Hide/Show).
  - `transaction_card.dart`: Item daftar transaksi dengan icon kategori yang dinamis.
  - `custom_popup.dart`: Dialog feedback estetik untuk sukses/gagal aksi.
  - `custom_text_field.dart`: Input teks kustom yang konsisten di seluruh aplikasi.

---

## 🛠️ 2. File di Luar `lib/`
- **`.env`**: Menyimpan rahasia (API Keys) agar tidak terekspos di kode sumber.
- **`pubspec.yaml`**: Daftar library (dependency) dan konfigurasi aset aplikasi.
- **`firebase_options.dart`**: Konfigurasi otomatis hasil generate dari FlutterFire CLI.
- **`android/` & `ios/`**: Pengaturan sistem spesifik platform (Izin kamera, nama paket, dll).
- **`assets/`**: Penyimpanan aset gambar, logo, dan font.

---

## 🎓 3. Standar Penamaan & Arsitektur
- **MVVM Pattern**: Pemisahan tegas antara UI (View), Provider (ViewModel), dan Service (Model/Data).
- **Clean Code**: Menggunakan standar `flutter_lints` untuk menjaga kualitas kode.

---

*Dokumen ini diperbarui untuk Versi 1.0.6 - Mei 2026*
