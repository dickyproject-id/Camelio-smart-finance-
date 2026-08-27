const fs = require('fs');
const path = require('path');

const absoluteLogoPath = "file://" + path.resolve('assets/logo_camelio.png');

let markdown = `
<div class="logo-container">
  <img src="${absoluteLogoPath}" width="150" alt="Logo Camelio">
</div>

<div class="center-title">Dokumentasi Teknis Lengkap & API Reference</div>
<div class="center-subtitle">(Dokumentasi Arsitektur Kode Camelio Finance)</div>

<div class="intro-card">
  <p>Halo! Selamat datang di <b>Dokumentasi Source Code Camelio Finance</b>.</p>
  <p>Dokumen ini dirancang khusus untuk memberikan gambaran arsitektur sistem (High-Level) sekaligus bedah kode spesifik (Low-Level) pada keseluruhan project ini.</p>
  <p>Dokumen ini mengekstrak secara otomatis semua file, class, dan fungsi dari dalam <i>source code</i> aplikasi untuk memastikan tidak ada file yang terlewat. Mari kita mulai!</p>
</div>

<h2 class="section-title">🧱 1. Tumpukan Teknologi (Tech Stack) Utama</h2>

- **Framework**: Flutter (Dart)
- **Architecture**: MVVM dengan Provider & GetIt (Service Locator)
- **Backend & Auth**: Firebase Auth, Cloud Firestore
- **Kecerdasan Buatan (AI)**: Google Gemini 1.5 Flash (Vision & LLM)
- **Cloud Storage**: Cloudinary (Image Optimization & Hosting)

<h2 class="section-title">🗄️ 2. Struktur Database (Firestore NoSQL)</h2>

1. **\`users\`**: Profil Pengguna (balance, monthlyBudget, dll)
2. **\`wallets\`**: Data E-Wallet dan Rekening Bank
3. **\`transactions\`**: History Pemasukan/Pengeluaran beserta detail item (OCR AI)
4. **\`notifications\`** & **\`rating\`**: Log peringatan AI Insight dan Feedback User.

<h2 class="section-title">🤖 3. Alur Kerja Integrasi AI (Gemini 1.5)</h2>

- **Scan Struk OCR**: Foto diupload ke Cloudinary -> URL dikirim ke Gemini Vision -> Ekstrak Entity JSON -> Simpan ke Firestore.
- **Input Suara/Teks Pintar**: Prompt Chat dikirim ke Gemini LLM -> Ekstrak nominal dan kategori secara otomatis.
- **AI Financial Advisor**: Sistem fetch data transaksi 30 hari -> Dikirim ke Gemini -> Gemini berperan sebagai Konsultan Bisnis UMKM dan mengembalikan rekomendasi.

<h2 class="section-title">📂 4. Bedah Kode Sumber (API Reference)</h2>

Berikut adalah rincian lengkap dari seluruh file \`.dart\` yang ada di folder \`lib/\`, beserta \`class\` dan \`fungsi\` yang ada di dalamnya:

`;

const libPath = path.join(__dirname, 'lib');

function walkDir(dir) {
    let results = [];
    let list = fs.readdirSync(dir);
    list.forEach(function(file) {
        file = path.join(dir, file);
        let stat = fs.statSync(file);
        if (stat && stat.isDirectory()) { 
            results = results.concat(walkDir(file));
        } else { 
            if (file.endsWith('.dart')) results.push(file);
        }
    });
    return results;
}

const dartFiles = walkDir(libPath);

dartFiles.forEach(filePath => {
    const relativePath = path.relative(__dirname, filePath);
    const content = fs.readFileSync(filePath, 'utf-8');
    const lines = content.split('\n').length;
    
    // Skip empty or extremely small files
    if (lines < 5) return;

    markdown += `### 📄 \`${relativePath}\`\n`;
    markdown += `- **Panjang Baris**: ${lines} lines\n`;
    
    const classRegex = /class\s+([A-Za-z0-9_]+)/g;
    let match;
    let classes = [];
    while ((match = classRegex.exec(content)) !== null) {
        classes.push(match[1]);
    }
    
    if (classes.length > 0) {
        markdown += "- **Class Name**: " + classes.map(c => "<code>" + c + "</code>").join(', ') + "\n";
    }
    
    const methodRegex = /(?:Future<[^>]+>|void|Widget|String|int|bool|List<[^>]+>|Map<[^>]+>)\s+([A-Za-z0-9_]+)\s*\(/g;
    let methods = [];
    let methodMatch;
    while ((methodMatch = methodRegex.exec(content)) !== null) {
        const m = methodMatch[1];
        if (!['if', 'switch', 'catch', 'while', 'for', 'setState', 'print', 'debugPrint'].includes(m)) {
            methods.push(m);
        }
    }
    
    methods = [...new Set(methods)];
    
    if (methods.length > 0) {
        markdown += "- **Method / Fungsi**: " + methods.map(m => "<code>" + m + "()</code>").join(', ') + "\n";
    }
    
    markdown += `\n<hr>\n\n`;
});

fs.writeFileSync('DOKUMENTASI_FINAL.md', markdown);
console.log('DOKUMENTASI_FINAL.md created successfully!');
