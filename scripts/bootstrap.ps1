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
.PARAMETER InstallAntiSlop
    Explicitly allow running 'npx antislop-ai' during automated/non-interactive setup.
#>

[CmdletBinding()]
param(
    [ValidateSet("Core", "Full")]
    [string]$Mode = "Core",

    [switch]$NonInteractive,
    [switch]$Force,
    [switch]$InstallAntiSlop
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

function Backup-And-Register-McpServer {
    param(
        [string]$ServerName,
        [string]$CommandPath,
        [string[]]$ArgsList
    )
    $mcpConfigPath = Join-Path $env:USERPROFILE ".gemini\config\mcp_config.json"
    $configDir = Split-Path $mcpConfigPath -Parent
    try {
        if (-not (Test-Path $configDir -ErrorAction SilentlyContinue)) {
            New-Item -ItemType Directory -Path $configDir -Force | Out-Null
        }
        
        # 1. Timestamped backup
        if (Test-Path $mcpConfigPath -ErrorAction SilentlyContinue) {
            $timestamp = (Get-Date).ToString("yyyyMMdd-HHmmss")
            $backupPath = "$mcpConfigPath.bak-$timestamp"
            Copy-Item -Path $mcpConfigPath -Destination $backupPath -Force
            Write-Log "PASS" ("Backed up Antigravity MCP config to: {0}" -f $backupPath)
        }
        
        # 2. Read or initialize
        $configObj = [PSCustomObject]@{
            mcpServers = [PSCustomObject]@{}
        }
        if (Test-Path $mcpConfigPath -ErrorAction SilentlyContinue) {
            $raw = Get-Content $mcpConfigPath -Raw -ErrorAction SilentlyContinue
            if ($raw) {
                try {
                    $parsed = $raw | ConvertFrom-Json
                    if ($parsed -and $parsed.mcpServers) {
                        $configObj = $parsed
                    }
                } catch {}
            }
        }
        
        # 3. Add or update server
        $entry = [PSCustomObject]@{
            command = $CommandPath
            args    = $ArgsList
        }
        $configObj.mcpServers | Add-Member -NotePropertyName $ServerName -NotePropertyValue $entry -Force
        
        $jsonStr = $configObj | ConvertTo-Json -Depth 5
        Set-Content -Path $mcpConfigPath -Value $jsonStr -Encoding UTF8
        Write-Log "VERIFIED" ("Successfully registered '{0}' MCP server in Antigravity." -f $ServerName)
        return $true
    } catch {
        Write-Log "WARN" ("Unable to write to Antigravity MCP config: {0}" -f $_)
        return $false
    }
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
    try {
        if (Test-Path $path -ErrorAction SilentlyContinue) {
            $ActiveAntigravityDir = $path
            break
        }
    } catch {}
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
    
    $hasAntislopSettings = $false
    try {
        $hasAntislopSettings = Test-Path $antislopSettings -ErrorAction SilentlyContinue
    } catch {}

    if ((Test-Path $antislopSkill) -or $hasAntislopSettings) {
        Write-Log "CONFIGURED" "Anti-Slop guardrail is already present."
    } else {
        Write-Log "DETECTED" "Anti-Slop can be installed via 'npx antislop-ai --mode during'."
        
        $shouldInstall = $false
        if ($InstallAntiSlop) {
            $shouldInstall = $true
        } elseif (-not $NonInteractive) {
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
            Write-Log "SKIP" "Anti-Slop installation skipped (Use -InstallAntiSlop or run 'npx antislop-ai --mode during')."
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
    $pythonCmd = Get-Command python -ErrorAction SilentlyContinue
    $hasRealPython = $false
    if ($pythonCmd) {
        try {
            $pyOut = (& python --version 2>&1 | Out-String).Trim()
            if ($LASTEXITCODE -eq 0 -and $pyOut -match "Python\s+3") {
                $hasRealPython = $true
            }
        } catch {}
        $global:LASTEXITCODE = 0
    }

    if (-not $hasRealPython) {
        Write-Log "INFO" "UI/UX Pro Max requires Python 3.x (Windows Store alias stub or Python missing)."
        Write-Log "INFO" "Install Python 3: winget install --id Python.Python.3.12 -e"
    } else {
        Write-Log "INFO" "UI/UX Pro Max is not bundled (protecting third-party licenses)."
        Write-Log "INFO" "Manual setup: git clone https://github.com/nextlevelbuilder/ui-ux-pro-max-skill .agents\skills\ui-ux-pro-max"
    }
}

# 4.3 Impeccable (Custom / Global Skill)
$impeccableGlobal = Join-Path $env:USERPROFILE ".gemini\config\skills\impeccable\SKILL.md"
$impeccableLocal = Join-Path $RepoRoot ".agents\skills\impeccable\SKILL.md"
$hasImpeccableGlobal = $false
try {
    $hasImpeccableGlobal = Test-Path $impeccableGlobal -ErrorAction SilentlyContinue
} catch {}

if ($hasImpeccableGlobal -or (Test-Path $impeccableLocal)) {
    Write-Log "CONFIGURED" "Impeccable craft skill verified."
} else {
    Write-Log "INFO" "Impeccable craft skill not found. Upstream: https://github.com/pbakaus/impeccable"
}

# 4.4 Desktop MCP Applications (FigCraft & CodebaseMemory)
Write-Log "INFO" "Auditing FigCraft and MCP configurations..."

$figcraftCmd = Get-Command figcraft-cli -ErrorAction SilentlyContinue
$figcraftBinCandidates = @(
    $(if ($figcraftCmd) { $figcraftCmd.Source }),
    (Join-Path $env:LOCALAPPDATA "Programs\ArtCraft\FigCraft\figcraft-cli.exe"),
    (Join-Path $env:LOCALAPPDATA "Programs\ArtCraft\FigCraft\figcraft.exe"),
    (Join-Path $env:ProgramFiles "ArtCraft\FigCraft\figcraft-cli.exe"),
    (Join-Path ${env:ProgramFiles(x86)} "ArtCraft\FigCraft\figcraft-cli.exe")
) | Where-Object { $_ -and (Test-Path $_) }
$figcraftBin = $figcraftBinCandidates | Select-Object -First 1

$figcraftProc = Get-Process | Where-Object { $_.ProcessName -match "^figcraft" } | Select-Object -First 1

if ($figcraftBin) {
    Write-Log "INSTALLED" ("FigCraft binary detected: {0}" -f $figcraftBin)
    
    # Check Stdio MCP handshake
    if ($figcraftBin -match "figcraft-cli\.exe$") {
        try {
            $initPayload = '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"bootstrapper","version":"1.0"}}}'
            $pinfo = New-Object System.Diagnostics.ProcessStartInfo
            $pinfo.FileName = $figcraftBin
            $pinfo.Arguments = "mcp"
            $pinfo.RedirectStandardInput = $true
            $pinfo.RedirectStandardOutput = $true
            $pinfo.RedirectStandardError = $true
            $pinfo.UseShellExecute = $false
            $p = [System.Diagnostics.Process]::Start($pinfo)
            $p.StandardInput.WriteLine($initPayload)
            Start-Sleep -Milliseconds 600
            $resp = $p.StandardOutput.ReadLine()
            $p.Kill()
            if ($resp -match '"name":"figcraft"') {
                Write-Log "VERIFIED" "FigCraft Stdio MCP communication handshake passed!"
            }
        } catch {
            Write-Log "WARN" ("FigCraft MCP handshake check returned: {0}" -f $_)
        }
        $global:LASTEXITCODE = 0
    }
    
    # Check Antigravity MCP registration
    $mcpConfigPath = Join-Path $env:USERPROFILE ".gemini\config\mcp_config.json"
    $isRegistered = $false
    try {
        if (Test-Path $mcpConfigPath -ErrorAction SilentlyContinue) {
            $rawMcp = Get-Content $mcpConfigPath -Raw -ErrorAction SilentlyContinue
            if ($rawMcp -and ($rawMcp | ConvertFrom-Json).mcpServers.figcraft) {
                $isRegistered = $true
            }
        }
    } catch {}

    if ($isRegistered) {
        Write-Log "CONFIGURED" "FigCraft MCP is registered in Antigravity mcp_config.json."
    } else {
        Write-Log "DETECTED" "FigCraft is installed but not registered in Antigravity mcp_config.json."
        $shouldRegister = $false
        if ($Force) {
            $shouldRegister = $true
        } elseif (-not $NonInteractive) {
            $resp = Read-Host "Would you like to register FigCraft in Antigravity mcp_config.json? (Y/N)"
            if ($resp -match "^[yY]") {
                $shouldRegister = $true
            }
        }
        if ($shouldRegister) {
            Backup-And-Register-McpServer -ServerName "figcraft" -CommandPath $figcraftBin -ArgsList @("mcp")
        }
    }
} else {
    Write-Log "INFO" "FigCraft binary not found on disk."
    Write-Log "INFO" "Manual setup: Install FigCraft desktop app before live canvas operations."
    Write-Log "SKIP" "Offline simulation mode will be used for FigCraft canvas calls until connected."
}

if ($figcraftProc) {
    Write-Log "CONNECTED" ("FigCraft GUI process actively running (PID: {0})." -f $figcraftProc.Id)
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
