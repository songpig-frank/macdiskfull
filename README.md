# MacDiskFull.com Builder

A standalone desktop application for managing the **MacDiskFull.com** affiliate comparison website. Compare Mac disk cleaning software and generate leads for GetDiskSpace and other products.

## 🖥️ System Requirements

- **macOS 12.0 (Monterey)** or later
- Works on both **Intel (x64)** and **Apple Silicon (arm64)** Macs
- *Windows support planned for future release*

## 📦 Download

Two DMG files are generated for maximum compatibility:

| File | For |
|------|-----|
| `MacDiskFull Builder-1.0.0.dmg` | Intel Macs (x64) |
| `MacDiskFull Builder-1.0.0-arm64.dmg` | Apple Silicon Macs (M1/M2/M3) |

## 🚀 Features

- **Comparison Engine**: Side-by-side comparison of Mac disk cleaners
- **Affiliate Ready**: Pre-configured affiliate links and tracking
- **SEO Optimized**: Built-in meta tags, semantic HTML, and fast loading
- **Premium Design**: Dark mode, glassmorphism, modern animations

## 🛠️ Development

### Prerequisites
- Node.js 18+ 
- npm

### Run Development Server
```bash
npm install
npm run dev          # Web dev server at http://localhost:3000
npm run electron:dev # Desktop app with hot reload
```

### Build DMGs
```bash
npm run electron:build  # Builds both Intel and ARM64 DMGs
```

Individual architecture builds:
```bash
npm run electron:build:intel  # Intel only
npm run electron:build:arm    # Apple Silicon only
```

### Build for Windows (Future)
```bash
npm run electron:build:win  # Creates NSIS installer
```

## 📁 Project Structure

```
├── electron/           # Electron main process
├── src/
│   ├── app/           # Next.js pages
│   ├── components/    # React components
│   └── data/          # Product data (edit products.ts)
├── dist/              # Built DMGs output
└── out/               # Static site export
```

## 📝 Editing Content

Edit `src/data/products.ts` to add/modify products in the comparison table.

## 📜 License

Proprietary - MacDiskFull.com
