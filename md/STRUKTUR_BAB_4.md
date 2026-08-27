# BAB IV
# PENGUJIAN DAN EVALUASI SISTEM

Bab ini membahas proses dan hasil pengujian terhadap aplikasi *Camelio Finance*. Pengujian dilakukan untuk memastikan bahwa sistem yang dikembangkan (artefak) telah memenuhi spesifikasi kebutuhan (sejalan dengan metode *Design Science Research*) serta untuk mengevaluasi kinerja model kecerdasan buatan (*Artificial Intelligence*) dalam memproses input *multimodal*.

---

## 4.1 Lingkungan Pengujian
*Bagian ini menjelaskan spesifikasi teknis dari perangkat yang digunakan untuk melakukan pengujian, baik dari sisi *developer* maupun dari sisi pengguna (UMKM Kopi Menceng).*

**Isi yang harus ditulis:**
*   **Perangkat Keras (Hardware):** Spesifikasi laptop/PC yang digunakan untuk *build* aplikasi (misal: MacBook Pro M1, RAM 16GB) dan spesifikasi *smartphone* Android/iOS yang digunakan untuk *testing* langsung di lapangan (misal: Samsung Galaxy S23, Kamera 50MP, Mic internal).
*   **Perangkat Lunak (Software):** Versi OS *smartphone* (Android 14/iOS 17), versi Flutter yang digunakan, dan layanan pendukung seperti Firebase (Firestore, Auth) dan Google Generative AI API (Gemini 1.5 Flash).

---

## 4.2 Hasil Implementasi Antarmuka Sistem (*User Interface*)
*Di sinilah tempat terbaik untuk **menampilkan screenshot tampilan layar aplikasi** Anda secara keseluruhan sebelum masuk ke tahap pengujian yang rumit.*

**Isi yang harus ditulis:**
*   **Gambar Tampilan:** Masukkan 4-6 *screenshot* halaman utama aplikasi (misal: Halaman Login, Halaman *Dashboard* Utama, Halaman *Chat/Voice AI*, dan Halaman *Scan* Struk).
*   **Penjelasan:** Berikan deskripsi singkat di bawah setiap gambar mengenai fungsi halaman tersebut (misal: *"Gambar 4.x menampilkan halaman antarmuka pemindai struk yang terintegrasi langsung dengan modul kamera perangkat..."*).

---

## 4.3 Pengujian Sistem
*Sesuai dengan pedoman penulisan, bagian ini menjabarkan metode pengujian yang diterapkan. Semua pengujian menggunakan format baku (Tujuan, Skenario, Langkah, Input, Output, Hasil, Status).*

### 4.3.1 Pengujian Ekstraksi Informasi dari Gambar Struk (*Ground Truth Validation*)
*Bagian ini menguji kinerja OCR pada input gambar struk menggunakan model Gemini 1.5 Flash.*
*   **Tujuan:** Mengukur tingkat akurasi model AI dalam mengekstrak entitas data dari gambar fisik struk menjadi format terstruktur (JSON murni).
*   **Skenario:** Pengujian pemindaian struk belanja operasional dari penyedia bahan baku (minimarket/grosir).
*   **Langkah:** Pengguna menekan tombol FAB (Tambah Transaksi) -> Memilih opsi "Scan Struk" -> Mengambil foto struk fisik menggunakan kamera (*ImagePicker*) -> Aplikasi mengirim `imageBytes` ke *method* `classifyReceiptFromImage` pada `GeminiAIService` -> Sistem melakukan konversi (OCR) dan menampilkan konfirmasi data.
*   **Input:** File gambar struk riil operasional Kopi Menceng (contoh: Gambar struk yang memuat daftar belanjaan kopi, gula, dan susu).
*   **Output:** Respons JSON dari API Gemini yang memuat key `storeName`, `category`, `type` (*expense*), dan *array* `items` (memuat `name`, `price_unit`, `qty`, dan `line_total`).
*   **Hasil:** (Contoh Data: Dari sampel 50 fisik struk, AI berhasil menghasilkan JSON valid dengan nilai total yang cocok secara eksak dengan harga asli/Ground Truth pada 46 struk, menghasilkan persentase akurasi 92%. Kegagalan pada 4 struk disebabkan oleh kondisi kertas yang pudar).
*   **Status:** Valid / Berhasil.

### 4.3.2 Pengujian Kemampuan *Natural Language Processing* (NLP) pada *Gemini AI*
*Bagian ini menguji fitur Chat AI dan Voice AI (Speech-to-Text).*
*   **Tujuan:** Mengukur tingkat keberhasilan *Intent Recognition* (klasifikasi pemasukan/pengeluaran) dan *Entity Extraction* (penerjemahan nominal tidak baku menjadi *integer*) dari input bahasa alami pengguna.
*   **Skenario:** Pemberian instruksi pencatatan transaksi menggunakan bahasa sehari-hari.
*   **Langkah:** Pengguna menekan tombol FAB -> Memilih "Voice AI" atau "Chat AI" -> Mengucapkan/mengetik kalimat -> Modul *Speech-to-Text* menerjemahkan suara ke teks (jika *voice*) -> Teks dikirim ke *method* `classifyTransaction` pada `GeminiAIService` -> Sistem menyimpan data.
*   **Input:** *String* teks tidak baku. Contoh: "Barusan beli es batu sama token listrik habis 150 rebu".
*   **Output:** Respons JSON `{ "description": "Beli es batu dan token listrik", "amount": 150000, "category": "Tagihan", "type": "expense" }`.
*   **Hasil:** Sistem berhasil melakukan *Intent Recognition* (menandai *type* sebagai `expense`) dan *Entity Extraction* (menerjemahkan bahasa slang "150 rebu" menjadi angka *integer* baku `150000` sesuai instruksi *Prompt Engineering*).
*   **Status:** Valid / Berhasil.

### 4.3.3 Pengujian Penerimaan Pengguna melalui *User Acceptance Test* (UAT)
*Bagian ini memvalidasi fungsionalitas analitik prediktif / AI Advisor secara kualitatif.*
*   **Tujuan:** Memvalidasi tingkat relevansi, pemahaman konteks bisnis, dan nilai aksi (*actionability*) dari fitur rekomendasi pembelian dan peringatan dini AI terhadap operasional bisnis UMKM.
*   **Skenario:** Pengguna meminta nasihat keuangan bulanan (*Financial Advice*).
*   **Langkah:** Pengguna membuka menu *AI Insight* -> Aplikasi mengeksekusi *method* `askForFinancialInsight` pada `AIInsightProvider` -> *Provider* menarik agregasi data `totalBalance` dan `monthlyBudget` dari *Firestore* -> Mengirim *Context Injection* ke Gemini AI -> Sistem menampilkan 3 paragraf rekomendasi bisnis.
*   **Input:** Penyisipan data dinamis (konteks) berupa total pengeluaran aktual bulan ini (misal: Rp 5.000.000) dan budget maksimal.
*   **Output:** Teks bahasa alami berupa saran efisiensi keuangan dan peringatan terhadap kategori terboros (misal: "Bahan Baku").
*   **Hasil (Feedback Pemilik):** Berdasarkan hasil *In-Depth Interview*, pemilik UMKM Kopi Menceng memvalidasi bahwa rekomendasi dari fitur *AI Insight* sangat sesuai dengan kondisi operasional di lapangan. Kutipan wawancara pemilik: *"Saran aplikasinya cukup masuk akal, Pak. Terutama pas ngingetin soal biaya bahan baku kopi yang lagi naik bulan ini. Biasanya saya baru sadar pengeluaran kedai bengkak pas akhir bulan pas ngitung manual, tapi gara-gara diingetin begini, saya jadi bisa ngerem pembelian barang lain yang nggak terlalu mendesak."* Pemilik juga menambahkan bahwa meskipun terkadang pemilihan kata AI-nya masih terasa agak baku, namun inti sarannya sangat mudah dipahami dan bisa langsung diterapkan untuk menjaga arus kas kedai tetap aman.
*   **Status:** Diterima / Valid.

---

## 4.4 Evaluasi Keseluruhan Berdasarkan Design Science Research
*Ini adalah validasi pamungkas untuk menyambungkan hasil Bab 4 dengan metode DSR di Bab 3.*

**Isi yang harus ditulis:**
*   Membahas tahapan *Evaluation* dari kerangka DSR (Peffers et al., 2007). 
*   Buat paragraf rangkuman yang membandingkan **"Masalah di Bab 1"** VS **"Solusi/Hasil Artefak di Bab 4"**. 
*   Contoh kalimat: *"Berdasarkan pengujian sistem (Black Box, Integrasi API, dan UAT), artefak Camelio Finance telah terbukti mampu menyelesaikan masalah akuisisi data melalui fitur ekstraksi teks multimodal (tingkat akurasi OCR >90%), serta memfasilitasi keputusan bisnis yang lebih baik melalui analitik prediktif AI. Dengan demikian, objektif penelitian telah tercapai."*
