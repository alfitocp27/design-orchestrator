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

Get-ChildItem -Path $RepoRoot -Recurse -File | Where-Object {
    $_.FullName -notmatch "\\\.git\\" -and
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
    throw "FAIL: Found $($violations.Count) security/privacy violation(s)!"
}

Write-Host "PASS: Clean security and privacy audit. Zero personal paths or secrets found." -ForegroundColor Green
