# 🎓 Proposal Skripsi: Camelio Finance

Dokumen ini berisi informasi proposal skripsi terkait proyek **Camelio Finance** (Smart Finance App), yang mencakup Topik, Judul, dan Abstrak dalam Bahasa Indonesia dan Bahasa Inggris.

---

## 📌 Topik Penelitian

### Bahasa Indonesia
**Artificial Intelligence, Optical Character Recognition (OCR), dan Mobile Financial Management System**

### English
**Artificial Intelligence, Optical Character Recognition (OCR), and Mobile Financial Management System**

---

## 🏷️ Judul Penelitian

### Bahasa Indonesia
> **PENGEMBANGAN MULTIMODAL ARTIFICIAL INTELLIGENCE FINANCIAL ASSISTANT DALAM REKOMENDASI PEMBELIAN OTOMATIS PADA UMKM KOPI MENCENG**

### English
> **Development of a Multimodal Artificial Intelligence Financial Assistant for Automated Purchase Recommendations in Kopi Menceng SMEs**

---

## 📝 Abstrak

### Bahasa Indonesia
Perkembangan teknologi Artificial Intelligence (AI) memberikan peluang yang signifikan dalam meningkatkan efektivitas pengelolaan keuangan, khususnya pada sektor Usaha Mikro, Kecil, dan Menengah (UMKM). Namun, sebagian besar pelaku UMKM masih melakukan pencatatan transaksi secara manual atau menggunakan sistem aplikasi keuangan yang hanya berfungsi sebagai alat pencatatan sederhana. Kondisi tersebut menyebabkan proses pengelolaan data keuangan menjadi kurang efisien, rentan terhadap kesalahan pencatatan (human error), serta belum mampu menghasilkan informasi analitis yang dapat mendukung pengambilan keputusan bisnis secara optimal. Permasalahan serupa juga ditemukan pada UMKM Kopi Menceng yang masih mengalami kendala dalam pencatatan transaksi, pengelolaan struk pembelian, serta analisis pola pengeluaran operasional.
Project ini bertujuan mengembangkan sistem analisis keuangan UMKM berbasis Android bernama Camelio Finance dengan mengintegrasikan teknologi Optical Character Recognition (OCR) dan Artificial Intelligence untuk membantu proses pencatatan transaksi serta menghasilkan rekomendasi pembelian yang lebih ekonomis. Sistem dirancang dengan pendekatan Multimodal Artificial Intelligence Financial Assistant untuk mendukung berbagai metode input transaksi, seperti pemindaian gambar struk pembelian, masukan berbasis teks, perintah suara, dan sinkronisasi data transaksi melalui Gmail API. Gambar struk yang diunggah pengguna diproses melalui layanan Cloudinary untuk optimalisasi media sebelum dianalisis menggunakan model Vision AI dari Google Gemini guna mengekstraksi informasi transaksi menjadi data yang terstruktur.
Metode pengembangan yang digunakan mengacu pada pendekatan Design Science Research (DSR) yang berfokus pada perancangan dan pembangunan artefak teknologi sebagai solusi terhadap permasalahan yang dihadapi mitra. Sistem memanfaatkan layanan Firebase yang terdiri atas Firebase Authentication untuk autentikasi pengguna dan Cloud Firestore sebagai basis data real-time dalam pengelolaan transaksi. Data yang tersimpan kemudian disajikan melalui dashboard interaktif dalam bentuk grafik dan ringkasan keuangan yang mudah dipahami.
Hasil pengembangan menunjukkan bahwa integrasi teknologi OCR dan AI mampu mengotomatisasi proses ekstraksi data transaksi, mempercepat pencatatan keuangan, serta meningkatkan akurasi pengelolaan data dibandingkan metode manual. Selain itu, fitur AI Insight yang dikembangkan mampu menganalisis pola pengeluaran, mengidentifikasi tren biaya operasional, dan menghasilkan rekomendasi penghematan yang relevan berdasarkan data historis transaksi. Dengan demikian, sistem yang dikembangkan diharapkan dapat membantu UMKM dalam mengelola keuangan secara lebih terstruktur, efisien, dan berbasis data sehingga mendukung pengambilan keputusan yang lebih tepat dalam upaya meningkatkan efisiensi operasional usaha.

Kata Kunci: Artificial Intelligence, Optical Character Recognition, Design Science Research, Manajemen Keuangan UMKM, Aplikasi Android.


---

### English
The advancement of Artificial Intelligence (AI) technology has provided significant opportunities to improve the effectiveness of financial management, particularly in the Micro, Small, and Medium Enterprises (UMKM) sector. However, most UMKMs still record transactions manually or use financial application systems that only function as simple bookkeeping tools. This condition causes financial data management processes to become less efficient, prone to recording errors (human error), and unable to generate analytical information that can optimally support business decision-making. Similar problems were also found in UMKM Kopi Menceng, which still experiences difficulties in transaction recording, purchase receipt management, and operational expenditure pattern analysis.
This project aims to develop an Android-based UMKM financial analysis system called Camelio Finance by integrating Optical Character Recognition (OCR) and Artificial Intelligence technologies to assist the transaction recording process and generate more economical purchasing recommendations. The system is designed using a Multimodal Artificial Intelligence Financial Assistant approach to support various transaction input methods, such as purchase receipt image scanning, text-based input, voice commands, and transaction data synchronization through the Gmail API. Receipt images uploaded by users are processed through the Cloudinary service for media optimization before being analyzed using Google Gemini's Vision AI model to extract transaction information into structured data.
The development method used refers to the Design Science Research (DSR) approach, which focuses on designing and building technological artifacts as solutions to problems faced by the partner organization. The system utilizes Firebase services, including Firebase Authentication for user authentication and Cloud Firestore as a real-time database for transaction management. The stored data are then presented through an interactive dashboard in the form of graphs and financial summaries that are easy to understand.
The development results indicate that the integration of OCR and AI technologies is capable of automating the transaction data extraction process, accelerating financial recording, and improving data management accuracy compared to manual methods. In addition, the AI Insight feature developed is capable of analyzing spending patterns, identifying operational cost trends, and generating relevant cost-saving recommendations based on historical transaction data. Therefore, the developed system is expected to assist UMKMs in managing their finances in a more structured, efficient, and data-driven manner, thereby supporting more accurate decision-making in efforts to improve business operational efficiency.

Keywords: Artificial Intelligence, Optical Character Recognition, Design Science Research, UMKM Financial Management, Android Application.


---

## 📖 BAB I: Pendahuluan

### 1.1 Latar Belakang

Perkembangan teknologi digital telah mendorong berbagai sektor usaha untuk mengadopsi sistem informasi dalam mendukung aktivitas operasional dan pengambilan keputusan bisnis. Salah satu aspek yang mengalami transformasi signifikan adalah pengelolaan keuangan. Pengelolaan keuangan yang baik menjadi faktor penting dalam menjaga stabilitas usaha, mengendalikan pengeluaran, serta mendukung perencanaan bisnis yang lebih terarah. Bagi pelaku Usaha Mikro, Kecil, dan Menengah (UMKM), kemampuan dalam mengelola data keuangan secara akurat dan berkelanjutan menjadi salah satu faktor yang menentukan keberlangsungan dan daya saing usaha.

Meskipun demikian, banyak UMKM yang masih menghadapi berbagai kendala dalam proses pencatatan dan analisis keuangan. Sebagian besar pelaku usaha masih melakukan pencatatan transaksi secara manual atau menggunakan aplikasi keuangan yang hanya berfungsi sebagai alat pencatatan sederhana. Kondisi tersebut menyebabkan proses pengelolaan data keuangan menjadi kurang efisien, membutuhkan waktu yang relatif lama, serta rentan terhadap kesalahan pencatatan (*human error*). Selain itu, data transaksi yang telah dicatat sering kali belum dimanfaatkan secara optimal untuk menghasilkan informasi yang dapat mendukung pengambilan keputusan bisnis secara objektif dan berbasis data.

Salah satu UMKM yang menghadapi permasalahan tersebut adalah Kopi Menceng, sebuah usaha yang bergerak di bidang *coffeeshop*. Dalam menjalankan operasional sehari-hari, Kopi Menceng melakukan berbagai aktivitas transaksi, seperti pembelian bahan baku, pengadaan perlengkapan operasional, pembayaran kebutuhan pendukung usaha, serta berbagai pengeluaran rutin lainnya. Tingginya frekuensi transaksi menyebabkan proses pencatatan dan pengelolaan data keuangan menjadi semakin kompleks. Nota pembelian yang masih berbentuk fisik umumnya hanya disimpan sebagai arsip tanpa dilakukan digitalisasi dan pengolahan lebih lanjut, sehingga menyulitkan proses pelacakan riwayat transaksi maupun evaluasi pengeluaran usaha.

Selain permasalahan pencatatan transaksi, Kopi Menceng juga menghadapi kendala dalam melakukan analisis terhadap pola pengeluaran yang terjadi. Pemilik usaha belum memiliki sistem yang mampu memberikan rekomendasi terkait pengeluaran maupun wawasan penghematan secara proaktif. Di sisi lain, perkembangan teknologi *Artificial Intelligence* (AI) saat ini, khususnya *Optical Character Recognition* (OCR) dan kecerdasan buatan analitik, membuka peluang besar untuk mengotomatisasi pemrosesan data tersebut.

Berdasarkan permasalahan di atas, diperlukan sebuah solusi yang inovatif dan komprehensif. Oleh karena itu, penelitian ini akan mengembangkan aplikasi **Camelio Finance**. Aplikasi manajemen keuangan ini akan mengintegrasikan OCR, Gemini AI, dan *Gmail API* dalam satu ekosistem berbasis *mobile*. Pendekatan ini diharapkan dapat mengubah paradigma manajemen keuangan dari yang sebelumnya manual menjadi otomatis, serta dapat memberikan rekomendasi pembelian yang lebih ekonomis guna mendukung operasional Kopi Menceng.

### 1.2 Rumusan Masalah
Berdasarkan latar belakang yang telah dipaparkan, maka rumusan masalah dalam penelitian ini adalah:
1. Bagaimana mengimplementasikan *Optical Character Recognition* (OCR) dan *Large Language Model* (LLM) Gemini AI untuk melakukan ekstraksi entitas transaksi secara otomatis dari gambar struk fisik, input teks, input suara, dan email pengguna?
2. Bagaimana merancang dan membangun aplikasi **Camelio Finance** berbasis mobile yang dapat mencatat, mengkategorikan, serta menyajikan analisis keuangan secara otomatis dan interaktif?

### 1.3 Tujuan Penelitian
Tujuan dari penelitian ini adalah sebagai berikut:
1. Mengimplementasikan dan mengevaluasi kinerja OCR dan LLM Gemini AI dalam mengekstrak informasi keuangan (seperti nominal, kategori, deskripsi, dan tanggal) dari berbagai sumber *unstructured data* (struk, teks, suara, dan email).
2. Membangun dan mengembangkan aplikasi **Camelio Finance** sebagai *Mobile Financial Management System* yang efisien, guna mempermudah pengguna personal maupun UMKM dalam memantau kesehatan finansial mereka secara _real-time_.

### 1.4 Manfaat Penelitian
Manfaat yang diharapkan dari penelitian ini adalah:
1. **Bagi Pengguna Personal dan UMKM:** Mengurangi waktu dan beban kognitif dalam mencatat pengeluaran secara manual, serta mendapatkan *insight* atau analisis cerdas mengenai pola pengeluaran melalui bantuan AI.
2. **Bagi Peneliti dan Akademisi:** Memberikan sumbangsih pengetahuan terkait implementasi teknologi *Large Language Model* dan OCR di dalam pengembangan perangkat lunak (khususnya *mobile application* di ranah _financial technology_).
3. **Bagi Pengembang Aplikasi:** Menjadi purwarupa dan acuan pengembangan fitur AI asisten terintegrasi untuk aplikasi manajemen produktivitas atau sistem informasi serupa.

### 1.5 Batasan Masalah
Agar penelitian ini lebih terarah dan tidak menyimpang dari tujuan yang telah ditetapkan, maka batasan masalahnya adalah:
1. Pengembangan aplikasi **Camelio Finance** difokuskan pada antarmuka platform *Mobile* (seperti Android/iOS menggunakan framework Flutter).
2. Fitur *input* otomatis dan ekstraksi transaksi dibatasi melalui empat kanal utama: pemindaian struk fisik dengan kamera (OCR), teks natural/bebas, pesan suara, dan integrasi Gmail API (membaca notifikasi/email tagihan).
3. Ekstraksi *Natural Language Processing* (NLP) dan analisis *insight* keuangan akan sepenuhnya menggunakan layanan eksternal dari **Gemini AI**.
4. Manajemen data aplikasi meliputi teks, relasi, otentikasi pengguna, dan konfigurasi jarak jauh dilakukan menggunakan ekosistem **Firebase** (Firestore, Authentication, Remote Config) untuk mendukung kapabilitas _real-time_, sedangkan penyimpanan berkas media (seperti gambar hasil pemindaian struk) menggunakan layanan **Cloudinary**.
5. Aplikasi ini hanya berfokus pada sisi manajemen/pencatatan/analisis (*tracking*) dan **tidak memuat** fitur *payment gateway*, transfer dana langsung, atau memproses pembayaran tagihan perbankan di dalam aplikasi.
