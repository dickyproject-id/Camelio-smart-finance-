# Perbaikan Proposal: Smart Finance App (Camelio Finance)

Berikut adalah penjabaran perbaikan proposal yang telah disesuaikan secara presisi dengan arsitektur **Camelio Finance** (menggunakan Flutter, Firebase, dan Google Gemini API). Poin nomor 4 (Luaran Akademik) diabaikan sesuai instruksi.

## 1. Metode Artificial Intelligence Secara Spesifik

*   **Algoritma & Model AI yang digunakan:**
    Sistem tidak membangun model prediktif kustom (seperti DNN dari awal), melainkan memanfaatkan kapabilitas *Generative AI* mutakhir berbasis *Large Language Model (LLM)* dan *Vision-Language Model (VLM)*. Secara spesifik, aplikasi menggunakan **Google Gemini 1.5 Flash API**. Model ini digunakan untuk tiga fungsi utama: *Vision AI* (OCR Struk), *NLP* (Ekstraksi teks suara/chat menjadi JSON), dan *Financial Insight Engine*.
*   **Mekanisme Training:**
    Aplikasi menggunakan *pre-trained model* dari ekosistem Google. Penyesuaian ke dalam ranah asisten keuangan dilakukan melalui teknik **Prompt Engineering** (*Zero-shot* dan *Few-shot prompting*). Melalui *prompt* sistem yang dirancang khusus, Gemini diinstruksikan untuk mengenali struktur struk, mengkategorikan pembelanjaan, dan mengembalikan hasil dalam format *Structured JSON* yang baku, tanpa perlu melatih beban *weights* secara lokal.
*   **Mekanisme Inferensi:**
    Infrastruktur inferensi berjalan secara *Serverless* (Cloud-based processing). 
    1. Klien (Flutter) menangkap gambar struk, mengunggah dan mengompresinya melalui API Cloudinary.
    2. URL gambar (atau teks dari hasil *Speech-to-Text*) beserta *Prompt* dikirimkan ke Endpoint Gemini AI.
    3. Gemini memproses input tersebut dan mengembalikan respons (JSON transaksi atau narasi teks rekomendasi) ke aplikasi *client* secara *real-time* dalam ukuran milidetik.
*   **Sumber Knowledge Rekomendasi:**
    Rekomendasi keuangan (Modul *AI Insight*) dihasilkan dengan menggabungkan pengetahuan fundamental keuangan (*general knowledge*) milik model bahasa Gemini, dengan **konteks lokal pengguna**. Konteks lokal ini berupa data tarikan (*query*) riwayat transaksi pengguna dari **Firebase Firestore** dalam 30 hari terakhir yang diinjeksikan secara dinamis ke dalam *Prompt* sebelum dikirim ke AI.

## 2. Evaluasi AI

Sistem evaluasi kualitas AI difokuskan pada metrik *Information Extraction* dan *User Acceptance*, yaitu:
*   **Accuracy & Precision (Ekstraksi OCR & NLP):** Mengukur tingkat keberhasilan (*Success Rate*) Gemini dalam membaca nominal uang (*amount*), nama barang (*title*), dan kategori (*category*) dari gambar struk maupun *input* suara/teks. Target akurasi > 90% (diukur dari seberapa jarang pengguna harus melakukan koreksi/menghapus item yang salah pada layar "Preview Transaksi").
*   **Relevansi Rekomendasi (AI Insight):** Evaluasi *Hallucination Rate*, memastikan bahwa nasihat berhemat yang diberikan oleh Gemini selaras dan berdasarkan data murni dari riwayat 30 hari transaksi pengguna, tidak mengarang data transaksi fiktif.
*   **User Satisfaction (Kepuasan Pengguna):** Diukur menggunakan pengumpulan umpan balik atau kuesioner *System Usability Scale* (SUS) terintegrasi untuk melihat apakah interaksi natural (Chat/Voice) dirasa mempermudah pengguna oleh berbagai rentang usia (termasuk lansia sesuai panduan).

## 3. Dampak Terukur Secara Kuantitatif

Implementasi sistem Camelio Finance ditargetkan untuk menghasilkan dampak sebagai berikut:
*   **Pengurangan Waktu Pencatatan (%):** Memangkas waktu pencatatan manual hingga **70% - 80%** dengan dukungan multi-input pintar (Scan OCR Struk, Suara, Chat AI) serta otomasi penarikan riwayat via integrasi Gmail API.
*   **Pengurangan Human Error (%):** Menurunkan tingkat kesalahan (*human error*) dalam memasukkan nominal angka dan kategori hingga **90%** karena pengenalan mesin pada bukti otentik transaksi.
*   **Peningkatan Efisiensi Pembelian (%):** Melalui fitur Nasihat Berhemat (*AI Insight*) bulanan, pengguna ditargetkan mampu menekan pengeluaran konsumtif/tersier sebesar **5% - 15%** dari total anggaran mereka secara berkelanjutan.

## 5. Keberlanjutan Sistem

*   **Administrator Sistem:** 
    Dikelola oleh tim pengembang sebagai pengelola konfigurasi utama (mengatur variabel *Firebase Remote Config*, batas kuota API Gemini, dan *Cloudinary*).
*   **Mekanisme Backup Data:**
    Data tersimpan terpusat di awan menggunakan **Cloud Firestore (NoSQL)**. Platform ini secara bawaan (native) mendukung skalabilitas tinggi, replikasi data yang aman, dan kapabilitas pencadangan otomatis sehingga mencegah kehilangan rekam jejak finansial pengguna.
*   **Pengembangan & Pemeliharaan Model AI:**
    Karena aplikasi berbasis konsumsi API eksternal (MaaS - Model as a Service), *maintenance* algoritma berada di pihak Google. Namun, tim pengembang akan secara periodik melakukan *tuning* dan optimalisasi pada **Prompt Engineering** (memperbarui *prompt* instruksi jika rilis model Gemini terbaru membutuhkan pendekatan berbeda) untuk memastikan konsistensi output JSON.
*   **Maintenance Aplikasi:**
    Pembaruan versi *library* Flutter (untuk dukungan cross-platform), perbaikan kelemahan (*bug-fixing*), serta manajemen integrasi otentikasi OAuth 2.0 (Gmail & Firebase Auth) agar akses token tetap aman dan valid.

## 6. Validasi Rekomendasi Ekonomis

Untuk memastikan fitur *AI Insight* benar-benar mendorong pengguna lebih ekonomis, sistem menerapkan validasi logis berikut:
*   **Historical Trend Analysis (Grafik Portofolio):** Aplikasi menampilkan grafik analitik bawaan pada layar "Portofolio". Pengguna dapat melihat secara transparan tren garis pengeluaran mereka; apakah grafiknya melandai (menurun) pada kategori boros setelah pengguna membaca dan menerapkan nasihat *AI Insight* di bulan sebelumnya (Validasi A/B bulan lalu vs bulan ini).
*   **Cerminan Peningkatan Saldo Akhir (Surplus):** Pembuktian yang paling faktual terlihat dari selisih Saldo Akhir di *Dashboard*. Rekomendasi dianggap valid apabila rasio sisa uang terhadap total pemasukan pengguna berangsur membesar di siklus pencatatan selanjutnya.
