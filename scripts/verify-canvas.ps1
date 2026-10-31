<#
.SYNOPSIS
    Design Orchestrator 2.2 -- Automated Canvas Geometry & Contrast Verifier.
.DESCRIPTION
    Deterministically audits FigCraft design documents (offline JSON fixtures or live documents)
    for table column alignment math, container overflow, WCAG 2.2 contrast, and context-aware
    reusable component linkage.
    Differentiates Deterministic QA (PASS / FAIL / NOT_VERIFIABLE) from Visual/UX Review.
.PARAMETER DocumentPath
    Path to synthetic JSON fixture or .figcraft document file.
.PARAMETER Mode
    Execution mode: 'Mock' (offline JSON fixture) or 'Live' (live FigCraft MCP).
.PARAMETER OutputDir
    Directory to save auditable JSON and Markdown reports. Default: 'test-output'.
.PARAMETER JsonReport
    Output JSON string to stdout.
.PARAMETER ThresholdContrastNormal
    Minimum contrast ratio for normal text (default: 4.5).
.PARAMETER ThresholdContrastLarge
    Minimum contrast ratio for large text (default: 3.0).
.PARAMETER ThresholdAlignmentDelta
    Maximum permitted horizontal column misalignment in pixels (default: 1.0).
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$DocumentPath,

    [ValidateSet("Mock", "Live")]
    [string]$Mode = "Mock",

    [string]$OutputDir = "test-output",
    [switch]$JsonReport,
    [double]$ThresholdContrastNormal = 4.5,
    [double]$ThresholdContrastLarge = 3.0,
    [double]$ThresholdAlignmentDelta = 1.0
)

# --- Math Helper: WCAG 2.2 Relative Luminance & Contrast ---

function Convert-HexToRgb {
    param([string]$Hex)
    if (-not $Hex) { return $null }
    $cleanHex = $Hex.TrimStart('#')
    if ($cleanHex.Length -eq 3) {
        $cleanHex = "$($cleanHex[0])$($cleanHex[0])$($cleanHex[1])$($cleanHex[1])$($cleanHex[2])$($cleanHex[2])"
    }
    if ($cleanHex.Length -ne 6) { return $null }
    try {
        $r = [Convert]::ToInt32($cleanHex.Substring(0, 2), 16)
        $g = [Convert]::ToInt32($cleanHex.Substring(2, 2), 16)
        $b = [Convert]::ToInt32($cleanHex.Substring(4, 2), 16)
        return @{ R = $r; G = $g; B = $b }
    } catch {
        return $null
    }
}

function Get-RelativeLuminance {
    param([hashtable]$Rgb)
    if (-not $Rgb) { return $null }
    
    $linearize = {
        param([double]$val)
        $s = $val / 255.0
        if ($s -le 0.04045) {
            return $s / 12.92
        } else {
            return [Math]::Pow(($s + 0.055) / 1.055, 2.4)
        }
    }
    
    $rPrime = & $linearize $Rgb.R
    $gPrime = & $linearize $Rgb.G
    $bPrime = & $linearize $Rgb.B
    
    return (0.2126 * $rPrime) + (0.7152 * $gPrime) + (0.0722 * $bPrime)
}

function Calculate-WcagContrastRatio {
    param(
        [string]$FgHex,
        [string]$BgHex,
        [double]$Opacity = 1.0
    )
    $fgRgb = Convert-HexToRgb -Hex $FgHex
    $bgRgb = Convert-HexToRgb -Hex $BgHex
    
    if (-not $fgRgb -or -not $bgRgb) {
        return $null
    }
    
    # Composite foreground over background if opacity < 1.0
    if ($Opacity -lt 1.0 -and $Opacity -gt 0.0) {
        $fgRgb = @{
            R = [Math]::Round(($Opacity * $fgRgb.R) + ((1.0 - $Opacity) * $bgRgb.R))
            G = [Math]::Round(($Opacity * $fgRgb.G) + ((1.0 - $Opacity) * $bgRgb.G))
            B = [Math]::Round(($Opacity * $fgRgb.B) + ((1.0 - $Opacity) * $bgRgb.B))
        }
    }
    
    $l1 = Get-RelativeLuminance -Rgb $fgRgb
    $l2 = Get-RelativeLuminance -Rgb $bgRgb
    
    if ($l1 -eq $null -or $l2 -eq $null) {
        return $null
    }
    
    $lighter = [Math]::Max($l1, $l2)
    $darker = [Math]::Min($l1, $l2)
    
    $ratio = ($lighter + 0.05) / ($darker + 0.05)
    return [Math]::Round($ratio, 2)
}

# --- Core Verifier Pipeline ---

if (-not (Test-Path $DocumentPath)) {
    throw "FAIL: Document path not found at '$DocumentPath'"
}

$rawJson = Get-Content -Path $DocumentPath -Raw -Encoding UTF8
$doc = $null
try {
    $doc = $rawJson | ConvertFrom-Json
} catch {
    throw "FAIL: Unable to parse document JSON at '$DocumentPath': $_"
}

$auditResults = [ordered]@{
    verifierVersion     = "2.2.0"
    evaluatedAt         = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
    targetMode          = $Mode
    documentId          = $(if ($doc.documentId) { $doc.documentId } else { "UNKNOWN_DOC" })
    documentName        = $(if ($doc.documentName) { $doc.documentName } else { (Split-Path $DocumentPath -Leaf) })
    deterministicStatus = "PASS"
    summary             = [ordered]@{
        totalChecks        = 0
        passedChecks       = 0
        failedChecks       = 0
        unverifiableChecks = 0
        p1Blockers         = 0
        p2Majors           = 0
        p3Minors           = 0
    }
    geometryChecks      = @()
    contrastChecks      = @()
    componentChecks     = @()
    findings            = @()
    visualReviewNote    = "Deterministic QA verifies mathematical, geometric, and structural rules only. Visual craft, tonal depth, and perceptual harmony require Tier 2 Multimodal Visual Evaluation with human sign-off."
}

function Add-AuditFinding {
    param(
        [string]$Category,
        [string]$Priority,
        [string]$NodeId,
        [string]$Title,
        [string]$Evidence,
        [string]$Expected
    )
    $finding = [ordered]@{
        id       = ("F-{0:D2}" -f ($auditResults.findings.Count + 1))
        category = $Category
        priority = $Priority
        nodeId   = $NodeId
        title    = $Title
        evidence = $Evidence
        expected = $Expected
    }
    $auditResults.findings += $finding
    
    switch ($Priority) {
        "P1" { $auditResults.summary.p1Blockers++ }
        "P2" { $auditResults.summary.p2Majors++ }
        "P3" { $auditResults.summary.p3Minors++ }
    }
}

# Recursively traverse all nodes and build parent map
$parentMap = @{}
function Get-AllNodes {
    param($NodeList, $ParentNode = $null)
    $all = @()
    foreach ($node in $NodeList) {
        $all += $node
        if ($ParentNode -and $node.id) {
            $parentMap[$node.id.ToString()] = $ParentNode
        }
        if ($node.children -and $node.children.Count -gt 0) {
            $all += Get-AllNodes -NodeList $node.children -ParentNode $node
        }
        if ($node.cells -and $node.cells.Count -gt 0) {
            $all += Get-AllNodes -NodeList $node.cells -ParentNode $node
        }
    }
    return $all
}

$allPages = $(if ($doc.pages) { $doc.pages } else { @($doc) })
$allNodes = Get-AllNodes -NodeList $allPages

# --- CHECK 1: Table Column Alignment Math ---

$tableNodes = $allNodes | Where-Object { $_.role -eq "table" -or ($_.name -and $_.name -match "Table|Grid") }

foreach ($table in $tableNodes) {
    $headerRow = $table.children | Where-Object { $_.role -eq "table_header" -or ($_.name -and $_.name -match "Header") } | Select-Object -First 1
    $dataRows = $table.children | Where-Object { $_.role -eq "table_row" -or ($_.name -and $_.name -match "Row") }
    
    if ($headerRow -and $headerRow.columns -and $dataRows) {
        $headerCols = $headerRow.columns
        
        foreach ($row in $dataRows) {
            $cells = $(if ($row.cells) { $row.cells } elseif ($row.children) { $row.children } else { @() })
            
            for ($i = 0; $i -lt [Math]::Min($headerCols.Count, $cells.Count); $i++) {
                $auditResults.summary.totalChecks++
                $hCol = $headerCols[$i]
                $cCell = $cells[$i]
                
                if ($hCol.x -eq $null -or $cCell.x -eq $null) {
                    $auditResults.summary.unverifiableChecks++
                    $auditResults.geometryChecks += [ordered]@{
                        check   = "ColumnAlignment"
                        nodeId  = $cCell.id
                        column  = $hCol.name
                        status  = "NOT_VERIFIABLE"
                        details = "Missing horizontal position x for column or cell."
                    }
                    continue
                }
                
                $deltaX = [Math]::Abs([double]$cCell.x - [double]$hCol.x)
                $deltaW = $(if ($hCol.width -ne $null -and $cCell.width -ne $null) { [Math]::Abs([double]$cCell.width - [double]$hCol.width) } else { 0.0 })
                
                if ($deltaX -le $ThresholdAlignmentDelta) {
                    $auditResults.summary.passedChecks++
                    $auditResults.geometryChecks += [ordered]@{
                        check   = "ColumnAlignment"
                        nodeId  = $cCell.id
                        column  = $hCol.name
                        deltaX  = "$($deltaX)px"
                        deltaW  = "$($deltaW)px"
                        status  = "PASS"
                    }
                } else {
                    $auditResults.summary.failedChecks++
                    $auditResults.geometryChecks += [ordered]@{
                        check   = "ColumnAlignment"
                        nodeId  = $cCell.id
                        column  = $hCol.name
                        deltaX  = "$($deltaX)px"
                        deltaW  = "$($deltaW)px"
                        status  = "FAIL"
                    }
                    Add-AuditFinding -Category "Geometry/TableAlignment" -Priority "P1" -NodeId $cCell.id `
                        -Title ("Column '{0}' alignment offset exceeds threshold" -f $hCol.name) `
                        -Evidence ("deltaX = {0:F1}px (Cell x={1}, Header x={2})" -f $deltaX, $cCell.x, $hCol.x) `
                        -Expected ("deltaX <= {0:F1}px" -f $ThresholdAlignmentDelta)
                }
            }
        }
    }
}

# --- CHECK 2: Container Boundary & Overflow Math ---

$containers = $allNodes | Where-Object {
    $_.children -and $_.children.Count -gt 0 -and
    $_.width -ne $null -and
    $_.type -ne "DOCUMENT"
}

foreach ($container in $containers) {
    $cWidth = [double]$container.width
    $pRight = 0.0
    if ($container.padding -and $container.padding.right -ne $null) {
        $pRight = [double]$container.padding.right
    }
    
    $effectiveRightLimit = $cWidth - $pRight
    
    foreach ($child in $container.children) {
        if ($child.x -ne $null -and $child.width -ne $null) {
            $auditResults.summary.totalChecks++
            $childRight = [double]$child.x + [double]$child.width
            $overflow = $childRight - $effectiveRightLimit
            
            if ($overflow -le 0.0) {
                $auditResults.summary.passedChecks++
                $auditResults.geometryChecks += [ordered]@{
                    check          = "ContainerBoundary"
                    containerId    = $container.id
                    childId        = $child.id
                    effectiveLimit = "$($effectiveRightLimit)px"
                    childRight     = "$($childRight)px"
                    status         = "PASS"
                }
            } else {
                $auditResults.summary.failedChecks++
                $auditResults.geometryChecks += [ordered]@{
                    check          = "ContainerBoundary"
                    containerId    = $container.id
                    childId        = $child.id
                    overflow       = "+$($overflow)px"
                    status         = "FAIL"
                }
                Add-AuditFinding -Category "Geometry/ContainerOverflow" -Priority "P1" -NodeId $child.id `
                    -Title ("Child element '{0}' overflows container boundary" -f $child.name) `
                    -Evidence ("childRight = {0}px, containerLimit = {1}px (overflow = +{2:F1}px)" -f $childRight, $effectiveRightLimit, $overflow) `
                    -Expected "child.x + child.width <= container.width - padding.right"
            }
        } elseif ($child.x -eq $null -or $child.width -eq $null) {
            # Incomplete geometric information
            $auditResults.summary.totalChecks++
            $auditResults.summary.unverifiableChecks++
            $auditResults.geometryChecks += [ordered]@{
                check       = "ContainerBoundary"
                containerId = $container.id
                childId     = $child.id
                status      = "NOT_VERIFIABLE"
                details     = "Missing x coordinate or width on child node."
            }
        }
    }
}
# --- CHECK 2B: Sibling Collision & Bounding-Box Overlap Math ---

foreach ($container in $containers) {
    $childrenWithBounds = @($container.children | Where-Object {
        $_.x -ne $null -and $_.y -ne $null -and $_.width -ne $null -and $_.height -ne $null -and
        (-not $_.isAbsolute)
    })
    
    if ($childrenWithBounds.Count -gt 1) {
        for ($i = 0; $i -lt $childrenWithBounds.Count; $i++) {
            for ($j = $i + 1; $j -lt $childrenWithBounds.Count; $j++) {
                $cA = $childrenWithBounds[$i]
                $cB = $childrenWithBounds[$j]
                
                # Check collision between siblings where at least one is a TEXT element
                $hasText = ($cA.type -eq "TEXT" -or $cA.text -ne $null -or $cB.type -eq "TEXT" -or $cB.text -ne $null)
                if (-not $hasText) { continue }
                
                $auditResults.summary.totalChecks++
                
                $lA = [double]$cA.x; $rA = $lA + [double]$cA.width
                $tA = [double]$cA.y; $bA = $tA + [double]$cA.height
                
                $lB = [double]$cB.x; $rB = $lB + [double]$cB.width
                $tB = [double]$cB.y; $bB = $tB + [double]$cB.height
                
                $xOverlap = [Math]::Max(0.0, [Math]::Min($rA, $rB) - [Math]::Max($lA, $lB))
                $yOverlap = [Math]::Max(0.0, [Math]::Min($bA, $bB) - [Math]::Max($tA, $tB))
                
                if ($xOverlap -ge 10.0 -and $yOverlap -ge 1.0) {
                    $auditResults.summary.failedChecks++
                    $auditResults.geometryChecks += [ordered]@{
                        check       = "SiblingCollision"
                        containerId = $container.id
                        childA      = $cA.id
                        childB      = $cB.id
                        overlap     = "x:${xOverlap}px, y:${yOverlap}px"
                        status      = "FAIL"
                    }
                    Add-AuditFinding -Category "Geometry/BoundingBoxCollision" -Priority "P1" -NodeId $cB.id `
                        -Title ("Visual collision: sibling elements '{0}' and '{1}' overlap in container '{2}'" -f $cA.name, $cB.name, $container.name) `
                        -Evidence ("Intersection bounds: xOverlap={0:F1}px, yOverlap={1:F1}px (A: [{2},{3},{4},{5}], B: [{6},{7},{8},{9}])" -f `
                            $xOverlap, $yOverlap, $lA, $tA, $rA, $bA, $lB, $tB, $rB, $bB) `
                        -Expected "Zero bounding box intersection between non-absolute siblings in same layout flow"
                } else {
                    $auditResults.summary.passedChecks++
                    $auditResults.geometryChecks += [ordered]@{
                        check       = "SiblingCollision"
                        containerId = $container.id
                        childA      = $cA.id
                        childB      = $cB.id
                        status      = "PASS"
                    }
                }
            }
        }
    }
}

# --- CHECK 3: WCAG 2.2 Contrast & Typography Legibility ---

$textNodes = $allNodes | Where-Object {
    $_.type -eq "TEXT" -or ($_.text -ne $null)
}

foreach ($textNode in $textNodes) {
    $auditResults.summary.totalChecks++
    $fg = $textNode.color
    $bg = $textNode.backgroundColor
    $fontSize = $(if ($textNode.fontSize) { [double]$textNode.fontSize } else { 14.0 })
    $fontWeight = $(if ($textNode.fontWeight) { [int]$textNode.fontWeight } else { 400 })
    $opacity = $(if ($textNode.opacity -ne $null) { [double]$textNode.opacity } else { 1.0 })
    
    # 1. Floor check (< 11px is P1 illegibility)
    if ($fontSize -lt 11.0) {
        $auditResults.summary.failedChecks++
        Add-AuditFinding -Category "Visual/Typography" -Priority "P1" -NodeId $textNode.id `
            -Title ("Typography below legibility floor ({0}px)" -f $fontSize) `
            -Evidence ("fontSize = {0}px on text '{1}'" -f $fontSize, $textNode.name) `
            -Expected "fontSize >= 11px (micro) or >= 13px (body)"
        continue
    }

    # 1B. Text Line-Height Multiplier Integrity & Sub-pixel Collapse Check
    $textVal = $(if ($textNode.characters) { $textNode.characters } elseif ($textNode.text) { $textNode.text } else { "" })
    $lineCount = 1
    if ($textVal) {
        $lineCount = [Math]::Max(1, ($textVal -split "\r?\n").Count)
    }
    
    if ($textNode.lineHeight -ne $null) {
        $auditResults.summary.totalChecks++
        $lhVal = $textNode.lineHeight
        $isNumeric = $false
        $numLh = 0.0
        if ($lhVal -is [ValueType] -or ($lhVal -is [string] -and $lhVal -match '^\d+(\.\d+)?$')) {
            $numLh = [double]$lhVal
            $isNumeric = $true
        }
        
        if ($isNumeric -and $numLh -gt 0 -and $numLh -lt 3.0) {
            $auditResults.summary.failedChecks++
            Add-AuditFinding -Category "Visual/Typography" -Priority "P1" -NodeId $textNode.id `
                -Title ("Text element '{0}' has invalid unitless lineHeight ({1})" -f $textNode.name, $numLh) `
                -Evidence ("lineHeight = {0} is interpreted as literal pixels ({0}px) in FigCraft, causing text collapse" -f $numLh) `
                -Expected "lineHeight must be 'Auto', percentage string (e.g. '140%'), or pixel value >= 10"
        } else {
            $auditResults.summary.passedChecks++
        }
    }
    
    if ($textNode.height -ne $null -and $fontSize -ge 10.0) {
        $auditResults.summary.totalChecks++
        $h = [double]$textNode.height
        $expectedMinHeight = [Math]::Max(10.0, ($fontSize * 0.75 * $lineCount))
        if ($h -lt ($expectedMinHeight - 0.5)) {
            $auditResults.summary.failedChecks++
            $auditResults.geometryChecks += [ordered]@{
                check    = "TextBoundsCollapse"
                nodeId   = $textNode.id
                target   = $textNode.name
                height   = "$($h)px"
                expected = ">= $($expectedMinHeight)px"
                status   = "FAIL"
            }
            Add-AuditFinding -Category "Geometry/TextBounds" -Priority "P1" -NodeId $textNode.id `
                -Title ("Text element '{0}' collapsed height violates typographical bounds" -f $textNode.name) `
                -Evidence ("height = {0:F1}px, fontSize = {1}px, lineCount = {2} (minimum expected = {3:F1}px)" -f $h, $fontSize, $lineCount, $expectedMinHeight) `
                -Expected ("height >= 0.75 * fontSize * lineCount ({0:F1}px)" -f $expectedMinHeight)
        } else {
            $auditResults.summary.passedChecks++
            $auditResults.geometryChecks += [ordered]@{
                check    = "TextBoundsCollapse"
                nodeId   = $textNode.id
                target   = $textNode.name
                height   = "$($h)px"
                status   = "PASS"
            }
        }
    }

    
    # 2. Contrast evaluation
    if (-not $fg -and $textNode.fills -and $textNode.fills.Count -gt 0) {
        $solidFill = $textNode.fills | Where-Object { $_.type -eq "solid" -and $_.color } | Select-Object -First 1
        if ($solidFill) { $fg = $solidFill.color }
    }
    
    if (-not $bg -and $textNode.id -and $parentMap.ContainsKey($textNode.id.ToString())) {
        $currParent = $parentMap[$textNode.id.ToString()]
        while ($currParent -and -not $bg) {
            if ($currParent.fills -and $currParent.fills.Count -gt 0) {
                $pSolid = $currParent.fills | Where-Object { $_.type -eq "solid" -and $_.color } | Select-Object -First 1
                if ($pSolid) { $bg = $pSolid.color }
            }
            if (-not $bg -and $currParent.background) {
                $bg = $currParent.background
            }
            if (-not $bg -and $currParent.id -and $parentMap.ContainsKey($currParent.id.ToString())) {
                $currParent = $parentMap[$currParent.id.ToString()]
            } else {
                $currParent = $null
            }
        }
    }

    if (-not $fg -or -not $bg) {
        $auditResults.summary.unverifiableChecks++
        $auditResults.contrastChecks += [ordered]@{
            nodeId    = $textNode.id
            textName  = $textNode.name
            status    = "NOT_VERIFIABLE"
            details   = "Missing foreground or background color data."
        }
        continue
    }
    
    $ratio = Calculate-WcagContrastRatio -FgHex $fg -BgHex $bg -Opacity $opacity
    
    if ($ratio -eq $null) {
        $auditResults.summary.unverifiableChecks++
        $auditResults.contrastChecks += [ordered]@{
            nodeId   = $textNode.id
            textName = $textNode.name
            status   = "NOT_VERIFIABLE"
            details  = "Color conversion failed for Fg='$fg' / Bg='$bg'."
        }
        continue
    }
    
    $isLarge = ($fontSize -ge 24.0) -or ($fontSize -ge 18.5 -and $fontWeight -ge 600)
    $requiredThreshold = $(if ($isLarge) { $ThresholdContrastLarge } else { $ThresholdContrastNormal })
    
    if ($ratio -ge $requiredThreshold) {
        $auditResults.summary.passedChecks++
        $auditResults.contrastChecks += [ordered]@{
            nodeId        = $textNode.id
            textName      = $textNode.name
            fontSize      = "$($fontSize)px"
            contrastRatio = "$($ratio):1"
            threshold     = "$($requiredThreshold):1"
            status        = "PASS"
        }
    } else {
        $auditResults.summary.failedChecks++
        $auditResults.contrastChecks += [ordered]@{
            nodeId        = $textNode.id
            textName      = $textNode.name
            fontSize      = "$($fontSize)px"
            contrastRatio = "$($ratio):1"
            threshold     = "$($requiredThreshold):1"
            status        = "FAIL"
        }
        
        $priority = $(if ($ratio -lt 3.0) { "P1" } else { "P2" })
        Add-AuditFinding -Category "Visual/WCAG_Contrast" -Priority $priority -NodeId $textNode.id `
            -Title ("WCAG 2.2 Contrast violation ({0}:1 on {1})" -f $ratio, $textNode.name) `
            -Evidence ("Ratio = {0}:1 (Fg: {1}, Bg: {2}, FontSize: {3}px)" -f $ratio, $fg, $bg, $fontSize) `
            -Expected ("Contrast ratio >= {0}:1" -f $requiredThreshold)
    }
}

# --- CHECK 4: Context-Aware Reusable Component Linkage ---

# Find all nodes under 04_Screens
$screenPage = $allPages | Where-Object { $_.name -and $_.name -match "04_Screens|Screens" }
if ($screenPage) {
    $screenNodes = Get-AllNodes -NodeList @($screenPage)
    
    foreach ($node in $screenNodes) {
        $name = $(if ($node.name) { $node.name } else { "" })
        $role = $(if ($node.role) { $node.role } else { "" })
        
        # Elements that MUST be reusable instances
        $isRepeatingControl = ($name -match "^(Button|Badge|Input|Avatar|Pill|Nav/Item|TableRow|Card/Item)") -or
                              ($role -in @("button", "input", "badge", "pill", "avatar"))
        
        # Structural layout containers that are explicitly permitted as FRAME
        $isStructuralContainer = ($name -match "^(Screen|Viewport|Sidebar|Main_Content|Page|Layout|Container|Column|Wrapper)") -or
                                 ($role -in @("layout_viewport", "layout_sidebar", "layout_body", "layout_card", "table"))
        
        $targetCompId = if ($node.mainComponentId) { $node.mainComponentId } elseif ($node.mainComponent) { $node.mainComponent } else { $null }
        if ($isRepeatingControl -and -not $isStructuralContainer) {
            $auditResults.summary.totalChecks++
            if ($node.type -eq "INSTANCE" -and $targetCompId) {
                $auditResults.summary.passedChecks++
                $auditResults.componentChecks += [ordered]@{
                    nodeId          = $node.id
                    name            = $node.name
                    type            = $node.type
                    mainComponentId = $targetCompId
                    status          = "PASS"
                }
            } else {
                $auditResults.summary.failedChecks++
                $auditResults.componentChecks += [ordered]@{
                    nodeId = $node.id
                    name   = $node.name
                    type   = $node.type
                    status = "FAIL"
                }
                Add-AuditFinding -Category "Component/Architecture" -Priority "P1" -NodeId $node.id `
                    -Title ("Repeating control '{0}' is modeled as plain FRAME instead of linked INSTANCE" -f $node.name) `
                    -Evidence ("type = '{0}', mainComponentId = '{1}'" -f $node.type, $node.mainComponentId) `
                    -Expected "type == 'INSTANCE' with valid mainComponentId"
            }
        }
    }
}

# --- Determine Overall Deterministic Status ---

if ($auditResults.summary.p1Blockers -gt 0 -or $auditResults.summary.failedChecks -gt 0) {
    $auditResults.deterministicStatus = "FAIL"
} elseif ($auditResults.summary.unverifiableChecks -gt 0) {
    $auditResults.deterministicStatus = "NOT_VERIFIABLE"
} else {
    $auditResults.deterministicStatus = "PASS"
}

# --- Generate Output Reports ---

try {
    if (-not (Test-Path $OutputDir)) {
        New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
    }
    
    $jsonFileName = "vqa-audit-$($auditResults.documentId).json"
    $mdFileName = "vqa-report-$($auditResults.documentId).md"
    
    $jsonPath = Join-Path $OutputDir $jsonFileName
    $mdPath = Join-Path $OutputDir $mdFileName
    
    $jsonOutput = $auditResults | ConvertTo-Json -Depth 6
    [System.IO.File]::WriteAllText($jsonPath, $jsonOutput, [System.Text.Encoding]::UTF8)
    
    # Generate Markdown Report
    $mdContent = @"
# Visual Quality Assurance (VQA 2.0) Deterministic Audit Report

- **Document ID**: ``$($auditResults.documentId)``
- **Document Name**: $($auditResults.documentName)
- **Evaluated At**: $($auditResults.evaluatedAt)
- **Execution Mode**: $($auditResults.targetMode)
- **Deterministic Status**: **$($auditResults.deterministicStatus)**

---

## 1. Executive Summary

| Total Checks | Passed Checks | Failed Checks | Incomplete / Unverifiable | P1 Blockers | P2 Major | P3 Minor |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| $($auditResults.summary.totalChecks) | $($auditResults.summary.passedChecks) | $($auditResults.summary.failedChecks) | $($auditResults.summary.unverifiableChecks) | **$($auditResults.summary.p1Blockers)** | $($auditResults.summary.p2Majors) | $($auditResults.summary.p3Minors) |

> [!NOTE]
> $($auditResults.visualReviewNote)

---

## 2. Findings Log

"@
    if ($auditResults.findings.Count -eq 0) {
        $mdContent += "No deterministic P1/P2/P3 defects found. All verified geometric and contrast checks passed.`n`n"
    } else {
        foreach ($f in $auditResults.findings) {
            $mdContent += @"
### [$($f.id)] $($f.title)
- **Category**: $($f.category)
- **Priority**: **$($f.priority)**
- **Node ID**: ``$($f.nodeId)``
- **Concrete Evidence**: $($f.evidence)
- **Expected**: $($f.expected)

"@
        }
    }
    
    $mdContent += @"
---

## 3. Geometric & Column Alignment Audit

| Check Type | Node ID | Target / Column | Delta / Overflow | Status |
| :--- | :--- | :--- | :--- | :--- |
"@
    foreach ($g in $auditResults.geometryChecks) {
        $deltaStr = $(if ($g.deltaX) { "deltaX=$($g.deltaX)" } elseif ($g.overflow) { "overflow=$($g.overflow)" } else { "N/A" })
        $targetStr = $(if ($g.column) { $g.column } elseif ($g.childId) { $g.childId } else { "Container" })
        $mdContent += "`n| $($g.check) | ``$($g.nodeId)$($g.containerId)`` | $targetStr | $deltaStr | **$($g.status)** |"
    }
    
    $mdContent += "`n`n---`n`n## 4. WCAG 2.2 Contrast Audit`n`n| Node ID | Text Label | Size | Calculated Ratio | Required | Status |`n| :--- | :--- | :--- | :--- | :--- | :--- |"
    foreach ($c in $auditResults.contrastChecks) {
        $mdContent += "`n| ``$($c.nodeId)`` | $($c.textName) | $($c.fontSize) | $($c.contrastRatio) | $($c.threshold) | **$($c.status)** |"
    }
    
    $mdContent += "`n`n---`n*Generated by Design Orchestrator 2.2 Automated QA Engine.*`n"
    
    [System.IO.File]::WriteAllText($mdPath, $mdContent, [System.Text.Encoding]::UTF8)
} catch {
    Write-Warning "Failed to write audit files: $_"
}

if ($JsonReport) {
    Write-Output $jsonOutput
} else {
    $statusColor = switch ($auditResults.deterministicStatus) {
        "PASS"           { "Green" }
        "FAIL"           { "Red" }
        "NOT_VERIFIABLE" { "Yellow" }
    }
    Write-Host ("[{0}] Document: {1} | Status: [{2}] | P1: {3} | P2: {4} | Incomplete: {5}" -f `
        $auditResults.targetMode, $auditResults.documentName, $auditResults.deterministicStatus, `
        $auditResults.summary.p1Blockers, $auditResults.summary.p2Majors, $auditResults.summary.unverifiableChecks) -ForegroundColor $statusColor
}

return $auditResults
