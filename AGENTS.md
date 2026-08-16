# AI Agent 專案操作指南 (AGENTS.md)

歡迎！身為一個 AI Agent（如 Claude、GitHub Copilot、Codex 或 Antigravity），當使用者要求你處理 YouTube 影片分析任務時，請遵循本指南中的工作流（Workflow）與工具（Skills）來完成任務。

## 專案概述
本專案提供了一套自動化腳本，用於將「小翠時政財經」與「美投侃新闻」的 YouTube 影片音訊下載、轉譯為文字稿，並交由 AI Agent（也就是你）進行各自的總結與投資分析，最後輸出觀點對比的「每日新聞綜述」。
所有操作應避免污染系統環境，並依賴 `uv run` 來隔離執行 Python 腳本。

## 你的核心任務與工作流程 (Workflow)

當使用者執行 `/process` 總管指令時，請自動掃描雙頻道並處理所有流程。

> **快速指令參考 (Slash Commands)**
> 每個步驟均可透過 `/` 命令獨立執行：
> | 命令 | 步驟 | 必要輸入 |
> |------|------|----------|
> | `/process` | 總管排程 (Orchestrator): 自動掃描全頻道並執行後續分析與同步 | （無） |
> | `/scan_cui` | 獨立掃描「小翠時政財經」並處理新影片 | （無） |
> | `/scan_meitou_news` | 獨立掃描「美投侃新聞」並處理新影片 | （無） |
> | `/scan_meitou_stock` | 獨立掃描「美投講美股」（每週日更新）並處理新影片 | （無） |
> | `/download` | Step 1: 下載音訊 | YouTube URL |
> | `/organize` | Step 2: 分類整理 | `.mp3` 檔案路徑 |
> | `/transcribe` | Step 3: 語音轉文字 | `.mp3` 檔案路徑 |
> | `/summarize` | Step 4: 摘要分析 | `.txt` 檔案路徑 |
> | `/compare` | Step 5: 觀點對比 (每日新聞綜述) | （無） |
> | `/sync_gist` | Step 6: 同步至 Gist | （無） |
> | `/archive` | Step 7: アーカイブ同期 | （無） |
> | `/pull_from_archive` | Step 8: 從存檔提取（反向操作，僅限手動執行） | （無） |

### 自動掃描 (Auto-Scan) — `/scan_cui`, `/scan_meitou_news`, `/scan_meitou_stock`
如果你希望 AI Agent 獨立去 YouTube 抓取個別頻道的最新影片並處理，請使用這三個指令。

### 一鍵總管排程 (Orchestrator) — `/process`
如果你希望 AI Agent 自動掃描「小翠時政財經」、「美投侃新聞」與「美投講美股」，若有新影片則進行處理，最後產生觀點對比並同步，請直接使用無參數的 `/process`。
> **參閱文件**：`.agent/workflows/process.prompt.md`

### Step 1: 下載音訊 (Download Audio) — `/download`
利用 `yt-dlp` 下載影片音訊。
> **參閱文件**：`.agent/workflows/download.prompt.md`

### Step 2: 判斷與分類整理 (Categorization & Organizing) — `/organize`
**請發揮你的 AI 判斷能力！**
根據 `.info.json` 的 `channel` 欄位與標題進行歸類：
- `美投侃新闻` ➔ `docs/美投君/美投侃新聞/YYYYMMDD/`
- `美投讲美股` ➔ `docs/美投君/美投講美股/YYYYMMDD/`
- `小翠時政財經` ➔ 由標題判斷為 `小翠時政財經/會員直播` 或 `小翠時政財經/每日要聞`
> **參閱文件**：`.agent/workflows/organize.prompt.md`

### Step 3: 語音轉文字 (Transcription) — `/transcribe`
利用 `skills/transcribe.py` 將整理好的音訊轉為文字。
> **參閱文件**：`.agent/workflows/transcribe.prompt.md`

### Step 4: 摘要與分析 (Summarization & Analysis) — `/summarize`
這一步是你展現分析能力的時候。
閱讀指定的文字稿（`.txt`），並根據提示詞生成分析報告。
> **參閱文件**：`.agent/workflows/summarize.prompt.md` 以及 `.agent/workflows/summarize.md`

### Step 5: 觀點對比分析 (Comparative Analysis) — `/compare`
讀取各頻道最新產生的摘要，並根據最新內容的類型動態切換分析模式（模式 A、B、C），自動選擇主比較對象進行多層次觀點對比與異同分析，將結果輸出至 `docs/每日新聞綜述/` 目錄。
> **參閱文件**：`.agent/workflows/compare.prompt.md`

### Step 6: 同步至 Gist (Sync to Gist) — `/sync_gist`
將生成的重點筆記與每日新聞綜述自動同步至 GitHub Gist。
請**一律先執行對應的載入腳本** (`load-env.sh` 或 `load-env.ps1`) 取得環境變數。
依據環境變數判斷是否需使用容器，若需使用容器則加上容器執行前綴（例如 Mac: `$CONTAINER_RUNTIME exec $CUI_CONTAINER uv run skills/sync_gist.py`，Windows: `& $env:CONTAINER_RUNTIME exec $env:CUI_CONTAINER uv run skills/sync_gist.py`），否則直接執行 `uv run skills/sync_gist.py`。
> 執行前請確保 `.env` 中已設定 `GITHUB_TOKEN` 與 `GIST_ID`。

### Step 7: アーカイブ同期 (Sync to Archive) — `/archive`
`./archive` 配下の任意の名前のアーカイブ用リポジトリが存在する場合、`docs` 内の `.md` ファイルをコピーし、Git コミットを行う。
請**一律先執行對應的載入腳本** (`load-env.sh` 或 `load-env.ps1`) 取得環境變數。
依據環境變數判斷是否需使用容器，若需使用容器則加上容器執行前綴（例如 Mac: `$CONTAINER_RUNTIME exec $CUI_CONTAINER uv run skills/sync_archive.py`，Windows: `& $env:CONTAINER_RUNTIME exec $env:CUI_CONTAINER uv run skills/sync_archive.py`），否則直接執行 `uv run skills/sync_archive.py`。
> `./archive` 配下にプロジェクトが存在しない場合は何もしない。

### Step 8: 從存檔提取 (Pull from Archive) — `/pull_from_archive`
手動將存檔的內容提取回本機的 `docs` 與 `logs` 目錄（不覆蓋現有檔案），此為 `/archive` 的反向操作。請注意，此指令僅限手動使用，不包含在 `/process` 等自動流程內。
請**一律先執行對應的載入腳本** (`load-env.sh` 或 `load-env.ps1`) 取得環境變數。
依據環境變數判斷是否需使用容器，若需使用容器則加上容器執行前綴（例如 Mac: `$CONTAINER_RUNTIME exec $CUI_CONTAINER uv run skills/pull_from_archive.py`，Windows: `& $env:CONTAINER_RUNTIME exec $env:CUI_CONTAINER uv run skills/pull_from_archive.py`），否則直接執行 `uv run skills/pull_from_archive.py`。
> 若 `./archive` 目錄下有多個存檔專案，將會提示使用者保留一個後再執行。

---

## 注意事項與規範
1. **無須依賴 Ollama**：摘要生成不再依賴本地 Ollama 腳本，而是直接由作為 AI Agent 的「你」來閱讀文本並產生 Markdown 報告。
2. **環境變數**：如果遇到認證或 API 錯誤，請檢查或提醒使用者 `.env` 的設定檔是否齊全。
3. **繁體中文輸出**：所有產生的資料夾名稱、分析報告以及與使用者的對話，請預設使用**繁體中文 (Traditional Chinese)**。
4. **絕對禁止污染系統環境**：身為 AI Agent，你在此專案中**發誓**執行任何 Python 腳本或安裝套件時，**絕對只使用 `uv`**（例如 `uv run`、`uv pip install` 等），**絕不使用系統全局的 `python` 或 `pip` 指令**，以確保系統環境不被污染。
5. **容器工具選擇 (Windows 必讀)**：在 Windows 環境執行**任何** `exec cui-tools ...` 指令之前，務必先讀取 `.env` 中的 `CONTAINER_RUNTIME` 值，並以該值取代指令中的容器工具名稱（例如 `podman exec cui-tools ...` 或 `docker exec cui-tools ...`）。若 `.env` 中未設定 `CONTAINER_RUNTIME`，預設使用 `docker`。**絕不可在未確認 `CONTAINER_RUNTIME` 前直接寫死 `docker exec`。**
6. **執行環境與依賴檢查**：在執行後續處理前，你必須遵守以下檢查邏輯：
   - **一律先執行** `source scripts/load-env.sh` (Mac) 或 `. scripts/load-env.ps1` (Windows) 以讀取環境變數。**絕對不要**使用讀檔工具直接讀取 `.env` 來判斷條件。
   - **檢查容器需求**：若 `USE_CONTAINER` 為 Truthy、或 `USE_CUDA` 為 Truthy、或 `WHISPER_MODE` 為 `local` 時：必須使用容器。若未偵測到 `CONTAINER_RUNTIME` 所指定的容器工具（`docker` 或 `podman`），請立即停止後續處理，並促請使用者安裝該容器工具。
   - **不需容器的情況**：若不滿足強制使用容器的條件時，不使用容器。若偵測到未安裝 `uv`，請立即停止後續處理，並促請使用者安裝 `uv`。
