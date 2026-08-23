/// @description Draws one visible enemy projectile.

if (OUTSIDE_VIEW_64)
    exit;

if (!scr_fog_position_visible(x, y))
    exit;

scr_projectile_enemy_draw(id);