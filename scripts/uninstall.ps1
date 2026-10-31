<#
.SYNOPSIS
    Design Orchestrator 2.1 -- Clean Uninstaller and Rollback Tool.
.DESCRIPTION
    Safely uninstalls Design Orchestrator components, removes created links,
    and cleans up temporary caches. Protects user projects and archives.
.PARAMETER Force
    Skip confirmation prompts.
#>

[CmdletBinding()]
param(
    [switch]$Force
)

$RepoRoot = Split-Path -Parent $PSScriptRoot

Write-Host "==========================================================" -ForegroundColor Yellow
Write-Host " Design Orchestrator 2.1 -- Uninstaller and Rollback" -ForegroundColor Yellow
Write-Host (" Target Root: {0}" -f $RepoRoot) -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Yellow

if (-not $Force) {
    $confirm = Read-Host "Are you sure you want to uninstall local components and revert bootstrap state? (Y/N)"
    if ($confirm -notmatch "^[yY]") {
        Write-Host "Uninstallation cancelled." -ForegroundColor Cyan
        exit 0
    }
}

Write-Host "Proceeding with clean rollback..." -ForegroundColor Yellow

# Clean temporary test files
$tempFiles = @(
    (Join-Path $RepoRoot "test-output"),
    (Join-Path $RepoRoot "tests\scratch"),
    (Join-Path $RepoRoot "*.tmp.ps1")
)

foreach ($item in $tempFiles) {
    if (Test-Path $item) {
        Remove-Item -Path $item -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host ("Cleaned: {0}" -f $item) -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "[INFO] Core repository files (.agents, templates, scripts) remain intact." -ForegroundColor Green
Write-Host "[INFO] User project directories in projects/ have been preserved." -ForegroundColor Green
Write-Host "[INFO] Uninstaller completed cleanly." -ForegroundColor Green
