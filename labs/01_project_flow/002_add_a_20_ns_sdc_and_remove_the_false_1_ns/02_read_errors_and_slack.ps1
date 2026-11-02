# Lab 002. Read the error count first, then setup slack.
# A negative setup slack near a 1 ns period means lab002.sdc still has the false clock.
# Run: .\check

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

$reports = @(
    "lab002.map.rpt",
    "lab002.fit.rpt",
    "lab002.asm.rpt",
    "lab002.sta.rpt",
    "lab002.flow.rpt"
)
foreach ($name in $reports) {
    if (-not (Test-Path $name)) {
        throw "Missing $name. Run .\compile first."
    }
}

Write-Output "Error lines:"
Select-String -Path $reports -Pattern "errors," |
    ForEach-Object { "{0}: {1}" -f $_.Filename, $_.Line.Trim() }

$slackText = $null
$summary = Get-Content "lab002.sta.summary" -Raw
$fromSummary = [regex]::Match($summary, "Type\s+:\s+Setup[^\r\n]*\r?\nSlack\s+:\s+([-\d.]+)")
if ($fromSummary.Success) {
    $slackText = $fromSummary.Groups[1].Value
} else {
    $fromReport = Select-String -Path "lab002.sta.rpt" -Pattern "Worst-case setup slack is ([-\d.]+)" | Select-Object -First 1
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
        Write-Output "Negative slack. lab002.sdc still has the false 1 ns period."
    }
}
