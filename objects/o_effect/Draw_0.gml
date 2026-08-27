/// @description Draws one visible generic temporary effect.

if (OUTSIDE_VIEW_256)
    exit;
	
if (!scr_fog_position_visible(x, y))
    exit;

scr_effect_draw(id);