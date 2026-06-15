#!/usr/bin/env node
// pre-tool-skills -- PreToolUse hook
//
// Injects active skill guidelines into context before tool execution.
// Skill order: karpathy -> karpathy-guidelines -> brainstorming (Write/Edit only)
//              -> writing-skills (Write/Edit on SKILL.md files only)

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
  const filePath = (data.tool_input || {}).file_path || '';
  const isWriteOrEdit = tool === 'Write' || tool === 'Edit';
  const isSkillFile = /[/\\]skills[/\\]/.test(filePath) || path.basename(filePath) === 'SKILL.md';

  const sections = [];

  const karpathy = readSkill('karpathy');
  if (karpathy) sections.push('=== SKILL: karpathy ===\n' + karpathy);

  const guidelines = readSkill('karpathy-guidelines');
  if (guidelines) sections.push('=== SKILL: karpathy-guidelines ===\n' + guidelines);

  if (isWriteOrEdit && !isSkillFile) {
    const brainstorming = readSkill('brainstorming');
    if (brainstorming) sections.push('=== SKILL: brainstorming ===\n' + brainstorming);

    const writingPlans = readSkill('writing-plans');
    if (writingPlans) sections.push('=== SKILL: writing-plans ===\n' + writingPlans);
  }

  if (isWriteOrEdit && isSkillFile) {
    const writingSkills = readSkill('writing-skills');
    if (writingSkills) sections.push('=== SKILL: writing-skills ===\n' + writingSkills);
  }

  if (sections.length === 0) process.exit(0);

  process.stdout.write(sections.join('\n\n'));
  process.exit(0);
});
