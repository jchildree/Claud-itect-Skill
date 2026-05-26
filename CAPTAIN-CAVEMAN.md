# 🦴 Captain Caveman Entrance Sound

Because every legendary skill pack deserves a legendary entrance.

## What This Does

Plays the iconic Captain Caveman roar **once** when you first start a Claude Code session with this skill pack installed. Cross-platform. Zero dependencies beyond Node.js (which you already need for hooks).

After that first glorious moment? Silent operation. The legend has been acknowledged.

---

## Installation

### 1. Get the Sound File

You'll need `captain-caveman.wav`. Options:

**Option A: Find Your Own**
- Search YouTube for "Captain Caveman sound effect"
- Download with `yt-dlp` or similar
- Convert to WAV if needed: `ffmpeg -i input.mp3 captain-caveman.wav`

**Option B: Generate It**
- Use a text-to-speech service with a deep, cave-dweller voice
- Say: "CAPTAIN CAVEMAAAAAAN!"
- Add echo/reverb for authenticity

**Option C: Use a Classic**
- Any short, triumphant sound effect works
- Keep it under 3 seconds for sanity

### 2. Add to Repository

Place your sound file in the repo:

```
Claude-ITect-Skill/
├── assets/
│   └── captain-caveman.wav  ← your sound file here
├── hooks/
│   ├── captain-caveman.js   ← the hook script
│   └── ...other hooks...
└── state/                     ← created automatically on first run
    └── captain-caveman-state.json
```

### 3. Wire the Hook

The install scripts (`install.ps1` / `install.sh`) should add this to `.claude/settings.json`:

```json
{
  "hooks": {
    "SessionStart": [
      ".claude/hooks/caveman-activate.js",
      ".claude/hooks/captain-caveman.js"  ← add this line
    ]
  }
}
```

Or manually add it after installation.

---

## Platform Support

| Platform | Audio Player | Always Available? |
|---|---|---|
| **macOS** | `afplay` | ✅ Yes (ships with OS) |
| **Linux** | `aplay`, `paplay`, `mpg123`, `ffplay` | ⚠️ Usually (tries all in order) |
| **Windows** | PowerShell `Media.SoundPlayer` | ✅ Yes (ships with PS) |

### Linux Note

If you're on a minimal Linux install and the sound doesn't play, install one of:

```bash
sudo apt install alsa-utils        # aplay
sudo apt install pulseaudio-utils  # paplay
sudo apt install mpg123            # mpg123
sudo apt install ffmpeg            # ffplay
```

---

## Configuration

### Disable the Sound

Three ways to silence the caveman (why would you?):

**1. Delete the state file:**
```bash
rm .claude/state/captain-caveman-state.json
```
Next session start will play it again.

**2. Remove from settings.json:**
Remove the `captain-caveman.js` line from your SessionStart hooks.

**3. Delete the sound file:**
```bash
rm .claude/assets/captain-caveman.wav
```
Hook will silently fail (logs error but continues).

### Reset for Testing

Want to hear it again?

```bash
rm .claude/state/captain-caveman-state.json
```

Restart Claude Code session. CAVEMAAAAAAN!

---

## Troubleshooting

### "Sound file not found"

The hook expects the WAV file at:
```
.claude/assets/captain-caveman.wav
```

Check the path. Check permissions. Check your spelling.

### "No audio player found" (Linux)

Install one of the supported players (see Platform Support above).

### "Audio player exited with code: 1" (Windows)

PowerShell might be blocked by execution policy. The hook uses `-ExecutionPolicy Bypass` to work around this, but if it still fails, check your system PowerShell settings.

### Sound plays every time

The state file isn't being saved. Check:
- Write permissions on `.claude/state/` directory
- Disk space (unlikely but... you know)
- Antivirus blocking file writes (Windows)

---

## Technical Details

### State Persistence

Uses JSON file at `.claude/state/captain-caveman-state.json`:

```json
{
  "soundPlayed": true
}
```

Simple. Readable. No database. No cloud. Just a boolean and a dream.

### Why WAV?

All platforms can play WAV natively. No codec dependencies. No format wars.

### Why Not MP3?

Linux players vary wildly. WAV just works everywhere.

### Performance

The sound plays asynchronously and has a 5-second timeout. If your audio player hangs, the hook kills it and moves on. Your session isn't blocked.

---

## Credits

Inspired by the legendary Hanna-Barbera character who taught us that:
1. Cave dwellers can fly
2. Clubs solve most problems
3. Entrance sounds matter

---

## License

Same as the rest of Claude-ITect-Skill. The Captain Caveman character belongs to Hanna-Barbera. This is just a silly homage. Don't sue me.

---

**Now go forth and CAVEMAN! 🦴**
