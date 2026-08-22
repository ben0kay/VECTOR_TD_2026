/// @description Initializes one generic enemy.

if (!scr_enemy_initialize(id))
{
    show_debug_message(
        "ENEMY ERROR - initialization failed."
    );

    instance_destroy();
    exit;
}