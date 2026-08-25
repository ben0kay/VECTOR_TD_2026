/// @description Draws one refinery and its inherited building state.

event_inherited();
if (BuildingState != BuildingState.ACTIVE && BuildingState != BuildingState.DISABLED) exit;
scr_refinery_draw(id);
