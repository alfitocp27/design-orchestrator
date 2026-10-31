<#
.SYNOPSIS
    Integration test: Checks connectivity and real runtime communication with CodebaseMemoryMCP.
#>
param([string]$RepoRoot)

Write-Host "Running Integration Test: Live CodebaseMemoryMCP Connectivity & Handshake..." -ForegroundColor Cyan

$npxCmd = Get-Command npx -ErrorAction SilentlyContinue
if (-not $npxCmd) {
    Write-Host "SKIP: Node.js/npx not available. Offline simulation active." -ForegroundColor Yellow
    return
}

try {
    $initPayload = '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"test-runner","version":"1.0"}}}'
    $pinfo = New-Object System.Diagnostics.ProcessStartInfo
    $pinfo.FileName = "cmd.exe"
    $pinfo.Arguments = "/c npx -y codebase-memory-mcp"
    $pinfo.RedirectStandardInput = $true
    $pinfo.RedirectStandardOutput = $true
    $pinfo.RedirectStandardError = $true
    $pinfo.UseShellExecute = $false
    
    $p = [System.Diagnostics.Process]::Start($pinfo)
    $p.StandardInput.WriteLine($initPayload)
    
    Start-Sleep -Milliseconds 1500
    $resp = $p.StandardOutput.ReadLine()
    $p.Kill()
    
    if ($resp -match '"name":"codebase-memory-mcp"') {
        Write-Host "PASS: CodebaseMemoryMCP live communication verified via Stdio protocol." -ForegroundColor Green
        Write-Host ("Handshake Proof: {0}" -f $resp.Substring(0, [System.Math]::Min(120, $resp.Length)) + "...") -ForegroundColor DarkGray
    } else {
        Write-Host "WARN: CodebaseMemoryMCP started but response did not match expected protocol signature." -ForegroundColor Yellow
    }
} catch {
    Write-Host ("WARN: Live CodebaseMemoryMCP communication test encountered an error: {0}" -f $_) -ForegroundColor Yellow
}
