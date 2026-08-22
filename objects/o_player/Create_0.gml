/// @description Initializes the player.

if (instance_number(object_index) > 1)
{
    instance_destroy();
    exit;
}

if (!scr_player_initialize(id))
{
    show_debug_message(
        "PLAYER ERROR - initialization failed."
    );

    instance_destroy();
    exit;
}