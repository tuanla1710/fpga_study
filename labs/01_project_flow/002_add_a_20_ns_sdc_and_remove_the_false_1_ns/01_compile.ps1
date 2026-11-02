# Lab 002. Compile this project with Quartus II 11.
# Run: .\compile

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

$quartus = "C:\altera\11.0\quartus\bin\quartus_sh.exe"
if (-not (Test-Path $quartus)) {
    throw "Quartus 11 was not found at $quartus"
}

& $quartus --flow compile lab002
if ($LASTEXITCODE -ne 0) {
    throw "Compile failed with exit code $LASTEXITCODE"
}
