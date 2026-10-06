/*
 * CZ TDM mod additions (implemented in player.cpp)
 *
 *  mp_respawn_keep_weapons  - respawn with the weapons you died with (full clip + full reserve)
 *  mp_hp_regen              - HP restored per tick (0 = off)
 *  mp_hp_regen_delay        - seconds without taking damage before regen starts
 *  mp_hp_regen_interval     - seconds between regen ticks
 *  mp_armoury_respawn_time  - seconds until a picked-up map weapon (armoury_entity) comes back (0 = never)
 *  mp_kill_announcer        - headshot / double kill / killing spree... sounds and messages
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

extern struct cvar_s respawn_keep_weapons;
extern struct cvar_s armoury_respawn_time;
