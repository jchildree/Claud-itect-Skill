#!/usr/bin/env node
// post-tool-skills -- PostToolUse hook
//
// Injects completion/wrap-up skill guidelines after tool execution.
// Skill order: verification-before-completion -> finishing-a-development-branch -> safe-push
//
// Conditions:
//   verification-before-completion  -- Write or Edit tool calls
//   finishing-a-development-branch  -- Bash calls containing git commit or git merge
//   safe-push                       -- Bash calls containing git push

'use strict';
const fs = require('fs');
const path = require('path');

const skillsDir = path.join(__dirname, '..', 'skills');

function stripFrontmatter(content) {
  return content.replace(/^---[\s\S]*?---\s*/, '');
}

function readSkill(name) {
  try {
    const raw = fs.readFileSync(path.join(skillsDir, name, 'SKILL.md'), 'utf8');
    return stripFrontmatter(raw).trim();
  } catch {
    return null;
  }
}

let raw = '';
process.stdin.on('data', chunk => { raw += chunk; });
process.stdin.on('end', () => {
  let data = {};
  try { data = JSON.parse(raw); } catch { /* passthrough */ }

  const tool = data.tool_name || '';
  const command = (data.tool_input || {}).command || '';
  const isWriteOrEdit = tool === 'Write' || tool === 'Edit';
  const isBash = tool === 'Bash';
  const isGitCommitOrMerge = isBash && /git\s+(commit|merge)\b/.test(command);
  const isGitPush = isBash && /git\s+push\b/.test(command);

  const sections = [];

  if (isWriteOrEdit) {
    const skill = readSkill('verification-before-completion');
    if (skill) sections.push('=== SKILL: verification-before-completion ===\n' + skill);
  }

  if (isGitCommitOrMerge) {
    const skill = readSkill('finishing-a-development-branch');
    if (skill) sections.push('=== SKILL: finishing-a-development-branch ===\n' + skill);
  }

  if (isGitPush) {
    const skill = readSkill('safe-push');
    if (skill) sections.push('=== SKILL: safe-push ===\n' + skill);
  }

  if (sections.length === 0) process.exit(0);

  process.stdout.write(sections.join('\n\n'));
  process.exit(0);
});
