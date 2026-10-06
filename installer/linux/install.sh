#!/bin/bash
# CZ TDM mod - Linux installer. Run: ./install.sh   (or ./install.sh /path/to/Half-Life)
# Uninstall: ./install.sh --uninstall
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

UNINSTALL=0
[ "$1" = "--uninstall" ] && { UNINSTALL=1; shift; }
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
  echo "Uninstalled. CZ is back to the original game."
  exit 0
fi

echo "Installing into $CZ"
install -m 755 "$HERE/czero/dlls/cstdm.so" "$CZ/dlls/cstdm.so"
install -m 644 "$HERE/czero/tdm.cfg" "$CZ/tdm.cfg"
mkdir -p "$CZ/sound/tdm" "$CZ/tdm-mod"
install -m 644 "$HERE"/czero/sound/tdm/*.wav "$CZ/sound/tdm/"
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
echo "Done. Use the \"CZ TDM\" / \"CZ Normal\" shortcuts (menu or desktop),"
echo "or: $CZ/tdm-mod/cz-mode.sh tdm|normal"
