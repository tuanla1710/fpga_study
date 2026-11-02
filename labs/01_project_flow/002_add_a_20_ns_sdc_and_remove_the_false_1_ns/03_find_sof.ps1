# Lab 002. The .sof is in this project directory, not in output_files.
# Run: .\check

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

$sof = Join-Path $PSScriptRoot "lab002.sof"
if (-not (Test-Path $sof)) {
    throw "lab002.sof was not found. Run .\compile first."
}

$info = Get-Item $sof
Write-Output ("SOF: {0}" -f $info.FullName)
Write-Output ("Bytes: {0}" -f $info.Length)
Write-Output ("Last write: {0}" -f $info.LastWriteTime)

if (Test-Path "output_files\lab002.sof") {
    Write-Output "A copy also exists in output_files. Use the .sof in this directory."
} else {
    Write-Output "No output_files\lab002.sof. This project writes the image next to lab002.qpf."
}

$asm = Get-Content "lab002.asm.rpt" -Raw
$block = [regex]::Match($asm, "lab002\.sof[\s\S]*?Checksum\s+;\s+(0x[0-9A-Fa-f]+)")
if ($block.Success) {
    Write-Output ("Checksum: {0}" -f $block.Groups[1].Value)
} else {
    Write-Output "Checksum was not found in lab002.asm.rpt."
}
