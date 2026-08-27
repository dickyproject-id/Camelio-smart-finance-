# 🗺️ Dokumentasi Arsitektur Sistem, Flowchart, dan UML (Camelio Finance)

Dokumen ini berisi dokumentasi teknis sistem aplikasi **Camelio Finance** (Smart Finance App). Dokumentasi ini dirancang menggunakan format **Mermaid** untuk rendering visual dan dilengkapi dengan penjelasan akademis dalam Bahasa Indonesia untuk kebutuhan penulisan Laporan Skripsi/Tugas Akhir.

---

## 🏗️ 1. Arsitektur Sistem (System Architecture)

Aplikasi Camelio Finance dirancang menggunakan arsitektur **Client-Server** dengan pola pemrosesan data berbasis awan (*Cloud-based processing*). Beban komputasi yang berat (seperti pengenalan pola gambar struk, konversi suara ke transaksi, dan analisis sentimen pengeluaran) dialihkan dari perangkat pengguna (*client-side*) ke penyedia eksternal (*cloud-side*) melalui API (Serverless Architecture).

```mermaid
graph TD
    classDef client fill:#e1f5fe,stroke:#03a9f4,stroke-width:2px;
    classDef cloud fill:#efebe9,stroke:#8d6e63,stroke-width:2px;
    classDef firebase fill:#fff9c4,stroke:#fbc02d,stroke-width:2px;
    classDef ai fill:#ede7f6,stroke:#5e35b1,stroke-width:2px;

    subgraph Client ["Client Side (Mobile Application)"]
        FlutterApp["Flutter Mobile App (Camelio Finance)"]:::client
        SQLite["Local Cache & State Management"]:::client
    end

    subgraph MediaStorage ["Media Storage Service"]
        Cloudinary["Cloudinary API (Upload & Compress Struk)"]:::cloud
    end

    subgraph FirebaseEcosystem ["Firebase Backend-as-a-Service (BaaS)"]
        FirebaseAuth["Firebase Authentication (Sesi Pengguna)"]:::firebase
        Firestore["Cloud Firestore (NoSQL Database)"]:::firebase
        RemoteConfig["Firebase Remote Config (Gemini API Key)"]:::firebase
    end

    subgraph GoogleAPIs ["Google API Ecosystem"]
        GeminiAI["Google Gemini AI API (Gemini 1.5 Flash)"]:::ai
        GmailAPI["Gmail API (OAuth 2.0 Integration)"]:::ai
    end

    %% Connections
    FlutterApp -->|1. Request Auth/Session| FirebaseAuth
    FlutterApp -->|2. Get Gemini API Key| RemoteConfig
    FlutterApp -->|3. Upload Receipt Photo| Cloudinary
    Cloudinary -->|4. Return Compressed Image URL| FlutterApp
    FlutterApp -->|5. Send Image URL / Voice Text / Prompt| GeminiAI
    GeminiAI -->|6. Return Structured JSON| FlutterApp
    FlutterApp -->|7. Authorize & Fetch Emails| GmailAPI
    GmailAPI -->|8. Return Transaction Emails| FlutterApp
    FlutterApp -->|9. Write & Stream Financial Data| Firestore
    Firestore -.->|Real-time Data Update| FlutterApp
```

### Penjelasan Arsitektur:
1.  **Client (Flutter App)**: Bertindak sebagai antarmuka utama pengguna. Aplikasi bertanggung jawab menangkap input (kamera, mic, teks) dan menampilkan visualisasi grafik.
2.  **Firebase Authentication**: Mengelola autentikasi pengguna secara aman untuk memastikan pemisahan data antar pengguna.
3.  **Firebase Remote Config**: Digunakan untuk mengunduh API Key Google Gemini secara dinamis ke aplikasi agar API Key tidak bocor di dalam kode sumber (*hardcoded*).
4.  **Cloudinary (Media Storage)**: Berkas gambar struk diunggah ke Cloudinary terlebih dahulu untuk dikompresi agar ukuran gambar menjadi ringan saat dibaca oleh AI.
5.  **Google Gemini AI API**: Model **Gemini 1.5 Flash** digunakan untuk tiga fungsi utama:
    *   **Vision AI (OCR)**: Membaca teks dari URL gambar struk dan menyusunnya menjadi format JSON.
    *   **NLP & Chat AI**: Memahami percakapan teks bebas atau transkrip suara pengguna dan mengekstrak entitas transaksi.
    *   **Financial Insight Engine**: Menganalisis riwayat transaksi 30 hari terakhir untuk memberikan rekomendasi finansial.
6.  **Gmail API**: Menghubungkan kotak masuk Gmail pengguna menggunakan otorisasi OAuth 2.0 untuk menarik surel bukti pembayaran dari bank/e-wallet lalu memprosesnya melalui Gemini AI.
7.  **Cloud Firestore**: Berfungsi sebagai database NoSQL utama yang menyimpan seluruh data profil, transaksi, rekening, dan preferensi pengguna dengan sinkronisasi *real-time stream*.

---

## 🔄 2. Alur Kerja Sistem (Flowchart)

### A. Alur Kerja Global (Global System Flowchart)
Flowchart ini memetakan jalannya aplikasi secara menyeluruh dari pertama kali aplikasi dibuka hingga semua fitur utama diakses.

```mermaid
flowchart TD
    Start([Mulai]) --> OpenApp[Buka Aplikasi Camelio Finance]
    OpenApp --> CheckAuth{Apakah user sudah login?}
    CheckAuth -- Tidak --> LoginPage[Halaman Login / Register]
    LoginPage --> AuthProcess[Firebase Authentication]
    AuthProcess --> CheckAuth
    CheckAuth -- Ya --> Dashboard[Halaman Dashboard Utama]
    
    Dashboard --> ChooseAction{Pilih Aksi Pengguna}
    
    ChooseAction -->|1. Catat Transaksi| InputMethod{Pilih Metode Input}
    InputMethod -->|A. Scan Struk| ScanStruk[Ambil Foto Struk via Kamera]
    InputMethod -->|B. Input Suara| VoiceInput[Tahan Mic & Bicara]
    InputMethod -->|C. Chat AI| ChatAI[Ketik Kalimat Bebas/Natural]
    InputMethod -->|D. Manual| ManualInput[Isi Form Transaksi Manual]
    
    ChooseAction -->|2. Sinkron Gmail| GmailSync[Sinkronisasi Transaksi via Gmail API]
    ChooseAction -->|3. AI Insight| AIInsight[Buka Halaman Analisis AI Insight]
    ChooseAction -->|4. Export PDF| ExportPDF[Generate Laporan Keuangan PDF]
    ChooseAction -->|5. Keluar| SignOut[Proses Sign Out / Logout]
    
    %% Processing paths
    ScanStruk --> UploadCloudinary[Upload Gambar ke Cloudinary]
    UploadCloudinary --> GetURL[Dapatkan URL Gambar]
    GetURL --> SendGeminiVision[Kirim URL & Prompt ke Gemini Vision AI]
    SendGeminiVision --> ParseVisionJSON[Ekstraksi JSON Transaksi]
    ParseVisionJSON --> PreviewScreen[Tampilkan Preview Transaksi]
    
    VoiceInput --> STT[Speech-to-Text Konversi ke String]
    STT --> SendGeminiLLM
    ChatAI --> SendGeminiLLM[Kirim Teks & Prompt ke Gemini LLM]
    SendGeminiLLM --> ParseLLMJSON[Ekstraksi JSON Transaksi]
    ParseLLMJSON --> SaveToDB
    
    ManualInput --> SubmitForm[Submit Form Manual]
    SubmitForm --> SaveToDB
    
    GmailSync --> CheckOAuth{Cek Token OAuth 2.0}
    CheckOAuth -- Belum/Expired --> OAuthFlow[Proses Otorisasi Google]
    OAuthFlow --> FetchEmails[Tarik Email Transaksi Terbaru]
    CheckOAuth -- Valid --> FetchEmails
    FetchEmails --> EmailToGemini[Kirim Isi Email ke Gemini LLM]
    EmailToGemini --> ParseEmailJSON[Ekstraksi JSON Transaksi]
    ParseEmailJSON --> SaveToDB
    
    AIInsight --> FetchDBData[Tarik Data Transaksi 30 Hari Terakhir]
    FetchDBData --> SendInsightGemini[Kirim Rangkuman ke Gemini LLM]
    SendInsightGemini --> RenderInsight[Tampilkan Rekomendasi/Tips Hemat]
    RenderInsight --> Dashboard
    
    ExportPDF --> ReadTransactions[Ambil Data Transaksi Pengguna]
    ReadTransactions --> CreatePDF[Render & Bagikan File PDF]
    CreatePDF --> Dashboard
    
    PreviewScreen --> UserChoice{Konfirmasi Pengguna}
    UserChoice -->|Hapus Item| PreviewScreen
    UserChoice -->|Simpan| SaveToDB
    
    SaveToDB[(Simpan Data ke Cloud Firestore)] --> UpdateDashboard[Perbarui UI Dashboard & Saldo]
    UpdateDashboard --> Dashboard
    
    SignOut --> LoginPage
```

---

### B. Detil Alur Fitur AI & API

#### 1. Alur Kerja Scan Struk (OCR + Gemini Vision AI)
Alur ini berfokus pada proses konversi struk fisik menjadi data transaksi otomatis menggunakan kamera dan Gemini Vision AI.

```mermaid
flowchart LR
    A[Kamera HP] -->|Potret Struk| B[Upload ke Cloudinary]
    B -->|URL Gambar Kompresi| C[Kirim ke Gemini Vision API]
    C -->|Bandingkan piksel & Prompt| D[Ekstraksi Teks & Deteksi Entitas]
    D -->|Kirim JSON Terstruktur| E[Tampilkan Preview Transaksi]
    E -->|User Hapus Item Salah| F[Simpan ke Firestore]
```

#### 2. Alur Kerja Input Suara & Chat AI (Gemini LLM)
Menjelaskan bagaimana kalimat suara (*Speech*) atau teks bebas diurai menjadi variabel transaksi terstruktur (`amount`, `category`, `title`).

```mermaid
flowchart TD
    A[Input Pengguna] --> B{Jenis Input?}
    B -->|Suara| C[Modul Speech-to-Text]
    C -->|Ubah ke String| D[Kirim String + Prompt ke Gemini LLM]
    B -->|Teks Chat| D
    D --> E[Gemini Mengurai Arti Kalimat]
    E --> F[Deteksi Nominal & Kategori]
    F -->|Output JSON Terstruktur| G[Simpan ke Database Firestore]
```

#### 3. Alur Kerja Sinkronisasi Gmail API
Menjelaskan sinkronisasi email masuk dari penyedia layanan keuangan (Bank/E-Wallet) menggunakan integrasi API.

```mermaid
flowchart TD
    A[Mulai Sinkronisasi] --> B{Apakah ada OAuth Token?}
    B -- Tidak/Expired --> C[Tampilkan Dialog Login Google]
    C --> D[Minta Izin Scope Gmail Readonly]
    D --> E[Simpan Access Token]
    B -- Ya --> F[Tarik Email Masuk Kategori Transaksi]
    E --> F
    F --> G[Ekstrak Teks Isi Email]
    G --> H[Kirim Teks ke Gemini LLM]
    H --> I[Ekstraksi Data Nominal & Merchant]
    I --> J[Simpan Transaksi Baru ke Firestore]
```

#### 4. Alur Kerja AI Insight (Rekomendasi Hemat)
Proses penganalisisan riwayat transaksi untuk menghasilkan tips keuangan kustom.

```mermaid
flowchart LR
    A[Klik Menu AI Insight] --> B[Tarik Data Riwayat 30 Hari Terakhir]
    B --> C[Ubah List Transaksi ke Rangkuman Teks]
    C --> D[Kirim Rangkuman + Prompt ke Gemini LLM]
    D --> E[Gemini Menganalisis Pola & Kebocoran Dana]
    E --> F[Tampilkan Tips & Rekomendasi di Layar]
```

---

## 📊 3. Unified Modeling Language (UML)

### A. Use Case Diagram
Use Case Diagram mendefinisikan batas sistem serta interaksi antara pengguna dengan fungsionalitas yang disediakan oleh aplikasi Camelio Finance secara menyeluruh.

```mermaid
leftToRightDirection
actor User as "Pengguna (Personal / UMKM)"

rectangle SystemBoundaries as "Aplikasi Camelio Finance" {
    %% Core & Profile
    usecase UC_Auth as "Melakukan Login / Register"
    usecase UC_Profil as "Mengelola Profil (Edit Foto & Detail)"
    
    %% Dashboard & Transaksi
    usecase UC_Dashboard as "Melihat Dashboard & Saldo"
    usecase UC_Portofolio as "Melihat Portofolio & Grafik"
    usecase UC_Riwayat as "Melihat Riwayat Transaksi"
    
    %% Input Transaksi
    usecase UC_Catat as "Mencatat Transaksi Baru"
    usecase UC_Scan as "Scan Struk (OCR & Vision AI)"
    usecase UC_Voice as "Input via Suara (Voice to Text)"
    usecase UC_Chat as "Input via Teks Pintar (Chat AI)"
    usecase UC_Manual as "Input Manual"
    
    %% Advanced Features
    usecase UC_Gmail as "Sinkronisasi Transaksi via Gmail API"
    usecase UC_Insight as "Melihat Analitik AI Insight"
    usecase UC_Export as "Export Laporan Transaksi (PDF)"
    usecase UC_Wallet as "Manajemen E-Wallet & Rekening"
    
    %% Settings & Support
    usecase UC_Settings as "Pengaturan Sistem (Tema, Notifikasi, Bahasa)"
    usecase UC_Privacy as "Mengelola Privasi & Izin"
    usecase UC_Support as "Melihat Bantuan, FAQ, & Kebijakan"
    usecase UC_Rating as "Memberikan Rating & Ulasan"
    usecase UC_Signout as "Keluar Aplikasi (Sign Out)"
}

%% Connections (Actor to Use Cases)
User --> UC_Auth
User --> UC_Dashboard
User --> UC_Portofolio
User --> UC_Riwayat
User --> UC_Catat
User --> UC_Gmail
User --> UC_Insight
User --> UC_Export
User --> UC_Wallet
User --> UC_Profil
User --> UC_Settings
User --> UC_Privacy
User --> UC_Support
User --> UC_Rating
User --> UC_Signout

%% Extends
UC_Catat <|-- UC_Scan : <<extends>>
UC_Catat <|-- UC_Voice : <<extends>>
UC_Catat <|-- UC_Chat : <<extends>>
UC_Catat <|-- UC_Manual : <<extends>>
```

---

### B. Activity Diagram (Pencatatan Transaksi via Scan Struk AI)
Menggambarkan alur aktivitas dinamis saat pengguna menggunakan fitur Scan Struk.

```mermaid
stateDiagram-v2
    state "Pengguna" as user
    state "Aplikasi Camelio (Client)" as client
    state "Cloudinary Storage" as cloud
    state "Gemini Vision AI API" as gemini
    state "Firebase Firestore" as db

    [*] --> user : Membuka Kamera
    user --> client : Memotret Struk Belanja
    client --> cloud : Upload Gambar Struk
    cloud --> client : Kembalikan URL Gambar
    client --> gemini : Kirim URL Gambar + Prompt Khusus
    gemini --> client : Kembalikan Hasil Ekstraksi (Structured JSON)
    client --> user : Tampilkan Preview Transaksi di Layar
    
    state user_confirm <<choice>>
    user --> user_confirm : Verifikasi Data Struk
    
    user_confirm --> client : Hapus Item (Jika ada salah ekstraksi)
    client --> user : Perbarui Tampilan Preview
    
    user_confirm --> client : Klik Tombol Simpan
    client --> db : Simpan Data Transaksi (userId, amount, title, date, category, receipt_url)
    db --> client : Konfirmasi Berhasil & Stream Data Terbaru
    client --> user : Perbarui Tampilan Dashboard & Notifikasi Sukses
    user --> [*]
```

---

### C. Class Diagram (Struktur MVVM)
Menunjukkan struktur kelas dalam kode sumber Flutter Camelio Finance yang memisahkan antara UI (*View*), Logika Keadaan (*ViewModel/Provider*), dan Akses Data (*Model/Service*).

```mermaid
classDiagram
    %% Core Locator and Theme
    class AppColors {
        +HexColor primary
        +HexColor secondary
    }
    class Locator {
        +GetIt locator
        +setupLocator()
    }
    
    %% Models
    class TransactionModel {
        +String id
        +String userId
        +double amount
        +String title
        +String category
        +String type
        +DateTime date
        +String receiptUrl
        +toMap() Map
        +fromMap() TransactionModel
    }
    class UserModel {
        +String id
        +String name
        +String email
        +double balance
        +fromMap() UserModel
    }
    class EWalletModel {
        +String id
        +String name
        +double balance
        +String type
    }

    %% Services
    class AuthService {
        -FirebaseAuth _auth
        +login(email, password)
        +register(name, email, password)
        +signOut()
    }
    class FirestoreService {
        -FirebaseFirestore _db
        +addTransaction(TransactionModel t)
        +getTransactionsStream(userId) Stream
        +updateUserBalance(userId, balance)
    }
    class GeminiAiService {
        -GenerativeModel _model
        +extractReceipt(receiptUrl) TransactionModel
        +extractVoiceOrChat(text) Map
        +generateInsight(List transactions) String
    }
    class CloudinaryService {
        +uploadImage(File imageFile) String
    }
    class GmailService {
        +fetchEmails(accessToken) List
    }
    
    %% ViewModels / Providers
    class AuthProvider {
        -AuthService _authService
        -UserModel currentUser
        +login(email, password)
        +register(name, email, password)
    }
    class TransactionProvider {
        -FirestoreService _firestoreService
        -List~TransactionModel~ transactions
        -double totalBalance
        +fetchTransactions()
        +saveTransaction(TransactionModel t)
        +deleteTransaction(id)
    }
    class AiInsightProvider {
        -GeminiAiService _geminiService
        -String latestInsight
        +generateFinancialInsight(List transactions)
    }
    
    %% Views / UI Components
    class SplashPage {
        +checkAuthStatus()
    }
    class LoginPage {
        +onLoginPressed()
    }
    class DashboardPage {
        +buildBalanceCard()
        +buildRecentTransactionsList()
    }
    class TransactionPage {
        +onScanPressed()
        +onVoicePressed()
        +onSavePressed()
    }
    class AiAdvisorPage {
        +buildChatArea()
    }

    %% Relations
    Locator ..> AuthService : Registers
    Locator ..> FirestoreService : Registers
    Locator ..> GeminiAiService : Registers
    Locator ..> CloudinaryService : Registers
    
    AuthProvider --> AuthService : Uses
    AuthProvider --> UserModel : Holds
    
    TransactionProvider --> FirestoreService : Uses
    TransactionProvider --> TransactionModel : Holds List of
    
    AiInsightProvider --> GeminiAiService : Uses
    
    SplashPage ..> AuthProvider : Checks session
    LoginPage --> AuthProvider : Triggers
    DashboardPage --> TransactionProvider : Listens to
    TransactionPage --> TransactionProvider : Triggers action
    TransactionPage --> CloudinaryService : Uses directly
    TransactionPage --> GeminiAiService : Uses directly
    AiAdvisorPage --> AiInsightProvider : Uses
```

---

### D. Sequence Diagram (Proses Input Scan Struk)
Sequence Diagram ini memetakan interaksi berurutan dan pesan antar objek sepanjang jalannya fitur Scan Struk, dari pemilihan kamera oleh aktor hingga penyimpanan data ke database.

```mermaid
sequenceDiagram
    autonumber
    actor User as Pengguna
    participant View as TransactionPage (UI)
    participant Provider as TransactionProvider (ViewModel)
    participant Cloudinary as CloudinaryService (Service)
    participant Gemini as GeminiAiService (Service)
    participant Firestore as FirestoreService (Service)
    database DB as Cloud Firestore

    User->>View: Buka Kamera & Potret Struk
    View->>Cloudinary: uploadImage(imageFile)
    activate Cloudinary
    Cloudinary-->>View: Kembalikan URL Gambar (receipt_url)
    deactivate Cloudinary

    View->>Gemini: extractReceipt(receipt_url)
    activate Gemini
    Gemini->>Gemini: Kirim URL + Prompt ke Gemini Vision AI API
    Gemini-->>View: Kembalikan structured JSON (amount, title, category, date)
    deactivate Gemini

    View->>User: Tampilkan Preview Transaksi (bisa hapus item salah)
    User->>View: Konfirmasi & Klik Simpan
    View->>Provider: saveTransaction(transactionData)
    activate Provider
    Provider->>Firestore: addTransaction(transaction)
    activate Firestore
    Firestore->>DB: Tulis data dokumen baru
    DB-->>Firestore: Sukses menyimpan data
    Firestore-->>Provider: Sukses
    deactivate Firestore
    
    Provider->>Firestore: updateUserBalance(userId, newBalance)
    activate Firestore
    Firestore->>DB: Update field balance di users/userId
    DB-->>Firestore: Sukses update balance
    Firestore-->>Provider: Sukses
    deactivate Firestore
    
    Provider-->>View: Perbarui State & Selesai
    deactivate Provider
    View-->>User: Tampilkan Notifikasi Sukses & kembali ke Dashboard
```

---

## 🗄️ 4. Skema Database (NoSQL Firestore Schema)

Aplikasi menggunakan database Cloud Firestore dengan arsitektur **Flat Root Collection** untuk mempercepat kueri (*query performance*) dan meminimalisir pembacaan bersarang (*deep nesting operations*). Diagram hubungan entitas (ERD NoSQL) adalah sebagai berikut:

```mermaid
erDiagram
    users {
        string id PK
        number balance
        timestamp birthDate
        timestamp createdAt
        timestamp deactivatedAt
        string email
        string gender
        number monthlyBudget
        string name
        string photoUrl
        string status
        timestamp updatedAt
        string whatsapp
    }
    wallets {
        string id PK
        string accountNumber
        number balance
        timestamp createdAt
        string iconUrl
        timestamp lastSyncDate
        string name
        string type
        string userId FK
    }
    transactions {
        string id PK
        number amount
        string category
        timestamp date
        string description
        string imageUrl
        string source
        string type
        string userId FK
        string walletId FK
        array items
    }
    rating {
        string id PK
        string comment
        timestamp createdAt
        string email
        string name
        number rating
        string userId FK
    }
    notifications {
        string id PK
        timestamp date
        boolean isRead
        string message
        string title
        string type
        string userId FK
    }

    users ||--o{ wallets : "memiliki (userId)"
    users ||--o{ transactions : "melakukan (userId)"
    users ||--o{ rating : "memberikan (userId)"
    users ||--o{ notifications : "menerima (userId)"
    wallets ||--o{ transactions : "digunakan untuk (walletId)"
```

### Rincian Koleksi Firestore:
1.  **`users`**: Menyimpan profil dan preferensi akun pengguna.
2.  **`wallets`**: Koleksi penyimpanan dompet digital atau akun perbankan milik pengguna.
3.  **`transactions`**: Mencatat riwayat transaksi pengeluaran atau pemasukan.
4.  **`rating`**: Menyimpan ulasan atau feedback aplikasi dari pengguna.
5.  **`notifications`**: Menampung log notifikasi sistem yang dikirimkan kepada pengguna.
