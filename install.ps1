# Claude-ITect-Skill v2.0 -- Windows Install Script
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

    function Has-Hook($hookArray, $cmd) {
        if (-not $hookArray) { return $false }
        foreach ($entry in $hookArray) {
            foreach ($h in $entry.hooks) {
                if ($h.command -eq $cmd) { return $true }
            }
        }
        return $false
    }

    function Add-HookEntry($event, $cmd, $label) {
        if (-not $settings.hooks.PSObject.Properties[$event]) {
            $settings.hooks | Add-Member -NotePropertyName $event -NotePropertyValue @() -Force
        }
        if (Has-Hook $settings.hooks.$event $cmd) {
            Write-Host "hooks  : $label already wired -- skipped"
            return
        }
        $settings.hooks.$event += [PSCustomObject]@{ hooks = @([PSCustomObject]@{ type = "command"; command = $cmd; timeout = 5000 }) }
        Write-Host "hooks  : wired $label"
    }

    Add-HookEntry "SessionStart"     $activateCmd "SessionStart -> caveman-activate.js"
    Add-HookEntry "UserPromptSubmit" $trackerCmd  "UserPromptSubmit -> caveman-mode-tracker.js"

    $settings | ConvertTo-Json -Depth 10 | Set-Content $settingsPath -Encoding UTF8
}

# Prerequisite check
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host ""
    Write-Host "ERROR: Node.js is required for caveman hooks but was not found." -ForegroundColor Red
    Write-Host "       Download it from https://nodejs.org (LTS version recommended)." -ForegroundColor Red
    Write-Host "       Re-run this installer after installing Node.js." -ForegroundColor Red
    Write-Host ""
    exit 1
}

Write-Host ""
Write-Host "Installing into: $ProjectPath"
Write-Host ""

Copy-Dir   "$src\skills"  "$claude\skills"  "skills "
Copy-Files "$src\agents"  "$claude\agents"  "agents "
Copy-Files "$src\hooks"   "$claude\hooks"   "hooks  "

if (Test-Path "$src\commands-ngon") {
    Write-Host "commands-ngon: skipped (NgonENGINE-specific -- copy manually if needed)"
}

if (-not $SkipHooks) {
    Wire-Hooks "$claude\hooks" "$claude\settings.json"
} else {
    Write-Host "hooks  : skipped settings.json wiring (-SkipHooks)"
}

Write-Host ""
Write-Host "Done. Restart Claude Code to pick up new skills."
