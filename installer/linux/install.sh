#!/bin/bash
# CZ TDM mod - Linux installer. Run: ./install.sh   (or ./install.sh /path/to/Half-Life)
# Options: --no-optimize (mod only)   Uninstall: ./install.sh --uninstall
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"

find_cz() {
  local steam vdf lib
  for steam in ~/.steam/steam ~/.local/share/Steam ~/.var/app/com.valvesoftware.Steam/.local/share/Steam; do
    vdf="$steam/steamapps/libraryfolders.vdf"
    [ -f "$steam/steamapps/common/Half-Life/czero/liblist.gam" ] && { echo "$steam/steamapps/common/Half-Life"; return; }
    [ -f "$vdf" ] || continue
    while read -r lib; do
      [ -f "$lib/steamapps/common/Half-Life/czero/liblist.gam" ] && { echo "$lib/steamapps/common/Half-Life"; return; }
    done < <(grep -oP '"path"\s+"\K[^"]+' "$vdf")
  done
}

BEGIN_MARK='// >>> CZ TDM installer: optimizations (re-run the installer to change, uninstall to remove)'
END_MARK='// <<< CZ TDM installer'

# Replaces (or removes, with no lines) the marked block in a cfg file
set_block() { # file [lines...]
  local file="$1"; shift
  touch "$file"
  python3 - "$file" "$BEGIN_MARK" "$END_MARK" "$@" <<'PY'
import re, sys
path, begin, end, lines = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4:]
text = open(path, encoding="latin-1").read()
text = re.sub(r"\n?" + re.escape(begin) + r".*?" + re.escape(end) + r"\n?", "\n", text, flags=re.S).rstrip("\n")
if lines:
    text += "\n\n" + begin + "\n" + "\n".join(lines) + "\n" + end + "\n"
elif text:
    text += "\n"
open(path, "w", encoding="latin-1").write(text)
PY
}

ask() { # question default(y/n)
  local def="$2" ans
  if [ ! -t 0 ]; then [ "$def" = y ]; return; fi
  read -r -p "$1 [$( [ "$def" = y ] && echo Y/n || echo y/N )] " ans
  ans="${ans:-$def}"
  [[ "$ans" =~ ^[Yy] ]]
}

UNINSTALL=0; OPTIMIZE=1
while [[ "$1" == --* ]]; do
  case "$1" in
    --uninstall) UNINSTALL=1;;
    --no-optimize) OPTIMIZE=0;;
  esac
  shift
done
HL="${1:-$(find_cz)}"
if [ ! -f "$HL/czero/liblist.gam" ]; then
  echo "Could not find Counter-Strike: Condition Zero. Run: $0 /path/to/steamapps/common/Half-Life"
  exit 1
fi
CZ="$HL/czero"
APPS=~/.local/share/applications
DESK="$(xdg-user-dir DESKTOP 2>/dev/null || echo ~/Desktop)"

if [ $UNINSTALL = 1 ]; then
  "$CZ/tdm-mod/cz-mode.sh" normal || true
  rm -rf "$CZ/dlls/cstdm.so" "$CZ/sound/tdm" "$CZ/tdm-mod" "$CZ/tdm.cfg"
  rm -f "$APPS/cz-tdm.desktop" "$APPS/cz-normal.desktop" "$DESK/cz-tdm.desktop" "$DESK/cz-normal.desktop"
  set_block "$CZ/userconfig.cfg"
  set_block "$CZ/listenserver.cfg"
  echo "Uninstalled. CZ is back to the original game (optimizations removed too)."
  exit 0
fi

echo "Installing into $CZ"
install -m 755 "$HERE/czero/dlls/cstdm.so" "$CZ/dlls/cstdm.so"
install -m 644 "$HERE/czero/tdm.cfg" "$CZ/tdm.cfg"
mkdir -p "$CZ/sound/tdm" "$CZ/tdm-mod"
install -m 644 "$HERE"/czero/sound/tdm/*.wav "$HERE/czero/sound/tdm/CREDITS.txt" "$CZ/sound/tdm/"
install -m 755 "$HERE/czero/tdm-mod/cz-mode.sh" "$CZ/tdm-mod/cz-mode.sh"

mkdir -p "$APPS"
make_launcher() { # file name mode
  cat > "$1" <<DESKTOP
[Desktop Entry]
Type=Application
Name=$2
Comment=Counter-Strike: Condition Zero ($3 mode)
Exec="$CZ/tdm-mod/cz-mode.sh" $3 --launch
Icon=steam_icon_80
Terminal=false
Categories=Game;
DESKTOP
  chmod +x "$1"
}
make_launcher "$APPS/cz-tdm.desktop" "CZ TDM" tdm
make_launcher "$APPS/cz-normal.desktop" "CZ Normal" normal
if [ -d "$DESK" ]; then
  cp "$APPS/cz-tdm.desktop" "$APPS/cz-normal.desktop" "$DESK/"
  for f in "$DESK/cz-tdm.desktop" "$DESK/cz-normal.desktop"; do
    gio set "$f" metadata::trusted true 2>/dev/null || true
  done
fi
if [ $OPTIMIZE = 1 ]; then
echo
echo "Make the game smoother:"
CLIENT=(); SERVER=()
ask "  Raw mouse input (no acceleration or smoothing)?" y && CLIENT+=('// mouse: raw input, no acceleration or smoothing' 'm_rawinput "1"' 'm_filter "0"' 'm_customaccel "0"' 'joystick "0"' '-jlook')
ask "  Uncap FPS and turn V-Sync off?" y && CLIENT+=('// uncapped fps, no V-Sync input delay' 'gl_vsync "0"' 'fps_override "1"' 'fps_max "1000"')
ask "  Smooth online play (100 updates/s, rates, interpolation)?" y && CLIENT+=('// network: 100 updates/s, small interpolation buffer, lag compensation' 'rate "100000"' 'cl_updaterate "100"' 'cl_cmdrate "100"' 'ex_interp "0.05"' 'cl_lc "1"' 'cl_lw "1"')
ask "  No muzzle-flash wall lighting (steadier FPS while shooting)?" y && CLIENT+=('// no muzzle-flash wall lighting (steadier fps while shooting)' 'r_dynamic "0"')
ask "  Show FPS / ping / loss in the corner?" n && CLIENT+=('// fps / ping / loss in the bottom right (net_graph 0 to hide)' 'net_graph "3"' 'net_graphpos "1"')
ask "  Smooth hosting for friends (server rates, lag compensation)?" y && SERVER+=('// smooth hosting: up to 102 updates/s per player, minimum rates, lag compensation up to 1s' 'sv_maxupdaterate 102' 'sv_minupdaterate 60' 'sv_maxrate 100000' 'sv_minrate 50000' 'sv_unlag 1' 'sv_unlagpush 0' 'sv_unlagsamples 1' 'sv_maxunlag 1')
set_block "$CZ/userconfig.cfg" "${CLIENT[@]}"
set_block "$CZ/listenserver.cfg" "${SERVER[@]}"
if command -v nvidia-smi >/dev/null && command -v prime-select >/dev/null; then
  echo "  Laptop with NVIDIA: to run CZ on it, set Steam > CZ > Properties > Launch Options to:"
  echo "    __NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia %command%"
fi
fi
echo
echo "Done. Use the \"CZ TDM\" / \"CZ Normal\" shortcuts (menu or desktop),"
echo "or: $CZ/tdm-mod/cz-mode.sh tdm|normal"
