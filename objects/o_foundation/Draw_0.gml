/// @description Draws one foundation tile.

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
    scr_foundation_draw(id);
}