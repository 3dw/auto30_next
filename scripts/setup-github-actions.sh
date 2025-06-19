#!/bin/bash

# GitHub Actions 設置腳本
# 用於快速配置 Flutter 專案的 GitHub Actions

echo "🚀 開始設置 GitHub Actions..."

# 檢查是否在 Git 倉庫中
if [ ! -d ".git" ]; then
    echo "❌ 錯誤：請在 Git 倉庫根目錄中執行此腳本"
    exit 1
fi

# 檢查 Flutter 是否安裝
if ! command -v flutter &> /dev/null; then
    echo "❌ 錯誤：Flutter 未安裝或不在 PATH 中"
    echo "請先安裝 Flutter：https://flutter.dev/docs/get-started/install"
    exit 1
fi

# 檢查 Flutter 版本
FLUTTER_VERSION=$(flutter --version | grep -o "Flutter [0-9]\+\.[0-9]\+\.[0-9]\+" | cut -d' ' -f2)
echo "📱 檢測到 Flutter 版本：$FLUTTER_VERSION"

# 更新 workflow 文件中的 Flutter 版本
echo "🔄 更新 workflow 文件中的 Flutter 版本..."
sed -i.bak "s/FLUTTER_VERSION: \"[0-9]\+\.[0-9]\+\.[0-9]\+\"/FLUTTER_VERSION: \"$FLUTTER_VERSION\"/g" .github/workflows/*.yml

# 檢查必要的文件是否存在
echo "📋 檢查專案配置..."

if [ ! -f "pubspec.yaml" ]; then
    echo "❌ 錯誤：找不到 pubspec.yaml 文件"
    exit 1
fi

if [ ! -f "web/index.html" ]; then
    echo "❌ 錯誤：找不到 web/index.html 文件"
    exit 1
fi

# 獲取倉庫名稱
REPO_NAME=$(basename -s .git `git config --get remote.origin.url`)
echo "📦 倉庫名稱：$REPO_NAME"

# 檢查是否需要更新 base href
CURRENT_BASE_HREF=$(grep -o 'base href="[^"]*"' web/index.html | cut -d'"' -f2)
if [ "$CURRENT_BASE_HREF" != "/$REPO_NAME/" ]; then
    echo "🔄 更新 web/index.html 中的 base href..."
    sed -i.bak "s|<base href=\"[^\"]*\">|<base href=\"/$REPO_NAME/\">|g" web/index.html
    
    echo "🔄 更新 pages.yml 中的 base href..."
    sed -i.bak "s|--base-href /[^/]*/|--base-href /$REPO_NAME/|g" .github/workflows/pages.yml
fi

# 檢查 .gitignore
if ! grep -q ".github/workflows/" .gitignore 2>/dev/null; then
    echo "✅ .github/workflows/ 已在 .gitignore 中（正確）"
else
    echo "⚠️  注意：.github/workflows/ 不應在 .gitignore 中"
fi

# 檢查 secrets 設置
echo ""
echo "🔐 請確保在 GitHub 倉庫設定中設置以下 Secrets："
echo "   - GOOGLE_CLIENT_ID: 您的 Google OAuth Client ID"
echo ""
echo "📝 設置步驟："
echo "   1. 前往 GitHub 倉庫設定"
echo "   2. 選擇 'Secrets and variables' > 'Actions'"
echo "   3. 點擊 'New repository secret'"
echo "   4. 添加 GOOGLE_CLIENT_ID"

# 檢查 GitHub Pages 設置
echo ""
echo "🌐 GitHub Pages 設置："
echo "   1. 前往 GitHub 倉庫設定"
echo "   2. 選擇 'Pages'"
echo "   3. Source: 選擇 'GitHub Actions'"
echo "   4. 保存設置"

# 顯示部署 URL
echo ""
echo "🎯 部署完成後，您的應用將可在以下位置訪問："
echo "   Web 版本: https://$(git config --get user.name).github.io/$REPO_NAME/"
echo "   APK 下載: GitHub Releases 頁面"

# 清理備份文件
rm -f .github/workflows/*.yml.bak web/index.html.bak

echo ""
echo "✅ GitHub Actions 設置完成！"
echo ""
echo "📋 下一步："
echo "   1. 提交並推送這些更改到 GitHub"
echo "   2. 設置必要的 Secrets"
echo "   3. 啟用 GitHub Pages"
echo "   4. 推送代碼到 main 分支觸發部署"
echo ""
echo "🔍 監控部署："
echo "   前往 GitHub 倉庫的 'Actions' 頁面查看部署狀態" 