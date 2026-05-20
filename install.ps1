# Claude-ITect-Skill v2.0 — Windows Install Script
# Installs all skills, agents, hooks, and commands into a project's .claude directory.
# Also wires caveman hooks into the project's .claude/settings.json.
#
# Usage:
#   .\install.ps1                        # installs into current directory
#   .\install.ps1 -ProjectPath C:\path  # installs into specified project
#   .\install.ps1 -Force                 # overwrite existing skills
#   .\install.ps1 -SkipHooks             # skip settings.json hook wiring

param(
    [string]$ProjectPath = (Get-Location),
    [switch]$Force,
    [switch]$SkipHooks
)

$src    = $PSScriptRoot
$claude = Join-Path $ProjectPath ".claude"

function Copy-Dir($from, $to, $label) {
    if (-not (Test-Path $from)) { return }
    New-Item -ItemType Directory -Force -Path $to | Out-Null
    $copied = 0; $skipped = 0
    Get-ChildItem $from -Directory | ForEach-Object {
        $target = Join-Path $to $_.Name
        if ((Test-Path $target) -and -not $Force) { $skipped++ }
        else { Copy-Item $_.FullName $to -Recurse -Force; $copied++ }
    }
    Write-Host "$label`: installed=$copied  skipped=$skipped"
}

function Copy-Files($from, $to, $label) {
    if (-not (Test-Path $from)) { return }
    New-Item -ItemType Directory -Force -Path $to | Out-Null
    Copy-Item "$from\*" $to -Force
    Write-Host "$label`: copied"
}

function Wire-Hooks($hooksDir, $settingsPath) {
    $activateCmd = "node `"$hooksDir\caveman-activate.js`""
    $trackerCmd  = "node `"$hooksDir\caveman-mode-tracker.js`""

    $settings = if (Test-Path $settingsPath) {
        Get-Content $settingsPath -Raw | ConvertFrom-Json
    } else {
        [PSCustomObject]@{ hooks = [PSCustomObject]@{} }
    }

    if (-not $settings.hooks) {
        $settings | Add-Member -NotePropertyName "hooks" -NotePropertyValue ([PSCustomObject]@{}) -Force
    }

    # Helper: check if a command is already registered in a hook array
    function Has-Hook($hookArray, $cmd) {
        if (-not $hookArray) { return $false }
        foreach ($entry in $hookArray) {
            foreach ($h in $entry.hooks) {
                if ($h.command -eq $cmd) { return $true }
            }
        }
        return $false
    }

    $newEntry = [PSCustomObject]@{
        hooks = @()
    }

    # SessionStart — caveman-activate
    if (-not (Has-Hook $settings.hooks.SessionStart $activateCmd)) {
        $newEntry.hooks = @([PSCustomObject]@{ type = "command"; command = $activateCmd; timeout = 5000 })
        if (-not $settings.hooks.PSObject.Properties["SessionStart"]) {
            $settings.hooks | Add-Member -NotePropertyName "SessionStart" -NotePropertyValue @() -Force
        }
        $settings.hooks.SessionStart += [PSCustomObject]@{ hooks = @([PSCustomObject]@{ type = "command"; command = $activateCmd; timeout = 5000 }) }
        Write-Host "hooks  : wired SessionStart -> caveman-activate.js"
    } else {
        Write-Host "hooks  : SessionStart already wired — skipped"
    }

    # UserPromptSubmit — caveman-mode-tracker
    if (-not (Has-Hook $settings.hooks.UserPromptSubmit $trackerCmd)) {
        if (-not $settings.hooks.PSObject.Properties["UserPromptSubmit"]) {
            $settings.hooks | Add-Member -NotePropertyName "UserPromptSubmit" -NotePropertyValue @() -Force
        }
        $settings.hooks.UserPromptSubmit += [PSCustomObject]@{ hooks = @([PSCustomObject]@{ type = "command"; command = $trackerCmd; timeout = 5000 }) }
        Write-Host "hooks  : wired UserPromptSubmit -> caveman-mode-tracker.js"
    } else {
        Write-Host "hooks  : UserPromptSubmit already wired — skipped"
    }

    New-Item -ItemType Directory -Force -Path (Split-Path $settingsPath) | Out-Null
    $settings | ConvertTo-Json -Depth 10 | Set-Content $settingsPath -Encoding UTF8
}

# --- Run ---

Copy-Dir   "$src\skills"        "$claude\skills"   "skills "
Copy-Files "$src\agents"        "$claude\agents"   "agents "
Copy-Files "$src\hooks"         "$claude\hooks"    "hooks  "

# NgonENGINE-specific commands — opt-in only
if (Test-Path "$src\commands-ngon") {
    Write-Host "commands-ngon: skipped (NgonENGINE-specific — copy manually if needed)"
}

if (-not $SkipHooks) {
    $hooksAbs = (Resolve-Path "$claude\hooks" -ErrorAction SilentlyContinue)?.Path
    if (-not $hooksAbs) { $hooksAbs = "$claude\hooks" }
    Wire-Hooks $hooksAbs "$claude\settings.json"
} else {
    Write-Host "hooks  : skipped settings.json wiring (-SkipHooks)"
}

Write-Host ""
Write-Host "Done. Restart Claude Code to pick up new skills."
Write-Host "Node.js required for caveman hooks."
