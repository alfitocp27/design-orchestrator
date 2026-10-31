<#
.SYNOPSIS
    Offline test: Validates orchestrator.manifest.json schema and required fields.
#>
param([string]$RepoRoot)

if (-not $RepoRoot) { $RepoRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent }
$ManifestPath = Join-Path $RepoRoot "orchestrator.manifest.json"

Write-Host "Running Test: Manifest Schema & Field Integrity..." -ForegroundColor Cyan

if (-not (Test-Path $ManifestPath)) {
    throw "FAIL: Manifest missing at $ManifestPath"
}

$raw = Get-Content $ManifestPath -Raw
$json = $raw | ConvertFrom-Json

if ($json.name -ne "design-orchestrator") {
    throw "FAIL: Manifest name must be 'design-orchestrator', got '$($json.name)'"
}

if (-not $json.version) {
    throw "FAIL: Manifest version missing"
}

if (-not $json.modes.core) {
    throw "FAIL: Core mode definition missing in manifest"
}

if (-not $json.modes.full) {
    throw "FAIL: Full mode definition missing in manifest"
}

if (-not $json.dependencies."design-orchestrator") {
    throw "FAIL: design-orchestrator core dependency missing in manifest"
}

Write-Host "PASS: Manifest schema and modes are valid." -ForegroundColor Green
