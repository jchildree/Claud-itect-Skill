#!/usr/bin/env node
// skill-metadata-loader -- Claude Code SessionStart hook
//
// Reads YAML frontmatter from all installed SKILL.md files and injects
// a compact skills registry into session context so Claude knows every
// available skill at session start without reading individual files.
//
// Output contract (SessionStart):
//   Plain text: the skills registry (markdown-formatted)
// On any failure: outputs empty string and exits 0 (never crashes the session).

'use strict';
const fs = require('fs');
const path = require('path');

// Skills live at <hook-dir>/../skills/*/SKILL.md
const SKILLS_DIR = path.resolve(__dirname, '..', 'skills');

// Parse YAML frontmatter between the first pair of --- markers.
// Returns a plain object with string/array values. Never throws.
function parseFrontmatter(content) {
  const match = content.match(/^---\r?\n([\s\S]*?)\r?\n---/);
  if (!match) return null;

  const block = match[1];
  const result = {};
  const lines = block.split(/\r?\n/);
  let i = 0;

  while (i < lines.length) {
    const line = lines[i];

    // Skip empty lines
    if (!line.trim()) { i++; continue; }

    // Key: value (scalar)
    const scalarMatch = line.match(/^(\w[\w-]*):\s+(.+)/);
    if (scalarMatch) {
      let val = scalarMatch[2].trim();
      // Strip surrounding quotes
      if ((val.startsWith('"') && val.endsWith('"')) ||
          (val.startsWith("'") && val.endsWith("'"))) {
        val = val.slice(1, -1);
      }
      // Multi-line folded scalar (>) -- collect continuation lines
      if (val === '>') {
        const parts = [];
        i++;
        while (i < lines.length && (lines[i].startsWith('  ') || lines[i].trim() === '')) {
          parts.push(lines[i].trim());
          i++;
        }
        result[scalarMatch[1]] = parts.filter(Boolean).join(' ');
        continue;
      }
      result[scalarMatch[1]] = val;
      i++;
      continue;
    }

    // Key: (block sequence follows)
    const seqKeyMatch = line.match(/^(\w[\w-]*):\s*$/);
    if (seqKeyMatch) {
      const items = [];
      i++;
      while (i < lines.length && lines[i].match(/^\s+-\s+/)) {
        const item = lines[i].replace(/^\s+-\s+/, '').trim();
        // Strip surrounding quotes from item
        let val = item;
        if ((val.startsWith('"') && val.endsWith('"')) ||
            (val.startsWith("'") && val.endsWith("'"))) {
          val = val.slice(1, -1);
        }
        items.push(val);
        i++;
      }
      result[seqKeyMatch[1]] = items;
      continue;
    }

    i++;
  }

  return result;
}

// Load all skills from the skills directory.
// Returns array of {name, category, execution_speed, token_efficiency, triggers}.
function loadSkills(skillsDir) {
  let entries;
  try {
    entries = fs.readdirSync(skillsDir, { withFileTypes: true });
  } catch (e) {
    return null; // skills dir doesn't exist
  }

  const skills = [];

  for (const entry of entries) {
    if (!entry.isDirectory()) continue;

    const skillPath = path.join(skillsDir, entry.name, 'SKILL.md');
    let content;
    try {
      content = fs.readFileSync(skillPath, 'utf8');
    } catch (e) {
      continue; // unreadable -- skip
    }

    const fm = parseFrontmatter(content);
    if (!fm || !fm.name) continue; // malformed -- skip

    skills.push({
      name: fm.name,
      category: fm.category || 'misc',
      execution_speed: fm.execution_speed || '',
      token_efficiency: fm.token_efficiency || '',
      triggers: Array.isArray(fm.triggers) ? fm.triggers : [],
    });
  }

  return skills;
}

// Build the compact registry string.
// Format per line: <name> [<category>|<speed>|<efficiency>] triggers: t1, t2, t3
// Token budget: ~150-180 tokens. Cap triggers at 3 per skill.
function buildRegistry(skills) {
  // Sort by category then name
  skills.sort((a, b) => {
    if (a.category < b.category) return -1;
    if (a.category > b.category) return 1;
    if (a.name < b.name) return -1;
    if (a.name > b.name) return 1;
    return 0;
  });

  const header = '## Skills Registry (' + skills.length + ' skills)';
  const lines = [header];

  for (const s of skills) {
    const badge = '[' + s.category + '|' + s.execution_speed + '|' + s.token_efficiency + ']';
    const triggerList = s.triggers.slice(0, 3).join(', ');
    const triggerPart = triggerList ? ' triggers: ' + triggerList : '';
    lines.push(s.name + ' ' + badge + triggerPart);
  }

  return lines.join('\n');
}

// Main
(function main() {
  try {
    const skills = loadSkills(SKILLS_DIR);

    // Skills dir missing -- exit gracefully
    if (skills === null) {
      process.stdout.write('');
      process.exit(0);
    }

    // No skills found -- still exit cleanly
    if (skills.length === 0) {
      process.stdout.write('');
      process.exit(0);
    }

    const registry = buildRegistry(skills);

    process.stdout.write(registry);
  } catch (e) {
    // Never crash the session
    process.stdout.write('');
    process.exit(0);
  }
})();
