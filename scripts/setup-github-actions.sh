#!/bin/bash

# GitHub Actions 設置腳本
# 用於快速配置 Flutter 專案的 GitHub Actions

echo "🚀 開始設置 GitHub Actions..."

# 檢查是否在 Git 倉庫中
if [ ! -d ".git" ]; then
    echo "❌ 請在 Git 倉庫根目錄執行此腳本"
    exit 1
fi

# 檢查 Flutter 是否安裝
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter 未安裝或不在 PATH 中"
    exit 1
fi

# 取得 Flutter 版本
FLUTTER_VERSION=$(flutter --version | grep -o "Flutter [0-9]\+\.[0-9]\+\.[0-9]\+" | cut -d' ' -f2)
echo "📱 Flutter 版本：$FLUTTER_VERSION"

# 更新 deploy-pages.yml 的 Flutter 版本
if [ -f ".github/workflows/deploy-pages.yml" ]; then
    sed -i.bak "s/FLUTTER_VERSION: \".*\"/FLUTTER_VERSION: \"$FLUTTER_VERSION\"/g" .github/workflows/deploy-pages.yml
    rm -f .github/workflows/deploy-pages.yml.bak
fi

# 取得 repo 名稱
REPO_NAME=$(basename -s .git `git config --get remote.origin.url`)
echo "📦 倉庫名稱：$REPO_NAME"

# base href 同步
if [ -f "web/index.html" ]; then
    sed -i.bak "s|<base href=\"[^\"]*\">|<base href=\"/$REPO_NAME/\">|g" web/index.html
    rm -f web/index.html.bak
fi
if [ -f ".github/workflows/deploy-pages.yml" ]; then
    sed -i.bak "s|--base-href /[^/]*/|--base-href /$REPO_NAME/|g" .github/workflows/deploy-pages.yml
    rm -f .github/workflows/deploy-pages.yml.bak
fi

echo ""
echo "🔐 請在 GitHub 設定 Secrets：GOOGLE_CLIENT_ID"
echo "🌐 請在 GitHub Pages 設定 Source: GitHub Actions"
echo ""
echo "✅ 設置完成！推送 main/master 分支即可自動部署到 GitHub Pages" 