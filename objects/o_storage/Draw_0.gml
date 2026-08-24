/// @description Draws one storage building and its construction state.

event_inherited();

if (BuildingState != BuildingState.ACTIVE)
    exit;

scr_storage_draw(id);