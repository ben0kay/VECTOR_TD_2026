/// @description Initializes one player projectile.

if (!scr_projectile_player_initialize(id))
{
    show_debug_message(
        "PLAYER PROJECTILE ERROR - initialization failed."
    );

    instance_destroy();
    exit;
}