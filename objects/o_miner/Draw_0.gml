/// @description Draws one miner and its construction state.

event_inherited();

if (BuildingState != BuildingState.ACTIVE)
    exit;

scr_miner_draw(id);