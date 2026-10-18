---
description: "清理 docs 目錄下的非 .md 檔案（僅限手動執行，預設不刪除）"
---

## /clean_up

此指令會統計 `./docs` 目錄下（含所有子目錄）**副檔名不是 `.md`** 的檔案（例如 `.mp3`、`.txt`、`.info.json` 等），但一律保留名稱為 `.gitkeep` 或 `.keep` 的檔案。一般啟動時預設不刪除；只有在取得使用者明確同意，或使用者以 `force`／`yes` 參數啟動時才刪除。

### 執行方式 (Mac & Windows 共用)
無論作業系統為何，請**一律先執行對應的載入腳本**取得環境變數，**絕對不要直接讀取 `.env` 文件**：
- **Mac**: `source scripts/load-env.sh`
- **Windows**: `Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass; . scripts/load-env.ps1`

執行後，請依據腳本輸出的環境變數，判斷是否需使用容器（依據 `AGENTS.md` 規則），並組裝下列指令前綴：
- **若需使用容器**：
  - Windows: `& $env:CONTAINER_RUNTIME exec $env:CUI_CONTAINER uv run skills/clean_up.py`
  - Mac: `$CONTAINER_RUNTIME exec $CUI_CONTAINER uv run skills/clean_up.py`
- **若不需使用容器**：
  - Windows: `. scripts/load-env.ps1; uv run skills/clean_up.py`
  - Mac: `source scripts/load-env.sh && uv run skills/clean_up.py`

### 處理流程

1. **判斷參數**：若指令為 `/clean_up force` 或 `/clean_up yes`，視為使用者明確授權刪除，執行統計後直接以 `--force` 或 `--yes` 參數執行刪除，不再詢問。其他參數不代表刪除授權。
2. **統計對象檔案**：一般啟動時以**不帶任何參數**的方式執行腳本（僅統計，不刪除）；帶 `force`／`yes` 時先統計並向使用者報告「對象檔案數」與「合計大小」，再執行刪除。
   - 若對象檔案數為 0，告知使用者無需清理後即結束。
3. **一般啟動時詢問是否刪除**：以選項方式向使用者確認，選項如下（**預設為「不刪除」**）：
   - `不刪除（預設）`：結束處理，不刪除任何檔案。
   - `列出檔案清單`：加上 `--list` 參數重新執行並顯示清單，之後再次詢問是否刪除。
   - `刪除`：執行刪除。
   > 若使用者未回覆、回覆不明確或選擇其他內容，一律視為「不刪除」。
4. **執行刪除**：一般啟動時僅在使用者**明確選擇「刪除」**後，加上 `--delete` 參數執行腳本；以 `force`／`yes` 啟動時，使用對應的 `--force`／`--yes` 參數執行。完成後向使用者報告刪除結果（成功與失敗的檔案數）。

> **注意：** 此為手動專用指令，請勿在 `/process` 等自動流程中呼叫此指令。`.md`、`.gitkeep` 與 `.keep` 檔案絕不在刪除範圍內。
