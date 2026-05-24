'use strict';
// SessionStart hook: inject vault index as plain-text context.
// Scans docs/Obsidian Vault/ for an Index.md and emits its content.
// Graceful fail: any error -> empty output, session continues.

const fs = require('fs');
const path = require('path');

(function main() {
    try {
        const projectRoot = process.cwd();
        const vaultBase = path.join(projectRoot, 'docs', 'Obsidian Vault');

        if (!fs.existsSync(vaultBase)) {
            process.stdout.write('');
            return;
        }

        // Find first subdirectory in docs/Obsidian Vault/
        let vaultDir = null;
        try {
            const entries = fs.readdirSync(vaultBase, { withFileTypes: true });
            for (const e of entries) {
                if (e.isDirectory()) {
                    vaultDir = path.join(vaultBase, e.name);
                    break;
                }
            }
        } catch (_) {
            process.stdout.write('');
            return;
        }

        if (!vaultDir) {
            process.stdout.write('');
            return;
        }

        // Find Index.md (case-insensitive match ending with "Index.md")
        let indexPath = null;
        try {
            const files = fs.readdirSync(vaultDir);
            for (const f of files) {
                if (f.toLowerCase().endsWith('index.md')) {
                    indexPath = path.join(vaultDir, f);
                    break;
                }
            }
        } catch (_) {
            process.stdout.write('');
            return;
        }

        if (!indexPath || !fs.existsSync(indexPath)) {
            process.stdout.write('');
            return;
        }

        // Read index -- cap at 8KB to limit context injection
        const MAX_BYTES = 8192;
        let content = '';
        try {
            const raw = fs.readFileSync(indexPath, 'utf8');
            content = raw.length > MAX_BYTES
                ? raw.slice(0, MAX_BYTES) + '\n[wiki index truncated at 8KB]'
                : raw;
        } catch (_) {
            process.stdout.write('');
            return;
        }

        const header = '## Project Wiki Index\n\n';
        process.stdout.write(header + content);
    } catch (_) {
        // Outer safety net: hook failure must never crash the session
        process.stdout.write('');
    }
}());
