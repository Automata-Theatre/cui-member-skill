---
description: "手動從 archive 目錄的 Git 專案中提取資料回本地端"
---

## /pull_from_archive

此指令會將存檔在 `./archive` 目錄下專案內的資料提取回本專案。

### 執行方式

請判斷目前的作業系統，並執行以下指令：

### 執行方式 (Mac & Windows 共用)
無論作業系統為何，請**一律先執行對應的載入腳本**取得環境變數，**絕對不要直接讀取 `.env` 文件**：
- **Mac**: `source scripts/load-env.sh`
- **Windows**: `Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass; . scripts/load-env.ps1`

執行後，請依據腳本輸出的環境變數或回顯結果，判斷是否需使用容器（依據 `AGENTS.md` 規則）。
- **若需使用容器**：
  - Windows: `& $env:CONTAINER_RUNTIME exec $env:CUI_CONTAINER uv run skills/pull_from_archive.py`
  - Mac: `$CONTAINER_RUNTIME exec $CUI_CONTAINER uv run skills/pull_from_archive.py`
- **若不需使用容器**：
  直接執行：`uv run skills/pull_from_archive.py`

> **注意：** 此為手動專用指令，請勿在 `/process` 等自動流程中呼叫此指令。
