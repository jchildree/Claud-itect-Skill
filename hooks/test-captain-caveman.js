#!/usr/bin/env node
/**
 * test-captain-caveman.js
 * 
 * Test the Captain Caveman hook independently.
 * Useful for development and debugging.
 * 
 * Usage:
 *   node test-captain-caveman.js          # Test sound playback
 *   node test-captain-caveman.js --reset  # Reset state and test
 *   node test-captain-caveman.js --force  # Force play (ignore state)
 */

const fs = require('fs');
const path = require('path');
const { playSound, loadState, saveState } = require('./captain-caveman.js');

const args = process.argv.slice(2);
const isReset = args.includes('--reset');
const isForce = args.includes('--force');

const STATE_FILE = path.join(__dirname, '..', 'state', 'captain-caveman-state.json');

async function main() {
  console.log('🦴 Captain Caveman Hook Test\n');
  
  if (isReset) {
    console.log('Resetting state...');
    if (fs.existsSync(STATE_FILE)) {
      fs.unlinkSync(STATE_FILE);
      console.log('✓ State file deleted\n');
    } else {
      console.log('✓ No state file to delete\n');
    }
  }
  
  if (isForce) {
    console.log('Force mode: ignoring state file\n');
    console.log('Playing sound...');
    await playSound();
    console.log('\n✓ Sound playback complete');
  } else {
    const state = loadState();
    console.log('Current state:', state);
    
    if (state.soundPlayed) {
      console.log('\n⚠ Sound already played once.');
      console.log('  Use --reset to reset state');
      console.log('  Use --force to play anyway');
    } else {
      console.log('\nPlaying sound for first time...');
      await playSound();
      state.soundPlayed = true;
      saveState(state);
      console.log('✓ Sound playback complete');
      console.log('✓ State saved');
    }
  }
  
  console.log('\nTest complete! 🦴');
}

main().catch(err => {
  console.error('Error:', err.message);
  process.exit(1);
});
