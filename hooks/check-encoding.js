#!/usr/bin/env node
// check-encoding -- PostToolUse hook
// Fires after Write or Edit. Exits 2 (blocks Claude) when the resulting
// file contains em-dashes, en-dashes, smart quotes, or a UTF-8 BOM --
// the most common encoding regressions on Windows PowerShell environments.
//
// checkEncoding(buf) is exported so CI scripts can call it directly
// without simulating a hook invocation.

'use strict';
const fs = require('fs');

// Keys use JS \uXXXX escapes so this source file stays ASCII-clean.
const SUSPECT = {
  '\u2013': 'en-dash (U+2013) -- use ASCII hyphen instead',
  '\u2014': 'em-dash (U+2014) -- use -- or --- instead',
  '\u2018': 'left smart quote (U+2018) -- use ASCII single quote instead',
  '\u2019': 'right smart quote (U+2019) -- use ASCII single quote instead',
  '\u201C': 'left double quote (U+201C) -- use ASCII double quote instead',
  '\u201D': 'right double quote (U+201D) -- use ASCII double quote instead',
};

const BINARY_EXT = /\.(png|jpg|jpeg|gif|ico|webp|bmp|woff2?|ttf|eot|otf|pdf|zip|gz|tar|bin|exe|dll|so|dylib|a|lib|pdb|class|jar|pyc|pyo)$/i;

// Returns array of issue strings. Empty = clean.
function checkEncoding(buf) {
  const issues = [];

  // UTF-8 BOM (EF BB BF) -- breaks JSON.parse and some PowerShell 5.1 parsers
  if (buf.length >= 3 && buf[0] === 0xEF && buf[1] === 0xBB && buf[2] === 0xBF) {
    issues.push('UTF-8 BOM (EF BB BF) -- breaks JSON.parse and PowerShell 5.1 parsers');
  }

  const text = buf.toString('utf8');
  const seen = new Set();
  for (const ch of text) {
    if (SUSPECT[ch] && !seen.has(ch)) {
      seen.add(ch);
      issues.push(SUSPECT[ch]);
    }
  }

  return issues;
}

if (require.main === module) {
  let raw = '';
  process.stdin.on('data', chunk => { raw += chunk; });
  process.stdin.on('end', () => {
    let data;
    try { data = JSON.parse(raw); } catch { process.exit(0); }

    const tool = data.tool_name || '';
    if (tool !== 'Write' && tool !== 'Edit') process.exit(0);

    const filePath = (data.tool_input || {}).file_path;
    if (!filePath || BINARY_EXT.test(filePath)) process.exit(0);

    let buf;
    try { buf = fs.readFileSync(filePath); } catch { process.exit(0); }

    const issues = checkEncoding(buf);

    if (issues.length === 0) process.exit(0);

    process.stdout.write(
      '[check-encoding] ' + filePath + '\n' +
      issues.map(i => '  - ' + i).join('\n') + '\n' +
      'Fix these encoding issues before continuing.\n'
    );
    process.exit(2);
  });
}

module.exports = { checkEncoding };

