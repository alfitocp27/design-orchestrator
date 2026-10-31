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

# Optional integration manifest validation
$needMcpManifest = Join-Path $RepoRoot "integrations\needmcp\needmcp.manifest.json"
if (Test-Path $needMcpManifest) {
    $needRaw = Get-Content $needMcpManifest -Raw
    $needData = $needRaw | ConvertFrom-Json
    if ($needData.name -ne "needmcp") {
        throw "FAIL: NeedMCP manifest name must be 'needmcp'"
    }
    if ($needData.verifiedTools.Count -ne 6) {
        throw "FAIL: NeedMCP manifest must declare exactly 6 verified tools"
    }
    $sel = $needData.verifiedTools | Where-Object { $_.name -eq "selectStyle" }
    if (-not $sel -or -not $sel.gated) {
        throw "FAIL: selectStyle must be gated in NeedMCP manifest"
    }
}

Write-Host "PASS: Manifest schema, modes, and integration manifests are valid." -ForegroundColor Green
