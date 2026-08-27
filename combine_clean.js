const fs = require('fs');
const path = require('path');

const docTeknis = fs.readFileSync('DOKUMENTASI_TEKNIS_LENGKAP.md', 'utf-8');
const docKode = fs.readFileSync('DOKUMENTASI_KODE_SUMBER.md', 'utf-8');

// Strip out the first big H1 headers to make it flow seamlessly
const cleanTeknis = docTeknis.replace(/^# 🛠️ Dokumentasi Teknis Lengkap - Camelio Finance App\n+/, '');
const cleanKode = docKode.replace(/^# 📚 Dokumentasi Teknis Kode Sumber \(Source Code\) - Camelio Finance\n+[\s\S]*?---\n+/, ''); // Also remove the intro paragraph of docKode

const absoluteLogoPath = "file://" + path.resolve('assets/logo_camelio.png');

const header = `
<div class="logo-container">
  <img src="${absoluteLogoPath}" width="150" alt="Logo Camelio">
</div>

<div class="center-title">Buku Panduan Teknis & Arsitektur Kode</div>
<div class="center-subtitle">(Dokumentasi Sistem Camelio Finance)</div>
`;

// Merge them
const mergedMarkdown = header + '\n' + cleanTeknis + '\n\n---\n\n' + cleanKode;

fs.writeFileSync('DOKUMENTASI_GABUNGAN.md', mergedMarkdown);
console.log('Successfully created DOKUMENTASI_GABUNGAN.md');
