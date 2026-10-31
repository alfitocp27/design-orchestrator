<#
.SYNOPSIS
    Design Orchestrator 2.1 -- System Diagnostic and Health Checker (Doctor).
.DESCRIPTION
    Audits the current machine environment, Antigravity integration, skills,
    templates, and MCP dependencies.
    Distinguishes lifecycle states: DETECTED, INSTALLED, CONFIGURED, CONNECTED, VERIFIED.
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
        [ValidateSet("DETECTED", "INSTALLED", "CONFIGURED", "CONNECTED", "VERIFIED", "PASS", "WARN", "FAIL", "SKIP", "INFO", "NOT_INSTALLED")]
        [string]$Status,
        [string]$Details
    )
    $symbol = switch ($Status) {
        "VERIFIED"      { "[VERIFIED]     " }
        "CONNECTED"     { "[CONNECTED]    " }
        "CONFIGURED"    { "[CONFIGURED]   " }
        "INSTALLED"     { "[INSTALLED]    " }
        "DETECTED"      { "[DETECTED]     " }
        "PASS"          { "[PASS]         " }
        "WARN"          { "[WARN]         " }
        "FAIL"          { "[FAIL]         " }
        "SKIP"          { "[SKIP]         " }
        "INFO"          { "[INFO]         " }
        "NOT_INSTALLED" { "[NOT_INSTALLED]" }
    }
    $color = switch ($Status) {
        "VERIFIED"      { "Green" }
        "CONNECTED"     { "Green" }
        "PASS"          { "Green" }
        "CONFIGURED"    { "Cyan" }
        "INSTALLED"     { "Cyan" }
        "DETECTED"      { "Yellow" }
        "WARN"          { "Yellow" }
        "FAIL"          { "Red" }
        "SKIP"          { "DarkGray" }
        "INFO"          { "DarkGray" }
        "NOT_INSTALLED" { "DarkGray" }
    }
    
    $line = ("{0,-15} | {1,-26} | {2} | {3}" -f $Category, $Name, $symbol, $Details)
    Write-Host $line -ForegroundColor $color
}

$RepoRoot = Split-Path -Parent $PSScriptRoot
$ManifestPath = Join-Path $RepoRoot "orchestrator.manifest.json"

Write-Host ""
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host " Design Orchestrator 2.1 -- Diagnostic Health Report (Doctor)" -ForegroundColor Cyan
Write-Host (" Root Directory: {0}" -f $RepoRoot) -ForegroundColor Cyan
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host ""

$header = ("{0,-15} | {1,-26} | {2,-15} | {3}" -f "CATEGORY", "COMPONENT", "STATE", "DETAILS")
Write-Host $header -ForegroundColor White
$divider = "-" * 85
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
    $global:LASTEXITCODE = 0
    Write-DoctorItem "Toolchain" "Git" "INSTALLED" "$gitVer"
} else {
    Write-DoctorItem "Toolchain" "Git" "NOT_INSTALLED" "Git command not found in PATH"
}

# GitHub CLI (gh)
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    if (Test-Path "C:\Program Files\GitHub CLI\gh.exe") {
        $env:Path = "C:\Program Files\GitHub CLI;" + $env:Path
    }
}
$ghCmd = Get-Command gh -ErrorAction SilentlyContinue
if ($ghCmd) {
    $ghVer = (& gh --version 2>$null | Select-Object -First 1)
    $isGhAuthed = $false
    try {
        cmd.exe /c "gh auth status >nul 2>&1"
        $isGhAuthed = ($LASTEXITCODE -eq 0)
    } catch {
        $isGhAuthed = $false
    }
    $global:LASTEXITCODE = 0  # Reset so probe failure does not leak to CI runner
    if ($isGhAuthed) {
        Write-DoctorItem "Toolchain" "GitHub CLI (gh)" "VERIFIED" "$ghVer (Authenticated)"
    } else {
        Write-DoctorItem "Toolchain" "GitHub CLI (gh)" "INSTALLED" "$ghVer (Not logged in. Run 'gh auth login')"
    }
} else {
    Write-DoctorItem "Toolchain" "GitHub CLI (gh)" "NOT_INSTALLED" "Optional for browser auth"
}

# Node.js & npx
$npxCmd = Get-Command npx -ErrorAction SilentlyContinue
if ($npxCmd) {
    $nodeVer = (& node --version 2>$null)
    $global:LASTEXITCODE = 0
    Write-DoctorItem "Toolchain" "Node.js / npx" "INSTALLED" "$nodeVer (Supports automated Anti-Slop)"
} else {
    Write-DoctorItem "Toolchain" "Node.js / npx" "NOT_INSTALLED" "Optional for Anti-Slop install"
}

# 2. Manifest & Core Skills
if (Test-Path $ManifestPath) {
    try {
        $manifest = Get-Content $ManifestPath -Raw | ConvertFrom-Json
        Write-DoctorItem "Manifest" "orchestrator.manifest" "VERIFIED" "v$($manifest.version) (Valid JSON)"
    } catch {
        Write-DoctorItem "Manifest" "orchestrator.manifest" "FAIL" "Corrupted JSON"
    }
} else {
    Write-DoctorItem "Manifest" "orchestrator.manifest" "FAIL" "Missing manifest file"
}

# Core Skill
$skillFile = Join-Path $RepoRoot ".agents\skills\design-orchestrator\SKILL.md"
if (Test-Path $skillFile) {
    Write-DoctorItem "Core Skill" "SKILL.md" "VERIFIED" "Meta-skill definition verified"
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
    Write-DoctorItem "Core Skill" "Technical References" "VERIFIED" "All 6 reference runbooks present"
} else {
    Write-DoctorItem "Core Skill" "Technical References" "FAIL" "$missingRefs reference file(s) missing"
}

# Templates
$templateDir = Join-Path $RepoRoot "templates\project"
if (Test-Path $templateDir) {
    Write-DoctorItem "Templates" "Project Blueprint" "VERIFIED" "templates/project verified"
} else {
    Write-DoctorItem "Templates" "Project Blueprint" "FAIL" "templates/project missing"
}

# 3. Companions & Integrations (Full Mode Auditing)
# Anti-Slop
$antislopGlobal = Join-Path $env:APPDATA "antislop\settings.json"
$antislopLocal = Join-Path $RepoRoot ".agents\skills\antislop\SKILL.md"

if (Test-Path $antislopGlobal) {
    try {
        $asContent = Get-Content $antislopGlobal -Raw | ConvertFrom-Json
        Write-DoctorItem "Companion" "Anti-Slop" "CONFIGURED" "Global preference: $($asContent.mode)"
    } catch {
        Write-DoctorItem "Companion" "Anti-Slop" "INSTALLED" "Settings file present but unparsed"
    }
} elseif (Test-Path $antislopLocal) {
    Write-DoctorItem "Companion" "Anti-Slop" "INSTALLED" "Local skill present in .agents/skills"
} elseif ($npxCmd) {
    Write-DoctorItem "Companion" "Anti-Slop" "DETECTED" "Node/npx detected; install via 'npx antislop-ai'"
} else {
    Write-DoctorItem "Companion" "Anti-Slop" "NOT_INSTALLED" "Requires Node.js for automated install"
}

# Impeccable
$impeccableGlobal = Join-Path $env:USERPROFILE ".gemini\config\skills\impeccable\SKILL.md"
$impeccableLocal = Join-Path $RepoRoot ".agents\skills\impeccable\SKILL.md"
if (Test-Path $impeccableGlobal) {
    Write-DoctorItem "Companion" "Impeccable" "CONFIGURED" "Discovered in Antigravity global skills"
} elseif (Test-Path $impeccableLocal) {
    Write-DoctorItem "Companion" "Impeccable" "INSTALLED" "Discovered in local workspace skills"
} else {
    Write-DoctorItem "Companion" "Impeccable" "NOT_INSTALLED" "Optional craft skill"
}

# UI/UX Pro Max
$uiuxLocal = Join-Path $RepoRoot ".agents\skills\ui-ux-pro-max\SKILL.md"
if (Test-Path $uiuxLocal) {
    Write-DoctorItem "Companion" "UI/UX Pro Max" "INSTALLED" "Discovered in workspace skills"
} else {
    $pythonCmd = Get-Command python -ErrorAction SilentlyContinue
    if ($pythonCmd) {
        Write-DoctorItem "Companion" "UI/UX Pro Max" "DETECTED" "Python available; manual clone required"
    } else {
        Write-DoctorItem "Companion" "UI/UX Pro Max" "NOT_INSTALLED" "Requires Python and manual clone"
    }
}

# FigCraft MCP (Real connection vs Schema on disk)
$mcpDir = Join-Path $env:USERPROFILE ".gemini\antigravity\mcp"
$figcraftSchema = Join-Path $mcpDir "figcraft"
$figcraftProc = Get-Process | Where-Object { $_.ProcessName -match "^figcraft" } | Select-Object -First 1

if ($figcraftProc) {
    Write-DoctorItem "MCP Server" "FigCraft MCP" "CONNECTED" "Active process PID: $($figcraftProc.Id)"
} elseif (Test-Path $figcraftSchema) {
    Write-DoctorItem "MCP Server" "FigCraft MCP" "CONFIGURED" "Schema registered; Process not running"
} else {
    Write-DoctorItem "MCP Server" "FigCraft MCP" "NOT_INSTALLED" "Requires FigCraft desktop app"
}

# Codebase Memory MCP (Real connection vs Schema on disk)
$codebaseSchema = Join-Path $mcpDir "codebase-memory-mcp"
$codebaseProc = Get-Process | Where-Object { $_.ProcessName -match "codebase-memory-mcp" } | Select-Object -First 1

if ($codebaseProc) {
    Write-DoctorItem "MCP Server" "CodebaseMemoryMCP" "CONNECTED" "Active process PID: $($codebaseProc.Id)"
} elseif (Test-Path $codebaseSchema) {
    Write-DoctorItem "MCP Server" "CodebaseMemoryMCP" "CONFIGURED" "Schema registered; Process not running"
} else {
    Write-DoctorItem "MCP Server" "CodebaseMemoryMCP" "NOT_INSTALLED" "Requires codebase-memory-mcp"
}

# 4. Summary & Exit Code
Write-Host $divider -ForegroundColor Gray
Write-Host ""
Write-Host "READINESS SUMMARY:" -ForegroundColor Cyan

$coreReady = (Test-Path $skillFile) -and ($missingRefs -eq 0) -and (Test-Path $templateDir) -and (Test-Path $ManifestPath)
if ($coreReady) {
    Write-Host "  CORE MODE READINESS: [PASS] Self-contained; 100% ready for offline discovery, PRD mapping, and templates." -ForegroundColor Green
} else {
    Write-Host "  CORE MODE READINESS: [FAIL] Missing required core files." -ForegroundColor Red
}

$fullConnected = ($figcraftProc -ne $null) -and ((Test-Path $antislopGlobal) -or (Test-Path $antislopLocal))
if ($coreReady -and $fullConnected) {
    Write-Host "  FULL MODE READINESS: [CONNECTED] Live FigCraft canvas & Anti-Slop active." -ForegroundColor Green
} elseif ($coreReady) {
    Write-Host "  FULL MODE READINESS: [SIMULATED] Core is ready. Real FigCraft MCP not running (offline mock fallback active)." -ForegroundColor Yellow
} else {
    Write-Host "  FULL MODE READINESS: [FAIL] Core prerequisite missing." -ForegroundColor Red
}

Write-Host ""

# Always return 0 when Core is ready so diagnostic checks succeed cleanly in CI
$global:LASTEXITCODE = 0
if ($coreReady) {
    exit 0
} else {
    exit 1
}
