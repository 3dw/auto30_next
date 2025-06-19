# GitHub Actions Workflow 說明

本專案包含三個 GitHub Actions workflow：

## 1. CI Workflow (`ci.yml`)

**觸發條件：**
- 推送到 `main` 或 `master` 分支
- 創建 Pull Request 到 `main` 或 `master` 分支

**功能：**
- 代碼格式檢查 (`dart format`)
- 代碼分析 (`flutter analyze`)
- 執行測試 (`flutter test`)
- 構建測試版本 (debug APK 和 Web)

## 2. Deploy Workflow (`deploy.yml`)

**觸發條件：**
- 推送到 `main` 或 `master` 分支
- 手動觸發 (`workflow_dispatch`)

**功能：**
- 執行完整的測試流程
- 構建 Android APK (release 版本)
- 構建 Web 版本 (release 版本)
- 創建 GitHub Release 並上傳 APK

## 3. GitHub Pages Workflow (`pages.yml`)

**觸發條件：**
- 推送到 `main` 或 `master` 分支
- 手動觸發 (`workflow_dispatch`)

**功能：**
- 專門用於 GitHub Pages 部署
- 使用正確的 base href 配置 (`/auto30_next/`)
- 自動部署到 GitHub Pages

## 設置步驟

### 1. 啟用 GitHub Pages

1. 前往您的 GitHub 倉庫設定
2. 在 "Pages" 選項中：
   - Source: 選擇 "GitHub Actions"
   - 這將啟用 GitHub Pages 部署

### 2. 設置 Secrets

在您的 GitHub 倉庫設定中，前往 "Secrets and variables" > "Actions"，添加以下 secrets：

#### 必需的 Secrets：
- `GOOGLE_CLIENT_ID`: 您的 Google OAuth Client ID（用於 Web 版本的身份驗證）

#### 可選的 Secrets：
- `FIREBASE_SERVICE_ACCOUNT_KEY`: Firebase 服務帳戶金鑰（如果需要 Firebase 功能）

### 3. 設置分支保護規則（推薦）

1. 前往倉庫設定 > "Branches"
2. 為 `main` 分支添加保護規則：
   - 要求狀態檢查通過
   - 要求 PR 審查
   - 限制直接推送

## Workflow 流程

### CI 流程：
```
Push/PR → 代碼檢查 → 測試 → 構建測試版本
```

### 部署流程：
```
Push to main → 測試 → 構建 → 創建 Release
```

### GitHub Pages 流程：
```
Push to main → 構建 Web → 部署到 GitHub Pages
```

## 輸出結果

### 成功部署後：
- **Web 版本**: 可在 `https://[username].github.io/auto30_next/` 訪問
- **Android APK**: 可在 GitHub Releases 頁面下載
- **構建產物**: 可在 Actions 頁面的 Artifacts 中下載

### 失敗處理：
- 檢查 Actions 頁面的錯誤日誌
- 確保所有必需的 secrets 已設置
- 檢查代碼格式和測試是否通過

## 自定義配置

### 修改 Flutter 版本：
在 workflow 文件中修改 `FLUTTER_VERSION` 環境變數。

### 修改倉庫名稱：
如果您的倉庫名稱不是 `auto30_next`，請修改：
1. `pages.yml` 中的 `--base-href /auto30_next/`
2. `web/index.html` 中的 `<base href="/auto30_next/">`

### 添加新的構建目標：
在 `deploy.yml` 中添加新的 job，例如 iOS 構建。

### 修改部署條件：
調整 `if` 條件來控制何時觸發部署。

## 故障排除

### 常見問題：

1. **構建失敗**：
   - 檢查 Flutter 版本兼容性
   - 確保所有依賴項正確安裝

2. **部署失敗**：
   - 檢查 GitHub Pages 是否已啟用
   - 確認 secrets 設置正確
   - 檢查 base href 配置是否正確

3. **測試失敗**：
   - 檢查代碼格式
   - 確保所有測試通過

4. **GitHub Pages 無法訪問**：
   - 確認 GitHub Pages 已啟用
   - 檢查 `pages.yml` workflow 是否成功執行
   - 確認 base href 設置正確

### 日誌查看：
- 前往 Actions 頁面查看詳細的執行日誌
- 每個步驟都有詳細的輸出信息

## Workflow 選擇建議

- **開發階段**: 使用 `ci.yml` 進行快速測試
- **發布階段**: 使用 `deploy.yml` 創建 Release
- **Web 部署**: 使用 `pages.yml` 部署到 GitHub Pages 