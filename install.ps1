# Installs the delivery-pipeline skills into your Claude Code skills directory.
# Usage:  ./install.ps1
$ErrorActionPreference = "Stop"

$dest = Join-Path $env:USERPROFILE ".claude\skills"
$src  = Join-Path $PSScriptRoot "skills"

New-Item -ItemType Directory -Force $dest | Out-Null

foreach ($skill in Get-ChildItem $src -Directory) {
    $target = Join-Path $dest $skill.Name
    if (Test-Path $target) { Remove-Item -Recurse -Force $target }
    Copy-Item $skill.FullName $target -Recurse -Force
    Write-Host "installed: $($skill.Name)"
}

Write-Host ""
Write-Host "Done. Restart Claude Code to load the skills."
Write-Host "NOTE: 'autopilot' also needs the 'superpowers' plugin (writing-plans, executing-plans)."
Write-Host "      See https://github.com/obra/superpowers"
