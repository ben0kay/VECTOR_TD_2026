/// @description Initializes one tower projectile.

if (!scr_projectile_tower_initialize(id))
{
    show_debug_message(
        "TOWER PROJECTILE ERROR - initialization failed."
    );

    instance_destroy();
    exit;
}