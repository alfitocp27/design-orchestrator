# Captures 1440x900 pixel-perfect screenshots of the 3 Artefacta concept previews using Edge headless.

$ErrorActionPreference = "Continue"

$edgePath = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
if (-not (Test-Path $edgePath)) {
    $edgePath = "C:\Program Files\Google\Chrome\Application\chrome.exe"
}
if (-not (Test-Path $edgePath)) {
    Write-Error "No supported headless browser found."
    exit 1
}

$repoRoot = [System.IO.Path]::GetFullPath("$PSScriptRoot\..")
$exportDir = Join-Path $repoRoot "projects\artefacta-museum\exports"
if (-not (Test-Path $exportDir)) {
    New-Item -ItemType Directory -Path $exportDir -Force | Out-Null
}

$artifactDir = "C:\Users\AI-Server\.gemini\antigravity\brain\15df6e0f-695c-4b34-94a0-c07040b7d486"

$concepts = @(
    @{ Name = "concept-1-monograph"; File = "concept-1-monograph.html" },
    @{ Name = "concept-2-kunsthalle"; File = "concept-2-kunsthalle.html" },
    @{ Name = "concept-3-conservator"; File = "concept-3-conservator.html" }
)

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " Capturing 1440x900 Screenshots for Artefacta Concepts" -ForegroundColor Cyan
Write-Host " Browser Engine: $edgePath" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

foreach ($c in $concepts) {
    $htmlPath = Join-Path $repoRoot "projects\artefacta-museum\references\$($c.File)"
    $outPng = Join-Path $exportDir "$($c.Name)-1440x900.png"

    Write-Host "Rendering: $($c.File) -> $($c.Name)-1440x900.png..." -ForegroundColor Yellow

    # Execute headless browser capture with Start-Process -Wait
    $argsList = @(
        "--headless=new",
        "--disable-gpu",
        "--window-size=1440,900",
        "--virtual-time-budget=2000",
        "--screenshot=$outPng",
        "$htmlPath"
    )
    $proc = Start-Process -FilePath $edgePath -ArgumentList $argsList -Wait -NoNewWindow -PassThru
    Start-Sleep -Milliseconds 500

    if (Test-Path $outPng) {
        $item = Get-Item $outPng
        Write-Host ("  [OK] Captured: {0} ({1:N0} bytes)" -f $item.Name, $item.Length) -ForegroundColor Green
        
        # Copy to artifact dir for report embedding
        if (Test-Path $artifactDir) {
            $artCopy = Join-Path $artifactDir "$($c.Name)-1440x900.png"
            Copy-Item -Path $outPng -Destination $artCopy -Force
            Write-Host "  [OK] Copied to artifact directory." -ForegroundColor Gray
        }
    } else {
        Write-Error "Failed to capture screenshot for $($c.Name)"
    }
}

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " All 3 concept screenshots successfully captured." -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan
