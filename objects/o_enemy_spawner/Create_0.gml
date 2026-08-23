/// @description Initializes level enemy pressure.

if (instance_number(object_index) > 1)
{
    instance_destroy();
    exit;
}


if (!scr_enemy_spawner_initialize(id))
{
    show_debug_message(
        "ENEMY SPAWNER ERROR - initialization failed."
    );

    instance_destroy();
    exit;
}