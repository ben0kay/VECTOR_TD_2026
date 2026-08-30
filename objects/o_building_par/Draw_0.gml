/// @description Draws one generic building and its field shield.

scr_building_draw(id);

if (!instance_exists(id))
    exit;


draw_set_alpha(1);
draw_set_color(c_lime);

draw_rectangle(
    bbox_left,
    bbox_top,
    bbox_right,
    bbox_bottom,
    true
);

draw_set_color(c_white);

scr_building_shield_draw(id);