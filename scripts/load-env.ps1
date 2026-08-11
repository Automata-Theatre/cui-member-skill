# load-env.ps1 — .env を環境変数に展開し、CUDA/CPU コンテナ設定を初期化する
# 使用法（ドットソース）: . scripts/load-env.ps1
#
# bash の `set -a; . .env; set +a` 相当の処理を PowerShell で実行します。
# 呼び出し後、以下の環境変数が利用可能になります:
#   $env:CONTAINER_RUNTIME  — 使用するコンテナツール (docker または podman)
#   $env:CUI_CONTAINER      — 操作対象のコンテナ名
#   $env:CUI_COMPOSE_FILE   — 使用する docker-compose ファイルパス

$ProjectRoot = Split-Path -Parent $PSScriptRoot

# --- .env を Process スコープの環境変数に展開 ---
$envFile = Join-Path $ProjectRoot '.env'
if (-not (Test-Path $envFile)) {
    Write-Warning "[load-env] .env が見つかりません: $envFile"
    return
}

Get-Content $envFile | ForEach-Object {
    # コメント行・空行をスキップし、KEY=VALUE 形式のみ処理
    if ($_ -match '^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*)$') {
        $name  = $Matches[1].Trim()
        $value = $Matches[2].Trim().Trim('"').Trim("'")
        Set-Item -Path "Env:$name" -Value $value
    }
}

# --- デフォルト値の補完 ---
if (-not $env:CONTAINER_RUNTIME) { $env:CONTAINER_RUNTIME = 'docker' }

# --- USE_CUDA に基づきコンテナ名と Compose ファイルを決定 ---
if ($env:USE_CUDA -eq 'true') {
    $env:CUI_CONTAINER    = 'cui-tools-cuda'
    $env:CUI_COMPOSE_FILE = 'docker-compose.cuda.yml'
} else {
    $env:CUI_CONTAINER    = 'cui-tools-cpu'
    $env:CUI_COMPOSE_FILE = 'docker-compose.cpu.yml'
}

Write-Host "[load-env] RUNTIME=$($env:CONTAINER_RUNTIME)  USE_CUDA=$($env:USE_CUDA)  CONTAINER=$($env:CUI_CONTAINER)  COMPOSE=$($env:CUI_COMPOSE_FILE)"
