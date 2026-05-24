#!/usr/bin/env pwsh
# memory-to-outline.ps1
# Locates Claude memory for the current git root and prints all memory file contents.
# Output is organized by memory type: user, feedback, project, reference.

param(
    [string]$ProjectPath = ""
)

$ErrorActionPreference = "Stop"

# Resolve project root
if ($ProjectPath -eq "") {
    try {
        $root = (git rev-parse --show-toplevel 2>$null).Trim()
        if (-not $root) { $root = $PWD.Path }
    } catch {
        $root = $PWD.Path
    }
} else {
    $root = $ProjectPath
}

# Normalize path to Claude project hash
# C:\Users\Joe\myproject -> C--Users-Joe-myproject
$hash = $root -replace '[:\\]', '-' -replace '^-+', '' -replace '-+$', ''

$memDir = Join-Path $env:USERPROFILE ".claude\projects\$hash\memory"

if (-not (Test-Path $memDir)) {
    Write-Error "Memory directory not found: $memDir`nExpected hash: $hash`nProject root: $root"
    exit 1
}

Write-Host "=== MEMORY DIRECTORY: $memDir ==="
Write-Host ""

# Read MEMORY.md index first
$indexPath = Join-Path $memDir "MEMORY.md"
if (Test-Path $indexPath) {
    Write-Host "=== MEMORY INDEX (MEMORY.md) ==="
    Get-Content $indexPath | Write-Host
    Write-Host ""
}

# Read files by type
$types = @("user_", "feedback_", "project_", "reference_")
$typeLabels = @{
    "user_"      = "USER PROFILE"
    "feedback_"  = "BEHAVIORAL GUIDELINES"
    "project_"   = "PROJECT CONTEXT"
    "reference_" = "REFERENCES"
}

foreach ($prefix in $types) {
    $files = Get-ChildItem -Path $memDir -Filter "$prefix*.md" -File 2>$null
    if ($files.Count -eq 0) { continue }

    Write-Host "=== $($typeLabels[$prefix]) ==="
    foreach ($f in $files) {
        Write-Host "--- $($f.Name) ---"
        Get-Content $f.FullName | Write-Host
        Write-Host ""
    }
}

# Any remaining .md files not matching a known prefix
$knownPrefixes = $types + @("MEMORY")
$others = Get-ChildItem -Path $memDir -Filter "*.md" -File | Where-Object {
    $name = $_.BaseName
    -not ($knownPrefixes | Where-Object { $name -like "$_*" })
}
if ($others.Count -gt 0) {
    Write-Host "=== OTHER MEMORY FILES ==="
    foreach ($f in $others) {
        Write-Host "--- $($f.Name) ---"
        Get-Content $f.FullName | Write-Host
        Write-Host ""
    }
}
