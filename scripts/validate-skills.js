#!/usr/bin/env node
// validate-skills.js — validate SKILL.md structure for all skills/

const fs = require('fs');
const path = require('path');

const PHASES = ['define', 'execute', 'verify'];

let errors = [];
let checked = 0;

for (const phase of PHASES) {
  const phaseDir = path.join(__dirname, '..', 'skills', phase);
  if (!fs.existsSync(phaseDir)) {
    errors.push(`Missing phase directory: skills/${phase}`);
    continue;
  }
  const entries = fs.readdirSync(phaseDir);
  const skills = entries.filter(e => {
    const stat = fs.statSync(path.join(phaseDir, e));
    return stat.isDirectory();
  });
  for (const skill of skills) {
    const skillFile = path.join(phaseDir, skill, 'SKILL.md');
    if (!fs.existsSync(skillFile)) {
      errors.push(`Missing SKILL.md: skills/${phase}/${skill}/SKILL.md`);
      continue;
    }
    const content = fs.readFileSync(skillFile, 'utf8');
    if (!content.startsWith('# ')) {
      errors.push(`${skillFile}: must start with a level-1 heading`);
    }
    const hasGoal = content.includes('**Goal**') || content.includes('## Goal');
    if (!hasGoal) {
      errors.push(`${skillFile}: missing Goal section (**Goal** or ## Goal)`);
    }
    const hasTrigger = content.includes('**Trigger**') || content.includes('## Trigger');
    if (!hasTrigger) {
      errors.push(`${skillFile}: missing Trigger section (**Trigger** or ## Trigger)`);
    }
    checked++;
  }
}

if (errors.length > 0) {
  console.error(`\n❌ Validation failed (${errors.length} errors):\n`);
  errors.forEach(e => console.error(`  • ${e}`));
  process.exit(1);
} else {
  console.log(`\n✅ All ${checked} skills validated successfully.\n`);
}
