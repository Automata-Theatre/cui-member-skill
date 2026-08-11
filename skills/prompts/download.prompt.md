---
mode: 'agent'
description: 'Step 1: 下載 YouTube 影片音訊與中繼資料'
---

## 任務：下載音訊 (Download Audio)

請根據使用者的作業系統（OS）使用對應的指令下載 YouTube 影片音訊：

### 🍎 Mac 版 (Apple Silicon / Intel)
```bash
uv run skills/download_audio.py "${input:url}"
```

### 🪟 Windows 版 (完全容器化)
Windows 將 `.env` 載入為環境變數，並依 `USE_CUDA` 自動選擇容器後，再執行下載：
```powershell
# .env 讀入與環境初始化（第一次或設定變更時執行）
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass; . scripts/load-env.ps1
# 容器未啟動時起動
& $env:CONTAINER_RUNTIME compose -f $env:CUI_COMPOSE_FILE up -d
# 音聲下載
& $env:CONTAINER_RUNTIME exec $env:CUI_CONTAINER uv run skills/download_audio.py "${input:url}"
```
> **注意**: `load-env.ps1` 必須以ドットソース（`. `）執行，才能將設定反映至當前 Shell 中。
同一次 Shell 會話中已經源入過一次 `load-env.ps1` 後，後續步驟不需重複執行。

### 執行後確認事項與自動化流程
1. 確認工作目錄下已生成 `.mp3` 音訊檔案與 `.info.json` 中繼資料檔案。
2. **自動進入後續處理流程**：在成功下載後，請你**自動並依序**執行接下來的處理步驟，直到完成摘要為止：
   - 執行 `/organize` 將音訊與中繼資料歸檔到對應的分類與日期資料夾。
   - 執行 `/transcribe` 對剛整理好的 `.mp3` 檔案進行語音轉文字。
   - 執行 `/summarize` 針對轉換出的文字稿 (`.txt`) 進行分析與摘要。
3. 全部完成後，向使用者回報流程執行完畢與各檔案產生的結果。

### 注意
- 預設會讀取 `.env` 中的 `COOKIES_PATH`（通常為 `./cookies.txt`）以下載會員限定影片。
- **⚠️ 處理 Cookie 錯誤（[COOKIE_ERROR]）**：若腳本輸出 `[COOKIE_ERROR]` 或因 YouTube 認證失敗而中斷，請**立即終止**所有後續流程。請向使用者提示目前的 Cookie 檔案路徑（如 `.env` 中的 `COOKIES_PATH` 或是預設的 `./cookies.txt`），並詢問使用者要選擇以下哪種方式處理：
  1. 手動更新目前的 Cookie 檔案（提示檔案路徑）
  2. 指定另一個新的 Cookie 檔案路徑
  3. 改為從瀏覽器自動讀取 Cookie（請使用者指定瀏覽器，例如 chrome, edge, firefox）
- 所有回覆請使用**繁體中文**。
