<#
.SYNOPSIS
    Offline test: Verifies the Automated Canvas Geometry & Contrast Verifier against synthetic fixtures.
.DESCRIPTION
    Executes scripts/verify-canvas.ps1 against valid and defective synthetic fixtures.
    Asserts exact acceptance criteria:
      1. Valid fixture produces PASS.
      2. Misaligned column fixture produces FAIL with actual numeric delta.
      3. Overflow fixture produces FAIL.
      4. Low contrast fixture produces FAIL with actual calculated ratio.
      5. Incomplete information fixture produces NOT_VERIFIABLE (never PASS).
      6. Fake component (plain frame for repeating control) produces FAIL.
#>
param([string]$RepoRoot)

if (-not $RepoRoot) { $RepoRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent }

Write-Host "Running Test: Automated Canvas Geometry & Contrast Verifier (Synthetic Fixtures)..." -ForegroundColor Cyan

$verifierScript = Join-Path $RepoRoot "scripts\verify-canvas.ps1"
$fixturesDir = Join-Path $RepoRoot "tests\fixtures\synthetic"

if (-not (Test-Path $verifierScript)) {
    throw "FAIL: Verifier script missing at '$verifierScript'"
}
if (-not (Test-Path $fixturesDir)) {
    throw "FAIL: Fixtures directory missing at '$fixturesDir'"
}

# --- Test Case 1: Valid Fixture ---
Write-Host "  -> Case 1: Valid Synthetic Document..." -ForegroundColor DarkGray
$validFile = Join-Path $fixturesDir "valid-document.json"
$resValid = & $verifierScript -DocumentPath $validFile -Mode Mock
if ($resValid.deterministicStatus -ne "PASS") {
    throw ("FAIL Case 1: Expected deterministicStatus 'PASS', got '{0}'" -f $resValid.deterministicStatus)
}
if ($resValid.summary.p1Blockers -ne 0 -or $resValid.summary.p2Majors -ne 0) {
    throw ("FAIL Case 1: Expected 0 P1/P2 defects, got P1={0}, P2={1}" -f $resValid.summary.p1Blockers, $resValid.summary.p2Majors)
}
Write-Host "     PASS: Valid fixture passed with 0 P1/P2 defects." -ForegroundColor Green

# --- Test Case 2: Misaligned Table Column Fixture ---
Write-Host "  -> Case 2: Column Misalignment Defect..." -ForegroundColor DarkGray
$alignFile = Join-Path $fixturesDir "defect-alignment.json"
$resAlign = & $verifierScript -DocumentPath $alignFile -Mode Mock
if ($resAlign.deterministicStatus -ne "FAIL") {
    throw ("FAIL Case 2: Expected deterministicStatus 'FAIL', got '{0}'" -f $resAlign.deterministicStatus)
}
$alignFinding = $resAlign.findings | Where-Object { $_.category -eq "Geometry/TableAlignment" }
if (-not $alignFinding) {
    throw "FAIL Case 2: Expected Geometry/TableAlignment finding not reported!"
}
if ($alignFinding.evidence -notmatch "deltaX = 4\.0px") {
    throw ("FAIL Case 2: Expected numeric delta evidence 'deltaX = 4.0px', got '{0}'" -f $alignFinding.evidence)
}
Write-Host ("     PASS: Alignment defect caught: {0}" -f $alignFinding.evidence) -ForegroundColor Green

# --- Test Case 3: Container Overflow Fixture ---
Write-Host "  -> Case 3: Container Overflow Defect..." -ForegroundColor DarkGray
$overflowFile = Join-Path $fixturesDir "defect-overflow.json"
$resOverflow = & $verifierScript -DocumentPath $overflowFile -Mode Mock
if ($resOverflow.deterministicStatus -ne "FAIL") {
    throw ("FAIL Case 3: Expected deterministicStatus 'FAIL', got '{0}'" -f $resOverflow.deterministicStatus)
}
$overflowFinding = $resOverflow.findings | Where-Object { $_.category -eq "Geometry/ContainerOverflow" }
if (-not $overflowFinding) {
    throw "FAIL Case 3: Expected Geometry/ContainerOverflow finding not reported!"
}
Write-Host ("     PASS: Overflow defect caught: {0}" -f $overflowFinding.evidence) -ForegroundColor Green

# --- Test Case 4: Low Contrast Fixture ---
Write-Host "  -> Case 4: WCAG 2.2 Contrast Defect..." -ForegroundColor DarkGray
$contrastFile = Join-Path $fixturesDir "defect-contrast.json"
$resContrast = & $verifierScript -DocumentPath $contrastFile -Mode Mock
if ($resContrast.deterministicStatus -ne "FAIL") {
    throw ("FAIL Case 4: Expected deterministicStatus 'FAIL', got '{0}'" -f $resContrast.deterministicStatus)
}
$contrastFinding = $resContrast.findings | Where-Object { $_.category -eq "Visual/WCAG_Contrast" }
if (-not $contrastFinding) {
    throw "FAIL Case 4: Expected Visual/WCAG_Contrast finding not reported!"
}
if ($contrastFinding.evidence -notmatch "Ratio = 2\.56:1") {
    throw ("FAIL Case 4: Expected ratio evidence 'Ratio = 2.56:1', got '{0}'" -f $contrastFinding.evidence)
}
Write-Host ("     PASS: Contrast defect caught: {0}" -f $contrastFinding.evidence) -ForegroundColor Green

# --- Test Case 5: Incomplete Information Fixture ---
Write-Host "  -> Case 5: Incomplete Information (Unverifiable)..." -ForegroundColor DarkGray
$incompleteFile = Join-Path $fixturesDir "defect-incomplete.json"
$resIncomplete = & $verifierScript -DocumentPath $incompleteFile -Mode Mock
if ($resIncomplete.deterministicStatus -ne "NOT_VERIFIABLE") {
    throw ("FAIL Case 5: Incomplete information MUST produce 'NOT_VERIFIABLE', got '{0}'" -f $resIncomplete.deterministicStatus)
}
if ($resIncomplete.deterministicStatus -eq "PASS") {
    throw "FAIL Case 5: Incomplete information must NEVER be reported as PASS!"
}
Write-Host "     PASS: Incomplete info correctly evaluated as NOT_VERIFIABLE." -ForegroundColor Green

# --- Test Case 6: Fake Component Fixture ---
Write-Host "  -> Case 6: Fake Component (Plain Frame) Defect..." -ForegroundColor DarkGray
$fakeCompFile = Join-Path $fixturesDir "defect-fake-component.json"
$resFake = & $verifierScript -DocumentPath $fakeCompFile -Mode Mock
if ($resFake.deterministicStatus -ne "FAIL") {
    throw ("FAIL Case 6: Expected deterministicStatus 'FAIL', got '{0}'" -f $resFake.deterministicStatus)
}
$compFinding = $resFake.findings | Where-Object { $_.category -eq "Component/Architecture" }
if (-not $compFinding) {
    throw "FAIL Case 6: Expected Component/Architecture finding not reported!"
}
Write-Host ("     PASS: Fake component caught: {0}" -f $compFinding.title) -ForegroundColor Green

Write-Host "PASS: All 6 automated verifier test cases verified with zero false PASS." -ForegroundColor Green
