/// @description Inherits building logic and processes active tower behaviour.

event_inherited();

if (!BUILDING_CAN_OPERATE)
    exit;

scr_tower_update(id);