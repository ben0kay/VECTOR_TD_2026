/// @description Initializes one hostile projectile.

if (!scr_projectile_enemy_initialize(id))
{
    show_debug_message("ENEMY PROJECTILE ERROR - initialization failed.");
    instance_destroy();
    exit;
}