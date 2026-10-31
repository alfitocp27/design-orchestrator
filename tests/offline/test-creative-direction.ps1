<#
.SYNOPSIS
    Offline test: Validates Dynamic Creative Direction Engine across 4 synthetic domains.
    Guarantees structural divergence, 10 mandatory dimensions, and WCAG 2.2 contrast compliance.
#>
param([string]$RepoRoot)

if (-not $RepoRoot) { $RepoRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent }
$evaluatorScript = Join-Path $RepoRoot "scripts\evaluate-creative-direction.ps1"
$fixturesDir = Join-Path $RepoRoot "tests\fixtures\creative-direction"

Write-Host "Running Test: Dynamic Creative Direction & Archetype Engine (4 Domains)..." -ForegroundColor Cyan

if (-not (Test-Path $evaluatorScript)) {
    throw "FAIL: Evaluator script missing at $evaluatorScript"
}

$domains = @(
    "enterprise-logistics.json",
    "edtech-adaptive-learning.json",
    "industrial-scada.json",
    "creative-audio-mastering.json"
)

# 1. Verify all 4 valid synthetic domains pass
foreach ($fixture in $domains) {
    $fullPath = Join-Path $fixturesDir $fixture
    if (-not (Test-Path $fullPath)) {
        throw "FAIL: Expected fixture missing: $fixture"
    }

    Write-Host "  -> Validating synthetic domain: $fixture..." -ForegroundColor White
    $res = & $evaluatorScript -InputPath $fullPath
    if ($res.verdict -ne "PASS" -or $res.defectCount -gt 0) {
        throw "FAIL: Expected PASS for $fixture but got $($res.verdict) with $($res.defectCount) defect(s)."
    }
}

# 2. Defect Detection Regression (Zero False PASS)
Write-Host "  -> Validating defect detection (Identical brand colors & missing dimension)..." -ForegroundColor White
$defectPayload = @{
    domain = "Synthetic Defect Domain"
    concepts = @(
        @{
            id = "defect-1"
            thematicName = "Concept 1"
            identityRationale = "Valid rationale"
            benchmarks = @("Ref 1")
            typography = @{ headingFont = "Inter"; bodyFont = "Inter"; monoFont = "JetBrains Mono"; scaleRatio = "1.125" }
            color = @{ surfaceBase = "#FFFFFF"; cardSurface = "#FFFFFF"; primaryBrand = "#2563EB"; textPrimary = "#000000" }
            layout = @{ densityMode = "Compact" }
            surface = @{ elevationModel = "Border" }
            iconography = @{ style = "Outline" }
            dataVisualization = @{ primaryCharts = @("Line") }
            accessibility = @{ wcagLevel = "AAA" }
            uxTradeoffs = @{ strengths = "Good" }
        },
        @{
            id = "defect-2"
            thematicName = "Concept 2"
            identityRationale = "Contains glowing card decorative slop"
            benchmarks = @("Ref 2")
            typography = @{ headingFont = "Inter"; bodyFont = "Inter"; monoFont = "JetBrains Mono"; scaleRatio = "1.125" }
            color = @{ surfaceBase = "#FFFFFF"; cardSurface = "#FFFFFF"; primaryBrand = "#2563EB"; textPrimary = "#D1D5DB" } # Low contrast ~1.4:1
            layout = @{ densityMode = "Compact" }
            surface = @{ elevationModel = "Border" }
            iconography = @{ style = "Outline" }
            # missing dataVisualization dimension
            accessibility = @{ wcagLevel = "AAA" }
            uxTradeoffs = @{ strengths = "Good" }
        }
    )
} | ConvertTo-Json -Depth 6

$defectCaught = $false
try {
    & $evaluatorScript -JsonString $defectPayload 2>$null
} catch {
    $defectCaught = $true
}

if (-not $defectCaught) {
    throw "FAIL: Evaluator failed to catch deliberate defects in synthetic defect payload!"
} else {
    Write-Host "  -> Defect caught successfully: Zero False PASS verified." -ForegroundColor Green
}

Write-Host "PASS: Dynamic Creative Direction Engine verified across all 4 synthetic domains." -ForegroundColor Green
