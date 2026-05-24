#!/usr/bin/env bash
# sync-platforms.sh — 将 Superman 平台配置同步到目标项目
# Usage: bash scripts/sync-platforms.sh [target-dir]

set -e

SUPERMAN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_DIR="${1:-$(pwd)}"

echo "🦸 Superman Platform Sync"
echo "  Source: $SUPERMAN_DIR"
echo "  Target: $TARGET_DIR"
echo ""

if [ ! -d "$TARGET_DIR" ]; then
  echo "❌ Target directory does not exist: $TARGET_DIR"
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "❌ python3 is required but not found in PATH — install Python 3 to continue"
  exit 1
fi
# On macOS without Xcode CLT, /usr/bin/python3 is Apple's stub — invoking it opens a GUI
# installer dialog. Resolve symlinks (including relative ones with .. components) to catch
# indirect references such as /usr/local/bin/python3 -> /usr/bin/python3.
# NOTE: shell-script shims (pyenv/asdf) are NOT symlinks — pyenv's system fallback is
# handled separately below; invoking an undetected shim at the version-check line would
# trigger the GUI dialog, so we must not rely on silent fall-through.
_resolve_symlinks() {
  local p="$1" link hops=0
  while [ -L "$p" ] && [ "$hops" -lt 20 ]; do
    link=$(readlink "$p")
    case "$link" in
      /*) p="$link" ;;
      *)  p="$(dirname "$p")/$link" ;;
    esac
    hops=$((hops + 1))
  done
  # Normalize accumulated .. components so the result string-equals /usr/bin/python3
  # when that is the true canonical target (e.g. /usr/local/bin/../../usr/bin/python3).
  local _dir _base
  _dir=$(dirname "$p")
  _base=$(basename "$p")
  ( cd -P -- "$_dir" 2>/dev/null && printf '%s/%s\n' "$(pwd -P)" "$_base" ) || printf '%s\n' "$p"
}
if [ "$(uname)" = "Darwin" ] && ! xcode-select -p >/dev/null 2>&1; then
  _py3=$(command -v python3)
  if [ "$(_resolve_symlinks "$_py3")" = "/usr/bin/python3" ]; then
    echo "❌ /usr/bin/python3 is Apple's stub and requires Xcode Command Line Tools — run: xcode-select --install"
    exit 1
  fi
  # pyenv shims are shell scripts, not symlinks — _resolve_symlinks cannot follow them.
  # When pyenv version is 'system', the shim delegates to Apple's stub and triggers the
  # GUI dialog. Detect this case before reaching the version check below.
  if command -v pyenv >/dev/null 2>&1 && [ "$(pyenv version-name 2>/dev/null)" = "system" ]; then
    echo "❌ pyenv python3 version is 'system' — on macOS without CLT this invokes Apple's stub. Run: xcode-select --install, or set a real version: pyenv global <version>"
    exit 1
  fi
fi
if ! python3 -c "import sys; sys.exit(0 if sys.version_info >= (3, 6) else 1)" 2>/dev/null; then
  if [ "$(uname)" = "Darwin" ] && ! xcode-select -p >/dev/null 2>&1; then
    echo "❌ python3 is not functional — check your Python installation. If using Apple's /usr/bin/python3, run: xcode-select --install"
  else
    echo "❌ python3 (>=3.6) is required — $(command -v python3) is not functional or too old. Install Python 3.6+ to continue."
  fi
  exit 1
fi

# 将 plugin.json 的 skill 路径改写为绝对路径后写入目标位置
install_plugin_json() {
  local src="$1"
  local dst="$2"
  python3 - "$SUPERMAN_DIR" "$src" "$dst" << 'PYEOF' || { echo "  ❌ Failed to rewrite paths in $(basename "$src") — aborting sync" >&2; return 1; }
import json, sys, re
superman_dir, src, dst = sys.argv[1], sys.argv[2], sys.argv[3]
with open(src) as f:
    d = json.load(f)
rewrote = 0
for s in d.get("skills", []):
    p = s.get("path")
    if p is None:
        print(f"warning: skill '{s.get('name', '?')}' has no 'path' field — skipped", file=sys.stderr)
        continue
    if p.startswith('/'):
        pass
    elif re.match(r'^[~$]', p):
        print(f"warning: skill '{s.get('name', '?')}' path '{p}' looks like a home/env path — left unchanged", file=sys.stderr)
    else:
        s["path"] = f"{superman_dir}/{p}"
        rewrote += 1
if d.get("skills") and rewrote == 0:
    print(f"warning: no skill paths were rewritten in {src} — check 'path' fields", file=sys.stderr)
if isinstance(d.get("hooks"), str) and not d["hooks"].startswith("/"):
    d["hooks"] = f"{superman_dir}/{d['hooks']}"
elif d.get("hooks") is not None and not isinstance(d["hooks"], str):
    print(f"error: 'hooks' field in {src} is not a string — cannot rewrite paths", file=sys.stderr)
    sys.exit(1)
with open(dst, "w") as f:
    json.dump(d, f, indent=2, ensure_ascii=False)
PYEOF
}

# 将 superman.js 的 SUPERMAN_ROOT 改写为安装时的绝对路径后写入目标位置
install_opencode_js() {
  local src="$1"
  local dst="$2"
  python3 - "$SUPERMAN_DIR" "$src" "$dst" << 'PYEOF' || { echo "  ❌ Failed to inject SUPERMAN_ROOT in $(basename "$src") — aborting sync" >&2; return 1; }
import sys, json
superman_dir, src, dst = sys.argv[1], sys.argv[2], sys.argv[3]
with open(src) as f:
    content = f.read()
sentinel = "const SUPERMAN_ROOT = path.resolve(__dirname, '../..');"
if sentinel not in content:
    print(f"error: SUPERMAN_ROOT sentinel not found in {src} — was the source file reformatted?", file=sys.stderr)
    sys.exit(1)
content = content.replace(
    sentinel,
    "const SUPERMAN_ROOT = " + json.dumps(superman_dir) + ";"
)
with open(dst, 'w') as f:
    f.write(content)
PYEOF
}

# Sync Claude Code
sync_claude() {
  echo "  Syncing Claude Code..."
  mkdir -p "$TARGET_DIR/.claude-plugin"
  install_plugin_json \
    "$SUPERMAN_DIR/platforms/claude/plugin.json" \
    "$TARGET_DIR/.claude-plugin/superman-plugin.json" || return 1

  # Merge CLAUDE.md (append Superman section if not present)
  if [ -f "$TARGET_DIR/CLAUDE.md" ]; then
    if ! grep -q "Superman Plugin" "$TARGET_DIR/CLAUDE.md" 2>/dev/null; then
      echo "" >> "$TARGET_DIR/CLAUDE.md"
      cat "$SUPERMAN_DIR/CLAUDE.md" >> "$TARGET_DIR/CLAUDE.md"
      echo "  ✓ Appended Superman instructions to existing CLAUDE.md"
    else
      echo "  ✓ CLAUDE.md already contains Superman instructions (skipped)"
    fi
  else
    cp "$SUPERMAN_DIR/CLAUDE.md" "$TARGET_DIR/CLAUDE.md"
    echo "  ✓ Created CLAUDE.md"
  fi

  # Install hooks
  if [ -f "$SUPERMAN_DIR/hooks/hooks.json" ]; then
    mkdir -p "$TARGET_DIR/.claude"
    cp "$SUPERMAN_DIR/hooks/hooks.json" "$TARGET_DIR/.claude/hooks.json"
    echo "  ✓ Installed Claude Code hooks"
  fi
}

# Sync Cursor
sync_cursor() {
  echo "  Syncing Cursor..."
  mkdir -p "$TARGET_DIR/.cursor-plugin"
  install_plugin_json \
    "$SUPERMAN_DIR/platforms/cursor/plugin.json" \
    "$TARGET_DIR/.cursor-plugin/superman-plugin.json" || return 1

  if [ ! -f "$TARGET_DIR/.cursorrules" ]; then
    cp "$SUPERMAN_DIR/platforms/cursor/cursorrules.md" "$TARGET_DIR/.cursorrules"
    echo "  ✓ Created .cursorrules"
  else
    echo "  ⚠ .cursorrules already exists — manual merge may be needed"
    echo "    Superman rules are in: $SUPERMAN_DIR/platforms/cursor/cursorrules.md"
  fi

  if [ -f "$SUPERMAN_DIR/hooks/hooks-cursor.json" ]; then
    cp "$SUPERMAN_DIR/hooks/hooks-cursor.json" "$TARGET_DIR/.cursor-hooks.json"
    echo "  ✓ Installed Cursor hooks"
  fi
}

# Sync Gemini CLI
sync_gemini() {
  echo "  Syncing Gemini CLI..."
  if [ -f "$TARGET_DIR/gemini-extension.json" ]; then
    echo "  ⚠ gemini-extension.json exists — overwriting with updated skill paths"
  fi
  install_plugin_json \
    "$SUPERMAN_DIR/platforms/gemini/gemini-extension.json" \
    "$TARGET_DIR/gemini-extension.json" || return 1
  echo "  ✓ Installed gemini-extension.json"

  if [ -f "$TARGET_DIR/GEMINI.md" ]; then
    if ! grep -q "Superman Plugin" "$TARGET_DIR/GEMINI.md" 2>/dev/null; then
      echo "" >> "$TARGET_DIR/GEMINI.md"
      cat "$SUPERMAN_DIR/GEMINI.md" >> "$TARGET_DIR/GEMINI.md"
      echo "  ✓ Appended Superman instructions to existing GEMINI.md"
    else
      echo "  ✓ GEMINI.md already contains Superman instructions (skipped)"
    fi
  else
    cp "$SUPERMAN_DIR/GEMINI.md" "$TARGET_DIR/GEMINI.md"
    echo "  ✓ Created GEMINI.md"
  fi
}

# Sync Codex
sync_codex() {
  echo "  Syncing Codex..."
  mkdir -p "$TARGET_DIR/.codex-plugin"
  install_plugin_json \
    "$SUPERMAN_DIR/platforms/codex/plugin.json" \
    "$TARGET_DIR/.codex-plugin/superman-plugin.json" || return 1

  if [ -f "$TARGET_DIR/AGENTS.md" ]; then
    if ! grep -q "Superman Plugin" "$TARGET_DIR/AGENTS.md" 2>/dev/null; then
      echo "" >> "$TARGET_DIR/AGENTS.md"
      cat "$SUPERMAN_DIR/AGENTS.md" >> "$TARGET_DIR/AGENTS.md"
    fi
  else
    cp "$SUPERMAN_DIR/AGENTS.md" "$TARGET_DIR/AGENTS.md"
  fi
  echo "  ✓ Codex configured"
}

# Sync Copilot
sync_copilot() {
  echo "  Syncing GitHub Copilot..."
  mkdir -p "$TARGET_DIR/.github"
  if [ ! -f "$TARGET_DIR/.github/copilot-instructions.md" ]; then
    cp "$SUPERMAN_DIR/platforms/copilot/copilot-instructions.md" "$TARGET_DIR/.github/copilot-instructions.md"
    echo "  ✓ Created .github/copilot-instructions.md"
  else
    echo "  ⚠ .github/copilot-instructions.md exists — manual merge may be needed"
  fi
}

# Sync OpenCode
sync_opencode() {
  echo "  Syncing OpenCode..."
  mkdir -p "$TARGET_DIR/.opencode/plugins" \
    || { echo "  ❌ Failed to create .opencode/plugins — check permissions"; return 1; }
  install_opencode_js \
    "$SUPERMAN_DIR/platforms/opencode/superman.js" \
    "$TARGET_DIR/.opencode/plugins/superman.js" \
    || { echo "  ❌ OpenCode SUPERMAN_ROOT injection failed — sync skipped"; return 1; }
  echo "  ✓ OpenCode plugin installed"
}

# Detect and sync all present platforms.
# DETECTED counts platforms whose marker files/dirs were found.
# SYNCED counts platforms that were successfully synced.
# The fallback only fires when DETECTED=0 (no platform config found at all),
# not when a platform was detected but its sync failed (e.g. permissions error).
SYNCED=0
DETECTED=0

if [ -d "$TARGET_DIR/.claude" ] || [ -f "$TARGET_DIR/CLAUDE.md" ]; then
  DETECTED=$((DETECTED+1)); sync_claude && SYNCED=$((SYNCED+1))
fi

if [ -d "$TARGET_DIR/.cursor" ] || [ -f "$TARGET_DIR/.cursorrules" ]; then
  DETECTED=$((DETECTED+1)); sync_cursor && SYNCED=$((SYNCED+1))
fi

if [ -f "$TARGET_DIR/GEMINI.md" ]; then
  DETECTED=$((DETECTED+1)); sync_gemini && SYNCED=$((SYNCED+1))
fi

if [ -f "$TARGET_DIR/AGENTS.md" ]; then
  DETECTED=$((DETECTED+1)); sync_codex && SYNCED=$((SYNCED+1))
fi

if [ -d "$TARGET_DIR/.github" ]; then
  DETECTED=$((DETECTED+1)); sync_copilot && SYNCED=$((SYNCED+1))
fi

if [ -d "$TARGET_DIR/.opencode" ]; then
  DETECTED=$((DETECTED+1))
  sync_opencode && SYNCED=$((SYNCED+1))
fi

if [ "$DETECTED" -eq 0 ]; then
  echo "  No platform config detected. Running full sync..."
  if ! sync_claude; then
    echo "❌ Full sync failed — see errors above"
    exit 1
  fi
  SYNCED=1
fi

# Sync CI gates
if [ -f "$SUPERMAN_DIR/ci/gates-default.json" ]; then
  mkdir -p "$TARGET_DIR/.superman/ci"
  cp "$SUPERMAN_DIR/ci/gates-default.json" "$TARGET_DIR/.superman/ci/gates.json"
  echo "  ✓ CI gates installed"
fi

if [ "$DETECTED" -gt 0 ] && [ "$SYNCED" -lt "$DETECTED" ]; then
  echo ""
  echo "❌ $((DETECTED - SYNCED)) platform sync(s) failed — see errors above"
  exit 1
fi

echo ""
echo "✅ Synced $SYNCED platform(s) in $TARGET_DIR"
echo ""
echo "To update later, re-run: bash $SUPERMAN_DIR/scripts/sync-platforms.sh $TARGET_DIR"
