/// @description Updates one generic building.

if (!GAMEPLAY_ACTIVE)
    exit;


scr_building_update(id);

if (!instance_exists(id))
    exit;


scr_building_shield_update(id);