<#
.SYNOPSIS
    Offline test: Scans repository files for hardcoded personal paths, credentials, and secrets.
#>
param([string]$RepoRoot)

if (-not $RepoRoot) { $RepoRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent }

Write-Host "Running Test: Security & Privacy Path Scan..." -ForegroundColor Cyan

# Generic regex patterns that MUST NEVER appear in committed files
$bannedPatterns = @(
    'C:\\Users\\[a-zA-Z0-9_\-\.]+',
    'c:/users/[a-zA-Z0-9_\-\.]+',
    'ghp_[a-zA-Z0-9]{36}',
    'github_pat_[a-zA-Z0-9_]{82}',
    'BEGIN (RSA|OPENSSH|EC) PRIVATE KEY',
    'AIzaSy[a-zA-Z0-9_-]{33}',
    'sk-[a-zA-Z0-9]{20,}'
)

$violations = @()

# Prefer tracked repository files to avoid false violations in git-ignored external dependencies
$filesToScan = @()
$gitCmd = Get-Command git -ErrorAction SilentlyContinue
if ($gitCmd) {
    try {
        $tracked = (& git -C $RepoRoot ls-files 2>$null)
        if ($LASTEXITCODE -eq 0 -and $tracked) {
            $filesToScan = $tracked | ForEach-Object { 
                $full = Join-Path $RepoRoot $_
                if (Test-Path $full -PathType Leaf) { Get-Item $full }
            } | Where-Object { $_ -ne $null }
        }
    } catch {}
    $global:LASTEXITCODE = 0
}

if ($filesToScan.Count -eq 0) {
    $filesToScan = Get-ChildItem -Path $RepoRoot -Recurse -File | Where-Object {
        $_.FullName -notmatch "\\\.git\\" -and
        $_.FullName -notmatch "\\tests\\offline\\test-no-secrets\.ps1" -and
        $_.FullName -notmatch "\\\.agents\\skills\\(impeccable|ui-ux-pro-max|anti-slop|antislop)\\" -and
        $_.FullName -notmatch "\\node_modules\\" -and
        $_.FullName -notmatch "\\__pycache__\\" -and
        $_.FullName -notmatch "\\\.system_generated\\"
    }
}

$filesToScan | Where-Object {
    $_.FullName -notmatch "\\tests\\offline\\test-no-secrets\.ps1"
} | ForEach-Object {
    $filePath = $_.FullName
    $relPath = $filePath.Substring($RepoRoot.Length).TrimStart("\")
    $content = Get-Content $filePath -Raw -ErrorAction SilentlyContinue

    if ($content) {
        foreach ($pattern in $bannedPatterns) {
            if ($content -match $pattern) {
                $violations += "Violation: '$pattern' found in $relPath"
            }
        }
    }
}

if ($violations.Count -gt 0) {
    $violations | ForEach-Object { Write-Host $_ -ForegroundColor Red }
    throw "FAIL: Found $($violations.Count) security/privacy violation(s) in repository files!"
}

Write-Host "PASS: Clean security and privacy audit. Zero personal paths or secrets found." -ForegroundColor Green
