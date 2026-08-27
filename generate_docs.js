const fs = require('fs');
const path = require('path');

function walkDir(dir, callback) {
    fs.readdirSync(dir).forEach(f => {
        let dirPath = path.join(dir, f);
        let isDirectory = fs.statSync(dirPath).isDirectory();
        isDirectory ? walkDir(dirPath, callback) : callback(path.join(dir, f));
    });
}

let markdown = `# 📖 DOKUMENTASI TEKNIS EKSTRIM (SOURCE CODE & API REFERENCE)\n\n`;
markdown += `Dokumen ini berisi hasil bedah kode secara menyeluruh dari aplikasi **Camelio Finance**. Dokumen ini digenerate secara otomatis dengan memindai setiap baris kode pada folder \`lib/\`.\n\n`;

markdown += `## 1. Rincian Direktori & File\n\n`;

const libPath = path.join(__dirname, 'lib');

walkDir(libPath, function(filePath) {
    if (filePath.endsWith('.dart')) {
        const relativePath = path.relative(__dirname, filePath);
        const content = fs.readFileSync(filePath, 'utf-8');
        const lines = content.split('\n').length;
        
        markdown += `### 📄 \`${relativePath}\`\n`;
        markdown += `- **Jumlah Baris Kode**: ${lines} lines\n`;
        
        // Extract Classes
        const classRegex = /class\s+([A-Za-z0-9_]+)/g;
        let match;
        let classes = [];
        while ((match = classRegex.exec(content)) !== null) {
            classes.push(match[1]);
        }
        
        if (classes.length > 0) {
            markdown += `- **Class yang Dideklarasikan**: \n`;
            classes.forEach(c => {
                markdown += `  - \`${c}\`\n`;
            });
        }
        
        // Extract Methods/Functions (Simplified regex for dart)
        const methodRegex = /(?:Future<[^>]+>|void|Widget|String|int|bool|List<[^>]+>|Map<[^>]+>)\s+([A-Za-z0-9_]+)\s*\(/g;
        let methods = [];
        let methodMatch;
        while ((methodMatch = methodRegex.exec(content)) !== null) {
            const m = methodMatch[1];
            if (!['if', 'switch', 'catch', 'while', 'for'].includes(m)) {
                methods.push(m);
            }
        }
        
        // Deduplicate methods
        methods = [...new Set(methods)];
        
        if (methods.length > 0) {
            markdown += `- **Fungsi / Method Utama**: \n`;
            methods.forEach(m => {
                markdown += `  - \`${m}()\`\n`;
            });
        }
        
        markdown += `\n---\n\n`;
    }
});

fs.writeFileSync('DOKUMENTASI_EKSTRIM.md', markdown);
console.log('DOKUMENTASI_EKSTRIM.md generated successfully!');
