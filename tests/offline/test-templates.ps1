<#
.SYNOPSIS
    Offline test: Validates project template blueprint completeness.
#>
param([string]$RepoRoot)

if (-not $RepoRoot) { $RepoRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent }
$TemplateDir = Join-Path $RepoRoot "templates\project"

Write-Host "Running Test: Project Template Blueprints..." -ForegroundColor Cyan

if (-not (Test-Path $TemplateDir)) {
    throw "FAIL: Template directory missing at $TemplateDir"
}

$requiredFiles = @(
    "AGENTS.md",
    "DESIGN.md",
    "PROJECT.md",
    "REQUIREMENTS_MAP.md",
    "SCREENS.md",
    "SESSION_HANDOFF.md"
)

foreach ($file in $requiredFiles) {
    $fullPath = Join-Path $TemplateDir $file
    if (-not (Test-Path $fullPath)) {
        throw "FAIL: Required template file '$file' missing in templates/project"
    }
}

Write-Host "PASS: All 6 mandatory project blueprint files are present." -ForegroundColor Green
