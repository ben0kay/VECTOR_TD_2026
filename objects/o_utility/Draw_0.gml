/// @description Draws one utility building and its construction state.

event_inherited();

if (BuildingState != BuildingState.ACTIVE)
    exit;

scr_utility_draw(id);