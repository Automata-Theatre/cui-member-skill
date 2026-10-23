---
name: download
description: 'Step 1: 下載 YouTube 影片音訊與中繼資料'
disable-model-invocation: true
---
## 任務：下載音訊 (Download Audio)

請根據使用者的作業系統（OS）使用對應的指令下載 YouTube 影片音訊：

### 執行方式 (Mac & Windows 共用)
無論作業系統為何，請**一律先執行對應的載入腳本**取得環境變數，**絕對不要直接讀取 `.env` 文件**：
- **Mac**: `source scripts/load-env.sh`
- **Windows**: `Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass; . scripts/load-env.ps1`

執行後，請依據腳本輸出的環境變數或回顯結果，判斷是否需使用容器（依據 `AGENTS.md` 規則）。

### 下載前：決定歸檔資料夾（日期順延判斷）
請**先**執行以下指令，在下載前取得中繼資料、判斷分類並決定日期資料夾（需使用容器時請加上容器前綴）：
```
uv run skills/resolve_target_dir.py "${input:url}" --create
```
- 腳本依上傳日期決定 `docs/<分類>/<YYYYMMDD>/`；若該日期資料夾**已有 `summary.md`**（或其他影片的音訊／文字稿），會自動**加 1 天**，直到找到可用資料夾為止，並建立該資料夾。
- 請解析最後一行 `TARGET_DIR=<路徑>`，作為後續所有步驟的資料夾。若有「日期順延」訊息，請在回報時說明。
- 若輸出 `[COOKIE_ERROR]`，依下方「處理 Cookie 錯誤」規則立即終止；若輸出 `[UNKNOWN_CATEGORY]`，請改為不加 `--output-dir` 下載，再以 `/organize` 由 AI 判斷分類。
- **禁止**建立 `summary_<影片ID>.md` 等替代檔名；同一日期資料夾只能有一份 `summary.md`。

### 下載指令
- **若需使用容器**：
  先確保容器已啟動（例如 `... compose -f <compose_file> up -d`），再執行下載指令：
  - Windows: `& $env:CONTAINER_RUNTIME exec $env:CUI_CONTAINER uv run skills/download_audio.py "${input:url}" --output-dir "<TARGET_DIR>"`
  - Mac: `$CONTAINER_RUNTIME exec $CUI_CONTAINER uv run skills/download_audio.py "${input:url}" --output-dir "<TARGET_DIR>"`
- **若不需使用容器**：
  直接執行：`uv run skills/download_audio.py "${input:url}" --output-dir "<TARGET_DIR>"`

### 執行後確認事項與自動化流程
1. 確認 `<TARGET_DIR>` 下已生成 `.mp3` 音訊檔案與 `.info.json` 中繼資料檔案。
2. **自動進入後續處理流程**：在成功下載後，請你**自動並依序**執行接下來的處理步驟，直到完成摘要為止：
   - `/organize`：檔案已直接下載至 `<TARGET_DIR>`，僅需確認分類結果，**無須再移動**。
   - 執行 `/transcribe` 對 `<TARGET_DIR>` 中的 `.mp3` 檔案進行語音轉文字。
   - 執行 `/summarize` 針對轉換出的文字稿 (`.txt`) 進行分析與摘要。
3. 全部完成後，向使用者回報流程執行完畢與各檔案產生的結果。

### 注意
- 預設會讀取 `.env` 中的 `COOKIES_PATH`（通常為 `./cookies.txt`）以下載會員限定影片。
- **⚠️ 處理 Cookie 錯誤（[COOKIE_ERROR]）**：若腳本輸出 `[COOKIE_ERROR]` 或因 YouTube 認證失敗而中斷，請**立即終止**所有後續流程。請向使用者提示目前的 Cookie 檔案路徑（如 `.env` 中的 `COOKIES_PATH` 或是預設的 `./cookies.txt`），並詢問使用者要選擇以下哪種方式處理：
  1. 手動更新目前的 Cookie 檔案（提示檔案路徑）
  2. 指定另一個新的 Cookie 檔案路徑
  3. 改為從瀏覽器自動讀取 Cookie（請使用者指定瀏覽器，例如 chrome, edge, firefox）
- 所有回覆請使用**繁體中文**。
