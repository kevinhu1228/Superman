#!/usr/bin/env bash
# update.sh — update superman-plugin to latest version and re-sync target project
# Usage: update.sh [--silent] [target-dir]
#
# --silent: suppress stdout; write progress to .superman/.update-log instead.
#           Used by the Stop hook auto-update (方案 C).

set -e

SUPERMAN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SILENT=0
TARGET_DIR=""

for arg in "$@"; do
  case "$arg" in
    --silent) SILENT=1 ;;
    *)        [ -z "$TARGET_DIR" ] && TARGET_DIR="$arg" ;;
  esac
done
TARGET_DIR="${TARGET_DIR:-$(pwd)}"

LOG_FILE="$TARGET_DIR/.superman/.update-log"

log() {
  if [ "$SILENT" = "0" ]; then
    echo "$@"
  fi
}

log_append() {
  mkdir -p "$(dirname "$LOG_FILE")"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Read installed version
CURRENT=$(node -e "try{console.log(require('$SUPERMAN_DIR/package.json').version)}catch(e){process.exit(1)}" 2>/dev/null) || {
  log "⚠ Could not read installed version"; exit 1
}

# Fetch latest version from npm registry
LATEST=$(npm show superman-plugin version 2>/dev/null || echo "")
if [ -z "$LATEST" ]; then
  log "⚠ Could not fetch latest version from npm registry"
  [ "$SILENT" = "1" ] && log_append "Version check failed: npm registry unreachable"
  exit 0
fi

# Semver comparison: is LATEST strictly newer than CURRENT?
IS_NEWER=$(node -e "
  const a='$CURRENT'.split('.').map(Number), b='$LATEST'.split('.').map(Number);
  const newer = b[0]>a[0] || (b[0]===a[0] && b[1]>a[1]) || (b[0]===a[0] && b[1]===a[1] && b[2]>a[2]);
  console.log(newer ? 'yes' : 'no');
" 2>/dev/null) || IS_NEWER="no"

if [ "$IS_NEWER" != "yes" ]; then
  log "🦸 Superman Update"
  log "  ✓ Already up to date ($CURRENT)"
  [ "$SILENT" = "1" ] && log_append "Version check: already up to date ($CURRENT)"
  exit 0
fi

log "🦸 Superman Update"
log "  Current version: $CURRENT"
log "  Latest version:  $LATEST"
log "  Updating..."

if [ "$SILENT" = "1" ]; then
  npm install -g "superman-plugin@$LATEST" --silent >/dev/null 2>&1
  log_append "Updated $CURRENT → $LATEST"
else
  npm install -g "superman-plugin@$LATEST"
  echo "  ✓ Updated to $LATEST"
fi

# Re-sync platform configs to target project
log ""
log "  Re-syncing $TARGET_DIR ..."
if [ "$SILENT" = "1" ]; then
  bash "$SUPERMAN_DIR/scripts/sync-platforms.sh" "$TARGET_DIR" >/dev/null 2>&1 || true
  log_append "Platform configs synced for $TARGET_DIR"
else
  bash "$SUPERMAN_DIR/scripts/sync-platforms.sh" "$TARGET_DIR"
fi

# Clear version cache so next check-version run re-fetches
rm -f "$TARGET_DIR/.superman/.version-cache"

log "  ✓ Done"
[ "$SILENT" = "1" ] && log_append "Update complete. Cache cleared."
