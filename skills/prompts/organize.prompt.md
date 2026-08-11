---
mode: 'agent'
description: 'Step 2: 判斷影片類型並整理至 docs/ 目錄'
---

## 任務：判斷與分類整理 (Categorization & Organizing)

請發揮你的 AI 判斷能力，將使用者指定的音訊檔案（`${input:audioFilePath}`）整理至對應的分類資料夾。

### 執行步驟
1. **定位目標檔案**：根據提供的音訊檔案路徑 (`${input:audioFilePath}`)，找出對應的 `.mp3` 與相鄰的 `.info.json` 檔案。
2. **讀取中繼資料**：使用 `skills/read_metadata.py` 讀取 `.info.json` 的關鍵資訊（標題、頻道、上傳日期等）。
   - **Mac**: `uv run skills/read_metadata.py <info.json 路徑>`
   - **Windows**: `& $env:CONTAINER_RUNTIME exec $env:CUI_CONTAINER uv run skills/read_metadata.py <info.json 路徑>`（`$env:CUI_CONTAINER` 等環境變數應已由 `load-env.ps1` 設定）
   - 腳本會輸出影片 ID、標題、頻道名稱、上傳日期、URL 與時長等欄位。
3. **判斷頻道與影片類型**：
   - 首先檢查 `read_metadata.py` 輸出的 `頻道`（channel）欄位與標題：
     - 若頻道為 `美投侃新闻` ➔ 分類為 `美投君/美投侃新聞`
     - 若頻道為 `美投讲美股` ➔ 分類為 `美投君/美投講美股`
     - 若頻道或標題包含 `小翠時政財經`：
       - 標題包含「會員直播」 ➔ 分類為 `小翠時政財經/會員直播`
       - 標題包含「每日要聞」 ➔ 分類為 `小翠時政財經/每日要聞`
       - 無法判斷子類型 ➔ 預設分類為 `小翠時政財經/會員直播`
     - 若無法匹配上述情況，但包含「美投」關鍵字 ➔ 預設分類為 `美投君/美投侃新聞`
4. **提取日期**：從 `read_metadata.py` 輸出的 `上傳日期` 欄位取得日期（格式：`YYYYMMDD`）。
5. **建立目錄**：建立 `./docs/<Channel>/[<SubFolder>/]<Date>/` 資料夾（例如 `./docs/小翠時政財經/每日要聞/20260805/` 或 `./docs/美投君/美投侃新聞/20260805/` 或 `./docs/美投君/美投講美股/20260802/`）。
6. **移動檔案**：將 `.mp3` 與 `.info.json` 移動到該目錄下。

### 執行後確認事項
- 向使用者回報分類結果（影片類型、日期、目標路徑）。
- 提示使用者可以接著執行 `/transcribe` 來進行語音轉文字。

### 注意
- 所有資料夾名稱與回覆請使用**繁體中文**。
