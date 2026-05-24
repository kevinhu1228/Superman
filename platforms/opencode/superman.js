// Superman Plugin for OpenCode
// Registers 21 superman:* skills and hooks via OpenCode Plugin API

const path = require('path');
const fs = require('fs');

const SUPERMAN_ROOT = path.resolve(__dirname, '../..');

const SKILLS = [
  // DEFINE
  { name: 'superman:size-classify', phase: 'define', path: 'skills/define/size-classify/SKILL.md' },
  { name: 'superman:brainstorming', phase: 'define', path: 'skills/define/brainstorming/SKILL.md' },
  { name: 'superman:propose', phase: 'define', path: 'skills/define/propose/SKILL.md' },
  { name: 'superman:spec-review', phase: 'define', path: 'skills/define/spec-review/SKILL.md' },
  { name: 'superman:writing-plans', phase: 'define', path: 'skills/define/writing-plans/SKILL.md' },
  { name: 'superman:archive', phase: 'define', path: 'skills/define/archive/SKILL.md' },
  // EXECUTE
  { name: 'superman:tdd', phase: 'execute', path: 'skills/execute/tdd/SKILL.md' },
  { name: 'superman:subagent-dev', phase: 'execute', path: 'skills/execute/subagent-dev/SKILL.md' },
  { name: 'superman:incremental-impl', phase: 'execute', path: 'skills/execute/incremental-impl/SKILL.md' },
  { name: 'superman:security', phase: 'execute', path: 'skills/execute/security/SKILL.md' },
  { name: 'superman:api-design', phase: 'execute', path: 'skills/execute/api-design/SKILL.md' },
  { name: 'superman:frontend-ui', phase: 'execute', path: 'skills/execute/frontend-ui/SKILL.md' },
  { name: 'superman:debugging', phase: 'execute', path: 'skills/execute/debugging/SKILL.md' },
  { name: 'superman:worktrees', phase: 'execute', path: 'skills/execute/worktrees/SKILL.md' },
  // VERIFY
  { name: 'superman:code-review', phase: 'verify', path: 'skills/verify/code-review/SKILL.md' },
  { name: 'superman:production-ready', phase: 'verify', path: 'skills/verify/production-ready/SKILL.md' },
  { name: 'superman:spec-satisfied', phase: 'verify', path: 'skills/verify/spec-satisfied/SKILL.md' },
  { name: 'superman:verification', phase: 'verify', path: 'skills/verify/verification/SKILL.md' },
  { name: 'superman:git-ship', phase: 'verify', path: 'skills/verify/git-ship/SKILL.md' },
  { name: 'superman:ci-gates', phase: 'verify', path: 'skills/verify/ci-gates/SKILL.md' },
  { name: 'superman:retrospective', phase: 'verify', path: 'skills/verify/retrospective/SKILL.md' },
];

function loadSkill(skillPath) {
  const fullPath = path.join(SUPERMAN_ROOT, skillPath);
  if (!fs.existsSync(fullPath)) return null;
  return fs.readFileSync(fullPath, 'utf8');
}

function register(plugin) {
  // Register each skill as a slash command
  for (const skill of SKILLS) {
    plugin.registerCommand(skill.name, {
      description: `Superman ${skill.phase} skill: ${skill.name}`,
      execute: async (context) => {
        const content = loadSkill(skill.path);
        if (!content) {
          context.output(`Error: skill file not found at ${skill.path}`);
          return;
        }
        context.injectSystemPrompt(content);
        context.output(`Loaded skill: ${skill.name}`);
      }
    });
  }

  // Session start hook: restore superman context
  plugin.on('session:start', async (context) => {
    if (context.workspaceRoot == null) return;
    const requirementsPath = path.join(context.workspaceRoot, '.superman/context/requirements.md');
    if (!fs.existsSync(requirementsPath)) return;

    const contextFiles = [
      '.superman/context/requirements.md',
      '.superman/context/decisions.md',
      '.superman/context/size-classification.md',
    ];

    let restoredContext = '# Superman Context (Restored)\n\n';
    for (const file of contextFiles) {
      const fullPath = path.join(context.workspaceRoot, file);
      if (fs.existsSync(fullPath)) {
        restoredContext += `## ${file}\n\n${fs.readFileSync(fullPath, 'utf8')}\n\n`;
      }
    }

    context.injectSystemPrompt(restoredContext);
    context.output('Superman: Context restored from .superman/');
  });
}

module.exports = { register, SKILLS };
