// PostCompact hook — reads Memory Outline.md from vault and injects it as
// additionalContext into the fresh compacted session.
'use strict';

const fs   = require('fs');
const path = require('path');

const PROJECT_ROOT = 'C:\\Users\\jchildree\\OneDrive - TheIndustrialLaboratoriesCompany\\Desktop\\Projects\\nexus\\apps\\eqms';

const CANDIDATES = [
  path.join(PROJECT_ROOT, 'docs', 'Obsidian Vault', 'eqms', 'Memory Outline.md'),
  path.join(PROJECT_ROOT, 'docs', 'qa-brain', 'Memory Outline.md'),
];

const found = CANDIDATES.find(p => fs.existsSync(p));

if (found) {
  const outline = fs.readFileSync(found, 'utf8');
  process.stdout.write(JSON.stringify({
    hookSpecificOutput: {
      hookEventName:     'PostCompact',
      additionalContext: `## Vault Memory Context (auto-loaded after compaction)\nSource: ${found}\n\n${outline}`,
    },
  }) + '\n');
}
// No outline found → silent exit 0, no injection
