#!/usr/bin/env bash
# Claude-ITect-Skill v2.0 -- Unix Install Script
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

    node - "$hooks_dir" "$settings_path" "$SRC/pack-manifest.json" <<'EOF'
const fs = require('fs');
const [,, hooksDir, settingsPath, manifestPath] = process.argv;
const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));

let s;
try {
    s = JSON.parse(fs.readFileSync(settingsPath, 'utf8'));
} catch (e) {
    s = { hooks: {} };
}
s.hooks = s.hooks || {};

function hasHook(arr, cmd) {
    return (arr || []).some(function(e) {
        return (e.hooks || []).some(function(h) { return h.command === cmd; });
    });
}

manifest.hookWiring.forEach(function(entry) {
    const cmd = 'node "' + hooksDir + '/' + entry.file + '"';
    s.hooks[entry.event] = s.hooks[entry.event] || [];
    if (!hasHook(s.hooks[entry.event], cmd)) {
        const hookEntry = { hooks: [{ type: 'command', command: cmd, timeout: 5000 }] };
        if (entry.matcher) hookEntry.matcher = entry.matcher;
        s.hooks[entry.event].push(hookEntry);
        process.stdout.write('wired ' + entry.event + ' -> ' + entry.file + '\n');
    } else {
        process.stdout.write(entry.event + ' already wired\n');
    }
});

fs.writeFileSync(settingsPath, JSON.stringify(s, null, 2) + '\n', 'utf8');
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

# Captain Caveman entrance sound
echo ""
echo "Captain Caveman: Installing entrance sound..."
CC_ASSETS_DIR="$CLAUDE/assets"
CC_STATE_DIR="$CLAUDE/state"
[ -d "$CC_ASSETS_DIR" ] || mkdir -p "$CC_ASSETS_DIR"
[ -d "$CC_STATE_DIR"  ] || mkdir -p "$CC_STATE_DIR"

CC_HOOK_SRC="$SRC/hooks/captain-caveman.js"
CC_HOOK_DEST="$CLAUDE/hooks/captain-caveman.js"

if [ -f "$CC_HOOK_SRC" ]; then
    cp "$CC_HOOK_SRC" "$CC_HOOK_DEST"
    printf "%-10s installed=%-3d skipped=%d\n" "captain" 1 0

    CC_SOUND_SRC="$SRC/assets/captain-caveman.wav"
    CC_SOUND_DEST="$CC_ASSETS_DIR/captain-caveman.wav"
    if [ -f "$CC_SOUND_SRC" ]; then
        cp "$CC_SOUND_SRC" "$CC_SOUND_DEST"
        echo "assets   : captain-caveman.wav copied"
    else
        echo "assets   : captain-caveman.wav not found -- see CAPTAIN-CAVEMAN.md"
    fi

    if [ "$SKIP_HOOKS" -eq 0 ]; then
        node - "$CLAUDE/settings.json" "$CC_HOOK_DEST" <<'CC_WIRE_EOF'
const fs = require('fs');
const [,, settingsPath, hookPath] = process.argv;
let s;
try { s = JSON.parse(fs.readFileSync(settingsPath, 'utf8')); } catch (e) { s = { hooks: {} }; }
s.hooks = s.hooks || {};
s.hooks.SessionStart = s.hooks.SessionStart || [];
const cmd = 'node "' + hookPath + '"';
const already = s.hooks.SessionStart.some(function(e) {
    return (e.hooks || []).some(function(h) { return h.command === cmd; });
});
if (!already) {
    s.hooks.SessionStart.push({ hooks: [{ type: 'command', command: cmd, timeout: 5000 }] });
    fs.writeFileSync(settingsPath, JSON.stringify(s, null, 2) + '\n', 'utf8');
    process.stdout.write('hooks    : wired captain-caveman.js to SessionStart\n');
} else {
    process.stdout.write('hooks    : captain-caveman.js already wired -- skipped\n');
}
CC_WIRE_EOF
    fi
else
    echo "hooks    : captain-caveman.js not found -- skipping"
fi

if [ -d "$SRC/commands-ngon" ]; then
    echo "commands-ngon: skipped (NgonENGINE-specific -- copy manually if needed)"
fi

if [ "$SKIP_HOOKS" -eq 0 ]; then
    wire_hooks "$CLAUDE/hooks" "$CLAUDE/settings.json"
else
    echo "hooks : skipped settings.json wiring (--skip-hooks)"
fi

echo ""
echo "Verifying installation..."
ok=1

REQUIRED_SKILLS=$(node -e "var m=JSON.parse(require('fs').readFileSync(process.argv[1],'utf8'));process.stdout.write(m.requiredSkills.join(' '))" "$SRC/pack-manifest.json")
REQUIRED_HOOKS=$(node -e "var m=JSON.parse(require('fs').readFileSync(process.argv[1],'utf8'));process.stdout.write(m.requiredHooks.join(' '))" "$SRC/pack-manifest.json")
WIRED_FILES=$(node -e "var m=JSON.parse(require('fs').readFileSync(process.argv[1],'utf8'));process.stdout.write(m.hookWiring.map(function(e){return e.file}).join(' '))" "$SRC/pack-manifest.json")

for skill in $REQUIRED_SKILLS; do
    sp="$CLAUDE/skills/$skill/SKILL.md"
    if [ -f "$sp" ]; then printf "  [ok] skills/%s/SKILL.md\n" "$skill"
    else printf "  [MISSING] skills/%s/SKILL.md\n" "$skill"; ok=0; fi
done

for hook in $REQUIRED_HOOKS; do
    hp="$CLAUDE/hooks/$hook"
    if [ -f "$hp" ]; then printf "  [ok] hooks/%s\n" "$hook"
    else printf "  [MISSING] hooks/%s\n" "$hook"; ok=0; fi
done

if [ "$SKIP_HOOKS" -eq 0 ]; then
    for file in $WIRED_FILES; do
        if grep -q "$file" "$CLAUDE/settings.json" 2>/dev/null; then
            printf "  [ok] %s wired in settings.json\n" "$file"
        else
            printf "  [MISSING] %s not found in settings.json\n" "$file"; ok=0
        fi
    done
fi

# memory-to-outline.ps1 is Windows-only; no Unix equivalent in this release
echo "  memory-to-vault: Windows-only post-install step (skipped on Unix)"

echo ""
if [ "$ok" -eq 1 ]; then
    echo "Done. Restart Claude Code to pick up new skills. Run the /audit command first."
else
    echo "Installation completed with warnings above. Fix missing items before use."
fi
