/// @description Draws one tower and its construction state.

if (OUTSIDE_VIEW_128)
    exit;

event_inherited();

if (BuildingState != BuildingState.ACTIVE)
    exit;

scr_tower_range_draw(id);
scr_tower_draw(id);

