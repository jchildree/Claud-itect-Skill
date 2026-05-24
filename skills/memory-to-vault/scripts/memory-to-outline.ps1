#!/usr/bin/env pwsh
# memory-to-outline.ps1
# Locates Claude memory for the current git root and prints all memory file contents.
# Output is organized by memory type: user, feedback, project, reference.
# Always exits 0 -- missing memory directory is a normal first-run condition, not an error.

param(
    [string]$ProjectPath = ""
)

function Get-MemoryDir {
    param([string]$Root)
    # git rev-parse returns forward slashes on Windows; normalize before hashing
    $normalized = $Root -replace '/', '\'
    $hash = $normalized -replace '[:\\]', '-' -replace '^-+', '' -replace '-+$', ''
    return Join-Path $env:USERPROFILE ".claude\projects\$hash\memory"
}

# Resolve project root
$root = $ProjectPath
if (-not $root) {
    try {
        $root = (git rev-parse --show-toplevel 2>$null).Trim()
    } catch {}
    if (-not $root) { $root = $PWD.Path }
}

$memDir = Get-MemoryDir -Root $root

if (-not (Test-Path $memDir)) {
    Write-Host "  memory-to-vault: no memory directory found at $memDir (skipped -- run after first Claude session)"
    exit 0
}

Write-Host "=== MEMORY DIRECTORY: $memDir =="
Write-Host ""

# Read MEMORY.md index first
$indexPath = Join-Path $memDir "MEMORY.md"
if (Test-Path $indexPath) {
    Write-Host "=== MEMORY INDEX (MEMORY.md) =="
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

    Write-Host "=== $($typeLabels[$prefix]) =="
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
    Write-Host "=== OTHER MEMORY FILES =="
    foreach ($f in $others) {
        Write-Host "--- $($f.Name) ---"
        Get-Content $f.FullName | Write-Host
        Write-Host ""
    }
}
