---
mode: 'agent'
description: 'Step 3: 使用 Whisper 將音訊轉為文字稿'
---

## 任務：語音轉文字 (Transcription)

請根據使用者的作業系統（OS）使用對應的指令，將指定的音訊檔案轉為文字稿：

### 🍎 Mac 版 (Apple Silicon / Intel)
```bash
uv run skills/transcribe.py "${input:audioFilePath}"
```

### 🪟 Windows 版
Windows 請先判斷是否需使用容器。依據 `AGENTS.md` 規則：
- 若需使用容器（`USE_CONTAINER=true` 等條件），載入環境變數後執行容器內轉譯：
  ```powershell
  Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass; . scripts/load-env.ps1
  & $env:CONTAINER_RUNTIME exec $env:CUI_CONTAINER uv run skills/transcribe.py "${input:audioFilePath}"
  ```
- 否則（不使用容器），直接在 PowerShell 執行：
  ```powershell
  uv run skills/transcribe.py "${input:audioFilePath}"
  ```

### 執行後確認事項
1. 確認在音訊檔案的同一目錄下已生成同名的 `.txt` 文字稿檔案。
2. 向使用者回報轉譯結果，包含輸出檔案路徑與文字量概況。
3. 提示使用者可以接著執行 `/summarize` 來進行摘要分析。

### 注意
- 該腳本會根據 `.env` 中的 `WHISPER_MODE` 自動選擇轉譯引擎：
  - `local`：使用本地 mlx-whisper（Apple Silicon Mac 專用）
  - `openai`：使用 OpenAI Whisper API
  - `azure`：使用 Azure OpenAI Whisper API
- 語言固定為中文 (`zh`)。
- 如果遇到 API 認證錯誤，請提醒使用者檢查 `.env` 中的 API Key 設定。
- 所有回覆請使用**繁體中文**。
