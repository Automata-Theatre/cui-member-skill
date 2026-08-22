# load-env.ps1 — 將 .env 展開為環境變數，並初始化 CUDA/CPU 容器設定
# 使用方法（dot-source）: . scripts/load-env.ps1
#
# 執行等同於 bash 的 `set -a; . .env; set +a` 處理。
# 呼叫後可使用以下環境變數：
#   $env:CONTAINER_RUNTIME  — 使用的容器工具 (docker 或 podman)
#   $env:CUI_CONTAINER      — 操作對象的容器名稱
#   $env:CUI_COMPOSE_FILE   — 使用的 docker-compose 檔案路徑

$ProjectRoot = Split-Path -Parent $PSScriptRoot

# --- 將 .env 展開為 Process 範圍的環境變數 ---
$envFile = Join-Path $ProjectRoot '.env'
if (-not (Test-Path $envFile)) {
    Write-Warning "[load-env] 找不到 .env: $envFile"
    return
}

Get-Content $envFile | ForEach-Object {
    # 跳過註解行與空行，僅處理 KEY=VALUE 格式
    if ($_ -match '^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*)$') {
        $name  = $Matches[1].Trim()
        $value = $Matches[2].Trim().Trim('"').Trim("'")
        Set-Item -Path "Env:$name" -Value $value
    }
}

# --- 補足預設值 ---
if (-not $env:USE_CONTAINER) { $env:USE_CONTAINER = 'false' }
if (-not $env:CONTAINER_RUNTIME) { $env:CONTAINER_RUNTIME = 'docker' }

# --- 依據 USE_CUDA 決定容器名稱與 Compose 檔案 ---
if ($env:USE_CUDA -eq 'true') {
    $env:CUI_CONTAINER    = 'cui-tools-cuda'
    $env:CUI_COMPOSE_FILE = 'docker-compose.cuda.yml'
} else {
    $env:CUI_CONTAINER    = 'cui-tools-cpu'
    $env:CUI_COMPOSE_FILE = 'docker-compose.cpu.yml'
}

Write-Host "[load-env] RUNTIME=$($env:CONTAINER_RUNTIME)  USE_CONTAINER=$($env:USE_CONTAINER)  USE_CUDA=$($env:USE_CUDA)  CONTAINER=$($env:CUI_CONTAINER)  COMPOSE=$($env:CUI_COMPOSE_FILE)"
