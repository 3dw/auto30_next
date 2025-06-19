# 🚀 簡單部署指南

## 設置步驟

### 1. 設置 GitHub Secrets
在 GitHub 倉庫設定中，前往 "Secrets and variables" > "Actions"，添加：
- **Name**: `GOOGLE_CLIENT_ID`
- **Value**: 您的 Google OAuth Client ID

### 2. 啟用 GitHub Pages
1. 前往 GitHub 倉庫設定
2. 選擇 "Pages"
3. Source: 選擇 "GitHub Actions"
4. 保存設置

### 3. 推送代碼
```bash
git add .
git commit -m "Add simple GitHub Pages workflow"
git push origin main
```

## 部署結果
成功部署後，您的應用將可在：
`https://[username].github.io/auto30_next/`

## 監控部署
前往 GitHub 倉庫的 "Actions" 頁面查看部署狀態。 