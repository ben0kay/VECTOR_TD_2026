if (!instance_exists(owner))
{
    instance_destroy();
    exit;
}

damage_per_step =
    damage_per_second
    / max(1, game_get_speed(gamespeed_fps));