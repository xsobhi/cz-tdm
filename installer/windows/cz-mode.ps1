# Switches Counter-Strike: Condition Zero between TDM and the original game, then starts it.
# Usage: cz-mode.ps1 tdm|normal [-NoLaunch]
param(
    [Parameter(Mandatory = $true)][ValidateSet('tdm', 'normal')][string]$Mode,
    [switch]$NoLaunch
)

$ErrorActionPreference = 'Stop'
$czero = Split-Path -Parent $PSScriptRoot          # ...\Half-Life\czero
$liblist = Join-Path $czero 'liblist.gam'
$dll = if ($Mode -eq 'tdm') { 'dlls\cstdm.dll' } else { 'dlls\mp.dll' }

if (Get-Process -Name hl -ErrorAction SilentlyContinue) {
    Add-Type -AssemblyName PresentationFramework
    [System.Windows.MessageBox]::Show('Close Counter-Strike first, then try again.', 'CZ TDM') | Out-Null
    exit 1
}

$text = [IO.File]::ReadAllText($liblist)
$text = [regex]::Replace($text, '(?m)^gamedll\s+"[^"]*"', "gamedll `"$dll`"")
[IO.File]::WriteAllText($liblist, $text, (New-Object System.Text.ASCIIEncoding))

if (-not $NoLaunch) {
    Start-Process 'steam://rungameid/80'
}
