/// @description Draws one active Fabricator.

event_inherited();

if (
    BuildingState != BuildingState.ACTIVE
    && BuildingState != BuildingState.DISABLED
)
{
    exit;
}


scr_fabricator_draw(id);