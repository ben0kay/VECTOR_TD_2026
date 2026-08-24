/// @description Inherits building logic and processes active utility behaviour.

event_inherited();

if (!BUILDING_CAN_OPERATE)
    exit;

scr_utility_update(id);