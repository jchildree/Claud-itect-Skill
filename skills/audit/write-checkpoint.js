#!/usr/bin/env node
// Appends one checkpoint line to the audit progress file.
// Usage: node write-checkpoint.js <progress-file> <skill> <status> <findings-count>
const fs = require('fs');
const [,, file, skill, status, findings] = process.argv;
const line = JSON.stringify({
  skill,
  status,
  findings: Number(findings),
  ts: new Date().toISOString()
}) + '\n';
fs.appendFileSync(file, line, 'utf8');
