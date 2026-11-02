# Lab 001, test step 2. Read the error count first, then setup slack.
# A negative setup slack near 1 ns means lab001.sdc is missing.
# Run: .\check

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

$reports = @(
    "lab001.map.rpt",
    "lab001.fit.rpt",
    "lab001.asm.rpt",
    "lab001.sta.rpt",
    "lab001.flow.rpt"
)
foreach ($name in $reports) {
    if (-not (Test-Path $name)) {
        throw "Missing $name. Run 01_compile.ps1 first."
    }
}

Write-Output "Error lines:"
Select-String -Path $reports -Pattern "errors," |
    ForEach-Object { "{0}: {1}" -f $_.Filename, $_.Line.Trim() }

$slackText = $null
$summary = Get-Content "lab001.sta.summary" -Raw
$fromSummary = [regex]::Match($summary, "Type\s+:\s+Setup[^\r\n]*\r?\nSlack\s+:\s+([-\d.]+)")
if ($fromSummary.Success) {
    $slackText = $fromSummary.Groups[1].Value
} else {
    $fromReport = Select-String -Path "lab001.sta.rpt" -Pattern "Worst-case setup slack is ([-\d.]+)" | Select-Object -First 1
    if ($fromReport) {
        $slackText = $fromReport.Matches[0].Groups[1].Value
    }
}

Write-Output ""
if (-not $slackText) {
    Write-Output "Setup slack: not in the timing report. Run .\compile again."
} else {
    Write-Output ("Setup slack: {0} ns" -f $slackText)
    if ([double]$slackText -lt 0) {
        Write-Output "Negative slack. If TimeQuest assumed a 1 ns period, lab001.sdc is missing."
    }
}
