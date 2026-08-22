#!/usr/bin/env bash
# load-env.sh — 將 .env 展開為環境變數，並初始化 CUDA/CPU 容器設定
# 使用方法（source 指令）: source scripts/load-env.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-${(%):-%x}}")" 2>/dev/null && pwd || pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
ENV_FILE="${PROJECT_ROOT}/.env"

if [ ! -f "$ENV_FILE" ]; then
    echo "[load-env] WARNING: 找不到 .env: $ENV_FILE" >&2
    return 1 2>/dev/null || exit 1
fi

# --- 將 .env 展開為環境變數 ---
set -a
source "$ENV_FILE"
set +a

# --- 補足預設值 ---
if [ -z "$USE_CONTAINER" ]; then
    export USE_CONTAINER="false"
fi
if [ -z "$CONTAINER_RUNTIME" ]; then
    export CONTAINER_RUNTIME="docker"
fi

# --- 決定容器名稱與 Compose 檔案 ---
# macOS 上忽略 USE_CUDA，一律使用 CPU 容器設定。
if [ "$(uname -s)" = "Darwin" ]; then
    # 嘗試載入使用者的環境設定，以確保非互動式 Shell (如 AI Agent) 具備完整的 PATH (包含 Homebrew 等)
    for profile in "$HOME/.zprofile" "$HOME/.bash_profile" "$HOME/.profile" "$HOME/.bashrc" "$HOME/.zshrc"; do
        if [ -f "$profile" ]; then
            source "$profile" >/dev/null 2>&1 || true
        fi
    done
    # 作為保底，仍確保 Homebrew 預設路徑存在
    export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

    if [ "$USE_CUDA" = "true" ]; then
        echo "[load-env] NOTICE: macOS 上忽略 USE_CUDA=true，改用 CPU 設定。" >&2
    fi
    export CUI_CONTAINER="cui-tools-cpu"
    export CUI_COMPOSE_FILE="docker-compose.cpu.yml"
elif [ "$USE_CUDA" = "true" ]; then
    export CUI_CONTAINER="cui-tools-cuda"
    export CUI_COMPOSE_FILE="docker-compose.cuda.yml"
else
    export CUI_CONTAINER="cui-tools-cpu"
    export CUI_COMPOSE_FILE="docker-compose.cpu.yml"
fi

echo "[load-env] RUNTIME=$CONTAINER_RUNTIME  USE_CONTAINER=$USE_CONTAINER  USE_CUDA=$USE_CUDA  CONTAINER=$CUI_CONTAINER  COMPOSE=$CUI_COMPOSE_FILE"
