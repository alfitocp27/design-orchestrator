<#
.SYNOPSIS
    Offline test: Validates SKILL.md structure and internal reference link integrity.
#>
param([string]$RepoRoot)

if (-not $RepoRoot) { $RepoRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent }
$SkillPath = Join-Path $RepoRoot ".agents\skills\design-orchestrator\SKILL.md"
$RefDir = Join-Path $RepoRoot ".agents\skills\design-orchestrator\references"

Write-Host "Running Test: Skill Structure & Reference Integrity..." -ForegroundColor Cyan

if (-not (Test-Path $SkillPath)) {
    throw "FAIL: SKILL.md missing at $SkillPath"
}

$skillContent = Get-Content $SkillPath -Raw

# Check frontmatter
if ($skillContent -notmatch "(?s)^---\s*\r?\nname:\s*design-orchestrator") {
    throw "FAIL: Valid YAML frontmatter with 'name: design-orchestrator' missing in SKILL.md"
}

# Check reference links in SKILL.md
$matches = [regex]::Matches($skillContent, '\[.*?\]\((references/[a-zA-Z0-9_\-]+\.md)\)')
if ($matches.Count -eq 0) {
    throw "FAIL: No reference links found in SKILL.md"
}

foreach ($m in $matches) {
    $refRelative = $m.Groups[1].Value
    $refFile = Join-Path $RepoRoot ".agents\skills\design-orchestrator\$refRelative"
    if (-not (Test-Path $refFile)) {
        throw "FAIL: Broken reference link in SKILL.md: $refRelative does not exist at $refFile"
    }
}

Write-Host "PASS: Verified $($matches.Count) reference links. All target files exist." -ForegroundColor Green
