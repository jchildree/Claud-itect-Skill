#!/usr/bin/env node
// prompt-submit-skills -- UserPromptSubmit hook
//
// Injects parallel/subagent skill guidelines when the user's prompt signals
// multi-agent or concurrent work.
//
// Skill order: dispatching-parallel-agents -> subagent-driven-development
//
// Triggers on: parallel, concurrent, subagent(s), in parallel, independent
//              tasks, dispatch, multiple agents, run agents, spawn agents

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

const PARALLEL_PATTERN = /\b(parallel|concurrent|subagents?|dispatch(ing)?|independent tasks?|in parallel|multiple agents?|run agents?|spawn agents?|agent pool|fan.?out)\b/i;

let raw = '';
process.stdin.on('data', chunk => { raw += chunk; });
process.stdin.on('end', () => {
  let data = {};
  try { data = JSON.parse(raw); } catch { /* passthrough */ }

  const prompt = (data.prompt || '').trim();

  const sections = [];

  const karpathy = readSkill('karpathy');
  if (karpathy) sections.push('=== SKILL: karpathy ===\n' + karpathy);

  if (PARALLEL_PATTERN.test(prompt)) {
    const dispatching = readSkill('dispatching-parallel-agents');
    if (dispatching) sections.push('=== SKILL: dispatching-parallel-agents ===\n' + dispatching);

    const sdd = readSkill('subagent-driven-development');
    if (sdd) sections.push('=== SKILL: subagent-driven-development ===\n' + sdd);
  }

  if (sections.length === 0) process.exit(0);

  process.stdout.write(sections.join('\n\n'));
  process.exit(0);
});
