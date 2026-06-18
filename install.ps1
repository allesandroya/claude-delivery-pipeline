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
Write-Host ""

# autopilot depends on the 'superpowers' plugin (writing-plans, executing-plans).
# It's a Claude Code plugin, installed via slash commands inside Claude Code —
# a shell script can't install it, so we detect it and print the commands if missing.
$pluginRoot = Join-Path $env:USERPROFILE ".claude\plugins"
$hasSuperpowers = $false
if (Test-Path $pluginRoot) {
    $hasSuperpowers = [bool](Get-ChildItem $pluginRoot -Recurse -Depth 5 -Directory -Filter "superpowers*" -ErrorAction SilentlyContinue | Select-Object -First 1)
}
if ($hasSuperpowers) {
    Write-Host "superpowers plugin detected - autopilot's full chain is ready."
} else {
    Write-Host "WARNING: superpowers plugin NOT detected. 'autopilot' needs it for the"
    Write-Host "writing-plans and executing-plans phases. Install it from inside Claude Code:"
    Write-Host "  /plugin marketplace add obra/superpowers-marketplace"
    Write-Host "  /plugin install superpowers@superpowers-marketplace"
}
