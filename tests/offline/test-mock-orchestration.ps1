<#
.SYNOPSIS
    Offline test: Tests simulated FigCraft MCP runbook and VQA 2.0 evaluation using JSON mock fixtures.
#>
param([string]$RepoRoot)

if (-not $RepoRoot) { $RepoRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent }
$MockFile = Join-Path $RepoRoot "tests\mocks\figcraft-mock.json"
$VqaMock = Join-Path $RepoRoot "tests\mocks\vqa-audit-sample.json"

Write-Host "Running Test: Offline Mock Orchestration & VQA 2.0..." -ForegroundColor Cyan

if (-not (Test-Path $MockFile)) {
    throw "FAIL: FigCraft mock fixture missing at $MockFile"
}

$mockData = Get-Content $MockFile -Raw | ConvertFrom-Json
$vqaData = Get-Content $VqaMock -Raw | ConvertFrom-Json

# 1. Simulate Document Inspection
$doc = $mockData.inspect_document.document
if ($doc.pages.Count -ne 4) {
    throw "FAIL: Expected 4 partitioned pages (Foundations, Components, Patterns, Screens), got $($doc.pages.Count)"
}

# 2. Simulate 8-Point Stress Test Sizing
$frame = $mockData.create_frame
if ($frame.layoutMode -ne "VERTICAL") {
    throw "FAIL: Frame Auto Layout must be VERTICAL"
}

# 3. Simulate VQA 2.0 Zero False PASS Verification
$tier1 = $vqaData.dimensions.tier1_technical_integrity
if ($tier1.p1_defects -ne 0 -or $tier1.p2_defects -ne 0) {
    throw "FAIL: VQA 2.0 requires 0 P1 and 0 P2 defects for PASS status"
}

Write-Host "PASS: Mock orchestration and VQA 2.0 simulated pipeline verified." -ForegroundColor Green
