#!/usr/bin/env zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_DIR="$ROOT_DIR/ScoonMobile"
PROJECT_PATH="$APP_DIR/ScoonMobile.xcodeproj"
SCHEME="ScoonMobile"

echo "[preflight] Root: $ROOT_DIR"
echo "[preflight] App dir: $APP_DIR"

if [[ ! -d "$PROJECT_PATH" ]]; then
  echo "[preflight] ERROR: Project not found at $PROJECT_PATH"
  exit 1
fi

echo "[preflight] 1/3 Build Debug (simulator)"
cd "$APP_DIR"
xcodebuild -project "$PROJECT_PATH" -scheme "$SCHEME" -sdk iphonesimulator -configuration Debug build CODE_SIGNING_ALLOWED=NO >/tmp/scoon_preflight_build.log
tail -n 10 /tmp/scoon_preflight_build.log

echo "[preflight] 2/3 Checking remote env settings"
echo "  SCOON_USE_REMOTE_DATA=${SCOON_USE_REMOTE_DATA:-<not-set>}"
echo "  SCOON_API_BASE_URL=${SCOON_API_BASE_URL:-<not-set>}"

echo "[preflight] 3/3 Done"
echo "[preflight] SUCCESS"
