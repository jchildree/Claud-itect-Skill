// PreCompact hook — reads Claude memory files and writes Memory Outline.md to
// the vault before the conversation context is discarded by compaction.
'use strict';

const fs   = require('fs');
const path = require('path');

const PROJECT_ROOT = 'C:\\Users\\jchildree\\OneDrive - TheIndustrialLaboratoriesCompany\\Desktop\\Projects\\nexus\\apps\\eqms';
const MEM_DIR      = 'C:\\Users\\jchildree\\.claude\\projects\\C--Users-jchildree-OneDrive---TheIndustrialLaboratoriesCompany-Desktop-Projects-nexus-apps-eqms\\memory';

const VAULT_CANDIDATES = [
  path.join(PROJECT_ROOT, 'docs', 'Obsidian Vault', 'eqms'),
  path.join(PROJECT_ROOT, 'docs', 'qa-brain'),
];

const TYPE_MAP = {
  user:      'User Profile',
  feedback:  'Behavioral Guidelines',
  project:   'Project Context',
  reference: 'References',
};

function done(msg) {
  process.stdout.write(JSON.stringify({ systemMessage: msg }) + '\n');
}

if (!fs.existsSync(MEM_DIR)) {
  done(`[memory-to-vault] Memory dir not found: ${MEM_DIR}`);
  process.exit(0);
}

const sections = {
  'User Profile':          [],
  'Behavioral Guidelines': [],
  'Project Context':       [],
  'References':            [],
};

const files = fs.readdirSync(MEM_DIR)
  .filter(n => n.endsWith('.md') && n !== 'MEMORY.md');

for (const name of files) {
  const raw = fs.readFileSync(path.join(MEM_DIR, name), 'utf8');
  if (!raw.trim()) continue;

  // Parse type from YAML frontmatter
  let fmType = 'project';
  const fmMatch = raw.match(/^---\s*\n([\s\S]*?)\n---/);
  if (fmMatch) {
    const tm = fmMatch[1].match(/type:\s*(\S+)/);
    if (tm) fmType = tm[1].trim();
  }

  // Body after frontmatter
  const body = raw.replace(/^---[\s\S]*?---\s*\n/, '').trim();
  if (!body) continue;

  const lines   = body.split('\n').filter(l => l.trim());
  let   summary = lines.slice(0, 4).join(' ').replace(/\s+/g, ' ');
  if (summary.length > 220) summary = summary.slice(0, 217) + '...';

  const bucket = TYPE_MAP[fmType] || 'Project Context';
  sections[bucket].push(`- **${path.basename(name, '.md')}**: ${summary}`);
}

// Build markdown outline
const date  = new Date().toISOString().slice(0, 10);
const lines = [
  '# Memory Outline',
  '',
  `Generated: ${date}`,
  `Source: ${MEM_DIR}`,
  '',
];

for (const [heading, entries] of Object.entries(sections)) {
  lines.push(`## ${heading}`);
  if (entries.length) {
    lines.push(...entries);
  } else {
    lines.push('_(none)_');
  }
  lines.push('');
}

lines.push('## Related');
lines.push('[[Claude-ITect-Skill Update Index]]');

const outline = lines.join('\n');

// Resolve vault dir
let vaultDir = VAULT_CANDIDATES.find(p => fs.existsSync(p));
if (!vaultDir) {
  fs.mkdirSync(VAULT_CANDIDATES[0], { recursive: true });
  vaultDir = VAULT_CANDIDATES[0];
}

const outFile = path.join(vaultDir, 'Memory Outline.md');
fs.writeFileSync(outFile, outline, 'utf8');

done(`[memory-to-vault] Archived to: ${outFile} (${files.length} memory files)`);
