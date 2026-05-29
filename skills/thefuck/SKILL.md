---
name: thefuck
version: "2.0"
category: utilities
execution_speed: fast
token_efficiency: high
triggers:
  - "fix that command"
  - "what should I have typed"
  - "correct that"
  - "diagnose error"
  - "failed shell command"
cache_key: "thefuck-2.0"
dependencies: []
disable-model-invocation: true
description: Fix the previous failed shell command. Trigger when a command errors out, user says "fix that command", "what should I have typed", "correct that", or types "fuck" as a message. Diagnoses the error, proposes corrected command, confirms before running.
---

# TheFuck

Diagnose and correct a failed shell command.


## Trigger patterns

- A Bash/PowerShell command in the session produced an error
- User says "fix that", "fuck", "what did I mean", "wrong command", "correct that"
- User pastes a failed command + error and asks for help

## Process

### 1. Read the failed command and error

Pull both from conversation context. If not present, ask the user to paste the command and error output.

### 2. Diagnose the error class

| Error class | Signal | Correction |
|---|---|---|
| Typo in command name | `command not found` | Fuzzy-match to nearest real command |
| Missing `sudo` | `permission denied` | Prepend `sudo` |
| Wrong flag | `unknown option`, `invalid flag` | Fix flag name/syntax |
| Wrong argument order | Tool-specific usage error | Reorder per man page |
| Wrong directory | `no such file or directory` | Suggest `cd` or correct path |
| Missing pipe/redirect | Unexpected EOF or stdin error | Add missing operator |
| Git typo | `git: '...' is not a git command` | Suggest nearest git subcommand |
| Package not found | `module not found`, `cannot find package` | Suggest install command |

### 3. Propose correction

State the corrected command. Explain the fix in one line. Example:

> `gti commit -m "msg"` → `git commit -m "msg"` -- typo in command name

### 4. Confirm before running

**Always ask before executing.** Never silently run the corrected command.

> Run `git commit -m "msg"`? (yes/no)

### 5. Use `thefuck` CLI if available

Check whether the `thefuck` CLI is installed:

```powershell
# Windows
where.exe thefuck
```

```bash
# Unix
which thefuck
```

If installed, prefer its output -- it has hundreds of curated rules. Run the previous command through it:

```bash
# Unix -- re-run previous command through thefuck
eval $(thefuck $(fc -ln -1))
```

```powershell
# Windows PowerShell -- pipe previous command
$prev = (Get-History -Count 1).CommandLine
thefuck $prev
```

## Install `thefuck` (if not present)

```bash
# pip (all platforms)
pip install thefuck

# Homebrew (macOS)
brew install thefuck
```

```powershell
# Windows -- winget
winget install thefuck

# Windows -- scoop
scoop install thefuck
```

After install, add the alias to your shell profile:

```bash
# bash/zsh -- add to ~/.bashrc or ~/.zshrc
eval $(thefuck --alias)

# fish
thefuck --alias | source
```

```powershell
# PowerShell -- add to $PROFILE
$env:TF_SHELL = "powershell"; iex "$(thefuck --alias)"
```

## Never

- Run a corrected destructive command (`rm`, `DROP`, `format`, `mkfs`) without explicit confirmation and a warning
- Guess when the error gives no useful signal -- ask the user what they intended
- Modify files to "fix" a command -- only suggest the correct invocation
