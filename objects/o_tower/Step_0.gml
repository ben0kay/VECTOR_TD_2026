/// @description Inherits building logic and processes active tower behaviour.

event_inherited();


if (!instance_exists(id))
    exit;

if (!GAMEPLAY_ACTIVE) exit;

if (BuildingState != BuildingState.ACTIVE)
    exit;


scr_tower_update(id);