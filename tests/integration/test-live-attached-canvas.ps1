<#
.SYNOPSIS
    Integration test: Live FigCraft Desktop Attached Mode & Dual-Mode Architecture validation.
#>
param([string]$RepoRoot)

Write-Host "Running Integration Test: Live FigCraft Desktop Attached Mode & Dual-Mode Architecture..." -ForegroundColor Cyan

# Locate Python 3 dynamically
$pythonCmd = Get-Command python -ErrorAction SilentlyContinue
$pyCandidates = @(
    $(if ($pythonCmd) { $pythonCmd.Source }),
    (Join-Path $env:LOCALAPPDATA "Programs\Python\Python312\python.exe"),
    (Join-Path $env:LOCALAPPDATA "Programs\Python\Python311\python.exe"),
    (Join-Path $env:ProgramFiles "Python312\python.exe"),
    (Join-Path $env:ProgramFiles "Python311\python.exe")
) | Where-Object { $_ -and (Test-Path $_) }

$pyBin = $null
foreach ($cand in $pyCandidates) {
    try {
        $out = (& $cand --version 2>&1 | Out-String).Trim()
        if ($LASTEXITCODE -eq 0 -and $out -match "Python\s+3\.\d+") {
            $pyBin = $cand
            break
        }
    } catch {}
    $global:LASTEXITCODE = 0
}

if (-not $pyBin) {
    Write-Host "SKIP: Python 3 not detected in standard paths." -ForegroundColor Yellow
    return
}

$testScript = Join-Path $RepoRoot "tests\integration\test_live_attached_canvas.py"
if (-not (Test-Path $testScript)) {
    Write-Host "SKIP: Test script not found." -ForegroundColor Yellow
    return
}

& $pyBin $testScript
if ($LASTEXITCODE -ne 0) {
    throw "Integration test failed with exit code $LASTEXITCODE"
}
