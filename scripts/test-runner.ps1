<#
.SYNOPSIS
    Design Orchestrator 2.1 -- Test Suite Runner.
.DESCRIPTION
    Runs offline mock tests and optional integration tests.
    Exits with code 0 on all tests passing, non-zero on failure.
.PARAMETER IncludeIntegration
    Include integration tests requiring real MCP servers.
#>

[CmdletBinding()]
param(
    [switch]$IncludeIntegration
)

$RepoRoot = Split-Path -Parent $PSScriptRoot
$OfflineDir = Join-Path $RepoRoot "tests\offline"
$IntegrationDir = Join-Path $RepoRoot "tests\integration"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " Design Orchestrator 2.1 -- Test Runner" -ForegroundColor Cyan
Write-Host (" Root Directory: {0}" -f $RepoRoot) -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""

$testFiles = Get-ChildItem -Path $OfflineDir -Filter "*.ps1"
if ($IncludeIntegration -and (Test-Path $IntegrationDir)) {
    $testFiles += Get-ChildItem -Path $IntegrationDir -Filter "*.ps1"
}

$passed = 0
$failed = 0
$skipped = 0

foreach ($test in $testFiles) {
    Write-Host "----------------------------------------------------------" -ForegroundColor Gray
    Write-Host ("Executing: {0}" -f $test.Name) -ForegroundColor White
    try {
        & $test.FullName -RepoRoot $RepoRoot
        $passed++
    } catch {
        Write-Host ("ERROR: {0}" -f $_) -ForegroundColor Red
        $failed++
    }
}

$summaryColor = "Green"
if ($failed -gt 0) {
    $summaryColor = "Red"
}

Write-Host ""
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " TEST RUN SUMMARY" -ForegroundColor Cyan
Write-Host (" Total: {0} | Passed: {1} | Failed: {2} | Skipped: {3}" -f $testFiles.Count, $passed, $failed, $skipped) -ForegroundColor $summaryColor
Write-Host "==========================================================" -ForegroundColor Cyan

if ($failed -gt 0) {
    exit 1
} else {
    exit 0
}
