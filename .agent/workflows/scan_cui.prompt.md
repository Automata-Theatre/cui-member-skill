---
mode: 'agent'
description: '自動掃描小翠時政財經最新影片，判斷是否已下載，若無則自動執行處理流程'
---

## 任務：自動掃描最新影片 (Auto-Scan)

請你執行 `/scan_cui` 的自動化掃描任務。

### 執行步驟

#### Step 0: 初始化環境與讀取設定
無論是在 Windows 或 Mac 環境，請**一律先執行對應的載入腳本**，以取得環境變數與判斷條件，**絕對不要直接讀取 `.env` 文件**：
- **Windows**:
  ```powershell
  Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass; . scripts/load-env.ps1
  ```
- **Mac**:
  ```bash
  source scripts/load-env.sh
  ```
執行後，根據腳本輸出的環境變數或回顯結果判斷是否需使用容器（依據 `AGENTS.md` 的規則）。
- 若需使用容器，後續指令請加上容器執行前綴，例如 `$env:CONTAINER_RUNTIME exec $env:CUI_CONTAINER uv run ...` (Windows) 或 `$CONTAINER_RUNTIME exec $CUI_CONTAINER uv run ...` (Mac)。
- 若不需使用容器，則後續指令直接使用 `uv run ...` 即可。
#### Step 1: 取得最新影片資訊
1. 根據作業系統執行對應指令，取得「小翠時政財經」最新直播影片的標題與 URL：
   - **Mac**: `uv run skills/get_latest_video.py "https://www.youtube.com/@cui_news/streams"`
   - **Windows**: 依環境設定使用容器指令（如 `& $env:CONTAINER_RUNTIME exec $env:CUI_CONTAINER uv run skills/get_latest_video.py ...`）或直接執行（`uv run skills/get_latest_video.py ...`）
2. 腳本會返回 `<標題>|<URL>` 的格式。請解析出該影片的 **標題** 與 **URL**。

#### Step 2: 檢查是否已下載與處理
1. 使用以下命令檢查剛才取得的 **URL** 是否已存在於下載紀錄中（腳本會自動解析影片 ID 並搜尋 `logs/download.log`）：
   - **Mac**: `uv run skills/log_download.py check "<URL>"`
   - **Windows**: 依環境設定使用容器指令或直接執行 `uv run skills/log_download.py check "<URL>"`
2. 判斷邏輯：
   - 若輸出 `[FOUND]`（結束代碼 0），代表已經處理過。請向使用者回報「小翠時政財經：最新影片已處理過，無須重新下載」，並 **結束此任務**。
   - 若輸出 `[NOT_FOUND]`（結束代碼 1），代表這是新的未處理影片，請進入 Step 3。

#### Step 3: 執行處理流程 (處理新影片)
既然這是一部新影片，請你自動針對剛取得的 **URL** 依序執行以下操作：
1. **下載**: 執行 `/download` (或使用 `skills/download_audio.py`) 下載音訊。
2. **分類**: 執行 `/organize` 將檔案移至 `docs/小翠時政財經/...`。
3. **轉譯**: 執行 `/transcribe` 產生文字稿。
4. **摘要**: 執行 `/summarize` 產生投資分析報告 (`summary.md`)。
5. **結束任務**: 若你是單獨執行 `/scan_cui`，請到此（完成 `/summarize`）為止，向使用者回報「小翠時政財經：新影片已下載並完成摘要」，**不要**接著執行 `/scan_meitou_news`、`/scan_meitou_stock`、`/compare`、`/sync_gist` 或 `/archive`。

### 注意
- **⚠️ 處理 Cookie 錯誤（[COOKIE_ERROR]）**：若執行 `get_latest_video.py` 或 `download_audio.py` 時遇到 `[COOKIE_ERROR]` 或因 YouTube 認證失敗而中斷，請**立即終止**所有後續流程（不可繼續下載或摘要）。請向使用者提示目前的 Cookie 檔案路徑（如 `.env` 中的 `COOKIES_PATH` 或是預設的 `./cookies.txt`），並詢問使用者要選擇以下哪種方式處理：
  1. 手動更新目前的 Cookie 檔案（提示檔案路徑）
  2. 指定另一個新的 Cookie 檔案路徑
  3. 改為從瀏覽器自動讀取 Cookie（請使用者指定瀏覽器，例如 chrome, edge, firefox）
- 回報與執行結果請使用**繁體中文**。
