#!/usr/bin/env node
// validate-spec.js — openspec validate CLI: programmatic spec enforcement

const fs = require('fs');
const path = require('path');

const REQUIRED_SECTIONS = [
  {
    patterns: ['## Goal', '**Goal**', '## 目标', '**目标**'],
    label: 'Goal',
  },
  {
    patterns: [
      '## Requirements', '## 需求', '## Features', '## 功能',
      '## Scope', '## 范围', '## What',
    ],
    label: 'Requirements/Scope',
  },
];

// \b word-boundary anchors are ineffective around CJK characters (they are \W,
// so \b adjacent to CJK is only true when preceded by a \w char — not at line
// start or after spaces). Chinese tokens are matched as plain substrings instead.
const PLACEHOLDER_RE = /\bTBD\b|\bTODO\b|\bFIXME\b|【待定】|【TODO】|(?:^|[\s:：])待定(?:[\s，。！？、：；]|$)|稍后补充/i;

const SPEC_REVIEW_PASSED_RE = /Spec Review: PASSED/;

const DEFAULT_PATHS = [
  '.superman/phases/define/spec.md',
  '.superman/context/requirements.md',
];

function validate(filePath, opts = {}) {
  const errors = [];
  const warnings = [];

  if (!fs.existsSync(filePath)) {
    return null; // skip missing
  }

  const content = fs.readFileSync(filePath, 'utf8');
  const lines = content.split('\n');

  if (!content.trimStart().startsWith('#')) {
    errors.push('Spec must start with a markdown heading (# Title)');
  }

  for (const section of REQUIRED_SECTIONS) {
    if (!section.patterns.some(p => content.includes(p))) {
      errors.push(
        `Missing required section: ${section.label} — add one of: ${section.patterns.join(', ')}`
      );
    }
  }

  lines.forEach((line, i) => {
    if (PLACEHOLDER_RE.test(line)) {
      errors.push(`Line ${i + 1}: unresolved placeholder → "${line.trim()}"`);
    }
  });

  const nonEmpty = lines.filter(l => l.trim()).length;
  if (nonEmpty < 8) {
    warnings.push(`Spec is very short (${nonEmpty} non-empty lines) — may be incomplete`);
  }

  if (!SPEC_REVIEW_PASSED_RE.test(content)) {
    if (opts.strict) {
      errors.push('Missing "Spec Review: PASSED" marker — run superman:spec-review first (required in --strict mode)');
    } else {
      warnings.push('No "Spec Review: PASSED" marker — run superman:spec-review before using this spec for planning');
    }
  }

  return { filePath, errors, warnings };
}

function main() {
  const args = process.argv.slice(2);
  const strict = args.includes('--strict');
  const files = args.filter(a => !a.startsWith('--'));

  const targets = files.length > 0
    ? files
    : DEFAULT_PATHS.map(p => path.join(process.cwd(), p));

  let totalErrors = 0;
  let checked = 0;

  for (const target of targets) {
    const result = validate(target, { strict });
    if (result === null) continue;

    checked++;
    const rel = path.relative(process.cwd(), result.filePath);

    if (result.errors.length === 0 && result.warnings.length === 0) {
      console.log(`✅ ${rel}`);
    } else {
      if (result.errors.length > 0) {
        console.error(`\n❌ ${rel} — ${result.errors.length} error(s):`);
        result.errors.forEach(e => console.error(`   • ${e}`));
        totalErrors += result.errors.length;
      }
      if (result.warnings.length > 0) {
        console.warn(`\n⚠️  ${rel} — ${result.warnings.length} warning(s):`);
        result.warnings.forEach(w => console.warn(`   • ${w}`));
      }
    }
  }

  if (checked === 0) {
    console.log('ℹ️  No spec files found — skipping validation.');
    process.exit(0);
  }

  if (totalErrors > 0) {
    console.error(`\n❌ Spec validation failed (${totalErrors} error(s) across ${checked} file(s)).\n`);
    process.exit(1);
  }

  console.log(`\n✅ ${checked} spec file(s) validated successfully.\n`);
}

main();
