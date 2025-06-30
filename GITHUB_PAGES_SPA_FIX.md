# 🔧 GitHub Pages SPA 路由修復說明

## 🚨 問題描述

當用戶直接訪問 QR 碼連結時：
```
https://auto30next.alearn.org.tw/user/b8643tA3lUfm4CEAd2pRKVyOe9v1
```

會出現 GitHub Pages 的 404 錯誤：
- "File not found"
- "The site configured at this address does not contain the requested file"

## 🔍 問題原因

### GitHub Pages 的限制
GitHub Pages 是靜態網站託管服務，當用戶訪問 `/user/123` 這樣的路徑時：

1. **GitHub Pages 尋找實際檔案：** 它會在伺服器上尋找 `user/123/index.html` 或 `user/123.html`
2. **找不到檔案：** 因為這些路徑只存在於 Flutter 的客戶端路由中，實際上沒有這些檔案
3. **返回 404：** GitHub Pages 返回 404 錯誤頁面

### SPA (Single Page Application) 的挑戰
Flutter Web 是 SPA 應用程式：
- 所有路由都由 JavaScript 在客戶端處理
- 只有一個實際的 `index.html` 檔案
- 路由如 `/user/123` 只在瀏覽器中存在，伺服器上沒有對應檔案

## ✅ 解決方案

### 1. 創建 `404.html`

我們添加了 `web/404.html` 檔案：

```html
<!DOCTYPE html>
<html>
<head>
  <script type="text/javascript">
    // 將 /user/123 轉換為 /?/user/123
    var l = window.location;
    l.replace(
      l.protocol + '//' + l.hostname + 
      l.pathname.split('/').slice(0, 1).join('/') + '/?/' +
      l.pathname.slice(1) + l.search + l.hash
    );
  </script>
</head>
</html>
```

**工作原理：**
- 當 GitHub Pages 找不到檔案時，會自動顯示 `404.html`
- 404.html 中的 JavaScript 會將 URL 重寫
- 例如：`/user/123` → `/?/user/123`
- 然後重導向到主頁面

### 2. 修改 `index.html`

在 `web/index.html` 中添加路由處理邏輯：

```javascript
// 處理從 404.html 重導向來的 URL
(function(l) {
  if (l.search[1] === '/' ) {
    var decoded = l.search.slice(1).split('&').map(function(s) { 
      return s.replace(/~and~/g, '&')
    }).join('?');
    window.history.replaceState(null, null,
        l.pathname.slice(0, -1) + decoded + l.hash
    );
  }
}(window.location))
```

**工作原理：**
- 檢查 URL 是否包含 `?/` 格式
- 將 `/?/user/123` 還原為 `/user/123`
- 更新瀏覽器歷史記錄
- Flutter 路由系統接手處理

## 🎯 完整流程示例

### 用戶訪問 QR 碼連結：

1. **用戶點擊：** `https://auto30next.alearn.org.tw/user/b8643tA3lUfm4CEAd2pRKVyOe9v1`

2. **GitHub Pages 查找：** 尋找 `/user/b8643tA3lUfm4CEAd2pRKVyOe9v1/index.html`

3. **找不到檔案：** 返回 `404.html`

4. **404.html 執行：** 
   ```
   重寫 URL: /user/b8643tA3lUfm4CEAd2pRKVyOe9v1
   變成: /?/user/b8643tA3lUfm4CEAd2pRKVyOe9v1
   ```

5. **重導向到 index.html：** 載入主應用程式

6. **index.html 處理：**
   ```
   解析: /?/user/b8643tA3lUfm4CEAd2pRKVyOe9v1
   還原: /user/b8643tA3lUfm4CEAd2pRKVyOe9v1
   ```

7. **Flutter 路由接手：** 顯示用戶詳細頁面 ✅

## 🧪 測試方法

### 部署後測試：
1. 等待 GitHub Actions 完成構建（約 2-5 分鐘）
2. 直接訪問：`https://auto30next.alearn.org.tw/user/b8643tA3lUfm4CEAd2pRKVyOe9v1`
3. 應該看到用戶資料頁面，而不是 404

### 其他路由測試：
- `https://auto30next.alearn.org.tw/flag/someUserId`
- `https://auto30next.alearn.org.tw/map_detail/25.0330,121.5654`
- 所有動態路由都應該正常工作

## 🔒 安全性說明

### ✅ 安全措施保持：
- 路由權限檢查仍然有效
- 未登入用戶只能訪問公開頁面
- 敏感功能仍需要認證

### 🔓 改進的可訪問性：
- QR 碼連結可以直接分享
- 支援書籤和社交媒體分享
- 搜尋引擎可以索引公開頁面

## 📱 實際應用

現在你可以：
- 分享 QR 碼給任何人
- 把用戶頁面連結貼到社交媒體
- 用戶可以收藏特定的個人資料頁面
- 支援深度連結 (Deep Linking)

## 🚀 部署狀態

修改已推送到 GitHub，GitHub Actions 會自動：
1. 構建 Flutter Web 應用程式
2. 部署到 GitHub Pages
3. 更新線上版本

**預估等待時間：** 2-5 分鐘

## 🎉 總結

這個修復解決了 GitHub Pages 託管 SPA 應用程式的常見問題：
- ✅ QR 碼連結現在可以直接訪問
- ✅ 所有動態路由都能正常工作
- ✅ 保持了原有的安全性和功能
- ✅ 提升了用戶體驗和分享便利性

等待部署完成後，你的 QR 碼就能正常工作了！🎯 