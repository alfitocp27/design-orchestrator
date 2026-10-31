<#
.SYNOPSIS
    Design Orchestrator 2.2 -- Deterministic Creative Direction Evaluator.
.DESCRIPTION
    Validates that formulated creative direction concepts satisfy the 10 mandatory
    dimensions, structural divergence across concepts, WCAG 2.2 contrast compliance,
    and anti-slop guardrails. Separates deterministic verification from subjective UX review.
.PARAMETER InputPath
    Path to JSON file containing creative direction concepts.
.PARAMETER JsonString
    Raw JSON string containing creative direction concepts.
#>

[CmdletBinding()]
param(
    [string]$InputPath,
    [string]$JsonString
)

function Convert-HexToRgb {
    param([string]$Hex)
    $clean = $Hex.Trim().TrimStart('#')
    if ($clean.Length -eq 3) {
        $r = [Convert]::ToInt32($clean.Substring(0, 1) + $clean.Substring(0, 1), 16)
        $g = [Convert]::ToInt32($clean.Substring(1, 1) + $clean.Substring(1, 1), 16)
        $b = [Convert]::ToInt32($clean.Substring(2, 1) + $clean.Substring(2, 1), 16)
        return @{ R = $r; G = $g; B = $b }
    } elseif ($clean.Length -ge 6) {
        $r = [Convert]::ToInt32($clean.Substring(0, 2), 16)
        $g = [Convert]::ToInt32($clean.Substring(2, 2), 16)
        $b = [Convert]::ToInt32($clean.Substring(4, 2), 16)
        return @{ R = $r; G = $g; B = $b }
    }
    return $null
}

function Get-RelativeLuminance {
    param($rgb)
    if (-not $rgb) { return 0.0 }
    $channels = @($rgb.R, $rgb.G, $rgb.B) | ForEach-Object {
        $c = $_ / 255.0
        if ($c -le 0.04045) {
            $c / 12.92
        } else {
            [Math]::Pow((($c + 0.055) / 1.055), 2.4)
        }
    }
    return (0.2126 * $channels[0]) + (0.7152 * $channels[1]) + (0.0722 * $channels[2])
}

function Calculate-WcagContrastRatio {
    param([string]$Hex1, [string]$Hex2)
    $rgb1 = Convert-HexToRgb $Hex1
    $rgb2 = Convert-HexToRgb $Hex2
    if (-not $rgb1 -or -not $rgb2) { return 0.0 }
    $l1 = Get-RelativeLuminance $rgb1
    $l2 = Get-RelativeLuminance $rgb2
    $lighter = [Math]::Max($l1, $l2)
    $darker = [Math]::Min($l1, $l2)
    return [Math]::Round(($lighter + 0.05) / ($darker + 0.05), 2)
}

# Resolve input data
$rawJson = $null
if ($InputPath -and (Test-Path $InputPath)) {
    $rawJson = Get-Content $InputPath -Raw
} elseif ($JsonString) {
    $rawJson = $JsonString
} else {
    throw "InputPath or JsonString parameter is required."
}

$payload = $rawJson | ConvertFrom-Json
$concepts = $payload.concepts
$domainName = if ($payload.domain) { $payload.domain } else { "Generic Domain" }

$defects = @()
$warnings = @()
$findings = @()

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " Creative Direction Evaluator -- $domainName" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Concept Count Verification
if (-not $concepts -or $concepts.Count -lt 2 -or $concepts.Count -gt 3) {
    $defects += "FAIL: Creative Direction requires exactly 2 or 3 distinct concepts. Found: $($concepts.Count)"
} else {
    $findings += "PASS: Concept count ($($concepts.Count)) meets exploration requirements."
}

# 2. Mandatory Dimensions Completeness Check per Concept
$mandatoryFields = @(
    "id",
    "thematicName",
    "identityRationale",
    "benchmarks",
    "typography",
    "color",
    "layout",
    "surface",
    "iconography",
    "dataVisualization",
    "accessibility",
    "uxTradeoffs"
)

$bannedKeywords = @(
    "mesh gradient",
    "glowing card",
    "floating card without anchor",
    "neon border",
    "gratuitous glow"
)

$index = 0
foreach ($concept in $concepts) {
    $index++
    $cName = if ($concept.thematicName) { $concept.thematicName } else { "Concept $index" }
    
    # Check 10 dimensions
    foreach ($field in $mandatoryFields) {
        $val = $concept.$field
        if ($val -eq $null -or ($val -is [string] -and [string]::IsNullOrWhiteSpace($val))) {
            $defects += "FAIL [$cName]: Missing mandatory dimension '$field'."
        }
    }

    # Anti-slop checks in rationale
    if ($concept.identityRationale) {
        foreach ($banned in $bannedKeywords) {
            if ($concept.identityRationale.ToLower().Contains($banned.ToLower())) {
                $defects += "FAIL [$cName]: Anti-Slop violation. Prohibited pattern '$banned' found in rationale."
            }
        }
    }

    # WCAG Contrast verification
    if ($concept.color) {
        $fg = $concept.color.textPrimary
        $bg = $concept.color.surfaceBase
        $card = $concept.color.cardSurface
        
        if ($fg -and $bg) {
            $ratioBg = Calculate-WcagContrastRatio $fg $bg
            if ($ratioBg -lt 4.5) {
                $defects += "FAIL [$cName]: Contrast ratio for textPrimary ($fg) on surfaceBase ($bg) is ${ratioBg}:1 (< 4.5:1 required by WCAG AA)."
            } else {
                $findings += "PASS [$cName]: Text contrast on canvas is ${ratioBg}:1 (WCAG AA compliant)."
            }
        }
        
        if ($fg -and $card) {
            $ratioCard = Calculate-WcagContrastRatio $fg $card
            if ($ratioCard -lt 4.5) {
                $defects += "FAIL [$cName]: Contrast ratio for textPrimary ($fg) on cardSurface ($card) is ${ratioCard}:1 (< 4.5:1 required by WCAG AA)."
            } else {
                $findings += "PASS [$cName]: Text contrast on card is ${ratioCard}:1 (WCAG AA compliant)."
            }
        }
    }
}

# 3. Structural & Visual Divergence Verification across Concepts
if ($concepts.Count -ge 2) {
    # Check 3.1: Typography divergence (different heading fonts)
    $headingFonts = @($concepts | ForEach-Object { $_.typography.headingFont })
    $uniqueHeadingFonts = $headingFonts | Select-Object -Unique
    if ($uniqueHeadingFonts.Count -lt $concepts.Count) {
        $warnings += "WARN: Typography heading fonts have overlapping families ($($headingFonts -join ', ')). Concepts should explore distinct typographic characters."
    } else {
        $findings += "PASS: Typography heading families are strictly divergent ($($headingFonts -join ' vs. '))."
    }

    # Check 3.2: Primary brand hue divergence
    $primaryColors = @($concepts | ForEach-Object { $_.color.primaryBrand })
    $uniquePrimaries = $primaryColors | Select-Object -Unique
    if ($uniquePrimaries.Count -lt $concepts.Count) {
        $defects += "FAIL: Primary brand colors are identical across concepts ($($primaryColors -join ', ')). Visual concepts must explore distinct palettes."
    } else {
        $findings += "PASS: Primary brand colors are divergent ($($primaryColors -join ' vs. '))."
    }

    # Check 3.3: Spatial density / layout divergence
    $layoutDensities = @($concepts | ForEach-Object { $_.layout.densityMode })
    $uniqueDensities = $layoutDensities | Select-Object -Unique
    if ($uniqueDensities.Count -lt 2) {
        $warnings += "WARN: All concepts share identical densityMode '$($layoutDensities[0])'. Consider offering contrasting density models."
    } else {
        $findings += "PASS: Layout density models are differentiated ($($layoutDensities -join ' vs. '))."
    }
}

# Output report
Write-Host ""
foreach ($f in $findings) {
    Write-Host "  [OK] $f" -ForegroundColor Green
}
foreach ($w in $warnings) {
    Write-Host "  [WARN] $w" -ForegroundColor Yellow
}
foreach ($d in $defects) {
    Write-Host "  [ERR] $d" -ForegroundColor Red
}

$verdict = if ($defects.Count -eq 0) { "PASS" } else { "FAIL" }
Write-Host ""
Write-Host "----------------------------------------------------------" -ForegroundColor Gray
Write-Host " EVALUATION VERDICT: [$verdict] (Defects: $($defects.Count), Warnings: $($warnings.Count))" -ForegroundColor $(if ($verdict -eq "PASS") { "Green" } else { "Red" })
Write-Host "----------------------------------------------------------" -ForegroundColor Gray

$resultObj = @{
    domain = $domainName
    verdict = $verdict
    defectCount = $defects.Count
    warningCount = $warnings.Count
    findings = $findings
    defects = $defects
    warnings = $warnings
}

if ($verdict -eq "PASS") {
    return $resultObj
} else {
    throw "Creative Direction Evaluation Failed with $($defects.Count) defect(s)."
}
