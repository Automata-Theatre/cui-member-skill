---
description: "手動從 archive 目錄的 Git 專案中提取資料回本地端"
---

## /pull_from_archive

此指令會將存檔在 `./archive` 目錄下專案內的資料提取回本專案。

### 執行方式

請判斷目前的作業系統，並執行以下指令：

**Mac 系統：**
```bash
uv run skills/pull_from_archive.py
```

**Windows 系統：**
請先判斷是否需使用容器。依據 `AGENTS.md` 中的規則：
- 若 `USE_CONTAINER` 為 true，或 `USE_CUDA` 為 true，或 `WHISPER_MODE` 為 local，請使用容器執行：
  ```powershell
  Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass; . scripts/load-env.ps1
  & $env:CONTAINER_RUNTIME exec $env:CUI_CONTAINER uv run skills/pull_from_archive.py
  ```
- 否則（不使用容器），直接在 PowerShell 執行：
  ```powershell
  uv run skills/pull_from_archive.py
  ```

> **注意：** 此為手動專用指令，請勿在 `/process` 等自動流程中呼叫此指令。
