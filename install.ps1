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

# Single source of truth for required skills, hooks, and wiring
$manifest = Get-Content "$src\pack-manifest.json" -Raw | ConvertFrom-Json

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

function Wire-Hooks($hooksDir, $settingsPath, $manifest) {
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

    function Add-HookEntryWithMatcher($event, $matcher, $cmd, $label) {
        if (-not $settings.hooks.PSObject.Properties[$event]) {
            $settings.hooks | Add-Member -NotePropertyName $event -NotePropertyValue @() -Force
        }
        if (Has-Hook $settings.hooks.$event $cmd) {
            Write-Host "hooks  : $label already wired -- skipped"
            return
        }
        $settings.hooks.$event += [PSCustomObject]@{
            matcher = $matcher
            hooks   = @([PSCustomObject]@{ type = "command"; command = $cmd; timeout = 5000 })
        }
        Write-Host "hooks  : wired $label"
    }

    foreach ($entry in $manifest.hookWiring) {
        $cmd   = "node `"$hooksDir\$($entry.file)`""
        $label = "$($entry.event) -> $($entry.file)"
        if ($entry.matcher) {
            Add-HookEntryWithMatcher $entry.event $entry.matcher $cmd $label
        } else {
            Add-HookEntry $entry.event $cmd $label
        }
    }

    $json = $settings | ConvertTo-Json -Depth 10
    [System.IO.File]::WriteAllText($settingsPath, $json + "`n", [System.Text.UTF8Encoding]::new($false))
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
    Wire-Hooks "$claude\hooks" "$claude\settings.json" $manifest
} else {
    Write-Host "hooks  : skipped settings.json wiring (-SkipHooks)"
}

Write-Host ""
Write-Host "Verifying installation..."
$ok = $true

foreach ($s in $manifest.requiredSkills) {
    $sp = Join-Path $claude "skills\$s\SKILL.md"
    if (Test-Path $sp) { Write-Host "  [ok] skills/$s/SKILL.md" }
    else               { Write-Host "  [MISSING] skills/$s/SKILL.md" -ForegroundColor Red; $ok = $false }
}

foreach ($h in $manifest.requiredHooks) {
    $hp = Join-Path $claude "hooks\$h"
    if (Test-Path $hp) { Write-Host "  [ok] hooks/$h" }
    else               { Write-Host "  [MISSING] hooks/$h" -ForegroundColor Red; $ok = $false }
}

if (-not $SkipHooks) {
    $settingsPath = Join-Path $claude "settings.json"
    $settingsRaw  = if (Test-Path $settingsPath) { Get-Content $settingsPath -Raw } else { "" }
    foreach ($entry in $manifest.hookWiring) {
        $file = $entry.file
        if ($settingsRaw -match [regex]::Escape($file)) { Write-Host "  [ok] $file wired in settings.json" }
        else { Write-Host "  [MISSING] $file not found in settings.json" -ForegroundColor Red; $ok = $false }
    }
}

Write-Host ""
Write-Host "Running memory-to-vault outline..."
$memScript = Join-Path $claude "skills\memory-to-vault\scripts\memory-to-outline.ps1"
if (Test-Path $memScript) {
    & pwsh -NoProfile -File $memScript -ProjectPath $ProjectPath
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  memory-to-vault: exited $LASTEXITCODE" -ForegroundColor Yellow
    }
} else {
    Write-Host "  memory-to-vault: script not found (skipped)" -ForegroundColor Yellow
}

Write-Host ""
if ($ok) { Write-Host "Done. Restart Claude Code to pick up new skills. Run the /audit command first." }
else     { Write-Host "Installation completed with warnings above. Fix missing items before use." -ForegroundColor Yellow }
