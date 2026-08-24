/// @description Inherits building logic and processes extraction and logistics.

event_inherited();

if (!GAMEPLAY_ACTIVE)
    exit;

if (BuildingState != BuildingState.ACTIVE)
    exit;

scr_miner_update(id);