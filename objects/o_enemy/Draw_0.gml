/// @description Draws one visible generic enemy.

if (OUTSIDE_VIEW_128)
    exit;

if (!scr_fog_position_visible(x, y))
    exit;

scr_enemy_draw(id);