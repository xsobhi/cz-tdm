/*
 * CZ TDM mod additions (implemented in player.cpp)
 *
 *  mp_respawn_keep_weapons  - respawn with the weapons you died with (full clip + full reserve)
 *  mp_hp_regen              - HP restored per tick (0 = off)
 *  mp_hp_regen_delay        - seconds without taking damage before regen starts
 *  mp_hp_regen_interval     - seconds between regen ticks
 *  mp_armoury_respawn_time  - seconds until a picked-up map weapon (armoury_entity) comes back (0 = never)
 *  mp_kill_announcer        - headshot / double kill / killing spree... sounds and messages
 *  mp_weapon_menu           - pick primary + pistol from a menu on every spawn
 *  mp_spawn_grenades        - HE + 2 flashbangs + smoke on every spawn
 *  mp_tdm_ask_host          - the listen-server host gets a setup menu on each map (spawns / weapons / gear);
 *                             reopen it with "tdm_setup" in the console or "!setup" in chat
 */

#pragma once

class CBasePlayer;

void TDM_SaveLoadout(CBasePlayer *pPlayer);
bool TDM_GiveSavedLoadout(CBasePlayer *pPlayer);
void TDM_ClientDisconnected(CBasePlayer *pPlayer);
void TDM_PlayerThink(CBasePlayer *pPlayer);
void TDM_PlayerKilled(CBasePlayer *pVictim, CBasePlayer *pKiller);
void TDM_Precache();
void TDM_RegisterCvars();
void TDM_OnSpawnEquipped(CBasePlayer *pPlayer);
bool TDM_MenuSelect(CBasePlayer *pPlayer, int slot);
bool TDM_ClientCommand(CBasePlayer *pPlayer, const char *pcmd, const char *parg1);

extern struct cvar_s respawn_keep_weapons;
extern struct cvar_s armoury_respawn_time;
