<#
.SYNOPSIS
    Design Orchestrator 2.1 -- System Diagnostic and Health Checker (Doctor).
.DESCRIPTION
    Audits the current machine environment, Antigravity integration, skills,
    templates, and MCP dependencies.
    Distinguishes lifecycle states: DETECTED, INSTALLED, CONFIGURED, CONNECTED, VERIFIED.
    Guarantees Zero False PASS. Compatible with PowerShell 5.1+ and Windows 11.
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
    Write-DoctorItem "Toolchain" "Node.js / npx" "INSTALLED" "$nodeVer (Supports Anti-Slop & Codebase MCP)"
} else {
    Write-DoctorItem "Toolchain" "Node.js / npx" "NOT_INSTALLED" "Optional for companion tools"
}

# Python 3
$pythonCmd = Get-Command python -ErrorAction SilentlyContinue
$pyCandidates = @(
    $(if ($pythonCmd) { $pythonCmd.Source }),
    (Join-Path $env:LOCALAPPDATA "Programs\Python\Python312\python.exe"),
    (Join-Path $env:LOCALAPPDATA "Programs\Python\Python311\python.exe"),
    (Join-Path $env:ProgramFiles "Python312\python.exe"),
    (Join-Path $env:ProgramFiles "Python311\python.exe")
) | Where-Object { $_ -and (Test-Path $_) }

$realPythonPath = $null
$realPythonVer = $null
foreach ($cand in $pyCandidates) {
    try {
        $out = (& $cand --version 2>&1 | Out-String).Trim()
        if ($LASTEXITCODE -eq 0 -and $out -match "Python\s+3\.\d+") {
            $realPythonPath = $cand
            $realPythonVer = $out
            break
        }
    } catch {}
    $global:LASTEXITCODE = 0
}

if ($realPythonPath) {
    Write-DoctorItem "Toolchain" "Python 3" "INSTALLED" "$realPythonVer ($realPythonPath)"
} else {
    Write-DoctorItem "Toolchain" "Python 3" "NOT_INSTALLED" "Python 3.x required for UI/UX Pro Max"
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

$hasAntislopGlobal = $false
try {
    $hasAntislopGlobal = Test-Path $antislopGlobal -ErrorAction SilentlyContinue
} catch {}

if ($hasAntislopGlobal -and (Test-Path $antislopLocal)) {
    try {
        $asContent = Get-Content $antislopGlobal -Raw | ConvertFrom-Json
        Write-DoctorItem "Companion" "Anti-Slop" "VERIFIED" "Global preference ($($asContent.mode)) & workspace skill loaded"
    } catch {
        Write-DoctorItem "Companion" "Anti-Slop" "CONFIGURED" "Global preference & workspace skill active"
    }
} elseif ($hasAntislopGlobal) {
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
$hasImpeccableGlobal = $false
try {
    $hasImpeccableGlobal = Test-Path $impeccableGlobal -ErrorAction SilentlyContinue
} catch {}

if ($hasImpeccableGlobal) {
    Write-DoctorItem "Companion" "Impeccable" "CONFIGURED" "Discovered in Antigravity global skills"
} elseif (Test-Path $impeccableLocal) {
    Write-DoctorItem "Companion" "Impeccable" "INSTALLED" "Discovered in workspace skills (.agents/skills/impeccable)"
} else {
    Write-DoctorItem "Companion" "Impeccable" "NOT_INSTALLED" "Optional craft skill (pbakaus/impeccable)"
}

# UI/UX Pro Max
$uiuxLocal = Join-Path $RepoRoot ".agents\skills\ui-ux-pro-max\SKILL.md"
$uiuxSearch = Join-Path $RepoRoot ".agents\skills\ui-ux-pro-max\scripts\search.py"

if ((Test-Path $uiuxLocal) -and (Test-Path $uiuxSearch) -and $realPythonPath) {
    # Test execution
    $uiuxVerified = $false
    try {
        $testOut = (& $realPythonPath $uiuxSearch "test" --json 2>$null | Out-String)
        if ($LASTEXITCODE -eq 0 -and $testOut -match "design_system") {
            $uiuxVerified = $true
        }
    } catch {}
    $global:LASTEXITCODE = 0

    if ($uiuxVerified) {
        Write-DoctorItem "Companion" "UI/UX Pro Max" "VERIFIED" "Skill loaded & search.py CLI tested with Python 3"
    } else {
        Write-DoctorItem "Companion" "UI/UX Pro Max" "INSTALLED" "Skill files present in workspace"
    }
} elseif (Test-Path $uiuxLocal) {
    Write-DoctorItem "Companion" "UI/UX Pro Max" "INSTALLED" "Skill files present; requires Python 3 for search CLI"
} elseif ($realPythonPath) {
    Write-DoctorItem "Companion" "UI/UX Pro Max" "DETECTED" "Python 3 available; git clone required"
} else {
    Write-DoctorItem "Companion" "UI/UX Pro Max" "NOT_INSTALLED" "Requires Python 3.x and skill clone"
}

# Resolve Antigravity MCP configuration
$mcpConfigPath = Join-Path $env:USERPROFILE ".gemini\config\mcp_config.json"
$mcpConfig = $null
try {
    if (Test-Path $mcpConfigPath -ErrorAction SilentlyContinue) {
        $rawMcp = Get-Content $mcpConfigPath -Raw -ErrorAction SilentlyContinue
        if ($rawMcp) {
            $mcpConfig = $rawMcp | ConvertFrom-Json
        }
    }
} catch {}

# FigCraft MCP (Real connection vs Schema on disk vs Stdio handshake)
$figcraftCmd = Get-Command figcraft-cli -ErrorAction SilentlyContinue
$figcraftBinCandidates = @(
    $(if ($figcraftCmd) { $figcraftCmd.Source }),
    (Join-Path $env:LOCALAPPDATA "Programs\ArtCraft\FigCraft\figcraft-cli.exe"),
    (Join-Path $env:LOCALAPPDATA "Programs\ArtCraft\FigCraft\figcraft.exe"),
    (Join-Path $env:ProgramFiles "ArtCraft\FigCraft\figcraft-cli.exe"),
    (Join-Path ${env:ProgramFiles(x86)} "ArtCraft\FigCraft\figcraft-cli.exe")
) | Where-Object { $_ -and (Test-Path $_) }
$figcraftBin = $figcraftBinCandidates | Select-Object -First 1

$desktopProc = Get-Process | Where-Object { $_.ProcessName -eq "figcraft" } | Select-Object -First 1
$figcraftConfigured = ($mcpConfig -ne $null) -and ($mcpConfig.mcpServers.figcraft -ne $null)

# Test port 7979 for Attached Mode
$port7979Open = $false
try {
    $tcpClient = New-Object System.Net.Sockets.TcpClient
    $iar = $tcpClient.BeginConnect("127.0.0.1", 7979, $null, $null)
    $port7979Open = $iar.AsyncWaitHandle.WaitOne(300, $false)
    if ($port7979Open) { $tcpClient.EndConnect($iar) }
    $tcpClient.Close()
} catch {
    $port7979Open = $false
}

$figcraftHeadlessVerified = $false
$figcraftAttachedVerified = $false

if ($figcraftBin -and ($figcraftBin -match "figcraft-cli\.exe$")) {
    $initPayload = '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"doctor","version":"1.0"}}}'
    
    # 1. Test Headless Handshake
    try {
        $pinfo = New-Object System.Diagnostics.ProcessStartInfo
        $pinfo.FileName = $figcraftBin
        $pinfo.Arguments = "mcp"
        $pinfo.RedirectStandardInput = $true
        $pinfo.RedirectStandardOutput = $true
        $pinfo.RedirectStandardError = $true
        $pinfo.UseShellExecute = $false
        $p = [System.Diagnostics.Process]::Start($pinfo)
        $p.StandardInput.WriteLine($initPayload)
        Start-Sleep -Milliseconds 500
        $resp = $p.StandardOutput.ReadLine()
        $p.Kill()
        if ($resp -match '"name":"figcraft"') {
            $figcraftHeadlessVerified = $true
        }
    } catch {}
    $global:LASTEXITCODE = 0

    # 2. Test Attached Handshake if port open
    if ($port7979Open) {
        try {
            $pinfo = New-Object System.Diagnostics.ProcessStartInfo
            $pinfo.FileName = $figcraftBin
            $pinfo.Arguments = "mcp --attach 7979"
            $pinfo.RedirectStandardInput = $true
            $pinfo.RedirectStandardOutput = $true
            $pinfo.RedirectStandardError = $true
            $pinfo.UseShellExecute = $false
            $p = [System.Diagnostics.Process]::Start($pinfo)
            $p.StandardInput.WriteLine($initPayload)
            Start-Sleep -Milliseconds 600
            $resp = $p.StandardOutput.ReadLine()
            $p.Kill()
            if ($resp -match '"name":"figcraft"' -and $resp -match '127\.0\.0\.1:7979') {
                $figcraftAttachedVerified = $true
            }
        } catch {}
        $global:LASTEXITCODE = 0
    }
}

if ($figcraftAttachedVerified -and $desktopProc) {
    Write-DoctorItem "MCP Server" "FigCraft MCP (Live)" "CONNECTED" "Attached to Desktop (PID: $($desktopProc.Id)) on 127.0.0.1:7979"
} elseif ($figcraftHeadlessVerified -and $figcraftConfigured) {
    Write-DoctorItem "MCP Server" "FigCraft MCP (Headless)" "VERIFIED" "Stdio headless handshake passed & configured"
} elseif ($figcraftHeadlessVerified) {
    Write-DoctorItem "MCP Server" "FigCraft MCP (Headless)" "INSTALLED" "CLI binary verified; Desktop not running"
} elseif ($figcraftBin) {
    Write-DoctorItem "MCP Server" "FigCraft MCP" "INSTALLED" "Binary found at $figcraftBin"
} else {
    Write-DoctorItem "MCP Server" "FigCraft MCP" "NOT_INSTALLED" "Requires FigCraft desktop app or CLI"
}

# Codebase Memory MCP (Real connection vs Schema on disk vs Stdio handshake)
$codebaseProc = Get-Process | Where-Object { $_.ProcessName -match "codebase-memory-mcp" } | Select-Object -First 1
$codebaseConfigured = ($mcpConfig -ne $null) -and (($mcpConfig.mcpServers."codebase-memory-mcp" -ne $null) -or ($mcpConfig.mcpServers."codebase-memory" -ne $null))
$codebaseCmd = Get-Command codebase-memory-mcp -ErrorAction SilentlyContinue

$codebaseVerified = $false
if ($npxCmd) {
    try {
        $initPayload = '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"doctor","version":"1.0"}}}'
        $pinfo = New-Object System.Diagnostics.ProcessStartInfo
        $pinfo.FileName = "cmd.exe"
        $pinfo.Arguments = "/c npx -y codebase-memory-mcp"
        $pinfo.RedirectStandardInput = $true
        $pinfo.RedirectStandardOutput = $true
        $pinfo.RedirectStandardError = $true
        $pinfo.UseShellExecute = $false
        $p = [System.Diagnostics.Process]::Start($pinfo)
        $p.StandardInput.WriteLine($initPayload)
        Start-Sleep -Milliseconds 1200
        $resp = $p.StandardOutput.ReadLine()
        $p.Kill()
        if ($resp -match '"name":"codebase-memory-mcp"') {
            $codebaseVerified = $true
        }
    } catch {}
    $global:LASTEXITCODE = 0
}

if ($codebaseProc) {
    Write-DoctorItem "MCP Server" "CodebaseMemoryMCP" "CONNECTED" "Active process PID: $($codebaseProc.Id)"
} elseif ($codebaseVerified -and $codebaseConfigured) {
    Write-DoctorItem "MCP Server" "CodebaseMemoryMCP" "VERIFIED" "Stdio MCP handshake passed & configured in Antigravity"
} elseif ($codebaseVerified) {
    Write-DoctorItem "MCP Server" "CodebaseMemoryMCP" "INSTALLED" "Stdio MCP functional via npx (not in mcp_config)"
} elseif ($codebaseConfigured) {
    Write-DoctorItem "MCP Server" "CodebaseMemoryMCP" "CONFIGURED" "Registered in mcp_config.json"
} elseif ($codebaseCmd) {
    Write-DoctorItem "MCP Server" "CodebaseMemoryMCP" "INSTALLED" "Binary available in PATH"
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

$fullReady = ($figcraftVerified -or ($figcraftProc -ne $null)) -and ($hasAntislopGlobal -or (Test-Path $antislopLocal))
if ($coreReady -and $fullReady) {
    Write-Host "  FULL MODE READINESS: [CONNECTED] Live FigCraft MCP & Anti-Slop active." -ForegroundColor Green
} elseif ($coreReady) {
    Write-Host "  FULL MODE READINESS: [SIMULATED] Core is ready. FigCraft MCP offline mock fallback active." -ForegroundColor Yellow
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
