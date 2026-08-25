/// @description Draws one generic building and its field shield.

scr_building_draw(id);

if (!instance_exists(id))
    exit;


scr_building_shield_draw(id);