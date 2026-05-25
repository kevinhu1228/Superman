#!/usr/bin/env bash
# superman init — inject Superman configuration into target project

set -e

SUPERMAN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_DIR="${1:-$(pwd)}"

echo "🦸 Superman Plugin Initializer"
echo "  Source: $SUPERMAN_DIR"
echo "  Target: $TARGET_DIR"
echo ""

# Create .superman/ directory structure
mkdir -p "$TARGET_DIR/.superman/context"
mkdir -p "$TARGET_DIR/.superman/phases/define"
mkdir -p "$TARGET_DIR/.superman/phases/execute"
mkdir -p "$TARGET_DIR/.superman/phases/verify"
mkdir -p "$TARGET_DIR/.superman/archive"
mkdir -p "$TARGET_DIR/.superman/ci"
echo "$SUPERMAN_DIR" > "$TARGET_DIR/.superman/.superman-dir"
echo "  ✓ Created .superman/ structure"
echo ""

# Install platform configs (delegated to sync-platforms.sh)
bash "$SUPERMAN_DIR/scripts/sync-platforms.sh" "$TARGET_DIR"

echo "Next steps:"
echo "  1. Add to .gitignore: .superman/context/  .superman/phases/  .superman/archive/"
echo "                        .superman/.superman-dir  .superman/.version-cache  .superman/.update-log"
echo "  2. Start with: 'Let's work on [your requirement]'"
echo "  3. Superman will classify the requirement and guide you through the workflow"
