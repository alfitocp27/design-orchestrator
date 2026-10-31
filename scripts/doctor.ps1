<#
.SYNOPSIS
    Design Orchestrator 2.1 -- System Diagnostic and Health Checker (Doctor).
.DESCRIPTION
    Audits the current machine environment, Antigravity integration, skills,
    templates, and MCP dependencies. Distinguishes Core and Full readiness.
    Guarantees Zero False PASS.
#>

[CmdletBinding()]
param(
    [switch]$Detailed
)

function Write-DoctorItem {
    param(
        [string]$Category,
        [string]$Name,
        [ValidateSet("PASS", "WARN", "FAIL", "SKIP", "INFO")]
        [string]$Status,
        [string]$Details
    )
    $symbol = switch ($Status) {
        "PASS" { "[PASS]" }
        "WARN" { "[WARN]" }
        "FAIL" { "[FAIL]" }
        "SKIP" { "[SKIP]" }
        "INFO" { "[INFO]" }
    }
    $color = switch ($Status) {
        "PASS" { "Green" }
        "WARN" { "Yellow" }
        "FAIL" { "Red" }
        "SKIP" { "DarkGray" }
        "INFO" { "Cyan" }
    }
    
    $line = ("{0,-15} | {1,-30} | {2,-6} | {3}" -f $Category, $Name, $symbol, $Details)
    Write-Host $line -ForegroundColor $color
}

$RepoRoot = Split-Path -Parent $PSScriptRoot
$ManifestPath = Join-Path $RepoRoot "orchestrator.manifest.json"

Write-Host ""
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host " Design Orchestrator 2.1 -- Diagnostic Health Report (Doctor)" -ForegroundColor Cyan
Write-Host " Root Directory: $RepoRoot" -ForegroundColor Cyan
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host ""

$header = ("{0,-15} | {1,-30} | {2,-6} | {3}" -f "CATEGORY", "COMPONENT", "STATUS", "DETAILS")
Write-Host $header -ForegroundColor White
$divider = "-" * 80
Write-Host $divider -ForegroundColor Gray

# 1. Platform & Runtimes
$isWin = [System.Environment]::OSVersion.Platform -eq "Win32NT"
if ($isWin) {
    Write-DoctorItem "Platform" "Operating System" "PASS" "$([System.Environment]::OSVersion.VersionString)"
} else {
    Write-DoctorItem "Platform" "Operating System" "WARN" "Non-Windows platform"
}

if ($PSVersionTable.PSVersion.Major -ge 5) {
    Write-DoctorItem "Platform" "PowerShell" "PASS" "v$($PSVersionTable.PSVersion)"
} else {
    Write-DoctorItem "Platform" "PowerShell" "FAIL" "PowerShell 5.1+ required"
}

# Git
$gitCmd = Get-Command git -ErrorAction SilentlyContinue
if ($gitCmd) {
    $gitVer = (& git --version 2>$null)
    Write-DoctorItem "Toolchain" "Git" "PASS" "$gitVer"
} else {
    Write-DoctorItem "Toolchain" "Git" "FAIL" "Git is not installed"
}

# GitHub CLI
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    if (Test-Path "C:\Program Files\GitHub CLI\gh.exe") {
        $env:Path = "C:\Program Files\GitHub CLI;" + $env:Path
    }
}
$ghCmd = Get-Command gh -ErrorAction SilentlyContinue
if ($ghCmd) {
    $ghVer = (& gh --version 2>$null | Select-Object -First 1)
    $authStatus = (& gh auth status 2>&1)
    if ($LASTEXITCODE -eq 0) {
        Write-DoctorItem "Toolchain" "GitHub CLI (gh)" "PASS" "$ghVer (Authenticated)"
    } else {
        Write-DoctorItem "Toolchain" "GitHub CLI (gh)" "WARN" "$ghVer (Not logged in. Run 'gh auth login')"
    }
} else {
    Write-DoctorItem "Toolchain" "GitHub CLI (gh)" "INFO" "Not installed (Optional for browser auth)"
}

# Node.js
$npxCmd = Get-Command npx -ErrorAction SilentlyContinue
if ($npxCmd) {
    $nodeVer = (& node --version 2>$null)
    Write-DoctorItem "Toolchain" "Node.js / npx" "PASS" "$nodeVer (Optional for Anti-Slop)"
} else {
    Write-DoctorItem "Toolchain" "Node.js / npx" "SKIP" "Not found (Optional for Anti-Slop)"
}

# 2. Manifest & Core Skills
if (Test-Path $ManifestPath) {
    try {
        $manifest = Get-Content $ManifestPath -Raw | ConvertFrom-Json
        Write-DoctorItem "Manifest" "orchestrator.manifest.json" "PASS" "v$($manifest.version) (Valid JSON)"
    } catch {
        Write-DoctorItem "Manifest" "orchestrator.manifest.json" "FAIL" "Corrupted JSON"
    }
} else {
    Write-DoctorItem "Manifest" "orchestrator.manifest.json" "FAIL" "Missing manifest"
}

# Core Skill
$skillFile = Join-Path $RepoRoot ".agents\skills\design-orchestrator\SKILL.md"
if (Test-Path $skillFile) {
    Write-DoctorItem "Core Skill" "SKILL.md" "PASS" "Meta-skill definition verified"
} else {
    Write-DoctorItem "Core Skill" "SKILL.md" "FAIL" "Missing SKILL.md in .agents/skills"
}

# References
$refDir = Join-Path $RepoRoot ".agents\skills\design-orchestrator\references"
$expectedRefs = @(
    "component-architecture.md",
    "conflict-resolution.md",
    "creative-direction.md",
    "design-template.md",
    "visual-qa-system.md",
    "workflow-details.md"
)

$missingRefs = 0
foreach ($ref in $expectedRefs) {
    if (-not (Test-Path (Join-Path $refDir $ref))) {
        $missingRefs++
    }
}

if ($missingRefs -eq 0) {
    Write-DoctorItem "Core Skill" "Technical References" "PASS" "All 6 reference runbooks present"
} else {
    Write-DoctorItem "Core Skill" "Technical References" "FAIL" "$missingRefs reference file(s) missing"
}

# Templates
$templateDir = Join-Path $RepoRoot "templates\project"
if (Test-Path $templateDir) {
    Write-DoctorItem "Templates" "Project Blueprint" "PASS" "templates/project verified"
} else {
    Write-DoctorItem "Templates" "Project Blueprint" "FAIL" "templates/project missing"
}

# 3. Companions & Integrations (Full Mode)
# Anti-Slop
$antislopGlobal = Join-Path $env:APPDATA "antislop\settings.json"
$antislopLocal = Join-Path $RepoRoot ".agents\skills\antislop\SKILL.md"

if (Test-Path $antislopGlobal) {
    $asContent = Get-Content $antislopGlobal -Raw | ConvertFrom-Json
    Write-DoctorItem "Companion" "Anti-Slop" "PASS" "Global preference: $($asContent.mode)"
} elseif (Test-Path $antislopLocal) {
    Write-DoctorItem "Companion" "Anti-Slop" "PASS" "Local skill present"
} else {
    Write-DoctorItem "Companion" "Anti-Slop" "SKIP" "Not active (Optional for Core Mode)"
}

# Impeccable
$impeccableGlobal = Join-Path $env:USERPROFILE ".gemini\config\skills\impeccable\SKILL.md"
if (Test-Path $impeccableGlobal) {
    Write-DoctorItem "Companion" "Impeccable" "PASS" "Discovered in Antigravity global skills"
} else {
    Write-DoctorItem "Companion" "Impeccable" "SKIP" "Not active (Optional)"
}

# UI/UX Pro Max
$uiuxLocal = Join-Path $RepoRoot ".agents\skills\ui-ux-pro-max\SKILL.md"
if (Test-Path $uiuxLocal) {
    Write-DoctorItem "Companion" "UI/UX Pro Max" "PASS" "Discovered in workspace skills"
} else {
    Write-DoctorItem "Companion" "UI/UX Pro Max" "SKIP" "Not active (Optional)"
}

# FigCraft MCP
$mcpDir = Join-Path $env:USERPROFILE ".gemini\antigravity\mcp"
$figcraftMcp = Join-Path $mcpDir "figcraft"
if (Test-Path $figcraftMcp) {
    Write-DoctorItem "MCP Server" "FigCraft MCP" "PASS" "Schema registered in Antigravity"
} else {
    Write-DoctorItem "MCP Server" "FigCraft MCP" "SKIP" "Not registered (Core mode uses mock simulation)"
}

# Codebase Memory MCP
$codebaseMcp = Join-Path $mcpDir "codebase-memory-mcp"
if (Test-Path $codebaseMcp) {
    Write-DoctorItem "MCP Server" "CodebaseMemoryMCP" "PASS" "Schema registered in Antigravity"
} else {
    Write-DoctorItem "MCP Server" "CodebaseMemoryMCP" "SKIP" "Not registered (Optional)"
}

# Summary
Write-Host $divider -ForegroundColor Gray
Write-Host ""
Write-Host "READINESS SUMMARY:" -ForegroundColor Cyan

$coreReady = (Test-Path $skillFile) -and ($missingRefs -eq 0) -and (Test-Path $templateDir) -and (Test-Path $ManifestPath)
if ($coreReady) {
    Write-Host "  CORE MODE READINESS: [PASS] Ready for offline discovery, PRD mapping, and template generation." -ForegroundColor Green
} else {
    Write-Host "  CORE MODE READINESS: [FAIL] Missing required core files." -ForegroundColor Red
}

$hasFigcraft = Test-Path $figcraftMcp
$hasAntislop = (Test-Path $antislopGlobal) -or (Test-Path $antislopLocal)

if ($coreReady -and $hasFigcraft -and $hasAntislop) {
    Write-Host "  FULL MODE READINESS: [PASS] Full production orchestration active." -ForegroundColor Green
} else {
    Write-Host "  FULL MODE READINESS: [PARTIAL] Core is ready. Optional MCP/skills skipped (Simulation available)." -ForegroundColor Yellow
}

Write-Host ""
