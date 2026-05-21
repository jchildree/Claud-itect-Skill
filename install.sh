#!/usr/bin/env bash
# Claude-ITect-Skill v2.0 — Unix Install Script
# Installs skills, agents, hooks and wires caveman hooks into settings.json.
#
# Usage:
#   ./install.sh                       # installs into current directory
#   ./install.sh /path/to/project      # installs into specified project
#   ./install.sh --force               # overwrite existing skills
#   ./install.sh --skip-hooks          # skip settings.json hook wiring

set -euo pipefail

FORCE=0
SKIP_HOOKS=0
PROJECT_PATH="$(pwd)"

for arg in "$@"; do
    case $arg in
        --force)       FORCE=1 ;;
        --skip-hooks)  SKIP_HOOKS=1 ;;
        *)             PROJECT_PATH="$arg" ;;
    esac
done

SRC="$(cd "$(dirname "$0")" && pwd)"
CLAUDE="$PROJECT_PATH/.claude"

copy_dir() {
    local from="$1" to="$2" label="$3"
    [ -d "$from" ] || return 0
    mkdir -p "$to"
    local copied=0 skipped=0
    for dir in "$from"/*/; do
        local name; name="$(basename "$dir")"
        local target="$to/$name"
        if [ -d "$target" ] && [ "$FORCE" -eq 0 ]; then
            skipped=$((skipped + 1))
        else
            cp -r "$dir" "$to/"
            copied=$((copied + 1))
        fi
    done
    printf "%-10s installed=%-3d skipped=%d\n" "$label" "$copied" "$skipped"
}

copy_files() {
    local from="$1" to="$2" label="$3"
    [ -d "$from" ] || return 0
    mkdir -p "$to"
    cp -r "$from"/. "$to/"
    echo "$label : copied"
}

wire_hooks() {
    local hooks_dir="$1"
    local settings_path="$2"
    local activate_cmd="node \"$hooks_dir/caveman-activate.js\""
    local tracker_cmd="node \"$hooks_dir/caveman-mode-tracker.js\""

    # Use node to patch settings.json (avoids jq dependency)
    node - "$settings_path" "$activate_cmd" "$tracker_cmd" <<'EOF'
const fs = require('fs');
const [,, settingsPath, activateCmd, trackerCmd] = process.argv;

let s;
try {
    s = JSON.parse(fs.readFileSync(settingsPath, 'utf8'));
} catch (e) {
    s = { hooks: {} };
}
s.hooks = s.hooks || {};

function hasHook(arr, cmd) {
    return (arr || []).some(e => (e.hooks || []).some(h => h.command === cmd));
}

function addHook(s, event, cmd) {
    s.hooks[event] = s.hooks[event] || [];
    if (!hasHook(s.hooks[event], cmd)) {
        s.hooks[event].push({ hooks: [{ type: 'command', command: cmd, timeout: 5000 }] });
        return true;
    }
    return false;
}

const a = addHook(s, 'SessionStart',     activateCmd);
const b = addHook(s, 'UserPromptSubmit', trackerCmd);

fs.writeFileSync(settingsPath, JSON.stringify(s, null, 2) + '\n', 'utf8');
process.stdout.write(
    (a ? 'wired SessionStart -> caveman-activate.js\n' : 'SessionStart already wired\n') +
    (b ? 'wired UserPromptSubmit -> caveman-mode-tracker.js\n' : 'UserPromptSubmit already wired\n')
);
EOF
}

# Prerequisite check
if ! command -v node &>/dev/null; then
    echo ""
    echo "ERROR: Node.js is required for caveman hooks but was not found."
    echo "       Download it from https://nodejs.org (LTS version recommended)."
    echo "       Re-run this installer after installing Node.js."
    echo ""
    exit 1
fi

echo ""
echo "Installing into: $PROJECT_PATH"
echo ""

copy_dir   "$SRC/skills"  "$CLAUDE/skills"  "skills"
copy_files "$SRC/agents"  "$CLAUDE/agents"  "agents"
copy_files "$SRC/hooks"   "$CLAUDE/hooks"   "hooks "

if [ -d "$SRC/commands-ngon" ]; then
    echo "commands-ngon: skipped (NgonENGINE-specific — copy manually if needed)"
fi

if [ "$SKIP_HOOKS" -eq 0 ]; then
    wire_hooks "$CLAUDE/hooks" "$CLAUDE/settings.json"
else
    echo "hooks : skipped settings.json wiring (--skip-hooks)"
fi

echo ""
echo "Done. Restart Claude Code to pick up new skills."
