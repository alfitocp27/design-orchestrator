<#
.SYNOPSIS
    Integration test: Validates live FigCraft Native Design System Engine and 8-point stress testing.
#>
param([string]$RepoRoot)

if (-not $RepoRoot) { $RepoRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent }
$builderScript = Join-Path $RepoRoot "scripts\build-native-design-system.ps1"

Write-Host "Running Integration Test: Live FigCraft Native Design System Engine & 8-Point Stress Tests..." -ForegroundColor Cyan

if (-not (Test-Path $builderScript)) {
    throw "FAIL: Builder script missing at $builderScript"
}

# Run builder targeting test-output
$outputDir = Join-Path $RepoRoot "test-output"
& $builderScript -OutputDir $outputDir

if ($LASTEXITCODE -ne 0) {
    throw "FAIL: Native Design System builder exited with code $LASTEXITCODE"
}

$reportFile = Join-Path $outputDir "stress-test-report.json"
if (-not (Test-Path $reportFile)) {
    throw "FAIL: Stress test report missing at $reportFile"
}

$report = Get-Content $reportFile -Raw | ConvertFrom-Json
if ($report.status -ne "PASS") {
    throw "FAIL: Stress test status is $($report.status)"
}

Write-Host "PASS: Live FigCraft Native Design System Engine passed all 8 stress tests and VQA checks." -ForegroundColor Green
