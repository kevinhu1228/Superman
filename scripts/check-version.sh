#!/usr/bin/env bash
# check-version.sh — check if a newer superman-plugin version is available
# Usage: check-version.sh [--auto] [target-dir]
#
# Normal mode: checks npm registry (with 24h cache), prints notification if update available.
# --auto mode:  reads cache only (no network); if update available, spawns update.sh --silent
#               in the background and exits silently. Used by the Stop hook.

SUPERMAN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AUTO=0
TARGET_DIR=""

for arg in "$@"; do
  case "$arg" in
    --auto) AUTO=1 ;;
    *)      [ -z "$TARGET_DIR" ] && TARGET_DIR="$arg" ;;
  esac
done
TARGET_DIR="${TARGET_DIR:-$(pwd)}"

CACHE_FILE="$TARGET_DIR/.superman/.version-cache"
CACHE_TTL=86400  # 24 hours

# Read installed version
CURRENT=$(node -e "try{console.log(require('$SUPERMAN_DIR/package.json').version)}catch(e){process.exit(1)}" 2>/dev/null) || exit 0

# Semver comparison helper: is B strictly newer than A?
is_newer() {
  node -e "
    const a='$1'.split('.').map(Number), b='$2'.split('.').map(Number);
    const newer = b[0]>a[0] || (b[0]===a[0] && b[1]>a[1]) || (b[0]===a[0] && b[1]===a[1] && b[2]>a[2]);
    process.exit(newer ? 0 : 1);
  " 2>/dev/null
}

if [ "$AUTO" = "1" ]; then
  # --auto mode: cache-only, no network call
  [ -f "$CACHE_FILE" ] || exit 0
  LATEST=$(cat "$CACHE_FILE" 2>/dev/null) || exit 0
  is_newer "$CURRENT" "$LATEST" || exit 0
  nohup bash "$SUPERMAN_DIR/scripts/update.sh" --silent "$TARGET_DIR" >/dev/null 2>&1 &
  disown $! 2>/dev/null || true
  exit 0
fi

# Normal mode: check cache freshness
CACHE_VALID=0
if [ -f "$CACHE_FILE" ]; then
  NOW=$(date +%s 2>/dev/null || echo 0)
  MTIME=$(stat -c %Y "$CACHE_FILE" 2>/dev/null || stat -f %m "$CACHE_FILE" 2>/dev/null || echo 0)
  AGE=$(( NOW - MTIME ))
  [ "$AGE" -lt "$CACHE_TTL" ] && CACHE_VALID=1
fi

if [ "$CACHE_VALID" = "0" ]; then
  LATEST=$(npm show superman-plugin version 2>/dev/null || echo "")
  [ -z "$LATEST" ] && exit 0  # network failure — exit silently
  mkdir -p "$TARGET_DIR/.superman"
  printf '%s' "$LATEST" > "$CACHE_FILE"
else
  LATEST=$(cat "$CACHE_FILE" 2>/dev/null) || exit 0
fi

is_newer "$CURRENT" "$LATEST" && \
  echo "[Superman] Update available: $CURRENT → $LATEST. Run: superman update"
