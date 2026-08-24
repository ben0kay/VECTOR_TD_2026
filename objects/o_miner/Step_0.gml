/// @description Inherits building logic and processes active extraction.

event_inherited();

if (!BUILDING_CAN_OPERATE)
    exit;

scr_miner_update(id);