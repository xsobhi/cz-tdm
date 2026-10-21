# Switches Counter-Strike: Condition Zero between TDM and the original game, then starts it.
# Usage: cz-mode.ps1 tdm|ffa|normal [-NoLaunch]
param(
    [Parameter(Mandatory = $true)][ValidateSet('tdm', 'ffa', 'normal')][string]$Mode,
    [switch]$NoLaunch
)

$ErrorActionPreference = 'Stop'
$czero = Split-Path -Parent $PSScriptRoot          # ...\Half-Life\czero
$liblist = Join-Path $czero 'liblist.gam'
$dll = if ($Mode -ne 'normal') { 'dlls\cstdm.dll' } else { 'dlls\mp.dll' }

if (Get-Process -Name hl -ErrorAction SilentlyContinue) {
    Add-Type -AssemblyName PresentationFramework
    [System.Windows.MessageBox]::Show('Close Counter-Strike first, then try again.', 'CZ TDM') | Out-Null
    exit 1
}

if ($Mode -ne 'normal') {
    $ffa = if ($Mode -eq 'ffa') { 1 } else { 0 }
    [IO.File]::WriteAllText((Join-Path $czero 'tdm_mode.cfg'), "mp_freeforall $ffa`r`n", (New-Object System.Text.ASCIIEncoding))
}

$text = [IO.File]::ReadAllText($liblist)
$text = [regex]::Replace($text, '(?m)^gamedll\s+"[^"]*"', "gamedll `"$dll`"")
[IO.File]::WriteAllText($liblist, $text, (New-Object System.Text.ASCIIEncoding))

if (-not $NoLaunch) {
    Start-Process 'steam://rungameid/80'
}
