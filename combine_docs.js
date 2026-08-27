const fs = require('fs');

// Read files
let docLengkap = fs.readFileSync('DOKUMENTASI_TEKNIS_LENGKAP.md', 'utf-8');
let docEkstrim = fs.readFileSync('DOKUMENTASI_EKSTRIM.md', 'utf-8');

// Strip the first title from docLengkap
docLengkap = docLengkap.replace(/^# 🛠️ Dokumentasi Teknis Lengkap - Camelio Finance App\n+/, '');

// Strip the first title and intro from docEkstrim
docEkstrim = docEkstrim.replace(/^# 📖 DOKUMENTASI TEKNIS EKSTRIM[\s\S]*?## 1\. Rincian Direktori & File/m, '');

// Create beautiful header with logo
const header = `
<div align="center">
  <img src="assets/logo_camelio.png" width="200" alt="Camelio Logo">
  <h1>DOKUMENTASI TEKNIS & REFERENSI KODE</h1>
  <h2>Camelio Finance App</h2>
</div>

<br>

`;

// Combine them
const finalMarkdown = header + docLengkap + `\n\n---\n\n## 6. Referensi Kode Sumber Lengkap (API Reference)\n\n` + docEkstrim;

fs.writeFileSync('DOKUMENTASI_FINAL.md', finalMarkdown);
console.log('DOKUMENTASI_FINAL.md created successfully!');
