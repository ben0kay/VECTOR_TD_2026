/// @description Draws one active Fabricator.

event_inherited();

if (
    BuildingState != BuildingState.ACTIVE
    && BuildingState != BuildingState.DISABLED
)
{
    exit;
}


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
    scr_fabricator_draw(id);
}