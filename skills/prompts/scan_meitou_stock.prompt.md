---
mode: 'agent'
description: '自動掃描美投講美股最新影片（每週日更新），判斷是否已下載，若無則自動執行處理流程'
---

## 任務：自動掃描「美投講美股」最新影片 (Auto-Scan)

請你執行 `/scan_meitou_stock` 的自動化掃描任務。

### 執行步驟

#### Step 0: 初始化 Windows 環境（Windows 限定）
若在 Windows 環境執行，請**先**以 ドットソース 執行下列指令，將 `.env` 載入為環境變數（相當於 `set -a; . .env; set +a`），並依 `USE_CUDA` 自動選擇正確的容器：
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass; . scripts/load-env.ps1
```
後續所有 Windows 指令均使用 `$env:CONTAINER_RUNTIME` 與 `$env:CUI_CONTAINER`，無需手動讀取 `.env`。

#### Step 1: 取得最新影片資訊
1. 根據作業系統執行對應指令，取得「美投講美股」最新影片的標題與 URL：
   - **Mac**: `uv run skills/get_latest_video.py "https://www.youtube.com/@MeiTouJun/videos"`
   - **Windows**: `& $env:CONTAINER_RUNTIME exec $env:CUI_CONTAINER uv run skills/get_latest_video.py "https://www.youtube.com/@MeiTouJun/videos"`
2. 腳本會返回 `<標題>|<URL>` 的格式。請解析出該影片的 **標題** 與 **URL**。

#### Step 2: 檢查是否已下載與處理
1. 使用以下命令檢查剛才取得的 **URL** 是否已存在於下載紀錄中（腳本會自動解析影片 ID 並搜尋 `logs/download.log`）：
   - **Mac**: `uv run skills/log_download.py check "<URL>"`
   - **Windows**: `& $env:CONTAINER_RUNTIME exec $env:CUI_CONTAINER uv run skills/log_download.py check "<URL>"`
2. 判斷邏輯：
   - 若輸出 `[FOUND]`（結束代碼 0），代表已經處理過。請向使用者回報「美投講美股：最新影片已處理過，無須重新下載」，並 **結束此任務**。
   - 若輸出 `[NOT_FOUND]`（結束代碼 1），代表這是新的未處理影片，請進入 Step 3。

#### Step 3: 執行處理流程 (處理新影片)
既然這是一部新影片，請你自動針對剛取得的 **URL** 依序執行以下操作：
1. **下載**: 執行 `/download` (或使用 `skills/download_audio.py`) 下載音訊。
2. **分類**: 執行 `/organize` 將檔案移至 `docs/美投君/美投講美股/YYYYMMDD/`。
3. **轉譯**: 執行 `/transcribe` 產生文字稿。
4. **摘要**: 執行 `/summarize` 產生投資分析報告 (`summary.md`)。
5. **結束任務**: 若你是單獨執行 `/scan_meitou_stock`，請到此（完成 `/summarize`）為止，向使用者回報「美投講美股：新影片已下載並完成摘要」，**不要**接着執行 `/scan_cui`、`/scan_meitou_news`、`/compare`、`/sync_gist` 或 `/archive`。

### 注意
- **⚠️ 處理 Cookie 錯誤（[COOKIE_ERROR]）**：若執行 `get_latest_video.py` 或 `download_audio.py` 時遇到 `[COOKIE_ERROR]` 或因 YouTube 認證失敗而中斷，請**開啟**終止所有後續流程。請向使用者提示目前的 Cookie 檔案路徑，並詢問處理解決方案。
- 回報與執行結果請使用**繁體中文**。
