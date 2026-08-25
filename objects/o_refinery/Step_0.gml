/// @description Inherits construction and processes refinery production.

event_inherited();
if (!instance_exists(id)) exit;
if (!GAMEPLAY_ACTIVE) exit;

scr_refinery_update(id);
