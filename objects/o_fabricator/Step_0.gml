/// @description Inherits construction and processes Fabricator production.

event_inherited();

if (!instance_exists(id))
    exit;

if (!GAMEPLAY_ACTIVE)
    exit;


scr_production_update(id);