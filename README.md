# CZ TDM

Team Deathmatch for **Counter-Strike: Condition Zero** (Steam), with a one-click switch back to the original game.

## What you get

- **Team deathmatch:** rounds never end and you respawn 2 seconds after dying, with 2 seconds of spawn protection.
- **Keep your weapons:** you respawn with the guns you died with, with a full magazine and full reserve ammo.
- **Infinite reserve ammo:** you still reload, but your spare ammo never runs out.
- **HP regeneration:** after 4 seconds without taking damage you heal 5 HP every half second.
- **Map weapons respawn:** guns placed on the map come back 20 seconds after someone picks them up.
- **Kill announcer** (real voice actor, the WARLORD pack):
  - kills in quick succession: double kill, triple kill, annihilation, eradication
  - kills without dying: rampage (3), dominating (5), unstoppable (7+)
  - first blood, headshot, and revenge kill (you kill whoever last killed you)
  - "Team Deathmatch" when you spawn on a new map
- **Host setup menu:** when the host spawns on a map, an in-game menu asks 3 questions. Press `0` to keep the current settings, or reopen it with `!setup` in chat.
  - spawns: random anywhere on the map, or team bases
  - weapons on respawn: keep yours, pick from a menu, or default pistol
  - free gear on every spawn: armor + helmet + grenades, armor, grenades, or nothing
- **Weapon menu** (if the host picks it): choose a primary and a pistol on every spawn; `0` repeats your last pick.
- **Shortcuts:** **CZ TDM** and **CZ Normal**, each switching the mode and then starting the game.
- **Optional optimizer** (checkboxes in the installer):
  - raw mouse input
  - uncapped FPS with V-Sync off
  - 100 updates/s networking with tuned interpolation
  - no muzzle-flash lighting
  - smooth-hosting server rates
  - forcing the high-performance GPU on laptops

Only the player who **hosts** the game needs the mod. Friends who join can play without installing anything, and their game downloads the announcer voices automatically when they connect.

## Install

Download from the [Releases](../../releases) page.

### Windows

1. Run `CZ-TDM-Setup-x.y.z.exe`.
   - It finds Condition Zero automatically in any of your Steam library folders and shows the folder it found. Click **Browse** if it's wrong; it should be `...\steamapps\common\Half-Life`.
   - Tick what you want: install the mod, desktop shortcuts, and each optimization. You can also run it just for the optimizations.
2. Start the game with the **CZ TDM** or **CZ Normal** shortcut (Start menu or desktop).

Run the installer again at any time to change your choices. The optimizations are written into a clearly marked block in `czero\userconfig.cfg` and `czero\listenserver.cfg`, and uninstalling removes them.

Windows SmartScreen may warn about an unknown publisher because the installer isn't code-signed. Click **More info → Run anyway**.

To remove the mod, uninstall **CZ TDM Mod** from *Settings → Apps*. The game goes back to normal.

### Linux

```sh
tar xzf cz-tdm-linux-x.y.z.tar.gz
cd cz-tdm-linux-x.y.z
./install.sh                # asks about each optimization; --no-optimize = mod only
                            # or: ./install.sh /path/to/steamapps/common/Half-Life
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
| `mp_tdm_ask_host` | 1 | show the host the setup menu on each map |
| `mp_randomspawn` | 0 | 1 = random spawn spots all over the map (needs the map's `.nav`) |
| `mp_weapon_menu` | 0 | 1 = pick primary + pistol from a menu on every spawn |
| `mp_free_armor` | 0 | 1 = kevlar, 2 = kevlar + helmet on every spawn |
| `mp_spawn_grenades` | 0 | 1 = HE + 2 flashbangs + smoke on every spawn |

The announcer voices are the files in `czero/sound/tdm/*.wav` (22050 Hz, mono, 16-bit). Replace them with your own if you like; any file you delete is simply skipped.

The file names are `headshot`, `firstblood`, `doublekill`, `triplekill`, `annihilation`, `eradication`, `rampage`, `dominating`, `unstoppable`, `revenge` and `teamdeathmatch`.

## How it works

The mod is a modified build of [ReGameDLL_CS](https://github.com/rehlds/ReGameDLL_CS), the open-source Counter-Strike game library. It installs **next to** the original as `dlls/cstdm.so` (Linux) or `dlls/cstdm.dll` (Windows). Switching modes changes one line in `czero/liblist.gam` and never touches the original files.

The new code lives in `regamedll/regamedll/dlls/tdm_mod.h` and the end of `regamedll/regamedll/dlls/player.cpp`, with small hooks in `weapons.cpp`, `multiplay_gamerules.cpp`, `client.cpp`, `game.cpp` and `gamerules.cpp`.

### Building

- **Linux:** `cmake -S regamedll -B build -DCMAKE_BUILD_TYPE=Release -DUSE_STATIC_LIBSTDC=ON && cmake --build build` (needs `gcc-multilib g++-multilib`).
- **Windows:** `msbuild regamedll/msvc/ReGameDLL.sln -p:Configuration=Release /p:Platform=Win32`.
- **Releases:** pushing a `v*` tag builds both platforms and the installer in GitHub Actions (`.github/workflows/release.yml`).
- **Voice pack:** `sounds-src/convert_warlord.sh` converts the original WARLORD WAV files into the game's format.

The library name must not contain an underscore: the current CZ engine strips anything after `_`, so `cs_tdm.so` would load as `cs.so`.

## License

- **Code:** MIT, same as ReGameDLL_CS (see `LICENSE`).
- **Announcer voice:** [WARLORD - Announcer Audio Pack](https://voicebosch.itch.io/warlord-announcer-audio-pack) by VoiceBosch, licensed [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/). The converted files in `dist/czero/sound/tdm/` are under the same license (see `CREDITS.txt` there).
