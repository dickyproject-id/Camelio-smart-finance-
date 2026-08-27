# BAB 3: METODOLOGI DAN RENCANA IMPLEMENTASI

## 3.1 Metode Pengembangan Sistem

Metode yang digunakan dalam pengembangan sistem aplikasi *Camelio Finance* adalah *Design Science Research* (DSR). Pemilihan metode ini didasarkan pada tujuan utama penelitian yang berfokus pada perancangan dan pembangunan artefak teknologi—berupa sistem analisis keuangan berbasis *Artificial Intelligence* (AI) dan *Optical Character Recognition* (OCR)—sebagai solusi komprehensif terhadap permasalahan nyata yang dihadapi oleh mitra penelitian, yaitu UMKM Kopi Menceng.

Metode DSR dipilih karena memiliki karakteristik yang sejalan dengan pengembangan sistem informasi yang tidak hanya berorientasi pada eksplorasi teori, tetapi juga menghasilkan produk teknologi (artefak) yang aplikatif dan fungsional. Dalam konteks penelitian ini, artefak yang dihasilkan berupa aplikasi Android yang mampu mengotomatisasi pencatatan transaksi melalui *multimodal input* (gambar, suara, teks), melakukan ekstraksi data keuangan, serta menyajikan rekomendasi pembelian ekonomis berbasis *AI Insight*.

Menurut Peffers et al. (2007), tahapan *Design Science Research* yang diterapkan dalam penelitian ini meliputi enam fase, yang diawali dengan:

### 3.1.1 Identifikasi Masalah dan Motivasi (*Problem Identification and Motivation*)

Pada tahap ini, dilakukan identifikasi terhadap akar permasalahan operasional yang terjadi pada UMKM Kopi Menceng melalui metode observasi langsung dan wawancara dengan pemilik usaha. Identifikasi ini bertujuan untuk merumuskan motivasi pengembangan artefak teknologi yang tepat guna.

Beberapa permasalahan utama yang ditemukan di lapangan meliputi:
1. **Inefisiensi Akuisisi Data Keuangan:** Pencatatan transaksi masih dilakukan secara manual dan konvensional, sehingga menyita waktu operasional dan rentan terhadap kesalahan manusia (*human error*).
2. **Belum Adanya Digitalisasi Dokumen Fisik:** Bukti transaksi (struk pembelian) belum terdigitalisasi, menyulitkan proses penelusuran (*tracking*) dan audit pengeluaran.
3. **Keterbatasan Analitik Pengeluaran:** Pemilik usaha kesulitan melakukan analisis pengeluaran secara berkala karena data tidak terstruktur dengan baik.
4. **Absennya Sistem Pendukung Keputusan Berbasis Data:** Belum tersedia sistem analitik cerdas yang mampu mengidentifikasi anomali fluktuasi harga bahan baku maupun memberikan rekomendasi pembelian yang lebih ekonomis.
5. **Keterbatasan Metode Input Transaksi:** Tidak adanya fleksibilitas (seperti input suara atau deteksi otomatis dari gambar) yang dapat memfasilitasi pencatatan secara cepat saat pemilik sedang sibuk di lapangan.

Hasil identifikasi masalah di atas kemudian menjadi landasan empiris (*baseline*) dalam merumuskan tujuan dan menentukan spesifikasi kebutuhan sistem (*system requirements*) yang akan dikembangkan pada tahap selanjutnya.

### 3.1.2 Penentuan Tujuan Solusi (*Define Objectives of a Solution*)

Tahapan ini berfokus pada perumusan spesifikasi teknis dan desain arsitektur yang mampu menjawab permasalahan pada tahap sebelumnya. Solusi yang diusulkan adalah membangun aplikasi *mobile* bernama *Camelio Finance*. Aplikasi ini dirancang menggunakan arsitektur *Client-Server* dengan pemrosesan berbasis awan (*Cloud-based processing*). Beban komputasi yang berat (seperti pengenalan pola gambar struk dan analisis sentimen pengeluaran) dialihkan dari perangkat pengguna (*client-side*) ke penyedia layanan eksternal melalui API (*Serverless Architecture*).

Untuk mencapai tujuan tersebut, ditetapkan beberapa tumpukan teknologi utama:
- **Flutter & Dart:** Sebagai kerangka kerja (*framework*) pengembangan antarmuka secara *cross-platform* yang ringan.
- **Firebase Ecosystem:** Memanfaatkan *Firebase Authentication* untuk keamanan sesi akses dan *Cloud Firestore* sebagai basis data NoSQL untuk manajemen *state* dan sinkronisasi data secara *real-time*.
- **Google Gemini AI API:** Menggunakan model kecerdasan buatan *Gemini 1.5 Flash* untuk menggerakkan tiga fungsionalitas inti: *Vision AI* (pembacaan struk OCR), *Natural Language Processing* (pemahaman input teks/suara bebas dari pengguna), dan mesin analitik penganalisis portofolio keuangan.

### 3.1.3 Perancangan dan Pengembangan (*Design and Development*)

Tahap ini merupakan fase inti pembuatan artefak, meliputi perancangan tata letak antarmuka (*UI/UX*), penulisan kode (*coding*), dan pengintegrasian logika kecerdasan buatan. Arsitektur perangkat lunak disusun menggunakan pola **Model-View-ViewModel (MVVM)** untuk memastikan pemisahan yang jelas antara antarmuka visual (*View*), penyedia keadaan/status (*Provider/ViewModel*), dan layanan pengaksesan sumber data eksternal (*Service/Model*).

Secara khusus pada pengembangan logika kecerdasan buatan, karena aplikasi ini sepenuhnya menggunakan *Pre-trained Model* melalui jalur API dari Google Generative AI, tidak ada fase pelatihan model secara konvensional (seperti *Fine-tuning* bobot *Neural Network*) yang dilakukan. Mekanisme "pelatihan" pada sistem ini berfokus kuat pada dua teknik utama:

1. **Prompt Engineering (Rekayasa Prompt):** Menggunakan instruksi statis yang sangat detail di dalam kode (seperti pendefinisian aturan kategori transaksi yang ketat dan instruksi wajib pemetaan output ke dalam format struktur JSON murni).
2. **Context Injection (Penyisipan Konteks):** Mengambil data transaksi historis pengguna dari *database* Firestore dan menyisipkannya sebagai variabel dinamis (konteks) ke dalam *prompt*, sehingga respons AI menjadi spesifik dan relevan dengan profil pengeluaran riil pengguna.

**Tabel 3.1 Perbandingan Skenario Prompt dan Injeksi Konteks pada Sistem**

| No | Fitur Aplikasi | Mekanisme yang Digunakan | Tujuan & Aturan Prompt | Skenario Prompt / Format Instruksi (Potongan Kode) |
|---|---|---|---|---|
| **1** | **Ekstraksi Teks Transaksi (Input Chat & Suara)** | *Prompt Engineering* | Memaksa AI mengekstrak entitas dari teks tidak terstruktur menjadi format JSON terstruktur. Mengandung aturan ketat penentuan tipe (income/expense) dan pemetaan kategori. | `"Ekstrak data transaksi dari teks ini: \"$userInput\" Format JSON: { "description": "...", "amount": 10000, "category": "Makanan", "type": "expense" } PENTING UNTUK TYPE: Tentukan "type" dengan "income" jika transaksi adalah pemasukan... "` |
| **2** | **Pemrosesan Gambar Struk (OCR / Vision)** | *Prompt Engineering* | Menginstruksikan Vision Model untuk membaca gambar struk dan memetakannya ke JSON murni. Memiliki aturan khusus untuk item diskon dan perhitungan otomatis `line_total` = `qty` * `price_unit`. | `"Ekstrak data dari struk belanja ini menjadi format JSON: { "storeName": "Nama Toko", "category": "Belanja", "type": "expense", "items": [ { "name": "Nama Barang", "price_unit": 10000, "qty": 2, "line_total": 20000 } ] } Wajib JSON murni..."` |
| **3** | **Saran Keuangan (AI Advisor)** | *Context Injection* | Memberikan saran finansial yang personal berdasarkan kondisi keuangan riil pengguna. Menyisipkan variabel dinamis berupa total pengeluaran dan limit budget bulanan. | `"Saya memiliki total pengeluaran sebesar $totalBalance dan target bulanan saya maksimal adalah $monthlyBudget. Berdasarkan kondisi tersebut, berikan saran finansial singkat dengan nada yang santai, memotivasi, dan berkelas."` |
| **4** | **Ringkasan Portofolio (Dashboard Insight)** | *Context Injection* | Menghasilkan ringkasan singkat (2 kalimat) tentang performa portofolio keuangan. Menyisipkan variabel total pemasukan, total pengeluaran, dan daftar kategori terboros. | `"Analisis data keuangan: Pemasukan Rp $income, Pengeluaran Rp $expense. Kategori terboros: ${topCategories.join(', ')}. Berikan 2 kalimat saran singkat dalam bahasa Indonesia."` |

### 3.1.4 Demonstrasi (*Demonstration*)

Fase demonstrasi bertujuan untuk menguji fungsionalitas artefak awal (*Alpha/Beta Release*) pada lingkungan pengujian operasional. Pengujian sistem aplikasi *Camelio Finance* dilakukan pada lingkungan yang mencakup perangkat keras (*hardware*), perangkat lunak (*software*), serta integrasi API eksternal pendukung. 

*   **Lingkungan Pengembangan (Development):** Pembuatan dan kompilasi kode aplikasi (*build*) dilakukan menggunakan perangkat MacBook (berbasis *chip* Apple M1) dengan editor Visual Studio Code dan Flutter SDK versi ^3.11.4.
*   **Lingkungan Operasional (Testing):** Pengujian aplikasi secara langsung (implementasi *real-world*) dilakukan pada *smartphone* Android Xiaomi Redmi 9T (RAM 6GB, ROM 128GB) dengan target batas minimum sistem operasi Android SDK versi 21 (Lollipop). Perangkat ini dipilih karena mewakili spesifikasi ponsel kelas menengah (*mid-range*) yang umum digunakan oleh pelaku UMKM. Kapasitas RAM 6GB dirasa representatif untuk menguji beban memori saat aplikasi memproses kompresi gambar (*Cloudinary*) untuk fitur OCR dan merekam data modul *Speech-to-Text*.

### 3.1.5 Evaluasi (*Evaluation*)

Evaluasi sistem dilakukan untuk mengukur tingkat efektivitas artefak teknologi dalam memecahkan masalah UMKM. Pendekatan evaluasi dilakukan secara komprehensif, mencakup pengujian teknis (*System Testing*) dan pengujian penerimaan pengguna akhir (*User Acceptance Testing*/UAT).

Pengujian kinerja *Artificial Intelligence* (AI) pada aplikasi *Camelio Finance* difokuskan pada pengujian akurasi fungsional dan penerimaan pengguna akhir (*User Acceptance*). Mengingat asisten keuangan ini bersifat multimodal (mampu memproses input berupa gambar, teks, dan suara), skenario pengujian dirancang secara spesifik untuk mengukur keandalan teknis serta kebermanfaatan sistem melalui tiga tahapan pengujian utama:

Pertama, pengujian kinerja pemrosesan gambar (*Vision AI / OCR*) yang digerakkan oleh *Multimodal Large Language Model* (Google Gemini 1.5 Flash). Pengujian ini menggunakan metode *information extraction* dengan sampel uji berupa lebih dari 50 lembar fisik struk/nota belanja acak dari luar aktivitas operasional UMKM Kopi Menceng. Pengujian menggunakan struk eksternal ini bertujuan untuk membuktikan keluwesan (*robustness*) model dalam membaca berbagai variasi format tata letak. Pengujian akurasi dilakukan melalui skenario pengujian silang (*Ground Truth Validation*), di mana hasil tebakan awal sistem (*AI Predicted Amount*) dikomparasikan secara langsung dengan harga faktual hasil koreksi manual pengguna (*Ground Truth*). Tingkat keberhasilan ini diekspor secara otomatis ke dalam format *Comma Separated Values* (CSV) untuk menghitung persentase akurasi model. Sistem ditetapkan memenuhi standar kelayakan apabila tingkat keberhasilan ekstraksi melampaui *threshold* 90%, guna meminimalisasi beban koreksi manual oleh pengguna.

Kedua, pengujian fungsionalitas *Natural Language Processing* (NLP) pada fitur *chat AI* dan *voice AI* (melalui modul *speech-to-text*). Metrik pengujian berfokus pada *intent recognition accuracy* dan *entity extraction success rate*, yakni persentase keberhasilan sistem dalam mengklasifikasikan tipe transaksi (*income* atau *expense*) serta menerjemahkan masukan bahasa alami pengguna baik ketikan pesan maupun perintah suara menjadi struktur data JSON yang valid dan tepat sasaran sesuai kaidah pembukuan.

Ketiga, pengujian penerimaan pengguna (*User Acceptance Testing*/UAT) pada fitur analitik prediktif (*AI Insight*). Mengingat sistem ini dikembangkan secara spesifik sebagai solusi *custom-built* untuk UMKM Kopi Menceng, pengujian tidak dilakukan menggunakan instrumen kuesioner massal, melainkan melalui wawancara mendalam (*In-Depth Interview*) dan pengujian skenario fungsional secara langsung bersama pemilik usaha. Aspek pengujian difokuskan pada tingkat relevansi, pemahaman konteks bisnis, serta nilai aplikatif (*actionability*) dari rekomendasi pembelian otomatis yang dihasilkan oleh AI. Hal ini bertujuan untuk memvalidasi apakah output rekomendasi yang diberikan oleh sistem sejalan dan dapat diterapkan pada kondisi operasional faktual di lapangan.

**Tabel 3.2 Metrik Pengujian Kecerdasan Buatan (AI)**

| No | Tahap / Modul Pengujian | Metrik Pengujian | Metode Validasi / Alat Ukur | Target Kelayakan (*Threshold*) |
|:---|:---|:---|:---|:---|
| **1** | **Pemrosesan Gambar (Vision AI / OCR)**<br>Ekstraksi struk/nota belanja | Akurasi Ekstraksi Informasi (*Information Extraction Accuracy*) | *Ground Truth Validation* (Pengujian silang hasil tebakan AI vs koreksi manual pengguna). Data diekspor via CSV. | Tingkat keberhasilan ekstraksi minimal **90%** benar. |
| **2** | **Pemrosesan Bahasa Alami (NLP)**<br>Fitur *Chat AI* dan *Voice AI* | 1. *Intent Recognition Accuracy* (Pengenalan Niat/Tipe Transaksi)<br>2. *Entity Extraction Success Rate* (Keberhasilan ekstrak nominal & kategori) | Pengujian fungsional konversi *prompt* bahasa alami ke dalam format struktur data JSON yang valid. | **100%** struktur JSON valid dan tipe *income/expense* terklasifikasi tepat sasaran. |
| **3** | **Analitik Prediktif (*AI Insight*)**<br>Saran rekomendasi keuangan | 1. Tingkat Relevansi<br>2. Pemahaman Konteks Bisnis<br>3. Nilai Aplikatif (*Actionability*) | *User Acceptance Testing* (UAT) melalui *In-Depth Interview* dengan pihak penguji. | Kepuasan subjektif (*User Acceptance*) bernilai positif berdasarkan skenario pengujian. |

<br>

**Tabel 3.3 Pengujian Komparatif Efisiensi Ekonomis**

| No | Aspek yang Diuji | Metode Konvensional (Tanpa Sistem) | Pendekatan Sistem AI (*Camelio*) | Indikator Keberhasilan / Efisiensi |
|:---|:---|:---|:---|:---|
| **1** | **Durasi Input Data** | Menginput data transaksi harian (pemasukan & pengeluaran) secara manual satu per satu ke buku/Excel. | Menggunakan foto struk (OCR) atau pesan suara (*Voice AI*) untuk mencatat banyak transaksi secara bersamaan. | Penurunan waktu rata-rata (dalam satuan menit) untuk mencatat transaksi harian. |
| **2** | **Analisis Pengeluaran Bulanan** | Merekap ulang seluruh nota secara manual pada akhir bulan untuk mengetahui total pengeluaran per kategori. | Sistem merangkum otomatis dan menyajikan portofolio grafis (*Dashboard Insight*) secara *real-time*. | Hilangnya waktu rekapitulasi manual di akhir bulan; visibilitas data *real-time*. |
| **3** | **Keputusan Pembelian Bahan Baku** | Mengandalkan ingatan atau tebakan terhadap fluktuasi harga bahan baku di berbagai toko (tanpa data empiris). | *AI Advisor* memberikan peringatan dini anomali harga dan rekomendasi toko yang lebih ekonomis berdasarkan *historical data* struk. | Pemilik usaha dapat memilih opsi belanja yang lebih murah berdasarkan notifikasi saran AI (Penghematan *Budget*). |

**Siklus Iteratif dan Pembaruan Versi (*Versioning*)**

Siklus evaluasi (termasuk UAT pada tanggal 10 Juni 2026 bersama UMKM Kopi Menceng) pada penelitian ini dilakukan secara berkesinambungan. Perbaikan dari setiap temuan evaluasi diintegrasikan ke dalam rilis *build* aplikasi secara bertahap. Hal ini tercermin dari peningkatan versi aplikasi hingga rilis pembaruan v1.0.6+1. Angka rilis ini menjadi bukti nyata (artefak historis) dari terjadinya siklus desain, pengembangan, dan evaluasi yang berulang (iteratif) sesuai dengan kaidah metodologi *Design Science Research*.

### 3.1.6 Komunikasi (*Communication*)

Fase terakhir dari metodologi DSR adalah tahapan komunikasi yang bertujuan untuk menyosialisasikan artefak dan hasil penelitian kepada para pemangku kepentingan (*stakeholders*) yang terkait. Pada tahap ini, luaran (*output*) difokuskan pada:

1.  **Penyusunan Dokumen Implementasi:** Merangkum seluruh aspek teknis dan operasional ke dalam satu dokumen laporan penelitian untuk kebutuhan akademis.
2.  **Pembuatan Panduan Pengguna (*User Manual*):** Menyediakan dokumentasi instruksional yang jelas untuk membantu pemilik UMKM dalam mengoperasikan fitur-fitur kompleks aplikasi seperti *Scan* Struk dan Sinkronisasi Gmail.
3.  **Sosialisasi dan Penyerahan Sistem:** Merilis produk jadi (versi rilis final) kepada UMKM Kopi Menceng secara penuh agar sistem dapat diimplementasikan untuk mendukung pencatatan transaksi harian usaha mereka di masa mendatang.

<br>

**Tabel 3.4 Jadwal Pelaksanaan Penelitian (*Design Science Research*)**

| No | Tahapan Pelaksanaan (DSR) | Aktivitas Utama | April 2026 | Mei 2026 | Juni 2026 | Juli 2026 |
|:---:|:---|:---|:---:|:---:|:---:|:---:|
| **1** | **Identifikasi Masalah & Motivasi** | Studi literatur dan perumusan masalah awal terkait pencatatan keuangan UMKM. | ✓ | | | |
| **2** | **Penentuan Tujuan Solusi** | Penentuan spesifikasi aplikasi, arsitektur *Flutter* & *Firebase*, pemilihan model *Gemini AI*. | ✓ | | | |
| **3** | **Perancangan & Pengembangan** | Pembuatan UI/UX, *coding*, integrasi AI (Versi aplikasi v1.0.0 hingga rilis pembaruan v1.0.6+1). | ✓ | ✓ | ✓ | |
| **4** | **Demonstrasi** | Implementasi awal (*Alpha/Beta Release*) aplikasi ke perangkat *smartphone*. | | ✓ | ✓ | |
| **5** | **Evaluasi** | Observasi, *User Acceptance Testing* (UAT), dan wawancara evaluasi dengan UMKM Kopi Menceng (10 Juni 2026). | | | ✓ | |
| **6** | **Komunikasi** | Penyusunan dokumen implementasi, pembuatan panduan pengguna, dan sosialisasi perilisan aplikasi ke pihak UMKM. | | | | ✓ |

<br>

## 3.2 Tahapan Pelaksanaan *Project*

Pelaksanaan *project* dilakukan secara bertahap agar pengembangan sistem dapat berjalan secara sistematis dan terukur.

### 3.2.1 Analisis Kebutuhan

Tahap awal dilakukan dengan mengumpulkan kebutuhan sistem berdasarkan kondisi nyata yang terjadi pada Kopi Menceng. Aktivitas yang dilakukan meliputi:

1. **Observasi Proses Bisnis:** Peneliti mengamati secara langsung kegiatan operasional harian yang terjadi di UMKM Kopi Menceng, mulai dari proses pembelian bahan baku, pencatatan transaksi harian, hingga rekapitulasi keuangan di akhir bulan yang selama ini masih dilakukan secara manual menggunakan buku catatan fisik dan Microsoft Excel.
2. **Wawancara dengan Pemilik Usaha:** Wawancara mendalam (*in-depth interview*) dilakukan dengan pemilik UMKM untuk menggali kendala utama yang sering dialami, seperti kesulitan melacak aliran kas, waktu yang tersita untuk pembukuan manual, hingga kesulitan menganalisis tren pengeluaran bulanan.
3. **Analisis Kebutuhan Pengguna:** Berdasarkan hasil observasi dan wawancara, didefinisikan kebutuhan fungsional dari sisi pengguna. Pengguna membutuhkan sebuah aplikasi pencatatan keuangan yang sangat praktis, mendukung otomatisasi ekstraksi data dari foto struk (OCR), *input* transaksi melalui perintah suara (*Speech-to-Text*), dan interaksi berbasis *chat* yang didukung oleh Kecerdasan Buatan (AI).
4. **Analisis Kebutuhan Sistem:** Merumuskan spesifikasi teknis yang dibutuhkan sistem. Sistem harus dibangun menggunakan *framework Flutter* agar dapat diakses melalui perangkat *mobile* (Android/iOS), memanfaatkan basis data *Firebase Firestore* untuk sinkronisasi *real-time* berbasis *cloud*, dan mengintegrasikan model bahasa besar (LLM) *Gemini AI* untuk pemrosesan *Natural Language Processing* (NLP) dan *Vision*.

### 3.2.2 Perancangan Sistem

Tahap ini bertujuan menghasilkan rancangan sistem yang akan menjadi acuan implementasi. Aktivitas yang dilakukan meliputi:

1. **Perancangan Arsitektur Sistem:** Merancang arsitektur perangkat lunak yang menggambarkan interaksi antara komponen sisi klien (aplikasi *mobile Flutter*) dengan layanan *backend* (otentikasi dan *cloud database Firebase*), serta bagaimana alur pemanggilan API *Gemini AI* terjadi secara efisien dan aman.
2. **Perancangan UML (*Unified Modeling Language*):** Membuat pemodelan sistem menggunakan *Use Case Diagram* untuk menggambarkan interaksi aktor (pengguna) dengan fungsionalitas sistem, dan *Activity Diagram* untuk memetakan alur kerja fitur utama seperti *Scan* Struk, *Input* Suara, dan fitur *Budget*.
3. **Perancangan Basis Data Firestore:** Merancang skema *database* NoSQL berbasis dokumen (*Document-Oriented*). Struktur koleksi dan dokumen didesain untuk menyimpan data pengguna, riwayat transaksi, portofolio, serta notifikasi secara terstruktur.
4. **Perancangan Antarmuka Aplikasi (UI/UX):** Merancang *wireframe* dan desain prototipe *User Interface* (UI) yang intuitif, modern, dan *user-friendly*. Desain antarmuka difokuskan pada aksesibilitas fitur utama, penyajian grafik portofolio yang interaktif, serta tata letak menu yang *clean*.
5. **Perancangan Alur Integrasi AI:** Merancang logika *prompt engineering* (rekayasa *prompt*) pada *system instruction Gemini AI*. Alur ini memastikan AI dapat secara akurat mengekstraksi nominal uang, kategori, dan deskripsi barang dari *input* teks tidak terstruktur, transkripsi suara, maupun teks gambar struk.

### 3.2.3 Implementasi Sistem

Tahap implementasi dilakukan dengan menerjemahkan rancangan menjadi aplikasi yang dapat dijalankan. Aktivitas yang dilakukan meliputi:

1. **Pengembangan *Front-End* dengan *Flutter*:** Menulis kode program menggunakan bahasa *Dart* dan *framework Flutter* untuk merealisasikan desain UI/UX ke dalam bentuk antarmuka aplikasi interaktif yang responsif pada perangkat pintar (*smartphone*).
2. **Pengembangan *Back-End*, Penyimpanan *Cloud*, dan Integrasi API:** Mengintegrasikan *Firebase Authentication* untuk otentikasi pengguna, *Cloud Firestore* untuk penyimpanan basis data transaksi secara *real-time*, *Cloudinary* sebagai layanan *cloud storage* untuk manajemen dan optimasi *file* gambar, menghubungkan *Google Gmail API* untuk otomatisasi sinkronisasi bukti transaksi elektronik (*e-receipt*), serta melakukan koneksi *API RESTful* ke *Google Gemini AI* (*SDK*) untuk mengeksekusi fitur kecerdasan buatan.
3. **Implementasi Fitur Cerdas (AI & OCR):** Membangun modul khusus untuk mengambil gambar struk fisik (*Image Picker*) yang diunggah secara sementara ke *Cloudinary* untuk kompresi sebelum diekstraksi datanya oleh *Gemini Vision*, mengimplementasikan fitur perekaman suara (*Speech-to-Text*) agar pengguna dapat meng-*input* transaksi lisan, serta merancang fitur *AI Insight* untuk menyajikan nasihat dan rekomendasi keuangan prediktif berdasarkan riwayat kas pengguna.
4. **Implementasi Fitur Pendukung:** Membuat logika fungsional untuk manajemen dompet digital (*E-Wallet*), sistem *Budgeting* untuk pengaturan target keuangan, pembuatan *chart* grafik portofolio visual, serta mengaktifkan notifikasi lokal untuk memberikan *update* kepada pengguna.
5. **Pengujian Internal (*Alpha Testing*):** Melakukan pengujian teknis (*debugging*) di lingkungan *developer* untuk meminimalisasi *error* atau kecacatan (*bug*), memastikan akurasi ekstraksi nilai *currency*, kelancaran navigasi, serta keandalan integrasi *prompt* AI terhadap berbagai skenario *input* pengguna.

### 3.2.4 Pengujian Sistem

Setelah implementasi selesai, dilakukan pengujian untuk memastikan seluruh fungsi berjalan sesuai kebutuhan. Rangkuman metode pengujian yang diterapkan dapat dilihat pada Tabel 3.5 berikut:

**Tabel 3.5 Rangkuman Metode Pengujian Sistem**

| No | Jenis Pengujian | Target / Fitur yang Diuji | Metode Pengujian | Hasil Pengujian |
|:---|:---|:---|:---|:---|
| **1** | **Ground Truth AI** | Akurasi nilai nominal hasil pindai struk (*Gemini Vision*) | Komparasi eksak "Harga Asli" vs "Sistem" menggunakan log CSV | Akurasi **100%** |
| **2** | **Gemini Vision** | Konsistensi struktur data dari konversi gambar struk | Validasi parameter JSON murni & klasifikasi kategori (*expense/income*) | *Success Rate* **100%** |
| **3** | **NLP (Gemini Text)** | Pemrosesan bahasa alami (*Natural Language*) dari input Teks/Suara | *Prompt testing* (menggunakan variasi input bahasa gaul, desimal, & *multi-item*) | *Success Rate* **100%** |
| **4** | **UAT (User Acceptance)** | Kepuasan fungsionalitas, performa, serta estetika aplikasi | Wawancara mendalam (*In-Depth Interview*) & skenario fungsional langsung | Penerimaan **100%** |

Untuk menunjang jalannya pengujian pada Tabel 3.5 di atas, telah disiapkan himpunan data uji (*dataset*) beserta skenario pengujian spesifik untuk setiap fitur. Rincian kebutuhan data uji dapat dilihat pada Tabel 3.6 dan pemetaan skenarionya pada Tabel 3.7 berikut:

**Tabel 3.6 Data Kebutuhan/Dataset Pengujian**

| Sumber Data / Entitas Uji | Jumlah / Volume | Fokus Pengujian |
|:---|:---|:---|
| **Struk Belanja Fisik** | > 50 lembar | Menguji akurasi ekstraksi nominal dan rincian item oleh *Gemini Vision* (*OCR*). |
| ***Voice Input* (Pesan Suara)** | 30 sampel audio | Menguji keandalan modul *Speech-to-Text* dan *Intent Recognition* (NLP). |
| ***Chat AI* (Teks Natural)** | 30 skenario *prompt* | Menguji keluwesan *Entity Extraction* (*NLP*) terhadap bahasa kasual/sehari-hari. |
| **Sinkronisasi *e-Receipt* Gmail** | 20 surel transaksi | Memvalidasi otomatisasi penarikan data transaksi (tagihan digital) dari kotak masuk. |
| **Responden UAT** | Pemilik & Staf UMKM | Wawancara mendalam (*In-Depth Interview*) mengevaluasi *AI Insight* dan fungsionalitas. |

**Tabel 3.7 Skenario Pengujian Fitur Utama**

| Fitur yang Diuji | Parameter Input | Output yang Diharapkan |
|:---|:---|:---|
| **Pindai Struk (*OCR/Vision*)** | Mengunggah gambar/foto struk fisik menggunakan kamera. | Sistem mengekstrak struktur *JSON* dan memunculkan rincian data transaksi di layar. |
| **Input Suara (*Voice AI*)** | Mengucapkan instruksi keuangan via mikrofon. | Sistem mentranskripsikan ucapan dan menghasilkan *JSON* transaksi yang valid. |
| **Chat AI (*NLP*)** | Mengetik pertanyaan atau pencatatan pada antarmuka *chat*. | AI merespons dengan pencatatan transaksi yang tepat atau memberikan jawaban relevan. |
| **Analitik *AI Insight*** | Agregasi riwayat kas (hingga ratusan transaksi). | Dasbor berhasil memunculkan ringkasan saran (*insight*) berdasarkan data pengeluaran. |
| **Export Laporan PDF** | Klik tombol ekspor pada antarmuka portofolio. | Dokumen PDF (*chart* & ringkasan kas) berhasil di-*-generate* dan siap dibagikan. |

Adapun penjabaran secara terperinci dari setiap tahapan metode pengujian tersebut dijabarkan lebih lanjut sebagai berikut:

**1. Pengujian Ekstraksi Informasi dari Gambar Struk (*Ground Truth Validation*)**
Bagian ini menguji kinerja *OCR* pada *input* gambar struk menggunakan model *Gemini 1.5 Flash*.
*   **Tujuan:** Mengukur tingkat akurasi model *AI* dalam mengekstrak entitas data dari gambar fisik struk menjadi format terstruktur (*JSON* murni).
*   **Skenario:** Pengujian pemindaian struk belanja operasional dari penyedia bahan baku (minimarket/grosir).
*   **Langkah:** Pengguna menekan tombol FAB (Tambah Transaksi) -> Memilih opsi "Scan Struk" -> Mengambil foto struk fisik menggunakan kamera (*ImagePicker*) -> Aplikasi mengirim `imageBytes` ke *method* `classifyReceiptFromImage` pada `GeminiAIService` -> Sistem melakukan konversi (*OCR*) dan menampilkan konfirmasi data.
*   ***Input*:** *File* gambar struk dan nota belanja acak/umum dari luar aktivitas operasional UMKM.
*   ***Output*:** Respons JSON dari API *Gemini* yang memuat *key* `storeName`, `category`, `type` (*expense*), dan *array* `items` (memuat `name`, `price_unit`, `qty`, dan `line_total`).
*   **Hasil:** (Contoh Data: Dari sampel 50 lebih fisik struk, *AI* berhasil menghasilkan JSON valid dengan nilai total yang cocok secara eksak dengan harga asli/*Ground Truth* pada 50 struk lebih, menghasilkan persentase akurasi 100%. Untuk saat ini kegagalan 0 pada struk dan kegagalan tersebut biasa disebabkan oleh kondisi kertas yang pudar).
*   **Status:** *Valid* / Berhasil.

**2. Pengujian Kemampuan *Natural Language Processing* (NLP) pada *Gemini AI***
Bagian ini menguji fitur *Chat AI* dan *Voice AI* (*Speech-to-Text*) dalam mengenali dan mengekstrak entitas dari perintah bahasa alami pengguna.
*   **Tujuan:** Mengukur tingkat keberhasilan *Intent Recognition* (klasifikasi pemasukan/pengeluaran) dan *Entity Extraction* (penerjemahan nominal tidak baku menjadi *integer*) dari *input* bahasa alami pengguna.
*   **Skenario:** Pemberian instruksi pencatatan transaksi menggunakan bahasa sehari-hari.
*   **Langkah:** Pengguna menekan tombol FAB -> Memilih "Voice AI" atau "Chat AI" -> Mengucapkan/mengetik kalimat -> Modul *Speech-to-Text* menerjemahkan suara ke teks (jika *voice*) -> Teks dikirim ke *method* `classifyTransaction` pada `GeminiAIService` -> Sistem memproses dan menyimpan data.
*   ***Input*:** *String* teks tidak baku. Contoh: "Barusan beli es batu sama token listrik habis 150 rebu".
*   ***Output*:** Respons JSON `{ "description": "Beli es batu dan token listrik", "amount": 150000, "category": "Tagihan", "type": "expense" }`.
*   **Hasil:** Sistem berhasil melakukan *Intent Recognition* (menandai *type* sebagai `expense`) dan *Entity Extraction* (menerjemahkan bahasa slang "150 rebu" menjadi angka *integer* baku `150000` sesuai instruksi *Prompt Engineering*).
*   **Status:** *Valid* / Berhasil.

**3. Pengujian Penerimaan Pengguna melalui *User Acceptance Test* (UAT)**
Bagian ini memvalidasi fungsionalitas analitik prediktif dan *AI Insight* secara kualitatif bersama pihak pengguna akhir (UMKM).
*   **Tujuan:** Memvalidasi tingkat relevansi, pemahaman konteks bisnis, dan nilai aksi (*actionability*) dari fitur rekomendasi pembelian dan peringatan dini AI terhadap operasional bisnis UMKM.
*   **Skenario:** Pengguna meminta nasihat keuangan bulanan (*Financial Advice*) untuk mendapatkan *insight* bisnis.
*   **Langkah:** Pengguna membuka menu *AI Insight* -> Aplikasi mengeksekusi *method* `askForFinancialInsight` pada `AIInsightProvider` -> *Provider* menarik agregasi data `totalBalance` dan `monthlyBudget` dari *Firestore* -> Mengirim *Context Injection* ke Gemini AI -> Sistem menampilkan paragraf rekomendasi bisnis.
*   ***Input*:** Penyisipan data dinamis (konteks) berupa total pengeluaran aktual bulan ini (misal: Rp 5.000.000) dan *budget* maksimal.
*   ***Output*:** Teks bahasa alami berupa saran efisiensi keuangan dan peringatan terhadap kategori pengeluaran terboros (misal: "Bahan Baku").
*   **Hasil:** Berdasarkan hasil wawancara (*In-Depth Interview*), pemilik UMKM memvalidasi bahwa rekomendasi dari fitur *AI Insight* sangat sesuai dengan kondisi operasional di lapangan. Walaupun pemilihan kata AI terkadang masih terasa kaku, inti saran sangat mudah dipahami dan aplikatif untuk menjaga arus kas tetap aman.
*   **Status:** Diterima / *Valid*.

### 3.2.5 Implementasi pada Mitra

Tahap ini dilakukan dengan menerapkan sistem secara langsung pada lingkungan operasional Kopi Menceng. Kegiatan meliputi:

*   **Instalasi aplikasi:** Melakukan *deployment* dan instalasi aplikasi *Camelio Finance* pada perangkat *smartphone* Android/iOS milik pengelola UMKM.
*   **Migrasi data awal:** Membantu memasukkan data transaksi historis secara manual maupun sinkronisasi via Gmail untuk membangun *baseline* riwayat keuangan awal di dalam aplikasi.
*   **Pelatihan pengguna:** Memberikan edukasi dan simulasi terkait cara memanfaatkan fitur-fitur berbasis AI (seperti Pemindai Struk, *Voice AI*, dan fitur *Chat*) agar pengguna dapat melakukan pencatatan secara mandiri.
*   **Pendampingan penggunaan sistem:** Melakukan pemantauan secara berkala di awal masa penerapan (*on-boarding*) untuk memastikan pengguna dapat mengadopsi sistem ke dalam rutinitas kegiatan operasional harian mereka tanpa hambatan teknis.

### 3.2.6 Evaluasi dan Penyempurnaan

Tahap akhir dilakukan berdasarkan hasil implementasi dan umpan balik (*feedback*) dari pengguna di lapangan. Aktivitas meliputi identifikasi kekurangan sistem, perbaikan kecacatan kode (*bug*), optimasi performa, dan penyempurnaan antarmuka UI/UX. 

Berdasarkan hasil evaluasi tersebut, sistem telah mengalami beberapa fase penyempurnaan (*iterative improvement*) yang tercatat secara historis ke dalam riwayat versi aplikasi (*Version History*), di antaranya:

*   **Versi 1.0.0 (Rilis Awal):** Peluncuran versi perdana aplikasi *Camelio Finance* dengan fitur inti berupa pelacakan pengeluaran dan pemasukan, serta sistem otentikasi pengguna terintegrasi (Google & Email).
*   **Versi 1.0.1:** Integrasi awal kecerdasan buatan untuk fitur pemindaian struk (*OCR*), penambahan dasbor ikhtisar portofolio interaktif beserta grafik dasarnya, perbaikan keandalan modul unggah foto profil, dan penghalusan transisi pada antarmuka *dark mode*.
*   **Versi 1.0.2:** Penambahan fitur visualisasi Grafik Lingkaran (*Pie Chart*) untuk distribusi pengeluaran, penyempurnaan antarmuka *drawer* modern bergaya kotak, sinkronisasi izin akses perangkat secara *real-time*, serta standarisasi efek animasi navigasi.
*   **Versi 1.0.3:** Perbaikan kelancaran alur otentikasi (terutama siklus sesi *Logout*), penstabilan kontras visual pada *Splash Screen*, serta peningkatan akurasi kecerdasan buatan dalam mendeteksi dan mengkategorikan transaksi bahasa lokal.
*   **Versi 1.0.4:** Pengimplementasian fitur sinkronisasi *e-receipt* via *Gmail API* secara otomatis, integrasi sistem pemfilteran transaksi pada halaman Detail Dompet (*E-Wallet*), serta penyatuan layanan Google Sign-In agar terhindar dari *crash* saat peralihan sesi.
*   **Versi 1.0.5:** Pengaktifan fitur Notifikasi Sistem (*Tray*) lokal untuk pemberitahuan sinkronisasi, penambahan deteksi tipe dompet otomatis berdasarkan nama, dan integrasi fitur ekspor dokumen PDF langsung ke media sosial pihak ketiga (*share-intent*).
*   **Versi 1.0.6:** Peningkatan kecerdasan *Chat AI* dengan kemampuan penjumlahan otomatis beberapa nominal (*multi-item*), pemutakhiran *parser* lokal untuk mengenali angka desimal (misal: 1.5jt), penerapan filter kategori berbasis *regex* yang ketat (*strict word boundaries*) untuk mencegah salah pencocokan kata pendek, serta pembersihan tombol notifikasi uji coba.
*   **Versi 1.0.6+1 (Rilis Terbaru):** Sinkronisasi Mode Akun (Pribadi/Bisnis) secara *real-time* ke *Firestore*, penambahan opsi *dropdown* tipe akun saat registrasi, sentralisasi pengaturan akun ke dalam menu Edit Profil, pengubahan konteks *prompt* AI menjadi lingkup "Bisnis" secara umum, serta perbaikan *flow* pemicu pemuatan ulang rekomendasi (*AI Insight*) secara otomatis setiap ada transaksi baru.

### 3.5 Target Luaran Berdampak

Penerapan metodologi dan rancangan sistem pada penelitian ini ditujukan untuk menghasilkan keluaran (*output*) yang terukur serta memberikan dampak (*outcome*) yang berkesinambungan bagi pihak mitra.

#### 3.5.1 Target Luaran Project

Luaran (artefak) yang dihasilkan dari keseluruhan rangkaian *project* ini meliputi:

1. **Aplikasi Mobile *Camelio Finance*:** Sebuah aplikasi berbasis Android dan iOS yang siap digunakan oleh pemilik UMKM (seperti Kopi Menceng) untuk mengelola dan merekapitulasi seluruh transaksi pengeluaran serta pemasukan secara digital dan *real-time*.
2. **Sistem Ekstraksi Otomatis (OCR) dengan Tingkat Keberhasilan 100%:** Sistem *Optical Character Recognition* berbasis *Google Gemini Vision AI* yang terbukti tangguh dalam mengekstrak entitas informasi transaksi (nama toko, item belanja, harga, dan total) dari gambar struk fisik. Berdasarkan pengujian pada 50 lebih sampel fisik struk/nota, sistem mencapai tingkat keberhasilan ekstraksi 100% dan angka kegagalan 0% selama struk dalam kondisi terbaca (tidak terlalu pudar).
3. **Analisa Keuangan dan Rekomendasi Pintar (*AI Insight*):** Keberhasilan integrasi kecerdasan buatan (*Generative AI*) yang bertindak layaknya asisten keuangan (*Financial Advisor*). Fitur ini mampu menganalisis pola arus kas harian/bulanan UMKM secara dinamis, mengidentifikasi kebocoran anggaran, serta menghasilkan rekomendasi langkah penghematan strategis yang dapat langsung dieksekusi oleh pemilik usaha.
4. **Dasbor Visualisasi Portofolio Interaktif:** Halaman *dashboard* terintegrasi berbasis grafik (seperti *Pie Chart* dan *Line Chart*) yang secara visual membantu pengguna untuk memahami kesehatan kondisi keuangan dan komposisi pengeluaran usaha dalam sekilas.
5. **Infrastruktur *Back-End* Terpusat:** Sistem otentikasi yang aman menggunakan *Firebase Authentication* (Email dan Google Sign-In), serta manajemen basis data *NoSQL* tersinkronisasi (*Cloud Firestore*) yang menjamin data UMKM tidak akan hilang meski perangkat berganti.
6. **Sistem Konfigurasi Dinamis (Firebase Remote Config):** Infrastruktur berbasis *cloud* yang memungkinkan pengembang untuk memperbarui parameter sistem (seperti batas *budget* *default* atau kunci *API*) secara *Over-The-Air* (OTA) tanpa memaksa pengguna mengunduh pembaruan aplikasi.
7. **Dokumentasi Ilmiah dan Teknis:** Dokumen laporan proyek (*capstone*), buku panduan pengguna (*user manual*), beserta kode sumber (artefak teknis) yang tersusun rapi untuk keberlanjutan riset ke depannya.

#### 3.5.2 Dampak bagi Mitra

Implementasi sistem aplikasi cerdas *Camelio Finance* ini diharapkan dapat memberikan dampak transformasi yang positif bagi Kopi Menceng, di antaranya:

1. **Peningkatan Efisiensi Waktu dan Tenaga:** Mengotomatisasi proses input data yang repetitif melalui pindai struk dan perintah suara, sehingga operasional pencatatan jauh lebih cepat dibanding penulisan di buku besar.
2. **Penekanan Risiko Kesalahan Manusia (*Human Error*):** Mengeliminasi risiko salah perhitungan matematis atau ketidaksengajaan yang sangat sering terjadi pada proses pencatatan konvensional/manual.
3. **Kemudahan Akses dan Pelacakan Histori:** Mempermudah pengelolaan pencarian arsip riwayat transaksi secara terstruktur berdasarkan filter tanggal, kategori, maupun jenis dompet.
4. **Pengambilan Keputusan Berbasis Data (*Data-Driven*):** Meningkatkan kualitas dan rasionalitas pemilik UMKM dalam mengambil keputusan bisnis berkat adanya analisis data finansial yang akurat dan obyektif.
5. **Optimasi Alokasi Dana:** Membantu mengidentifikasi secara instan area atau pola pengeluaran operasional yang boros (tidak efisien).
6. **Rekomendasi Tindakan Korektif:** Memberikan landasan rekomendasi ekonomi dari *AI Insight* untuk menekan biaya operasional di bulan berikutnya, misalnya peringatan dini sebelum batas *budget* bahan baku tercapai.
7. **Jaminan Keamanan Aset Informasi:** Meningkatkan keamanan dan privasi data keuangan UMKM melalui mekanisme otentikasi biometrik/akun Google dan penyimpanan terenkripsi yang mustahil dilakukan pada catatan kertas.
8. **Digitalisasi UMKM Berkelanjutan:** Menjadi tonggak keberhasilan adopsi dan transformasi teknologi pada skala UMKM, sehingga Kopi Menceng menjadi bisnis yang lebih modern, tahan banting (*resilient*), dan siap berekspansi di era bisnis berbasis data cerdas.

### 3.6 Rencana Berkelanjutan Sistem

Fase keberlanjutan sistem (*sustainability plan*) dirancang untuk memastikan aplikasi tetap dapat beroperasi, relevan, dan terpelihara setelah implementasi penelitian selesai. Aspek keberlanjutan ini diuraikan ke dalam tiga mekanisme operasional utama:

1. **Penunjukan Administrator Sistem:** Hak pengelolaan tertinggi (*master admin*) diserahkan sepenuhnya kepada kasir senior atau pemilik UMKM Kopi Menceng. Pendelegasian kewenangan ini memberikan kontrol penuh kepada mitra atas proses verifikasi pembukuan, validasi pencatatan hasil pemindaian struk, serta evaluasi tren profitabilitas usaha secara mandiri.
2. **Pemeliharaan Aplikasi Dinamis:** Guna mencegah kendala operasional yang mewajibkan instalasi ulang perangkat lunak (*rebuild file* aplikasi) akibat perubahan teknis, sistem memanfaatkan layanan *Firebase Remote Config*. Fitur ini memungkinkan pembaruan parameter pendukung—seperti rotasi antarmuka pemrograman aplikasi (*API key*) atau penyesuaian batasan transaksi harian—dieksekusi secara nirkabel (*over-the-air*). Mekanisme ini menjamin pemeliharaan berkelanjutan tanpa menghentikan aktivitas pengguna.
3. **Mekanisme Pencadangan Data:** Integritas data transaksi diamankan melalui skema replikasi otomasi antarkawasan (*multi-region*) yang terintegrasi pada infrastruktur *Cloud Firestore*, sehingga mampu mempertahankan tingkat ketersediaan tinggi (*high availability*). Sebagai langkah mitigasi tambahan, sistem menyediakan fitur ekstraksi riwayat keuangan secara berkala ke dalam format dokumen PDF atau *Excel* untuk memfasilitasi kebutuhan pengarsipan luring (*offline*) oleh pihak Kopi Menceng.

***

Bab 3 mengenai Metodologi dan Rencana Implementasi ini telah menguraikan kerangka kerja penelitian secara komprehensif. Dimulai dari penjabaran metode pengembangan dan tahapan pelaksanaan *project* yang sistematis, perumusan rencana pengujian teknis, alokasi waktu (*timeline*) pengerjaan yang terstruktur, hingga pemetaan target luaran yang berdampak serta perancangan strategi keberlanjutan sistem. Seluruh elemen metodologi ini berfungsi sebagai cetak biru (*blueprint*) yang memastikan aplikasi *Camelio Finance* dibangun secara terukur, sesuai standar rekayasa perangkat lunak, dan mampu memecahkan permasalahan pencatatan keuangan UMKM secara efektif.

Setelah sistem berhasil dirancang dan diimplementasikan berdasarkan kerangka metodologi tersebut, tahapan krusial selanjutnya adalah melakukan validasi atas kinerja dan fungsionalitas aplikasi secara empiris. Rincian evaluasi performa—yang mencakup pengukuran metrik pengujian teknis kecerdasan buatan (*OCR* dan *NLP*), analisis komparatif efisiensi ekonomis, hingga temuan tingkat penerimaan dari pengguna akhir berdasarkan *User Acceptance Test* bersama Kopi Menceng—akan dipaparkan dan dianalisis secara mendalam pada **BAB IV: Pengujian dan Evaluasi Project**.
