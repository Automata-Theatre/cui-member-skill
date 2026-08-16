#!/usr/bin/env bash
# load-env.sh — .env を環境変数に展開し、CUDA/CPU コンテナ設定を初期化する
# 使用法（source コマンド）: source scripts/load-env.sh

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
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
if [ -z "$CONTAINER_RUNTIME" ]; then
    export CONTAINER_RUNTIME="docker"
fi

# --- USE_CUDA に基づきコンテナ名と Compose ファイルを決定 ---
if [ "$USE_CUDA" = "true" ]; then
    export CUI_CONTAINER="cui-tools-cuda"
    export CUI_COMPOSE_FILE="docker-compose.cuda.yml"
else
    export CUI_CONTAINER="cui-tools-cpu"
    export CUI_COMPOSE_FILE="docker-compose.cpu.yml"
fi

echo "[load-env] RUNTIME=$CONTAINER_RUNTIME  USE_CUDA=$USE_CUDA  CONTAINER=$CUI_CONTAINER  COMPOSE=$CUI_COMPOSE_FILE"
