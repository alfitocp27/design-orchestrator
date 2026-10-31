# Design Orchestrator 2.2 -- Context & Token Footprint Measurer
# Measures line, word, character, and estimated token counts across skill and references.

param(
    [string]$TargetDir = "$PSScriptRoot\..\.agents\skills\design-orchestrator"
)

$targetPath = [System.IO.Path]::GetFullPath($TargetDir)
if (-not (Test-Path $targetPath)) {
    Write-Error "Target directory not found: $targetPath"
    exit 1
}

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " Design Orchestrator Context & Token Measurer" -ForegroundColor Cyan
Write-Host " Target: $targetPath" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

$files = Get-ChildItem -Path $targetPath -Filter *.md -Recurse | Sort-Object Name
$results = @()
$totalBytes = 0
$totalLines = 0
$totalWords = 0
$totalEstTokens = 0

foreach ($f in $files) {
    $content = Get-Content $f.FullName -Raw -Encoding UTF8
    $lines = ($content -split "`r?`n").Count
    $words = ($content -split "\s+" | Where-Object { $_ -ne "" }).Count
    $bytes = [System.Text.Encoding]::UTF8.GetByteCount($content)
    # Standard LLM token estimation: ~4 chars per token or ~0.75 words per token (words * 1.33)
    $estTokens = [math]::Round($words * 1.33)

    $relPath = $f.FullName.Replace($targetPath, "").TrimStart("\", "/")

    $results += [PSCustomObject]@{
        File = $relPath
        Lines = $lines
        Words = $words
        Bytes = $bytes
        EstTokens = $estTokens
    }

    $totalBytes += $bytes
    $totalLines += $lines
    $totalWords += $words
    $totalEstTokens += $estTokens
}

$results | Format-Table -AutoSize -Property File, Lines, Words, Bytes, EstTokens

Write-Host "----------------------------------------------------------"
Write-Host ("TOTAL: {0} files | {1} lines | {2} words | {3} bytes | ~{4} tokens" -f $results.Count, $totalLines, $totalWords, $totalBytes, $totalEstTokens) -ForegroundColor Green
Write-Host "=========================================================="

# Export to JSON for programmatic comparison
$summary = [PSCustomObject]@{
    timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
    fileCount = $results.Count
    totalLines = $totalLines
    totalWords = $totalWords
    totalBytes = $totalBytes
    totalEstTokens = $totalEstTokens
    files = $results
}

$jsonPath = Join-Path $PSScriptRoot "..\test-output\context-measurement.json"
$parentDir = Split-Path $jsonPath -Parent
if (-not (Test-Path $parentDir)) { New-Item -ItemType Directory -Path $parentDir -Force | Out-Null }
$summary | ConvertTo-Json -Depth 4 | Set-Content -Path $jsonPath -Encoding UTF8
Write-Host "Measurement recorded to: test-output\context-measurement.json" -ForegroundColor Gray
