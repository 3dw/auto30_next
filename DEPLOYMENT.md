# 🚀 快速部署指南

本指南將幫助您快速設置和部署您的 Flutter 應用。

## 📋 前置需求

- GitHub 帳戶
- Flutter SDK 已安裝
- Google OAuth Client ID（用於身份驗證）

## ⚡ 快速開始

### 1. 自動設置（推薦）

運行自動設置腳本：

```bash
./scripts/setup-github-actions.sh
```

這個腳本會：
- 檢查您的 Flutter 版本
- 更新 deploy-pages.yml 配置
- 設置正確的 base href
- 提供簡單的後續步驟

### 2. 手動設置

如果您偏好手動設置，請按照以下步驟：

#### 步驟 1: 設置 GitHub Secrets

1. 前往您的 GitHub 倉庫設定
2. 選擇 "Secrets and variables" > "Actions"
3. 點擊 "New repository secret"
4. 添加以下 secret：
   - **Name**: `GOOGLE_CLIENT_ID`
   - **Value**: 您的 Google OAuth Client ID

#### 步驟 2: 啟用 GitHub Pages

1. 前往您的 GitHub 倉庫設定
2. 選擇 "Pages"
3. Source: 選擇 "GitHub Actions"
4. 保存設置

#### 步驟 3: 推送代碼

```bash
git add .
git commit -m "Setup GitHub Pages workflow"
git push origin main
```

## 🔍 監控部署

### 查看部署狀態

1. 前往您的 GitHub 倉庫
2. 點擊 "Actions" 標籤
3. 查看 workflow 執行狀態

### 部署結果

成功部署後，您的應用將可在以下位置訪問：

- **Web 版本**: `https://[username].github.io/auto30_next/`

## 🛠️ Workflow 說明

### Deploy Pages Workflow (`deploy-pages.yml`)
- 觸發：每次推送、PR 或手動執行
- 功能：自動測試、分析、build 並部署到 GitHub Pages

## 🔧 故障排除

### 常見問題

#### 1. 構建失敗
- 檢查 Flutter 版本是否正確
- 確保所有依賴項已安裝
- 查看 Actions 頁面的錯誤日誌

#### 2. GitHub Pages 無法訪問
- 確認 GitHub Pages 已啟用
- 檢查 `deploy-pages.yml` workflow 是否成功執行
- 確認 base href 設置正確

#### 3. 身份驗證失敗
- 檢查 `GOOGLE_CLIENT_ID` secret 是否正確設置
- 確認 Google OAuth 配置正確

### 獲取幫助

如果遇到問題：

1. 查看 Actions 頁面的詳細日誌
2. 確認所有設置步驟已完成

## 📚 進階配置

### 自定義 Flutter 版本

編輯 `.github/workflows/deploy-pages.yml` 文件中的 `FLUTTER_VERSION`：

```yaml
env:
  FLUTTER_VERSION: "3.32.4"  # 修改為您需要的版本
```

### 修改 base href

如果您的倉庫名稱不是 `auto30_next`，請同步修改：
- `web/index.html` 中的 `<base href="/your_repo/">`
- `.github/workflows/deploy-pages.yml` 中的 `--base-href /your_repo/`

## 🎉 完成！

恭喜！您的 Flutter 應用現在已經配置了自動部署到 GitHub Pages 的流程。

每次推送到 main/master 分支時，GitHub Actions 將自動：
- 運行測試
- 構建 Web 應用
- 部署到 GitHub Pages

享受自動化部署的便利！ 