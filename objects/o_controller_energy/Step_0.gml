/// @description Updates local energy networks.

if (!GAMEPLAY_ACTIVE)
    exit;

if (keyboard_check_pressed(ord("P")))
{
    global.vtd_level.energy.overlay.mode =
        (global.vtd_level.energy.overlay.mode + 1)
        mod 3;
}

scr_energy_update();