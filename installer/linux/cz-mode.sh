#!/bin/bash
# Switches Counter-Strike: Condition Zero between TDM and the original game.
# Usage: cz-mode.sh tdm|ffa|normal|status [--launch]
CZERO="$(cd "$(dirname "$(readlink -f "$0")")/.." && pwd)"
LIBLIST="$CZERO/liblist.gam"

set_dll() { sed -i "s#^gamedll_linux .*#gamedll_linux \"$1\"#" "$LIBLIST"; }

case "$1" in
  tdm)    echo 'mp_freeforall 0' > "$CZERO/tdm_mode.cfg"; set_dll dlls/cstdm.so; echo "CZ mode: TDM";;
  ffa)    echo 'mp_freeforall 1' > "$CZERO/tdm_mode.cfg"; set_dll dlls/cstdm.so; echo "CZ mode: FFA";;
  normal) set_dll dlls/cs.so;    echo "CZ mode: original";;
  status|"")
    if ! grep -q 'cstdm' "$LIBLIST"; then echo "CZ mode: original"
    elif grep -q '^mp_freeforall 1' "$CZERO/tdm_mode.cfg" 2>/dev/null; then echo "CZ mode: FFA"
    else echo "CZ mode: TDM"; fi
    exit 0;;
  *) echo "Usage: $0 tdm|ffa|normal|status [--launch]"; exit 1;;
esac

if [ "$2" = "--launch" ]; then
  if pgrep -x hl_linux >/dev/null; then
    notify-send "CZ TDM" "Close Counter-Strike first, then try again." 2>/dev/null
    exit 1
  fi
  xdg-open steam://rungameid/80 >/dev/null 2>&1 || steam steam://rungameid/80 >/dev/null 2>&1 &
fi
