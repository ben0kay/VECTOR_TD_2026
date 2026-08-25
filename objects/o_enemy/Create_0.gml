/// @description Initializes one generic enemy.

if (!scr_enemy_initialize(id))
{
    show_debug_message(
        "ENEMY ERROR - initialization failed."
    );

    instance_destroy();
    exit;
}


if (!scr_enemy_stealth_initialize(id))
{
    show_debug_message(
        "ENEMY ERROR - stealth initialization failed."
    );

    instance_destroy();
    exit;
}


if (!scr_enemy_advanced_initialize(id))
{
    show_debug_message(
        "ENEMY ERROR - advanced initialization failed."
    );

    instance_destroy();
    exit;
}


if (!scr_enemy_centipede_initialize(id))
{
    show_debug_message(
        "ENEMY ERROR - Centipede initialization failed."
    );

    instance_destroy();
    exit;
}