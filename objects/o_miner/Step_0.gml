/// @description Inherits building logic and processes active extraction.

event_inherited();


if (!instance_exists(id))
    exit;

if (!GAMEPLAY_ACTIVE) exit;

if (BuildingState != BuildingState.ACTIVE)
    exit;


scr_miner_update(id);