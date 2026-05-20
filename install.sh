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
    local settings="$CLAUDE/settings.json"
    local activate_cmd="node \"$hooks_dir/caveman-activate.js\""
    local tracker_cmd="node \"$hooks_dir/caveman-mode-tracker.js\""

    mkdir -p "$CLAUDE"

    if [ ! -f "$settings" ]; then
        printf '{\n  "hooks": {}\n}\n' > "$settings"
    fi

    # Use node to patch settings.json (avoids jq dependency)
    node - "$settings" "$activate_cmd" "$tracker_cmd" <<'EOF'
const fs = require('fs');
const [,, settingsPath, activateCmd, trackerCmd] = process.argv;
const s = JSON.parse(fs.readFileSync(settingsPath, 'utf8'));
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

# --- Run ---

copy_dir   "$SRC/skills"  "$CLAUDE/skills"  "skills"
copy_files "$SRC/agents"  "$CLAUDE/agents"  "agents"
copy_files "$SRC/hooks"   "$CLAUDE/hooks"   "hooks "

echo "commands-ngon: skipped (NgonENGINE-specific — copy manually if needed)"

if [ "$SKIP_HOOKS" -eq 0 ]; then
    if command -v node &>/dev/null; then
        wire_hooks "$CLAUDE/hooks"
    else
        echo "hooks : Node.js not found — skipped settings.json wiring"
        echo "        Add hooks manually per CLAUDE.md"
    fi
else
    echo "hooks : skipped settings.json wiring (--skip-hooks)"
fi

echo ""
echo "Done. Restart Claude Code to pick up new skills."
