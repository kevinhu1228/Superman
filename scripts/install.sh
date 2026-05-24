#!/usr/bin/env bash
# superman init — 将 Superman 配置注入目标项目

set -e

SUPERMAN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_DIR="${1:-$(pwd)}"

echo "🦸 Superman Plugin Initializer"
echo "  Source: $SUPERMAN_DIR"
echo "  Target: $TARGET_DIR"
echo ""

# 创建 .superman/ 目录结构
mkdir -p "$TARGET_DIR/.superman/context"
mkdir -p "$TARGET_DIR/.superman/phases/define"
mkdir -p "$TARGET_DIR/.superman/phases/execute"
mkdir -p "$TARGET_DIR/.superman/phases/verify"
mkdir -p "$TARGET_DIR/.superman/archive"
mkdir -p "$TARGET_DIR/.superman/ci"
echo "  ✓ Created .superman/ structure"
echo ""

# 安装各平台配置（委托给 sync-platforms.sh）
bash "$SUPERMAN_DIR/scripts/sync-platforms.sh" "$TARGET_DIR"

echo "Next steps:"
echo "  1. Add to .gitignore: .superman/context/  .superman/phases/  .superman/archive/"
echo "  2. Start with: 'Let's work on [your requirement]'"
echo "  3. Superman will classify the requirement and guide you through the workflow"
