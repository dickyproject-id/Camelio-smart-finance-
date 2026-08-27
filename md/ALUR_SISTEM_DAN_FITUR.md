# 📱 Alur Sistem & Fitur Utama (Camelio Finance)

Dokumen ini menjelaskan secara rinci tentang fitur utama, alur kerja sistem, skema database, dan integrasi Artificial Intelligence (Google Gemini) pada aplikasi **Camelio Finance**. Dokumen ini ditulis dalam format teks murni agar mudah dibaca dan divisualisasikan menjadi gambar oleh sistem lain.

---

## 🌟 1. Fitur Utama Aplikasi

1. **Scan Struk (OCR & Vision AI):** Fitur untuk memindai nota/struk belanja fisik menggunakan kamera. Gambar akan diproses menggunakan AI untuk mengekstrak nama barang, total harga, dan tanggal secara otomatis tanpa perlu diketik manual.
2. **Input Suara (Voice AI):** Memungkinkan pengguna mencatat pengeluaran hanya dengan berbicara (misal: *"Saya baru saja beli bahan baku seharga 50 ribu"*). Sistem akan mengubah suara menjadi teks, lalu AI akan menerjemahkannya menjadi data transaksi.
3. **Chat AI (Input Teks Pintar):** Fitur chat yang berfungsi sebagai jalan pintas pencatatan. Pengguna cukup mengetik bahasa natural seperti *"saya beli coffee 15k"*, dan AI (Gemini) secara cerdas akan langsung memecah kalimat tersebut menjadi format transaksi (Harga: 15.000, Kategori: Minuman, Jenis: Pengeluaran).
4. **Input Manual:** Pencatatan transaksi konvensional melalui *form* biasa (mengisi nominal, kategori, dan deskripsi secara mandiri).
5. **AI Insight (Rekomendasi Ekonomis):** Fitur analitik cerdas yang dapat diakses melalui halaman khusus "AI Insight". Fitur ini menganalisis pola riwayat transaksi pengguna dan secara proaktif memberikan "Tips Hemat" serta rekomendasi solusi operasional yang lebih ekonomis.

---

## 🔄 2. Alur Kerja Aplikasi (Global Workflow)

Berikut adalah urutan bagaimana sistem secara keseluruhan bekerja dari awal hingga akhir:

- **Langkah 1:** Pengguna membuka aplikasi. Sistem mengecek status sesi. Jika belum memiliki akun, pengguna diarahkan ke halaman Login/Register (menggunakan Firebase Auth). Jika sudah, langsung masuk ke Dashboard Utama.
- **Langkah 2:** Di Dashboard, pengguna dapat melihat ringkasan saldo. Pengguna lalu memilih tombol tambah transaksi.
- **Langkah 3:** Pengguna memilih metode input (Scan Struk, Suara, Chat/Teks, atau Manual).
- **Langkah 4:** Sistem memproses inputan tersebut:
  - *Jika Scan Struk:* Gambar dilempar ke Cloudinary & Gemini Vision.
  - *Jika Suara / Chat AI:* Teks dilempar ke Gemini LLM.
  - *Jika Manual:* Data langsung dirangkum di sistem lokal.
- **Langkah 5:** Data transaksi yang sudah terbentuk (berupa nominal, kategori, dll) disimpan secara *real-time* ke database Firebase Firestore.
- **Langkah 6:** Aplikasi secara otomatis memperbarui grafik saldo di Dashboard.
- **Langkah 7:** Pengguna dapat menekan menu/kartu **AI Insight** di Dashboard untuk beralih ke halaman khusus AI Insight, di mana AI akan membaca pola pengeluaran terbaru pengguna dan menyajikan tips serta solusi berhemat.

---

## 📸 3. Alur Kerja Detail Setiap Fitur

### A. Alur Fitur Scan Struk (OCR + Vision AI)
1. Pengguna membuka kamera di dalam aplikasi dan memotret fisik struk belanja.
2. Aplikasi mengirimkan (upload) gambar struk tersebut ke server **Cloudinary**.
3. Cloudinary memproses gambar (kompresi) dan mengembalikan URL (link) gambar tersebut ke aplikasi.
4. Aplikasi mengirimkan URL gambar beserta instruksi (*prompt*) rahasia ke **Gemini Vision AI**.
5. Gemini bertindak sebagai OCR cerdas; ia mengamati piksel gambar, membaca teks, dan membedakan mana yang nominal harga dan mana yang nama barang.
6. Gemini mengembalikan hasil ekstraksi tersebut ke aplikasi dalam format data JSON terstruktur.
7. Aplikasi menampilkan rangkuman data tersebut di layar pengguna (sebagai *preview*). Jika terdapat item atau data yang kurang sesuai dari hasil scan, pengguna hanya dapat **menghapus** data tersebut (tidak dapat diubah/edit) sebelum menyimpannya.
8. Setelah pengguna menekan tombol konfirmasi, data resmi disimpan ke Firebase Firestore.

### B. Alur Fitur Input Suara & Chat AI (Text Input)
1. Pengguna menahan tombol *Mic* lalu berbicara, atau pengguna mengetik kalimat di kolom Chat (Contoh: "Beli tepung 50rb").
2. Jika menggunakan suara, modul *Speech-to-Text* akan mengubah suara tersebut menjadi bentuk teks (*string*).
3. Teks tersebut dikirim ke sistem **Gemini LLM** beserta *prompt* klasifikasi khusus.
4. AI membedah makna kalimat, mendeteksi nominal angka ("50rb" menjadi 50000), dan menentukan kategori yang pas ("tepung" masuk ke kategori Bahan Baku/Makanan).
5. Gemini mengembalikan hasil identifikasi tersebut dalam wujud JSON.
6. Data langsung diproses oleh aplikasi dan disimpan ke Firebase Firestore.

### C. Alur Fitur AI Insight (Rekomendasi Pembelian Ekonomis)
1. Pengguna mengklik menu/kartu AI Insight yang terdapat pada halaman Dashboard.
2. Aplikasi membuka Halaman AI Insight dan menarik data seluruh pengeluaran (misal 30 hari terakhir) milik pengguna dari Firebase Firestore.
3. Data pengeluaran tersebut dirangkum menjadi format teks sederhana.
4. Rangkuman data ini dikirim ke **Gemini LLM API** dengan *prompt* khusus untuk melakukan "Analisis Keuangan UMKM".
5. Gemini memproses data, mencari anomali pengeluaran, lalu merumuskan nasihat keuangan atau tips berhemat.
6. Teks rekomendasi dan solusi operasional singkat dari AI tersebut ditampilkan di Halaman AI Insight.

---

## 🗄️ 4. Arsitektur Layanan Cloud & Database (Backend)

Sistem menggunakan layanan *cloud* dari **Firebase** dan **Cloudinary** untuk mengelola data, keamanan, dan konfigurasi aplikasi:

**1. Firebase Authentication**
Bertugas mengelola sistem otentikasi (login/pendaftaran) pengguna secara aman, sehingga memastikan setiap pengguna hanya dapat mengakses data keuangannya sendiri.

**2. Firebase Remote Config**
Digunakan untuk menyimpan dan mengelola konfigurasi atau pengaturan aplikasi secara jarak jauh tanpa perlu memperbarui aplikasi di *store*. Pada aplikasi ini, Remote Config secara khusus digunakan untuk menyimpan **API Key Gemini** secara dinamis, sehingga *key* aman dan tidak ditaruh langsung (*hardcoded*) di dalam kode aplikasi.

**3. Cloudinary (Media Storage)**
Bertugas murni sebagai penyimpan dan pengoptimal resolusi gambar (foto struk) agar tidak membebani server dan mempercepat proses ekstraksi data oleh AI.

**4. Firebase Firestore (NoSQL Database)**
Sebagai database utama, sistem menggunakan struktur arsitektur data **Flat (Koleksi Root)** untuk memudahkan *query* berkinerja tinggi. Berikut adalah koleksi utama (Root Collections) yang ada:

- **Koleksi: `users`** (Menyimpan profil pengguna)
  - `balance`: *Number*
  - `birthDate`: *Timestamp*
  - `createdAt`: *Timestamp*
  - `deactivatedAt`: *Timestamp*
  - `email`: *String*
  - `gender`: *String*
  - `monthlyBudget`: *Number*
  - `name`: *String*
  - `photoUrl`: *String*
  - `status`: *String*
  - `updatedAt`: *Timestamp*
  - `whatsapp`: *String*
- **Koleksi: `wallets`** (Menyimpan dompet digital atau akun perbankan)
  - `accountNumber`: *String*
  - `balance`: *Number*
  - `createdAt`: *Timestamp*
  - `iconUrl`: *String*
  - `lastSyncDate`: *Timestamp*
  - `name`: *String*
  - `type`: *String*
  - `userId`: *String* (Foreign Key ke `users`)
- **Koleksi: `transactions`** (Mencatat riwayat transaksi)
  - `amount`: *Number*
  - `category`: *String*
  - `date`: *Timestamp*
  - `description`: *String*
  - `imageUrl`: *String*
  - `source`: *String*
  - `type`: *String*
  - `userId`: *String* (Foreign Key ke `users`)
  - `walletId`: *String* (Foreign Key ke `wallets`)
  - `items`: *Array (List of Maps)* -> Detail barang (name, qty, price_unit, line_total)
- **Koleksi: `rating`** (Menyimpan ulasan dari pengguna)
  - `comment`: *String*
  - `createdAt`: *Timestamp*
  - `email`: *String*
  - `name`: *String*
  - `rating`: *Number*
  - `userId`: *String* (Foreign Key ke `users`)
- **Koleksi: `notifications`** (Log notifikasi sistem)
  - `date`: *Timestamp*
  - `isRead`: *Boolean*
  - `message`: *String*
  - `title`: *String*
  - `type`: *String*
  - `userId`: *String* (Foreign Key ke `users`)

---

## 🧠 5. Pengambilan API Gemini & Hasil Output AI

Aplikasi berkomunikasi dengan otak AI Google melalui *package* `google_generative_ai`. Kunci utama agar output AI tidak melantur dan langsung bisa dimasukkan ke database adalah dengan teknik **Prompt Engineering** dan pemaksaan format JSON.

**Alur Pengambilan Keputusan AI:**
1. Aplikasi menyusun perintah dasar (*System Instruction*) di dalam kode (contoh: "Kamu adalah sistem pencatat keuangan, temukan harga dari teks ini, ubah ke angka murni tanpa Rp, lalu balas dalam bentuk JSON").
2. AI (Gemini Flash) memproses data masuk (entah itu berupa Teks, Suara yang diubah ke teks, atau Gambar Struk).
3. AI membalas dengan kode JSON (Structured Data).
4. Kode Flutter mengubah JSON tersebut menjadi objek Model Transaksi di dalam memori aplikasi, sehingga UI bisa langsung menampilkannya sebagai kartu riwayat transaksi di layar pengguna.
