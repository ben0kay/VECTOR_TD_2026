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


if (!scr_enemy_performance_initialize(id))
{
    show_debug_message(
        "ENEMY ERROR - performance initialization failed."
    );

    instance_destroy();
    exit;
}


if (!scr_enemy_order_initialize(id))
{
    show_debug_message(
        "ENEMY ORDER ERROR - initialization failed."
    );

    instance_destroy();
    exit;
}