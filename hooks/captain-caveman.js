/**
 * captain-caveman.js
 * 
 * Plays the Captain Caveman entrance sound on first session start.
 * Cross-platform support: macOS, Linux, Windows
 * 
 * Hook: SessionStart
 * Triggers: First time user starts a Claude Code session with this skill pack
 */

const fs = require('fs');
const path = require('path');
const { spawn } = require('child_process');

const STATE_FILE = path.join(__dirname, '..', 'state', 'captain-caveman-state.json');
const SOUND_FILE = path.join(__dirname, '..', 'assets', 'captain-caveman.wav');

/**
 * Load state from disk
 * @returns {{ soundPlayed: boolean }}
 */
function loadState() {
  try {
    if (fs.existsSync(STATE_FILE)) {
      const data = fs.readFileSync(STATE_FILE, 'utf8');
      return JSON.parse(data);
    }
  } catch (err) {
    console.error('[Captain Caveman] Error loading state:', err.message);
  }
  return { soundPlayed: false };
}

/**
 * Save state to disk
 * @param {{ soundPlayed: boolean }} state
 */
function saveState(state) {
  try {
    const stateDir = path.dirname(STATE_FILE);
    if (!fs.existsSync(stateDir)) {
      fs.mkdirSync(stateDir, { recursive: true });
    }
    fs.writeFileSync(STATE_FILE, JSON.stringify(state, null, 2));
  } catch (err) {
    console.error('[Captain Caveman] Error saving state:', err.message);
  }
}

/**
 * Detect platform and play sound using native audio player
 * Returns true when playback happened successfully, false otherwise.
 * @returns {Promise<boolean>}
 */
async function playSound() {
  if (!fs.existsSync(SOUND_FILE)) {
    console.error('[Captain Caveman] Sound file not found:', SOUND_FILE);
    return false;
  }

  const platform = process.platform;
  let command, args;

  if (platform === 'darwin') {
    // macOS - use afplay (always available)
    command = 'afplay';
    args = [SOUND_FILE];
  } else if (platform === 'linux') {
    // Linux - try common players
    const players = [
      { cmd: 'aplay', args: [SOUND_FILE] },
      { cmd: 'paplay', args: [SOUND_FILE] },
      { cmd: 'mpg123', args: [SOUND_FILE] },
      { cmd: 'ffplay', args: ['-nodisp', '-autoexit', SOUND_FILE] }
    ];

    // Find first available player
    for (const player of players) {
      try {
        const { cmd, args: playerArgs } = player;
        // Test if command exists
        const test = spawn('which', [cmd]);
        const exists = await new Promise((resolve) => {
          test.on('close', (code) => resolve(code === 0));
          test.on('error', () => resolve(false));
        });
        if (exists) {
          command = cmd;
          args = playerArgs;
          break;
        }
      } catch (err) {
        continue;
      }
    }

    if (!command) {
      console.error('[Captain Caveman] No audio player found. Install: aplay, paplay, mpg123, or ffplay');
      return false;
    }
  } else if (platform === 'win32') {
    // Windows - use PowerShell SoundPlayer
    command = 'powershell';
    args = [
      '-ExecutionPolicy', 'Bypass',
      '-Command',
      `(New-Object Media.SoundPlayer '${SOUND_FILE.replace(/'/g, "''")}').PlaySync()`
    ];
  } else {
    console.error('[Captain Caveman] Unsupported platform:', platform);
    return false;
  }

  return new Promise((resolve) => {
    const player = spawn(command, args, { stdio: 'ignore' });

    let finished = false;

    player.on('close', (code) => {
      finished = true;
      if (code === 0) {
        resolve(true);
      } else {
        console.error('[Captain Caveman] Audio player exited with code:', code);
        resolve(false);
      }
    });

    player.on('error', (err) => {
      console.error('[Captain Caveman] Error playing sound:', err.message);
      if (!finished) resolve(false);
    });

    // Timeout after 5 seconds
    setTimeout(() => {
      try { player.kill(); } catch (e) {}
      if (!finished) resolve(false);
    }, 5000);
  });
}

/**
 * Main hook entry point
 * SessionStart hook - runs once per session
 */
async function main() {
  try {
    const state = loadState();

    if (!state.soundPlayed) {
      console.log('🦴 CAPTAIN CAVEMAAAAAAN! 🦴');
      const played = await playSound();
      if (played) {
        state.soundPlayed = true;
        saveState(state);
      } else {
        console.error('[Captain Caveman] Did not play sound; will retry on next SessionStart.');
      }
    }
  } catch (err) {
    console.error('[Captain Caveman] Hook error:', err.message);
  }
}

// Run if called directly
if (require.main === module) {
  main().catch(err => {
    console.error('[Captain Caveman] Fatal error:', err);
    process.exit(1);
  });
}

module.exports = { playSound, loadState, saveState };
