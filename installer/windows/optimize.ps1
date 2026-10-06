# Applies (or removes) the CZ smoothness tweaks chosen in the installer.
# Settings go into a marked block in czero\userconfig.cfg (client) and czero\listenserver.cfg
# (hosting); running again replaces the block, -Remove takes it out.
param(
    [switch]$Mouse,      # raw mouse input, no acceleration/smoothing
    [switch]$Fps,        # uncapped FPS, V-Sync off
    [switch]$Network,    # 100 updates/s, rates, interpolation, lag compensation
    [switch]$Perf,       # no muzzle-flash lighting
    [switch]$NetGraph,   # fps/ping/loss in the corner
    [switch]$Server,     # smooth hosting for friends
    [switch]$Gpu,        # high-performance GPU on laptops
    [switch]$Remove
)

$ErrorActionPreference = 'Stop'
$czero = Split-Path -Parent $PSScriptRoot
$hlExe = Join-Path (Split-Path -Parent $czero) 'hl.exe'
$begin = '// >>> CZ TDM installer: optimizations (re-run the installer to change, uninstall to remove)'
$end = '// <<< CZ TDM installer'

function Set-Block([string]$file, [string[]]$lines) {
    $text = ''
    if (Test-Path $file) { $text = [IO.File]::ReadAllText($file) }
    $pattern = '(?s)\r?\n?' + [regex]::Escape($begin) + '.*?' + [regex]::Escape($end) + '\r?\n?'
    $text = [regex]::Replace($text, $pattern, "`r`n")
    $text = $text.TrimEnd([char[]]"`r`n")
    if ($lines.Count -gt 0) {
        $text += "`r`n`r`n" + $begin + "`r`n" + ($lines -join "`r`n") + "`r`n" + $end + "`r`n"
    } elseif ($text.Length -gt 0) {
        $text += "`r`n"
    }
    [IO.File]::WriteAllText($file, $text, (New-Object System.Text.ASCIIEncoding))
}

$clientLines = @()
$serverLines = @()

if (-not $Remove) {
    if ($Mouse) {
        $clientLines += '// mouse: raw input, no acceleration or smoothing', 'm_rawinput "1"', 'm_filter "0"', 'm_customaccel "0"', 'joystick "0"', '-jlook'
    }
    if ($Fps) {
        $clientLines += '// uncapped fps, no V-Sync input delay', 'gl_vsync "0"', 'fps_override "1"', 'fps_max "1000"'
    }
    if ($Network) {
        $clientLines += '// network: 100 updates/s, small interpolation buffer, lag compensation',
            'rate "100000"', 'cl_updaterate "100"', 'cl_cmdrate "100"', 'ex_interp "0.05"', 'cl_lc "1"', 'cl_lw "1"'
    }
    if ($Perf) {
        $clientLines += '// no muzzle-flash wall lighting (steadier fps while shooting)', 'r_dynamic "0"'
    }
    if ($NetGraph) {
        $clientLines += '// fps / ping / loss in the bottom right (net_graph 0 to hide)', 'net_graph "3"', 'net_graphpos "1"'
    }
    if ($Server) {
        $serverLines += '// smooth hosting: up to 102 updates/s per player, minimum rates, lag compensation up to 1s',
            'sv_maxupdaterate 102', 'sv_minupdaterate 60', 'sv_maxrate 100000', 'sv_minrate 50000',
            'sv_unlag 1', 'sv_unlagpush 0', 'sv_unlagsamples 1', 'sv_maxunlag 1'
    }
}

Set-Block (Join-Path $czero 'userconfig.cfg') $clientLines
Set-Block (Join-Path $czero 'listenserver.cfg') $serverLines

# Windows "Graphics settings" preference for hl.exe (2 = high performance GPU)
$gpuKey = 'HKCU:\Software\Microsoft\DirectX\UserGpuPreferences'
if ($Gpu -and -not $Remove) {
    New-Item -Path $gpuKey -Force | Out-Null
    Set-ItemProperty -Path $gpuKey -Name $hlExe -Value 'GpuPreference=2;'
} elseif (Test-Path $gpuKey) {
    Remove-ItemProperty -Path $gpuKey -Name $hlExe -ErrorAction SilentlyContinue
}
