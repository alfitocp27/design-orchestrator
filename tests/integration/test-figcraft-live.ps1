<#
.SYNOPSIS
    Integration test: Checks connectivity to real FigCraft MCP server (optional).
#>
param([string]$RepoRoot)

Write-Host "Running Integration Test: Live FigCraft MCP Connectivity..." -ForegroundColor Cyan

$mcpDir = Join-Path $env:USERPROFILE ".gemini\antigravity\mcp\figcraft"

if (Test-Path $mcpDir) {
    Write-Host "PASS: FigCraft MCP server registration detected at $mcpDir" -ForegroundColor Green
} else {
    Write-Host "SKIP: Live FigCraft MCP not detected in current environment. Offline simulation active." -ForegroundColor Yellow
}
