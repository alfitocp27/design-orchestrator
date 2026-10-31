<#
.SYNOPSIS
    Offline test: Verifies UTF-8 encoding integrity and ensures zero mojibake byte corruption.
.DESCRIPTION
    Scans repository markdown, powershell, and JSON files to assert clean UTF-8 encoding.
    Checks raw file bytes for double-encoded UTF-8/CP1252 sequences to avoid parser encoding dependency.
#>
param([string]$RepoRoot)

if (-not $RepoRoot) { $RepoRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent }

Write-Host "Running Test: UTF-8 Encoding & Mojibake Hygiene..." -ForegroundColor Cyan

# Binary byte signatures of common CP1252 -> UTF-8 mojibake:
# Defined purely by hexadecimal byte values to maintain 100% ASCII script source.
$mojibakeSignatures = @(
    @{ Name = "Corrupted-Dash-Quote"; Bytes = [byte[]]@(0xC3, 0xA2, 0xE2, 0x82, 0xAC) },
    @{ Name = "Corrupted-Emoji";      Bytes = [byte[]]@(0xC3, 0xB0, 0xC5, 0xB8) },
    @{ Name = "Corrupted-Checkmark";  Bytes = [byte[]]@(0xC3, 0xA2, 0xC5, 0x93) },
    @{ Name = "Corrupted-Times-Sign"; Bytes = [byte[]]@(0xC3, 0x83, 0xC2, 0x97) },
    @{ Name = "Corrupted-Delta";      Bytes = [byte[]]@(0xC3, 0x8E, 0xE2, 0x80, 0x9D) }
)

function Find-ByteSequence {
    param(
        [byte[]]$Source,
        [byte[]]$Pattern
    )
    if ($Source.Length -lt $Pattern.Length) { return $false }
    $max = $Source.Length - $Pattern.Length
    for ($i = 0; $i -le $max; $i++) {
        $match = $true
        for ($j = 0; $j -lt $Pattern.Length; $j++) {
            if ($Source[$i + $j] -ne $Pattern[$j]) {
                $match = $false
                break
            }
        }
        if ($match) { return $true }
    }
    return $false
}

$filesToScan = @()
$gitCmd = Get-Command git -ErrorAction SilentlyContinue
if ($gitCmd) {
    try {
        $tracked = (& git -C $RepoRoot ls-files 2>$null)
        if ($LASTEXITCODE -eq 0 -and $tracked) {
            $filesToScan = $tracked | Where-Object {
                $_ -match "\.(md|ps1|json|yml|yaml)$" -and
                $_ -notmatch "^tests/offline/test-encoding-hygiene\.ps1$"
            } | ForEach-Object {
                $full = Join-Path $RepoRoot $_
                if (Test-Path $full -PathType Leaf) { Get-Item $full }
            } | Where-Object { $_ -ne $null }
        }
    } catch {}
    $global:LASTEXITCODE = 0
}

if ($filesToScan.Count -eq 0) {
    $filesToScan = Get-ChildItem -Path $RepoRoot -Recurse -File | Where-Object {
        $_.FullName -match "\.(md|ps1|json|yml|yaml)$" -and
        $_.FullName -notmatch "\\\.git\\" -and
        $_.FullName -notmatch "\\\.agents\\skills\\(impeccable|ui-ux-pro-max|anti-slop|antislop)\\" -and
        $_.FullName -notmatch "\\node_modules\\" -and
        $_.FullName -notmatch "\\__pycache__\\" -and
        $_.FullName -notmatch "\\tests\\offline\\test-encoding-hygiene\.ps1$" -and
        $_.FullName -notmatch "\\\.system_generated\\"
    }
}

$violations = @()

foreach ($file in $filesToScan) {
    try {
        $bytes = [System.IO.File]::ReadAllBytes($file.FullName)
        foreach ($sig in $mojibakeSignatures) {
            if (Find-ByteSequence -Source $bytes -Pattern $sig.Bytes) {
                $relPath = $file.FullName.Replace($RepoRoot, "").TrimStart("\/")
                $violations += ("File '{0}' contains {1} byte signature!" -f $relPath, $sig.Name)
                break
            }
        }
    } catch {
        $violations += ("File '{0}' failed byte read: {1}" -f $file.FullName, $_)
    }
}

if ($violations.Count -gt 0) {
    $violations | ForEach-Object { Write-Host $_ -ForegroundColor Red }
    throw ("FAIL: Found {0} encoding/mojibake violation(s) across repository files!" -f $violations.Count)
}

Write-Host ("PASS: All {0} tracked documentation and script files verified with clean UTF-8 encoding." -f $filesToScan.Count) -ForegroundColor Green
