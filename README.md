# 🐪 Camelio Finance - Smart Finance Manager untuk UMKM

> **Judul Penelitian / Skripsi:** 
> *"PENGEMBANGAN MULTIMODAL ARTIFICIAL INTELLIGENCE FINANCIAL ASSISTANT DALAM REKOMENDASI PEMBELIAN OTOMATIS PADA UMKM KOPI MENCENG"*

Camelio Finance adalah sistem aplikasi analitik keuangan berbasis Android (Flutter) yang didesain secara khusus untuk mendigitalisasi dan menyederhanakan proses pencatatan serta analisis pengeluaran bagi pelaku Usaha Mikro, Kecil, dan Menengah (UMKM). Aplikasi ini mengintegrasikan teknologi terkini seperti *Optical Character Recognition* (OCR) dan *Artificial Intelligence* (Google Gemini) untuk menggeser paradigma dari sekadar "mencatat" menjadi "menganalisis" demi efisiensi biaya.

---

## 🎯 Latar Belakang & Tujuan Utama
Sebagian besar UMKM masih mengandalkan pencatatan buku kas secara manual yang rentan *human error* dan tidak memberikan wawasan strategis. Camelio Finance hadir untuk menyelesaikan masalah tersebut dengan cara:
1. **Mengotomatisasi Input Data:** Melalui pindaian struk (OCR), perintah suara, dan deteksi chat teks pintar.
2. **Menganalisis Pola Belanja:** AI akan mencari pola dari data historis transaksi.
3. **Memberikan Rekomendasi Ekonomis:** Memberikan tips atau panduan proaktif agar UMKM dapat menekan biaya operasional mereka.

---

## ✨ Fitur Utama (Core Features)

- **📸 Scan Struk Otomatis (OCR & Vision AI):**
  Tidak perlu lagi mengetik manual. Cukup potret nota fisik Anda, biarkan teknologi integrasi Cloudinary dan model Google Gemini 1.5 Flash mengekstrak nama barang, total harga, dan tanggal secara instan.
  
- **💡 AI Insight (Penasihat Keuangan Virtual):**
  Fitur analitik cerdas yang membaca pola pengeluaran Anda selama 30 hari terakhir. AI akan menyajikan peringatan dini, mencari anomali fluktuasi harga bahan baku, dan merekomendasikan solusi pembelian yang jauh lebih hemat.

- **💬 Chat AI (Input Teks Pintar):**
  Catat pengeluaran semudah mengirim pesan teks. Cukup ketik *"Saya beli kopi dan gula 50rb"*, dan sistem cerdas akan langsung membedahnya menjadi struktur JSON yang siap disimpan ke database.

- **🎙️ Voice AI (Perintah Suara):**
  Fitur pencatatan instan berbasis audio (*Speech-to-Text*) yang sangat memanjakan pengguna saat sedang sibuk di lapangan.

- **📧 Gmail API Synchronization:**
  Sinkronisasi mutasi transaksi bank dan dompet digital (E-Wallet) secara otomatis dengan membaca struk digital di kotak masuk Gmail pengguna.

- **📊 Interactive Portfolio:**
  Dashboard ringkasan dengan bagan grafik (Pie & Bar Chart) dinamis untuk memonitor arus kas (*Cash Flow*) bisnis harian dan bulanan.

---

## 🛠️ Arsitektur Teknologi & Database

Camelio dibangun dengan tumpukan teknologi modern untuk skalabilitas dan performa tinggi:

*   **Frontend / Mobile Framework:** Flutter & Dart (Cross-platform).
*   **Artificial Intelligence:** Google Generative AI SDK (Gemini 1.5 Flash).
*   **Media Storage (Image Optimization):** Cloudinary (Kompresi foto struk cerdas di cloud).
*   **Backend & Database:** Firebase
    *   *Firebase Authentication* (Login & Keamanan pengguna).
    *   *Firebase Remote Config* (Manajemen API Key dinamis dan konfigurasi jarak jauh).
    *   *Cloud Firestore (NoSQL)* dengan struktur **Flat-Root Collection** untuk *query* yang cepat. Terdiri dari koleksi: `users`, `transactions`, `wallets`, `notifications`, dan `rating`.

---

## 🚀 Panduan Instalasi & Setup (Bagi Developer)

Jika Anda ingin menjalankan atau mengembangkan project ini secara lokal:

1. Kloning repositori ini: `git clone <repo-url>`
2. Buka folder project, lalu unduh seluruh *dependencies*:
   ```bash
   flutter pub get
   ```
3. Buat file bernama `.env` di *root* direktori project dan masukkan API Key yang diperlukan:
   ```env
   GEMINI_API_KEY=Kunci_Gemini_Anda
   CLOUDINARY_URL=URL_Cloudinary_Anda
   ```
4. Pastikan file konfigurasi Firebase `google-services.json` (untuk Android) sudah berada di `android/app/`.
5. Jalankan aplikasi pada emulator atau perangkat fisik:
   ```bash
   flutter run
   ```

---

## 📜 Direktori Dokumentasi Lanjutan
Aplikasi ini dilengkapi dengan catatan perancangan sistem yang mendetail untuk keperluan skripsi. Silakan baca file-file berikut untuk pemahaman alur sistem secara teknis:

- 📖 **[Alur Sistem, Flowchart, dan Skema Fitur (PENTING)](ALUR_SISTEM_DAN_FITUR.md)**
- 📂 **[Catatan Struktur Folder & Kegunaan File](CATATAN_STRUKTUR.md)**

---

<div align="center">
  <b>© 2026 Camelio Finance - Muhammad Dicky Adicandra</b>
  <br><i>Tugas Akhir / Skripsi Pengembangan Multimodal Artificial Intelligence Financial Assistant dalam Rekomendasi Pembelian Otomatis pada UMKM Kopi Menceng</i>
</div>
