<#
.SYNOPSIS
    Design Orchestrator 2.2 -- Native Design System Engine Runner.
.DESCRIPTION
    Executes the 7 native FigCraft design system recipes (Tokens, Central Icons,
    Atomic Masters, Variants, Linked Instances, Adaptive Auto-Layout, and Composite Patterns),
    runs the live 8-point component stress test harness, exports native .figcraft document,
    takes unselected screenshot, and runs automated canvas VQA deterministic verification.
.PARAMETER OutputDir
    Target directory for generated design system artifacts. Default: 'test-output'.
.PARAMETER SkipQa
    Skip canvas geometry/contrast QA verification.
#>

[CmdletBinding()]
param(
    [string]$OutputDir = "test-output",
    [switch]$SkipQa
)

$RepoRoot = Split-Path -Parent $PSScriptRoot
$enginePy = Join-Path $RepoRoot "scripts\figcraft_engine.py"
$verifierPs1 = Join-Path $RepoRoot "scripts\verify-canvas.ps1"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " Design Orchestrator 2.2 -- Native Design System Engine" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# Locate real Python 3 binary (bypassing Windows Store stub)
$pyCandidates = @(
    (Join-Path $env:LOCALAPPDATA "Programs\Python\Python312\python.exe"),
    (Join-Path $env:LOCALAPPDATA "Programs\Python\Python311\python.exe"),
    (Join-Path $env:ProgramFiles "Python312\python.exe"),
    (Join-Path $env:ProgramFiles "Python311\python.exe"),
    $(if (Get-Command python -ErrorAction SilentlyContinue) { (Get-Command python).Source })
) | Where-Object { $_ -and (Test-Path $_) }

$realPython = $null
foreach ($cand in $pyCandidates) {
    try {
        $out = (& $cand --version 2>&1 | Out-String).Trim()
        if ($LASTEXITCODE -eq 0 -and $out -match "Python\s+3\.\d+") {
            $realPython = $cand
            break
        }
    } catch {}
    $global:LASTEXITCODE = 0
}
if (-not $realPython) {
    throw "FAIL: Python 3.x is required to execute FigCraft Native Design System Engine."
}

# Resolve target directory
$targetDir = if ([System.IO.Path]::IsPathRooted($OutputDir)) { $OutputDir } else { Join-Path $RepoRoot $OutputDir }
if (-not (Test-Path $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
}

Write-Host "Executing FigCraft Native Engine Recipes & 8-Point Stress Tests..." -ForegroundColor White
& $realPython $enginePy $targetDir

if ($LASTEXITCODE -ne 0) {
    throw "FAIL: FigCraft Native Design System Engine encountered an error (exit code $LASTEXITCODE)."
}

$docFile = Join-Path $targetDir "native-design-system-test.figcraft"
$jsonFile = Join-Path $targetDir "native-design-system-test.json"
$pngFile = Join-Path $targetDir "native-design-system-test.png"
$reportFile = Join-Path $targetDir "stress-test-report.json"

if (-not (Test-Path $docFile) -or -not (Test-Path $jsonFile) -or -not (Test-Path $pngFile)) {
    throw "FAIL: Expected output artifacts missing in $targetDir."
}

Write-Host ""
Write-Host "Verifying generated design system with verify-canvas.ps1..." -ForegroundColor Cyan
if (-not $SkipQa) {
    $qaResult = & $verifierPs1 -DocumentPath $jsonFile -OutputDir $targetDir
    if ($qaResult.deterministicStatus -ne "PASS") {
        throw "FAIL: Deterministic Canvas QA failed with status $($qaResult.deterministicStatus)."
    }
}

Write-Host ""
Write-Host "==========================================================" -ForegroundColor Green
Write-Host " PASS: Native Design System Engine & 8-Point Stress Tests Verified." -ForegroundColor Green
Write-Host " Document:   $docFile" -ForegroundColor DarkGray
Write-Host " Screenshot: $pngFile" -ForegroundColor DarkGray
Write-Host " Audit JSON: $jsonFile" -ForegroundColor DarkGray
Write-Host "==========================================================" -ForegroundColor Green
