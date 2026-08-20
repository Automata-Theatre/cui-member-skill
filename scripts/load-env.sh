#!/usr/bin/env bash
# load-env.sh — .env を環境変数に展開し、CUDA/CPU コンテナ設定を初期化する
# 使用法（source コマンド）: source scripts/load-env.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-${(%):-%x}}")" 2>/dev/null && pwd || pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
ENV_FILE="${PROJECT_ROOT}/.env"

if [ ! -f "$ENV_FILE" ]; then
    echo "[load-env] WARNING: .env が見つかりません: $ENV_FILE" >&2
    return 1 2>/dev/null || exit 1
fi

# --- .env を環境変数に展開 ---
set -a
source "$ENV_FILE"
set +a

# --- デフォルト値の補完 ---
if [ -z "$USE_CONTAINER" ]; then
    export USE_CONTAINER="false"
fi
if [ -z "$CONTAINER_RUNTIME" ]; then
    export CONTAINER_RUNTIME="docker"
fi

# --- コンテナ名と Compose ファイルを決定 ---
# macOS では USE_CUDA を無視し、常に CPU コンテナ設定を使う。
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
        echo "[load-env] NOTICE: macOS では USE_CUDA=true を無視し、CPU 設定を使用します。" >&2
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
