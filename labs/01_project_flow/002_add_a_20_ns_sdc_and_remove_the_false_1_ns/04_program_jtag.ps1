# Lab 002. Program lab002.sof over JTAG.
# Cable on the JTAG header, RUN/PROG switch on RUN. This does not program the .pof.
# Run: .\upload

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

$quartusPgm = "C:\altera\11.0\quartus\bin\quartus_pgm.exe"
$sof = Join-Path $PSScriptRoot "lab002.sof"
if (-not (Test-Path $quartusPgm)) {
    throw "Quartus 11 programmer was not found at $quartusPgm"
}
if (-not (Test-Path $sof)) {
    throw "lab002.sof was not found. Run .\compile first."
}

& $quartusPgm -c "USB-Blaster [USB-0]" -m JTAG -o ("p;" + $sof)
if ($LASTEXITCODE -ne 0) {
    throw "JTAG programming failed with exit code $LASTEXITCODE"
}
