# CZ TDM

Team Deathmatch for **Counter-Strike: Condition Zero** (Steam), with a one-click switch back to the original game.

## What you get

- **Team deathmatch:** rounds never end and you respawn 2 seconds after dying, with 2 seconds of spawn protection.
- **Keep your weapons:** you respawn with the guns you died with, with a full magazine and full reserve ammo.
- **Infinite reserve ammo:** you still reload, but your spare ammo never runs out.
- **HP regeneration:** after 4 seconds without taking damage you heal 5 HP every half second.
- **Map weapons respawn:** guns placed on the map come back 20 seconds after someone picks them up.
- **Kill announcer:** headshot, first blood, double / triple / multi / mega / ultra / monster kill, killing spree, rampage, dominating, unstoppable, godlike, and humiliation for knife kills.
- **Shortcuts:** **CZ TDM** and **CZ Normal**, each switching the mode and then starting the game.

Only the player who **hosts** the game needs the mod. Friends who join can play without installing anything, and their game downloads the announcer voices automatically when they connect.

## Install

Download from the [Releases](../../releases) page.

### Windows

1. Run `CZ-TDM-Setup-x.y.z.exe`. It finds Condition Zero through Steam; if it can't, point it at `...\steamapps\common\Half-Life`.
2. Start the game with the **CZ TDM** or **CZ Normal** shortcut (Start menu or desktop).

Windows SmartScreen may warn about an unknown publisher because the installer isn't code-signed. Click **More info → Run anyway**.

To remove the mod, uninstall **CZ TDM Mod** from *Settings → Apps*. The game goes back to normal.

### Linux

```sh
tar xzf cz-tdm-linux-x.y.z.tar.gz
cd cz-tdm-linux-x.y.z
./install.sh                # or: ./install.sh /path/to/steamapps/common/Half-Life
```

Use the **CZ TDM** / **CZ Normal** launchers, or run `czero/tdm-mod/cz-mode.sh tdm|normal|status` from the game folder.
To remove the mod, run `./install.sh --uninstall`.

## Settings

All settings are in `czero/tdm.cfg`, which only TDM mode reads. Put your own changes in `czero/tdm_custom.cfg` so updates don't overwrite them.

| Setting | Default | Meaning |
|---|---|---|
| `mp_forcerespawn` | 2 | seconds until respawn |
| `mp_respawn_keep_weapons` | 1 | respawn with the weapons you died with |
| `mp_infinite_ammo` | 2 | 2 = infinite reserve ammo, 1 = infinite magazine |
| `mp_hp_regen` | 5 | HP per tick (0 = off) |
| `mp_hp_regen_delay` | 4 | seconds without damage before regeneration starts |
| `mp_hp_regen_interval` | 0.5 | seconds between ticks |
| `mp_armoury_respawn_time` | 20 | seconds until a picked-up map weapon returns (0 = never) |
| `mp_kill_announcer` | 1 | announcer sounds and messages |

The announcer voices are the files in `czero/sound/tdm/*.wav` (22050 Hz, mono, 16-bit). Replace them with your own if you like; any file you delete is simply skipped.

## How it works

The mod is a modified build of [ReGameDLL_CS](https://github.com/rehlds/ReGameDLL_CS), the open-source Counter-Strike game library. It installs **next to** the original as `dlls/cstdm.so` (Linux) or `dlls/cstdm.dll` (Windows). Switching modes changes one line in `czero/liblist.gam` and never touches the original files.

The new code lives in `regamedll/regamedll/dlls/tdm_mod.h` and the end of `regamedll/regamedll/dlls/player.cpp`, with small hooks in `weapons.cpp`, `multiplay_gamerules.cpp`, `client.cpp`, `game.cpp` and `gamerules.cpp`.

### Building

- **Linux:** `cmake -S regamedll -B build -DCMAKE_BUILD_TYPE=Release -DUSE_STATIC_LIBSTDC=ON && cmake --build build` (needs `gcc-multilib g++-multilib`).
- **Windows:** `msbuild regamedll/msvc/ReGameDLL.sln -p:Configuration=Release /p:Platform=Win32`.
- **Releases:** pushing a `v*` tag builds both platforms and the installer in GitHub Actions (`.github/workflows/release.yml`).
- **Voice pack:** `sounds-src/make_sounds.sh` regenerates it with [Piper](https://github.com/rhasspy/piper), using the `en_US-joe-medium` voice (CC0 dataset).

The library name must not contain an underscore: the current CZ engine strips anything after `_`, so `cs_tdm.so` would load as `cs.so`.

## License

MIT, same as ReGameDLL_CS (see `LICENSE`). The voice pack was generated with Piper TTS from a CC0 voice.
