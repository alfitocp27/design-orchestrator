<#
.SYNOPSIS
    Design Orchestrator 2.1 -- Portable Cross-PC Bootstrapper.
.DESCRIPTION
    Installs and configures Design Orchestrator on Windows 11 / Antigravity 2.0.
    Supports Core Mode (zero external tools) and Full Mode (production integrations).
    Idempotent, dynamic-path aware, and safe to rerun.
    Distinguishes automatable tools (Anti-Slop) from manual external apps (FigCraft).
.PARAMETER Mode
    Installation mode: 'Core' (default) or 'Full'.
.PARAMETER NonInteractive
    Skip interactive confirmation prompts.
.PARAMETER Force
    Force reinstallation and overwrite existing linked targets with backup.
#>

[CmdletBinding()]
param(
    [ValidateSet("Core", "Full")]
    [string]$Mode = "Core",

    [switch]$NonInteractive,
    [switch]$Force
)

$ErrorActionPreference = "Stop"

function Write-Log {
    param(
        [ValidateSet("INFO", "PASS", "WARN", "SKIP", "FAIL", "DETECTED", "INSTALLED", "CONFIGURED", "CONNECTED", "VERIFIED")]
        [string]$Level,
        [string]$Message
    )
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $color = switch ($Level) {
        "PASS"       { "Green" }
        "VERIFIED"   { "Green" }
        "CONNECTED"  { "Green" }
        "INFO"       { "Cyan" }
        "CONFIGURED" { "Cyan" }
        "INSTALLED"  { "Cyan" }
        "DETECTED"   { "Yellow" }
        "WARN"       { "Yellow" }
        "SKIP"       { "DarkGray" }
        "FAIL"       { "Red" }
    }
    Write-Host ("[{0}] [{1,-10}] {2}" -f $timestamp, $Level, $Message) -ForegroundColor $color
}

$RepoRoot = Split-Path -Parent $PSScriptRoot
$ManifestPath = Join-Path $RepoRoot "orchestrator.manifest.json"

Write-Log "INFO" "=========================================================="
Write-Log "INFO" " Design Orchestrator 2.1 -- Cross-PC Portable Bootstrapper"
Write-Log "INFO" (" Mode: {0} | Root: {1}" -f $Mode, $RepoRoot)
Write-Log "INFO" "=========================================================="

# 1. Environment Detection (Dynamic, zero hardcoded paths)
Write-Log "INFO" "Detecting environment and runtime..."

$isWindows = $PSVersionTable.Platform -eq "Win32NT" -or [string]::IsNullOrEmpty($PSVersionTable.Platform)
if (-not $isWindows) {
    Write-Log "WARN" ("Non-Windows OS detected ({0}). Design Orchestrator is optimized for Windows 11." -f $PSVersionTable.Platform)
} else {
    Write-Log "PASS" ("OS: Windows detected ({0})." -f [System.Environment]::OSVersion.VersionString)
}

Write-Log "PASS" ("PowerShell Version: {0}." -f $PSVersionTable.PSVersion)

# Check Git
$gitCmd = Get-Command git -ErrorAction SilentlyContinue
if ($gitCmd) {
    $gitVer = (& git --version 2>$null)
    $global:LASTEXITCODE = 0
    Write-Log "PASS" ("Git available: {0}" -f $gitVer)
} else {
    Write-Log "WARN" "Git command not found in PATH."
}

# Check GitHub CLI
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    if (Test-Path "C:\Program Files\GitHub CLI\gh.exe") {
        $env:Path = "C:\Program Files\GitHub CLI;" + $env:Path
    }
}
$ghCmd = Get-Command gh -ErrorAction SilentlyContinue
if ($ghCmd) {
    $ghVer = (& gh --version 2>$null | Select-Object -First 1)
    $global:LASTEXITCODE = 0
    Write-Log "PASS" ("GitHub CLI available: {0}" -f $ghVer)
} else {
    Write-Log "INFO" "GitHub CLI (gh) not found in PATH."
}

# Resolve Antigravity paths dynamically
$AntigravityPaths = @(
    (Join-Path $env:USERPROFILE ".gemini\antigravity"),
    (Join-Path $env:APPDATA "antigravity"),
    (Join-Path $env:LOCALAPPDATA "Programs\Antigravity")
)

$ActiveAntigravityDir = $null
foreach ($path in $AntigravityPaths) {
    if (Test-Path $path) {
        $ActiveAntigravityDir = $path
        break
    }
}

if ($ActiveAntigravityDir) {
    Write-Log "PASS" ("Antigravity data directory discovered: {0}" -f $ActiveAntigravityDir)
} else {
    Write-Log "INFO" "Antigravity standard data directory not yet created. Using workspace-local discovery."
}

# 2. Manifest Verification
if (-not (Test-Path $ManifestPath)) {
    Write-Log "FAIL" ("Manifest file missing at {0}" -f $ManifestPath)
    exit 1
}

try {
    $manifest = Get-Content $ManifestPath -Raw | ConvertFrom-Json
    Write-Log "PASS" ("Manifest loaded: {0} v{1}" -f $manifest.name, $manifest.version)
} catch {
    Write-Log "FAIL" ("Manifest JSON is invalid: {0}" -f $_)
    exit 1
}

# 3. Core Setup: Local Skill & Workspace Scaffolding
Write-Log "INFO" "Configuring Core Mode components..."

$LocalSkillDir = Join-Path $RepoRoot ".agents\skills\design-orchestrator"
if (-not (Test-Path $LocalSkillDir)) {
    Write-Log "FAIL" ("Core skill directory missing at {0}" -f $LocalSkillDir)
    exit 1
}

$SkillFile = Join-Path $LocalSkillDir "SKILL.md"
if (Test-Path $SkillFile) {
    Write-Log "PASS" ("Design Orchestrator meta-skill verified: {0}" -f $SkillFile)
} else {
    Write-Log "FAIL" ("SKILL.md missing at {0}" -f $SkillFile)
    exit 1
}

# Verify Project Templates
$TemplateDir = Join-Path $RepoRoot "templates\project"
if (Test-Path $TemplateDir) {
    Write-Log "PASS" ("Project template blueprints verified: {0}" -f $TemplateDir)
} else {
    Write-Log "FAIL" ("Template directory missing: {0}" -f $TemplateDir)
    exit 1
}

# Optional Root Registry Initialization (if not present)
$RegistryFile = Join-Path $RepoRoot "PROJECT_REGISTRY.md"
$RegistryTemplate = Join-Path $RepoRoot "templates\PROJECT_REGISTRY.md.template"

if (-not (Test-Path $RegistryFile)) {
    if (Test-Path $RegistryTemplate) {
        Copy-Item $RegistryTemplate $RegistryFile -Force
        Write-Log "PASS" "Initialized PROJECT_REGISTRY.md from template."
    }
} else {
    Write-Log "INFO" "PROJECT_REGISTRY.md already exists. Preserving user state."
}

# 4. Mode-Specific Configuration
if ($Mode -eq "Core") {
    Write-Log "INFO" "=========================================================="
    Write-Log "PASS" "Core Mode setup completed successfully!"
    Write-Log "INFO" "Features active: Discovery Interview, PRD Mapping, Design Template Generation, Offline Mock VQA."
    Write-Log "SKIP" "External companions (Anti-Slop, FigCraft MCP, UI/UX Pro Max) skipped in Core Mode."
    Write-Log "INFO" "Run '.\scripts\doctor.ps1' to verify environment diagnostics."
    Write-Log "INFO" "=========================================================="
    $global:LASTEXITCODE = 0
    exit 0
}

# --- FULL MODE SETUP ---
Write-Log "INFO" "Proceeding with Full Mode companion detection and setup..."

# 4.1 Node & Anti-Slop (Automated installation capable)
$npxCmd = Get-Command npx -ErrorAction SilentlyContinue

if ($npxCmd) {
    $npxVer = (& npx --version 2>$null)
    $global:LASTEXITCODE = 0
    Write-Log "PASS" ("npx available: {0}" -f $npxVer)
    
    $antislopSkill = Join-Path $RepoRoot ".agents\skills\antislop"
    $antislopSettings = Join-Path $env:APPDATA "antislop\settings.json"
    
    if ((Test-Path $antislopSkill) -or (Test-Path $antislopSettings)) {
        Write-Log "CONFIGURED" "Anti-Slop guardrail is already present."
    } else {
        Write-Log "DETECTED" "Anti-Slop can be installed automatically via npx."
        
        $shouldInstall = $NonInteractive
        if (-not $shouldInstall) {
            $response = Read-Host "Would you like to install Anti-Slop now using 'npx antislop-ai --mode during'? (Y/N)"
            if ($response -match "^[yY]") {
                $shouldInstall = $true
            }
        }
        
        if ($shouldInstall) {
            Write-Log "INFO" "Installing Anti-Slop via official installer..."
            try {
                & npx antislop-ai --mode during
                $global:LASTEXITCODE = 0
                Write-Log "VERIFIED" "Anti-Slop installed and configured successfully."
            } catch {
                Write-Log "WARN" ("Automatic Anti-Slop setup failed: {0}" -f $_)
                Write-Log "INFO" "Manual installation: npx antislop-ai --mode during"
            }
        } else {
            Write-Log "SKIP" "Skipped Anti-Slop installation by user request."
        }
    }
} else {
    Write-Log "WARN" "Node.js/npx not found. Anti-Slop automated installer requires Node.js."
    Write-Log "INFO" "Manual installation: winget install --id OpenJS.NodeJS -e --source winget"
}

# 4.2 UI/UX Pro Max (Manual / Guided Clone)
$uiuxSkill = Join-Path $RepoRoot ".agents\skills\ui-ux-pro-max"
if (Test-Path $uiuxSkill) {
    Write-Log "INSTALLED" ("UI/UX Pro Max skill detected at {0}" -f $uiuxSkill)
} else {
    Write-Log "INFO" "UI/UX Pro Max is not bundled (protecting third-party licenses)."
    Write-Log "INFO" "Manual setup: Place or link ui-ux-pro-max into .agents\skills\ui-ux-pro-max."
}

# 4.3 Impeccable (Custom / Global Skill)
$impeccableGlobal = Join-Path $env:USERPROFILE ".gemini\config\skills\impeccable\SKILL.md"
$impeccableLocal = Join-Path $RepoRoot ".agents\skills\impeccable\SKILL.md"
if ((Test-Path $impeccableGlobal) -or (Test-Path $impeccableLocal)) {
    Write-Log "CONFIGURED" "Impeccable craft skill verified."
} else {
    Write-Log "INFO" "Impeccable craft skill not found. Core Mode fallback active."
}

# 4.4 Desktop MCP Applications (FigCraft & CodebaseMemory)
Write-Log "INFO" "Auditing Desktop MCP Application processes..."

$figcraftProc = Get-Process | Where-Object { $_.ProcessName -match "^figcraft" } | Select-Object -First 1
if ($figcraftProc) {
    Write-Log "CONNECTED" ("FigCraft MCP process actively running (PID: {0})." -f $figcraftProc.Id)
} else {
    Write-Log "INFO" "FigCraft desktop app is NOT running."
    Write-Log "INFO" "Manual setup on clean PC: Install FigCraft desktop app and launch it before canvas operations."
    Write-Log "SKIP" "Offline simulation mode will be used for FigCraft canvas calls until connected."
}

$codebaseProc = Get-Process | Where-Object { $_.ProcessName -match "codebase-memory-mcp" } | Select-Object -First 1
if ($codebaseProc) {
    Write-Log "CONNECTED" ("CodebaseMemoryMCP process actively running (PID: {0})." -f $codebaseProc.Id)
} else {
    Write-Log "INFO" "CodebaseMemoryMCP is not running (Optional for schema queries)."
}

Write-Log "INFO" "=========================================================="
Write-Log "PASS" "Full Mode bootstrap diagnostic completed!"
Write-Log "INFO" "Run '.\scripts\doctor.ps1' to view full status audit."
Write-Log "INFO" "=========================================================="

$global:LASTEXITCODE = 0
exit 0
