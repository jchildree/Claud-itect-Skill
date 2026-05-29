# Captain Caveman Integration Guide

Complete guide for adding the Captain Caveman entrance sound to your Claude-ITect-Skill repository.

---

## 📁 Repository Structure Changes

After integration, your repository will look like this:

```
Claude-ITect-Skill/
├── assets/                          ← NEW DIRECTORY
│   ├── captain-caveman.wav          ← YOUR SOUND FILE
│   └── .gitkeep                     ← Keep directory in git
│
├── hooks/
│   ├── captain-caveman.js           ← NEW HOOK
│   ├── test-captain-caveman.js      ← NEW TEST SCRIPT
│   ├── caveman-activate.js
│   ├── caveman-mode-tracker.js
│   ├── check-encoding.js
│   ├── caveman-config.js
│   ├── caveman-stats.js
│   ├── caveman-statusline.ps1
│   └── package.json
│
├── state/                           ← NEW DIRECTORY (auto-created)
│   ├── captain-caveman-state.json   ← Created on first run
│   └── .gitignore                   ← Ignore state files in git
│
├── CAPTAIN-CAVEMAN.md               ← NEW DOCUMENTATION
├── README.md                        ← UPDATED (add section)
├── install.ps1                      ← UPDATED (add snippet)
├── install.sh                       ← UPDATED (add snippet)
├── CLAUDE.md
└── ...other files...
```

---

## 🔧 Step-by-Step Integration

### Step 1: Create Directory Structure

```bash
# In your Claude-ITect-Skill repository root:

# Create assets directory
mkdir -p assets
touch assets/.gitkeep

# Create state directory with gitignore
mkdir -p state
echo "*.json" > state/.gitignore
echo "!.gitignore" >> state/.gitignore
```

### Step 2: Add the Files

Copy these files to your repository:

| File | Destination | Purpose |
|---|---|---|
| `captain-caveman.js` | `hooks/captain-caveman.js` | Main hook script |
| `test-captain-caveman.js` | `hooks/test-captain-caveman.js` | Test utility |
| `CAPTAIN-CAVEMAN.md` | `CAPTAIN-CAVEMAN.md` | Feature documentation |

```bash
# Example:
cp /path/to/captain-caveman.js hooks/
cp /path/to/test-captain-caveman.js hooks/
cp /path/to/CAPTAIN-CAVEMAN.md ./
```

### Step 3: Get Your Sound File

**Option A: Download from YouTube**
```bash
# Install yt-dlp if needed
# brew install yt-dlp  # macOS
# pip install yt-dlp   # any platform

# Find a Captain Caveman sound effect on YouTube
yt-dlp -x --audio-format wav "https://youtube.com/watch?v=VIDEO_ID"

# Rename and move to assets
mv "downloaded-file.wav" assets/captain-caveman.wav
```

**Option B: Generate with TTS**
```bash
# Use say (macOS) or espeak (Linux) or online TTS
say -v "Fred" -o assets/captain-caveman.wav "CAPTAIN CAVEMAAAAAAN!"
```

**Option C: Use Any Sound**
- Find a short (2-3 second) triumphant sound effect
- Convert to WAV: `ffmpeg -i input.mp3 assets/captain-caveman.wav`

### Step 4: Update install.ps1

Open `install.ps1` and add this section after the hooks installation block:

```powershell
# Find this section in install.ps1:
# Copy hooks
# foreach ($hook in $hooks) { ... }

# Add right after that section:
```

Then paste the content from `install-ps1-captain-caveman-snippet.ps1`

### Step 5: Update install.sh

Open `install.sh` and add this section after the hooks installation block:

```bash
# Find this section in install.sh:
# Copy hooks
# for hook in "${hooks[@]}"; do ... done

# Add right after that section:
```

Then paste the content from `install-sh-captain-caveman-snippet.sh`

### Step 6: Update README.md

Add the Captain Caveman section to `README.md`. Suggested placement:

- After the "Hooks (6)" section, OR
- Before the "Sources" section, OR
- Create a new "Special Features" section

Paste the content from `README-captain-caveman-snippet.md`

### Step 7: Update Hook Count

In `README.md`, update the hook count:

```markdown
# Change from:
## Hooks (6)

# To:
## Hooks (7)
```

And add an entry to the hooks table:

```markdown
| `captain-caveman.js` | `SessionStart` | Plays entrance sound on first session (optional) |
```

### Step 8: Commit and Push

```bash
git add assets/ hooks/captain-caveman.js hooks/test-captain-caveman.js
git add CAPTAIN-CAVEMAN.md README.md install.ps1 install.sh
git add state/.gitignore

git commit -m "Add Captain Caveman entrance sound feature

- Cross-platform audio playback (macOS/Linux/Windows)
- Plays once on first session start
- Optional feature, configurable via settings.json
- Includes test script and comprehensive docs"

git push origin main
```

---

## ✅ Testing

### Local Testing (Before Pushing)

```bash
# Navigate to hooks directory
cd hooks

# Test with force (ignore state)
node test-captain-caveman.js --force

# Test normal flow (respects state)
node test-captain-caveman.js

# Reset state and test again
node test-captain-caveman.js --reset
```

### Installation Testing

```bash
# Test the installer on a fresh project
cd /path/to/test/project

# Windows
powershell -ExecutionPolicy Bypass -File "C:\path\to\Claude-ITect-Skill\install.ps1"

# macOS/Linux
bash "/path/to/Claude-ITect-Skill/install.sh"

# Check that captain-caveman.js was copied
ls .claude/hooks/captain-caveman.js

# Check that it was wired to SessionStart
cat .claude/settings.json | grep captain-caveman
```

### End-to-End Testing

1. Install the skill pack in a test project
2. Start Claude Code
3. Listen for the glorious sound 🦴
4. Check state file: `cat .claude/state/captain-caveman-state.json`
5. Restart Claude Code - sound should NOT play again
6. Reset: `rm .claude/state/captain-caveman-state.json`
7. Restart Claude Code - sound should play again

---

## 🎨 Customization Ideas

### Make It Configurable

Add to `hooks/caveman-config.js`:

```javascript
module.exports = {
  // Existing caveman config...
  captainCaveman: {
    enabled: true,
    soundFile: 'captain-caveman.wav',
    volume: 0.8  // 0.0 to 1.0 (requires player support)
  }
};
```

### Alternative Sounds

Users can replace `captain-caveman.wav` with their own:
- Custom company jingle
- Game startup sound
- Famous movie quote
- Meme sound effect

Just keep it:
- WAV format
- Under 3 seconds
- Not too loud (for coworker sanity)

### Random Sound Pool

Modify `captain-caveman.js` to select randomly from multiple files:

```javascript
const sounds = [
  'captain-caveman.wav',
  'alt-sound-1.wav',
  'alt-sound-2.wav'
];
const randomSound = sounds[Math.floor(Math.random() * sounds.length)];
const SOUND_FILE = path.join(__dirname, '..', 'assets', randomSound);
```

---

## 🐛 Troubleshooting

### "Module not found" error

```bash
# Make sure you're in the hooks directory
cd /path/to/Claude-ITect-Skill/hooks

# Install dependencies if needed
npm install  # Only if package.json requires it
```

### Sound doesn't play on Linux

```bash
# Install an audio player
sudo apt install alsa-utils    # for aplay
sudo apt install mpg123        # for mpg123
sudo apt install ffmpeg        # for ffplay
```

### Permission denied (macOS/Linux)

```bash
# Make the hook executable
chmod +x hooks/captain-caveman.js
chmod +x hooks/test-captain-caveman.js
```

### Windows PowerShell execution policy

```powershell
# Check current policy
Get-ExecutionPolicy

# If it's Restricted, the installer uses -ExecutionPolicy Bypass
# This is safe - it only bypasses for that single command
```

---

## 📊 Metrics

Expected impact:
- **Installation time:** +2 seconds (file copy)
- **First session delay:** +0.5-2 seconds (one-time sound playback)
- **Subsequent sessions:** 0 impact (state check is <1ms)
- **Disk usage:** ~100-500 KB (WAV file)
- **Dependencies:** None (uses Node.js already required by hooks)

---

## 🎯 Success Criteria

✅ Files copied to correct locations
✅ Installer scripts updated
✅ Documentation added to README
✅ Sound plays on first session
✅ Sound does NOT play on subsequent sessions
✅ State file created automatically
✅ Works on all three platforms (Windows/macOS/Linux)
✅ No breaking changes to existing functionality
✅ Users can disable it easily

---

## 🚀 Optional Enhancements

### Add to CLAUDE.md

Include a reference in your main `CLAUDE.md`:

```markdown
## First Time Setup

When you first start a session with this skill pack, you'll hear the 
legendary Captain Caveman entrance sound. This is normal. Expected. 
Encouraged. It only happens once to acknowledge your wise choice in 
skill packs.

To disable it, see CAPTAIN-CAVEMAN.md.
```

### Create a GitHub Release

Tag the version that includes Captain Caveman:

```bash
git tag -a v2.1.0 -m "Add Captain Caveman entrance sound"
git push origin v2.1.0
```

### Add to Changelog

```markdown
## [2.1.0] - 2025-01-XX

### Added
- 🦴 Captain Caveman entrance sound (optional feature)
  - Cross-platform audio playback on first session
  - Configurable and disableable
  - Includes comprehensive documentation
```

---

**Now go make it legendary! 🦴**
