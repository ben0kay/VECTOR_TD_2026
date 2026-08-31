/// @description Draws one local energy battery.

event_inherited();
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
    scr_energy_battery_draw(id);
}