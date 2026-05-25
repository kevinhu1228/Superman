#!/usr/bin/env node
'use strict';

// Runs after `npm install -g superman-plugin`.
// Checks whether the npm global bin directory is in PATH and prints
// OS-specific instructions to fix it if not — the most common reason
// `superman` is not found after installation, especially on macOS when
// Claude Code is launched as a GUI app (which skips ~/.zshrc).

const { execSync } = require('child_process');
const path = require('path');
const os = require('os');

// Only relevant for global installs
if (!process.env.npm_config_global) process.exit(0);

function getNpmGlobalBin() {
  try {
    const prefix = execSync('npm config get prefix', { encoding: 'utf8' }).trim();
    return path.join(prefix, 'bin');
  } catch {
    return null;
  }
}

function isInPath(dir) {
  if (!dir || !process.env.PATH) return false;
  const sep = process.platform === 'win32' ? ';' : ':';
  return process.env.PATH.split(sep).some(p => p === dir || p === dir + path.sep);
}

const binDir = getNpmGlobalBin();
const inPath = isInPath(binDir);

console.log('\n🦸 Superman installed!');

if (inPath) {
  console.log('  ✓ superman command is ready.');
  console.log('  Run: superman [target-dir]\n');
  process.exit(0);
}

console.log('  ⚠ The npm global bin directory is not in your current PATH.');
console.log(`  npm global bin: ${binDir || '(could not detect)'}\n`);

const platform = os.platform();

if (platform === 'darwin') {
  const zprofile = path.join(os.homedir(), '.zprofile');
  console.log('  macOS fix — add to ~/.zprofile (sourced for both terminal and GUI apps):');
  console.log(`    echo 'export PATH="${binDir}:$PATH"' >> ${zprofile}`);
  console.log(`    source ${zprofile}`);
  console.log('');
  console.log('  Note: ~/.zshrc is NOT sourced when apps like Claude Code are launched');
  console.log('  from the Dock or Spotlight — use ~/.zprofile instead.');
} else if (platform === 'linux') {
  const profile = path.join(os.homedir(), '.profile');
  console.log('  Linux fix — add to ~/.profile:');
  console.log(`    echo 'export PATH="${binDir}:$PATH"' >> ${profile}`);
  console.log(`    source ${profile}`);
} else if (platform === 'win32') {
  console.log('  Windows fix — add the npm global bin to your system PATH:');
  console.log(`    setx PATH "%PATH%;${binDir}"`);
  console.log('  Then restart your terminal.');
}

console.log('\n  After updating PATH, run: superman [target-dir]\n');
