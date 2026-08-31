/// @description Draws one utility building and its construction state.

event_inherited();

if (BuildingState != BuildingState.ACTIVE)
    exit;

if (
    !scr_building_baked_draw(
        id,
        0,
        0,
        0,
        visual.color
    )
)
{
    scr_utility_draw(id);
}