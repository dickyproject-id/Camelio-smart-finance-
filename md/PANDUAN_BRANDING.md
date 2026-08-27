# 🎨 Panduan Branding & Identitas Aplikasi (Camelio)

Dokumen ini menjelaskan cara mengubah identitas visual dan nama aplikasi untuk keperluan branding atau pembaruan.

---

## 1. Mengubah Logo Aplikasi (App Icon)
Logo aplikasi adalah ikon yang muncul di layar utama (home screen) HP. Kita menggunakan paket `flutter_launcher_icons` untuk memudahkan proses ini.

**Langkah-langkah:**
1. Siapkan file gambar baru di folder `assets/`. Contoh: `assets/logo_baru.png`.
2. Buka file `pubspec.yaml`.
3. Cari bagian `flutter_launcher_icons:`.
4. Ubah `image_path` menjadi path file baru Anda:
   ```yaml
   flutter_launcher_icons:
     android: "ic_launcher"
     ios: true
     image_path: "assets/logo_baru.png"
   ```
5. Jalankan perintah berikut di terminal:
   ```bash
   flutter pub get
   flutter pub run flutter_launcher_icons
   ```
6. Aplikasi akan secara otomatis memperbarui ikon untuk Android dan iOS.

---

## 2. Mengubah Nama Aplikasi
Nama aplikasi adalah teks yang muncul di bawah ikon aplikasi atau di judul menu HP.

### **Untuk Android:**
1. Buka file: `android/app/src/main/AndroidManifest.xml`.
2. Cari bagian `android:label="Camelio"`.
3. Ubah `"Camelio"` menjadi nama yang Anda inginkan.

### **Untuk iOS:**
1. Buka file: `ios/Runner/Info.plist`.
2. Cari kunci `<key>CFBundleName</key>`.
3. Ubah string di bawahnya: `<string>Camelio</string>` menjadi nama baru.

---

## 3. Mengubah Logo Pemilihan Akun Google
Saat pengguna menekan tombol "Login with Google", muncul jendela pop-up pemilihan akun. Ikon yang muncul di sana biasanya ditarik dari **Firebase Console**.

**Langkah-langkah:**
1. Masuk ke [Firebase Console](https://console.firebase.google.com/).
2. Pilih proyek Anda.
3. Klik ikon Gear (Project Settings) > **General**.
4. Di bagian **Public settings**, Anda bisa mengunggah "Public-facing name" dan "Support email".
5. Untuk logo spesifik di layar pemilihan akun, Anda harus mengaturnya di [Google Cloud Console](https://console.cloud.google.com/):
   - Pilih proyek yang sama.
   - Buka **APIs & Services** > **OAuth consent screen**.
   - Di sana Anda bisa mengunggah **App Logo**. Logo inilah yang akan muncul saat pemilihan akun Google.

---

## 4. Mengubah Logo di Dalam Aplikasi (UI)
Beberapa logo di dalam kode ditarik langsung dari file asset:
- **Login Screen**: Menggunakan `assets/logo_camelio.png`.
- **Splash Screen**: Menggunakan `assets/logo_camelio.png`.
- **Balance Card**: Menggunakan `assets/logo_camelio_white.png`.
- **Drawer/Profil**: Menggunakan `assets/logo_camelio.png` sebagai fallback jika tidak ada foto profil.

Jika ingin menggantinya, cukup timpa file gambar tersebut di folder `assets/` dengan nama yang sama, atau ubah path-nya di file `.dart` terkait.

---

## 5. Standar Visual Khusus (UI/UX)
Camelio memiliki beberapa aturan visual unik untuk menjaga tampilan "Premium":

- **Splash Screen**: Logo (`160px`) disejajarkan dengan Judul ("Camelio") dan Subjudul ("Manage Money Efficiently") menggunakan `FittedBox`. Lebar teks wajib sama dengan lebar logo untuk estetika simetris.
- **Drawer Header**: Menggunakan gradien `AppColors.primaryGradient` dengan radius khusus pada **pojok kanan bawah** (`80.0`). Bagian atas dan sisi lainnya tetap tajam/standar.
- **Wallet Logo Badge**: Untuk menjaga estetika pada kartu dompet yang berwarna, setiap logo (Shopee, GoPay, dll) wajib dibungkus dalam wadah putih melingkar (*White Circle Badge*) untuk menghindari "white box" dan memastikan simetri visual.
- **Kartu Pengaturan**: Menggunakan kartu berwarna putih (Light) atau `darkSurface` (Dark) dengan bayangan halus (`blurRadius: 20`) dan pojok yang sangat bulat (`borderRadius: 24`).
- **Ikon Menu**: Menggunakan varian `outlined` atau `rounded` dengan warna brand (`AppColors.primary`) untuk menjaga konsistensi.
- **Standar Warna Grafik**: Garis Pengeluaran (*Expense*) wajib menggunakan warna **Merah** (`AppColors.error`), sedangkan Pemasukan (*Income*) menggunakan warna **Hijau** untuk kejelasan visual.

---

## 6. Standar Tata Letak Baru (iOS Style)
Sejak Versi 1.0.4+4, Camelio menerapkan standar tata letak baru untuk halaman utama (Dashboard, E-Wallet, Riwayat Transaksi):

- **Header Tanpa AppBar**: Judul halaman diletakkan di dalam `body` menggunakan `SafeArea` dan `Padding(24.0)`, bukan di `AppBar` standar.
- **Tipografi Judul**: Judul menggunakan `fontSize: 24`, `fontWeight: FontWeight.bold`, dan warna `titleLarge`.
- **Tipografi Subjudul**: Subjudul diletakkan tepat di bawah judul dengan `SizedBox(height: 8)` dan menggunakan gaya `bodyMedium`.
- **Konsistensi Baris**: Seluruh elemen input (seperti Search Bar) dan daftar (ListView) disejajarkan secara horizontal dengan padding **24.0** agar selaras dengan teks judul.

---

## 7. App Versioning
Versi aplikasi saat ini adalah **1.0.4+4**. Versi diatur dalam `pubspec.yaml` dan ditampilkan secara manual pada bagian bawah Drawer dan Halaman Pengaturan.
