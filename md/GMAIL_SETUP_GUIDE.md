# 📧 Panduan Lengkap Konfigurasi Gmail API (Camelio Finance)

Dokumen ini berisi langkah-langkah teknis untuk menghubungkan aplikasi Camelio dengan layanan Gmail API agar fitur sinkronisasi transaksi otomatis dapat berjalan.

---

## 1. Persiapan di Google Cloud Console

Langkah-langkah di [Google Cloud Console](https://console.cloud.google.com/):

1.  **Buat Project Baru**: Buat project baru bernama `Camelio Finance`.
2.  **Aktifkan Gmail API**:
    *   Buka menu **APIs & Services > Library**.
    *   Cari `Gmail API` dan klik **Enable**.
3.  **Konfigurasi OAuth Consent Screen**:
    *   Pilih User Type: **External**.
    *   Isi App Information (Nama aplikasi: `Camelio Finance`, Email dukungan).
    *   **Scopes**: Tambahkan scope berikut:
        *   `./auth/gmail.readonly` (Melihat email transaksi).
        *   `./auth/gmail.send` (Mengirim notifikasi jika diperlukan).
    *   **Test Users**: Tambahkan email Gmail Anda (dan email penguji lain) ke daftar Test Users. *Catatan: Aplikasi tidak akan bisa mengakses Gmail akun lain jika belum dipublikasikan/diverifikasi Google.*
4.  **Buat Kredensial OAuth 2.0**:
    *   Buka menu **APIs & Services > Credentials**.
    *   Klik **Create Credentials > OAuth client ID**.
    *   **Android**:
        *   Package Name: `com.camelio.smartfinance` (Cek di `android/app/build.gradle.kts`).
        *   SHA-1 Certificate Fingerprint: Dapatkan dengan menjalankan `cd android && ./gradlew signingReport`.
    *   **iOS**:
        *   Bundle ID: `com.example.smartFinanceApp` (Cek di Xcode).
    *   **Web** (Opsional): Masukkan Authorized JavaScript origins jika diperlukan.

---

## 2. Sinkronisasi dengan Firebase

Aplikasi ini menggunakan Firebase sebagai jembatan autentikasi:

1.  **Firebase Console**: Buka [Firebase Console](https://console.firebase.google.com/).
2.  **Authentication**:
    *   Aktifkan metode **Google Sign-In**.
    *   Pastikan **Web Client ID** dan **Web Client Secret** yang ada di Firebase sama dengan yang ada di Google Cloud Console.
3.  **Google Services Config**:
    *   Download `google-services.json` (Android) dan masukkan ke `android/app/`.
    *   Download `GoogleService-Info.plist` (iOS) dan masukkan ke `ios/Runner/`.

---

## 3. Alur Penggunaan di Aplikasi (End-to-End)

Setelah konfigurasi di atas selesai, ikuti langkah ini di dalam aplikasi:

1.  **Login**: Masuk ke aplikasi menggunakan akun Google (AuthService).
2.  **Aktifkan Izin**:
    *   Buka **Sidebar Menu > Izin (Permissions)**.
    *   Nyalakan toggle **Sinkronisasi Gmail**.
    *   Anda akan melihat *popup* permintaan izin dari Google. Klik **Allow/Izinkan**.
3.  **Tambah Dompet**:
    *   Buka halaman **E-Wallets**.
    *   Klik tombol **(+)** untuk menambah dompet.
    *   Pilih tipe dompet (Banking, E-Wallet, atau Marketplace).
    *   Klik tombol **"Hubungkan dengan Gmail"**.
4.  **Proses Sinkronisasi**:
    *   Aplikasi akan memindai email masuk yang mengandung kata kunci transaksi (seperti "Transfer", "Pembayaran", "Top Up").
    *   Data saldo akan terisi secara otomatis jika ditemukan email yang relevan.
5.  **Berhasil**: Saldo dompet akan terupdate dan sinkron dengan **Total Saldo** di Dashboard. Aplikasi juga secara otomatis mencatat "Saldo Awal" atau "Penyesuaian Saldo" sebagai transaksi pemasukan agar portofolio tetap akurat.

---

## 4. Troubleshooting (Masalah Umum)

*   **Status Aplikasi (Penting!)**: Jika Anda ingin mengizinkan akses ke akun Gmail apa pun tanpa harus mendaftarkan email satu per satu, buka Google Cloud Console > OAuth Consent Screen dan klik tombol **"Publish App"**. Status akan berubah menjadi "In Production" (Tetap Gratis) dan peringatan keamanan akan berkurang.
*   **Error: Developer has not verified this app**: Ini normal saat tahap pengembangan. Klik "Advanced" dan "Go to Camelio (unsafe)".
*   **Error: 403 Forbidden**: Pastikan email yang Anda gunakan sudah terdaftar di **Test Users** (jika masih status Testing).

---

## 5. Koneksi Lainnya (Google Cloud & Firebase)

Untuk fitur **Scan Struk** dan **Penyimpanan Profil**, aplikasi menggunakan:
1.  **Firebase Storage**: Digunakan untuk menyimpan foto struk fisik secara aman di infrastruktur Google Cloud. Lokasi: `gs://smart-finance-app.appspot.com/`.
2.  **Cloudinary**: Sebagai alternatif CDN untuk pengolahan gambar yang lebih cepat (resizing/cropping) sebelum dikirim ke AI Gemini.
3.  **Firestore**: Database NoSQL utama untuk menyimpan seluruh meta-data transaksi dan profil pengguna secara real-time.

---

*Panduan ini disusun untuk mendukung Versi 1.0.4+4 - Mei 2026*
